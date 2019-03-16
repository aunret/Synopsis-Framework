//
//  GPUVisionMobileNetV2.m
//  Synopsis-Framework
//
//  Created by vade on 12/13/18.
//  Copyright © 2018 v002. All rights reserved.
//

#import <Vision/Vision.h>

#import "TrashNetModuleV1_2.h"

#import "TrashNetV1_2.h"

#import "SynopsisVideoFrameMPImage.h"
#import "SynopsisVideoFrameCVPixelBuffer.h"

#import "SynopsisSlidingWindow.h"

@interface TrashNetModuleV1_2 ()
{
    CGColorSpaceRef linear;
    NSUInteger stride;
    NSUInteger numWindows;
}

@property (readwrite, strong) CIContext* context;

@property (readwrite, strong) VNCoreMLModel* trashNetCoreVNModel;

@property (readwrite, strong) TrashNetV1_2* trashNetCoreMLModel;

@property (readwrite, strong) SynopsisDenseFeature* averageFeatureVec;
@property (readwrite, strong) NSMutableArray<SynopsisDenseFeature*>* featureVectorWindowAverages;
@property (readwrite, strong) NSMutableArray<NSValue*>* featureVectorWindowAveragesTimes;
@property (readwrite, strong) NSMutableArray<SynopsisSlidingWindow*>* featureVectorWindows;

@property (readwrite, strong) SynopsisDenseFeature* averageProbabilities;
@property (readwrite, strong) NSMutableArray<SynopsisDenseFeature*>* probabilityWindowAverages;
@property (readwrite, strong) NSMutableArray<NSValue*>* probabilityWindowAveragesTimes;
@property (readwrite, strong) NSMutableArray<SynopsisSlidingWindow*>* probabilityWindows;

@end

@implementation TrashNetModuleV1_2

static NSUInteger probabilityCount = 93;
static NSUInteger featureVectorCount = 1280;

// GPU backed modules init with an options dict for Metal Device bullshit
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
        
        self.trashNetCoreMLModel = [[TrashNetV1_2 alloc] init];
        self.trashNetCoreVNModel = [VNCoreMLModel modelForMLModel:self.trashNetCoreMLModel.model error:&error];
        
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
    return kSynopsisStandardMetadataFeatureVectorDictKey;
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
    
    VNCoreMLRequest* mobileRequest = [[VNCoreMLRequest alloc] initWithModel:self.trashNetCoreVNModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        
        NSMutableDictionary* metadata = nil;
        if([request results].count)
        {
            // LETS ENSURE the order here is consisten - because its unclear to me how
            // THE FUCK Im supposed to know the order of these request results
            // IF THEY ARENT THE ORDER SPECIFIED IN THE MODEL OUTPUTS
            
            VNCoreMLFeatureValueObservation* featureOutput = [request results][0];
            VNCoreMLFeatureValueObservation* probabilityOutput = [request results][1];

            MLMultiArray* featureVector = featureOutput.featureValue.multiArrayValue;
            MLMultiArray* probabilityVector = probabilityOutput.featureValue.multiArrayValue;

            NSMutableArray<NSNumber*>*featureVec_NSNumber = [NSMutableArray new];
            NSMutableArray<NSNumber*>*probabilities_NSNumber = [NSMutableArray new];

#pragma mark - This is beyond wasteful and shitty
           
            for(NSUInteger i = 0; i < featureVectorCount; i++)
            {
                featureVec_NSNumber[i] = [featureVector objectForKeyedSubscript:@[@(0), @(0), @(i), @(0), @(0)] ];
            }

            SynopsisDenseFeature* denseFeatureVector = [[SynopsisDenseFeature alloc] initWithFeatureArray:featureVec_NSNumber];

            for(NSUInteger i = 0; i < probabilityCount; i++)
            {
                probabilities_NSNumber[i] = [probabilityVector objectForKeyedSubscript:@[@(0), @(0), @(i), @(0), @(0)] ];
            }
            
            SynopsisDenseFeature* denseProbabilities = [[SynopsisDenseFeature alloc] initWithFeatureArray:probabilities_NSNumber];

            if(self.averageFeatureVec == nil)
            {
                self.averageFeatureVec = [[SynopsisDenseFeature alloc] initWithFeatureArray:featureVec_NSNumber];
            }
            else
            {
                self.averageFeatureVec = [SynopsisDenseFeature denseFeatureByAveragingFeature:self.averageFeatureVec withFeature:denseFeatureVector];
            }
            
            if(self.averageProbabilities == nil)
            {
                self.averageProbabilities = [[SynopsisDenseFeature alloc] initWithFeatureArray:probabilities_NSNumber];
            }
            else
            {
                // We max on probabilites because math
                self.averageProbabilities = [SynopsisDenseFeature denseFeatureByMaximizingFeature:self.averageProbabilities withFeature:denseProbabilities];
            }
                        
            
            [self.featureVectorWindows enumerateObjectsUsingBlock:^(SynopsisSlidingWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
                SynopsisDenseFeature* possible = [window appendFeature:denseFeatureVector];
                if(possible != nil)
                {
                    [self.featureVectorWindowAverages addObject:possible];
                    [self.featureVectorWindowAveragesTimes addObject:[NSValue valueWithCMTime:frame.presentationTimeStamp]];
                }
            }];
          
            [self.probabilityWindows enumerateObjectsUsingBlock:^(SynopsisSlidingWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
                SynopsisDenseFeature* possible = [window appendFeature:denseProbabilities];
                if(possible != nil)
                {
                    [self.probabilityWindowAverages addObject:possible];
                    [self.probabilityWindowAveragesTimes addObject:[NSValue valueWithCMTime:frame.presentationTimeStamp]];
                }
            }];
            
           
            
            metadata = [NSMutableDictionary dictionary];
            metadata[kSynopsisStandardMetadataFeatureVectorDictKey] = featureVec_NSNumber;
            metadata[kSynopsisStandardMetadataProbabilitiesDictKey] = probabilities_NSNumber;

            if(completionBlock)
            {
                completionBlock(metadata, nil);
            }
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
             kSynopsisStandardMetadataFeatureVectorDictKey : (self.averageFeatureVec) ? self.averageFeatureVec.arrayValue : @[ ],
             kSynopsisStandardMetadataProbabilitiesDictKey : (averageProbabilities) ? averageProbabilities : @[ ],
//             kSynopsisStandardMetadataInterestingFeaturesAndTimesDictKey  : (windowAverages) ? windowAverages : @[ ],
//             kSynopsisStandardMetadataDescriptionDictKey: (labels) ? labels : @[ ],
             };
}

- (NSArray<NSString*>*) topLabelForScores:(NSDictionary*)scoresDict withThreshhold:(float)thresh maxLabelCount:(NSUInteger)maxLabels
{
    NSMutableDictionary* scores = [scoresDict mutableCopy];
    
    NSArray* sortedScores = [[scores allValues] sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        if([obj1 floatValue] > [obj2 floatValue])
            return NSOrderedAscending;
        else if([obj1 floatValue] < [obj2 floatValue])
            return NSOrderedDescending;
        
        return NSOrderedSame;
    }] ;
    
        //    NSString* topFrameLabel = nil;
    NSMutableArray* top = [NSMutableArray array];
        // Modulate percentage based off of number of possible categories?
    [sortedScores enumerateObjectsUsingBlock:^(NSNumber*  _Nonnull score, NSUInteger idx, BOOL * _Nonnull stop) {
        if(idx >= (maxLabels - 1) )
            *stop = YES;
        
        if(score.floatValue >= (thresh / scores.allKeys.count))
        {
            NSString* scoreLabel = [[scores allKeysForObject:score] firstObject];
            [top addObject:scoreLabel];
        }
    }];
    
    return  [top sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];;
}

@end
