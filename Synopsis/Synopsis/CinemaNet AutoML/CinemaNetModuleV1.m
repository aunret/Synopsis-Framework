//
//  CinemaNetModuleV1.m
//  Synopsis-Framework
//
//  Created by vade on 6/12/19.
//  Copyright © 2019 v002. All rights reserved.
//

#import <Vision/Vision.h>
#import "CinemaNetModuleV1.h"
#import "CinemaNet.h"
#import "SynopsisVideoFrameMPImage.h"
#import "SynopsisVideoFrameCVPixelBuffer.h"

#import "SynopsisSlidingWindow.h"

@interface CinemaNetModuleV1 ()
{
    CGColorSpaceRef linear;
    NSUInteger stride;
    NSUInteger numWindows;
}

@property (readwrite, strong) CIContext* context;

@property (readwrite, strong) VNCoreMLModel* vnModel;

@property (readwrite, strong) CinemaNet* mlModel;

@property (readwrite, strong) SynopsisDenseFeature* averageFeatureVec;
@property (readwrite, strong) NSMutableArray<SynopsisDenseFeature*>* featureVectorWindowAverages;
@property (readwrite, strong) NSMutableArray<NSValue*>* featureVectorWindowAveragesTimes;
@property (readwrite, strong) NSMutableArray<SynopsisSlidingWindow*>* featureVectorWindows;

@property (readwrite, strong) SynopsisDenseFeature* averageProbabilities;
@property (readwrite, strong) NSMutableArray<SynopsisDenseFeature*>* probabilityWindowAverages;
@property (readwrite, strong) NSMutableArray<NSValue*>* probabilityWindowAveragesTimes;
@property (readwrite, strong) NSMutableArray<SynopsisSlidingWindow*>* probabilityWindows;

@end


@implementation CinemaNetModuleV1

- (instancetype) initWithQualityHint:(SynopsisAnalysisQualityHint)qualityHint device:(id<MTLDevice>)device
{
    self = [super initWithQualityHint:qualityHint device:device];
    if(self)
    {
        stride = 5;
        numWindows = 2;
        
        linear = CGColorSpaceCreateWithName(kCGColorSpaceExtendedLinearSRGB);
        
        NSDictionary* opt = @{ kCIContextWorkingColorSpace : (__bridge id)linear,
                               kCIContextOutputColorSpace : (__bridge id)linear,
                               };
        
        self.context = [CIContext contextWithMTLDevice:device options:opt];
        
        NSError* error = nil;

        if (@available(macOS 10.14, *)) {
            
            MLModelConfiguration* modelConfig = [[MLModelConfiguration alloc] init];
            modelConfig.computeUnits = MLComputeUnitsCPUAndGPU;
            
            @try {
                self.mlModel = [[CinemaNet alloc] initWithConfiguration:modelConfig error:&error];
            } @catch (NSException *exception) {
                NSLog(@"Exception: %@", exception);
            } @finally {
                
            }
          
            if(error)
            {
                NSLog(@"Error: %@", error);
            }
        }
        else
        {
            self.mlModel = [[CinemaNet alloc] init];
        }

        self.vnModel = [VNCoreMLModel modelForMLModel:self.mlModel.model error:&error];
        
        if(error)
        {
            NSLog(@"Error: %@", error);
        }
        
    }
    return self;
}

- (void)dealloc
{
    CGColorSpaceRelease(linear);
}

- (NSString*) moduleName
{
    return @"CinemaNet";
}

+ (SynopsisVideoBacking) requiredVideoBacking
{
    return SynopsisVideoBackingMPSImage;
    //    return SynopsisVideoBackingCVPixelbuffer;
}

+ (SynopsisVideoFormat) requiredVideoFormat
{
    return SynopsisVideoFormatBGR8;
}

- (void) beginAndClearCachedResults
{
    self.averageFeatureVec = nil;
    self.featureVectorWindowAverages = [NSMutableArray new];
    self.featureVectorWindowAveragesTimes = [NSMutableArray new];
    self.featureVectorWindows = [NSMutableArray new];
    
    self.averageProbabilities = nil;
    self.probabilityWindowAverages = [NSMutableArray new];
    self.probabilityWindowAveragesTimes = [NSMutableArray new];
    self.probabilityWindows = [NSMutableArray new];
    
    for(NSUInteger i = 0; i < numWindows; i++)
    {
        SynopsisSlidingWindow* aWindow = [[SynopsisSlidingWindow alloc] initWithLength:10 offset:stride * i];
        SynopsisSlidingWindow* bWindow = [[SynopsisSlidingWindow alloc] initWithLength:10 offset:stride * i];
        [self.featureVectorWindows addObject:aWindow];
        [self.probabilityWindows addObject:bWindow];
    }
}

- (void) analyzedMetadataForCurrentFrame:(id<SynopsisVideoFrame>)frame previousFrame:(id<SynopsisVideoFrame>)lastFrame commandBuffer:(id<MTLCommandBuffer>)buffer completionBlock:(GPUModuleCompletionBlock)completionBlock
{
    CIImage* imageForRequest = nil;
    if([frame isKindOfClass:[SynopsisVideoFrameMPImage class]])
    {
        SynopsisVideoFrameMPImage* frameMPImage = (SynopsisVideoFrameMPImage*)frame;
        MPSImage* frameMPSImage = frameMPImage.mpsImage;
        imageForRequest = [CIImage imageWithMTLTexture:frameMPSImage.texture options:nil];
    }
    
    else if ([frame isKindOfClass:[SynopsisVideoFrameCVPixelBuffer class]])
    {
        SynopsisVideoFrameCVPixelBuffer* frameCVPixelBuffer = (SynopsisVideoFrameCVPixelBuffer*)frame;
        
        imageForRequest = [CIImage imageWithCVImageBuffer:[frameCVPixelBuffer pixelBuffer]];
    }
    
    VNCoreMLRequest* mobileRequest = [[VNCoreMLRequest alloc] initWithModel:self.vnModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        
        NSMutableDictionary* metadata = [NSMutableDictionary dictionary];
;
        NSArray* results = [[request results] copy];
        if([request results].count)
        {
            // Sort our labels alphabetically, since results returns in order of confidence
            // This means for future iterations our probabilities arrays will be potentially 'out of order'
            // or different between versions of the classifier.
            // Ahh!
            
            results = [results sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                VNClassificationObservation* one = (VNClassificationObservation *)obj1;
                VNClassificationObservation* two = (VNClassificationObservation *)obj2;
                return [one.identifier compare:two.identifier options:NSNumericSearch];

            }];

            NSMutableArray* labels = [NSMutableArray arrayWithCapacity:[request results].count];
            NSMutableArray* probabilities = [NSMutableArray arrayWithCapacity:[request results].count];

            for(VNClassificationObservation* result in results)
            {
                [labels addObject:result.identifier];
                [probabilities addObject: @(result.confidence)];
            }
            
            SynopsisDenseFeature* denseProbabilities = [[SynopsisDenseFeature alloc] initWithFeatureArray:probabilities];

            if(self.averageProbabilities == nil)
            {
                self.averageProbabilities = denseProbabilities;
            }
            else
            {
                // We max on probabilites because math
//                self.averageProbabilities = [SynopsisDenseFeature denseFeatureByMaximizingFeature:self.averageProbabilities withFeature:denseProbabilities];
                self.averageProbabilities = [SynopsisDenseFeature denseFeatureByAveragingFeature:self.averageProbabilities withFeature:denseProbabilities];

            }
            
            // we want to order these arrays so they always are in alpabetical order
            
            
//            VNCoreMLFeatureValueObservation* probabilityOutput = [request results][0];

//            metadata[kSynopsisStandardMetadataFeatureVectorDictKey] = featureVec_NSNumber;
            metadata[kSynopsisStandardMetadataProbabilitiesDictKey] = probabilities;

        }
        
        
        if(completionBlock)
        {
            completionBlock(metadata, nil);
        }
        
      
    }];
    
    mobileRequest.imageCropAndScaleOption = VNImageCropAndScaleOptionScaleFill;
    mobileRequest.preferBackgroundProcessing = NO;
    
    // Works fine:
    CGImagePropertyOrientation orientation = kCGImagePropertyOrientationUp;
    VNImageRequestHandler* imageRequestHandler = [[VNImageRequestHandler alloc] initWithCIImage:imageForRequest orientation:orientation options:@{
                                                                                                                                                  VNImageOptionCIContext : self.context
                                                                                                                                                  }];
    
    NSError* submitError = nil;
    if(![imageRequestHandler performRequests:@[mobileRequest] error:&submitError] )
        //    if(![self.sequenceRequestHandler performRequests:@[mobileNetRequest] onCIImage:imageForRequest error:&submitError])
    {
        NSLog(@"Error submitting request: %@", submitError);
    }
}

- (NSDictionary*) finalizedAnalysisMetadata;
{
    //    NSMutableArray* windowAverages = [NSMutableArray arrayWithCapacity:self.featureVectorWindowAverages.count];
    //
    //    [self.featureVectorWindowAverages enumerateObjectsUsingBlock:^(SynopsisDenseFeature * _Nonnull feature, NSUInteger idx, BOOL * _Nonnull stop) {
    //        NSValue* windowTime = [self.featureVectorWindowAveragesTimes objectAtIndex:idx];
    //
    //        [windowAverages addObject: @{ @"Feature" : [feature arrayValue],
    //                                      @"Time" : (NSDictionary*) CFBridgingRelease(CMTimeCopyAsDictionary([windowTime CMTimeValue], kCFAllocatorDefault)),
    //                                      }];
    //    }];
    
    NSArray<NSNumber*>* averageProbabilities = self.averageProbabilities.arrayValue;
    
    
    return @{
             kSynopsisStandardMetadataProbabilitiesDictKey : (averageProbabilities) ? averageProbabilities : @[ ],
             //             kSynopsisStandardMetadataInterestingFeaturesAndTimesDictKey  : (windowAverages) ? windowAverages : @[ ],
             //             kSynopsisStandardMetadataDescriptionDictKey: (labels) ? labels : @[ ],
             };
}

@end
