//
//  GPUVisionMobileNetV2.m
//  Synopsis-Framework
//
//  Created by vade on 12/13/18.
//  Copyright © 2018 v002. All rights reserved.
//

#import <Vision/Vision.h>

#import "GPUVisionMobileNetV2.h"

#import "smoosh_5tasks_softmax_no_labels_subtasks.h"

#import "SynopsisVideoFrameMPImage.h"
#import "SynopsisVideoFrameCVPixelBuffer.h"

#import "SynopsisSlidingWindow.h"

@interface GPUVisionMobileNetV2 ()
{
    CGColorSpaceRef linear;
    NSUInteger stride;
    NSUInteger numWindows;
}

@property (readwrite, strong) CIContext* context;

@property (readwrite, strong) VNCoreMLModel* smooshNetCoreVNModel;

@property (readwrite, strong) smoosh_5tasks_softmax_no_labels_subtasks* smooshNetCoreMLModel;

@property (readwrite, strong) NSMutableArray<NSNumber*>* averageFeatureVec;
@property (readwrite, strong) NSMutableArray<SynopsisDenseFeature*>* windowAverages;
@property (readwrite, strong) NSMutableArray<NSValue*>* windowAverageTimes;
@property (readwrite, strong) NSArray* labels;

@property (readwrite, strong) NSMutableArray<SynopsisSlidingWindow*>* windows;

@end

@implementation GPUVisionMobileNetV2

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
        
        self.smooshNetCoreMLModel = [[smoosh_5tasks_softmax_no_labels_subtasks alloc] init];
        self.smooshNetCoreVNModel = [VNCoreMLModel modelForMLModel:self.smooshNetCoreMLModel.model error:&error];
        
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
    
    self.windowAverages = [NSMutableArray new];
    self.windowAverageTimes = [NSMutableArray new];
    self.windows = [NSMutableArray new];
    
    for(NSUInteger i = 0; i < numWindows; i++)
    {
        SynopsisSlidingWindow* aWindow = [[SynopsisSlidingWindow alloc] initWithLength:10 offset:stride * i];
        [self.windows addObject:aWindow];
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
    
    VNCoreMLRequest* mobileRequest = [[VNCoreMLRequest alloc] initWithModel:self.smooshNetCoreVNModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        
        NSMutableDictionary* metadata = nil;
        if([request results].count)
        {
            // LETS ENSURE the order here is consisten - because its unclear to me how
            // THE FUCK Im supposed to know the order of these request results
            // IF THEY ARENT THE ORDER SPECIFIED IN THE MODEL OUTPUTS
            
            VNCoreMLFeatureValueObservation* scene_attrs = [request results][0];
            VNCoreMLFeatureValueObservation* style_atrs = [request results][1];
            VNCoreMLFeatureValueObservation* places = [request results][4];
            VNCoreMLFeatureValueObservation* objects = [request results][5];
            VNCoreMLFeatureValueObservation* objects_attrs = [request results][2];
            VNCoreMLFeatureValueObservation* featureOutput = [request results][3];

            MLMultiArray* featureVector = featureOutput.featureValue.multiArrayValue;
            
            NSMutableArray<NSNumber*>*vec = [NSMutableArray new];
            
            if(self.averageFeatureVec == nil)
            {
                for(NSUInteger i = 0; i < featureVector.count; i++)
                {
                    vec[i] = featureVector[i];
                }
                
                self.averageFeatureVec = vec;
            }
            
            else
            {
                for(NSUInteger i = 0; i < featureVector.count; i++)
                {
                    NSNumber* avgFeatureValue = self.averageFeatureVec[i];
                    NSNumber* featureValue = featureVector[i];
                    
                    self.averageFeatureVec[i] = @( (avgFeatureValue.floatValue + featureValue.floatValue) * 0.5 );
                    vec[i] = featureValue;
                }
            }
            
            SynopsisDenseFeature* denseFeatureVector = [[SynopsisDenseFeature alloc] initWithFeatureArray:vec];
            
            metadata = [NSMutableDictionary dictionary];
            
            [self.windows enumerateObjectsUsingBlock:^(SynopsisSlidingWindow * _Nonnull window, NSUInteger idx, BOOL * _Nonnull stop) {
                SynopsisDenseFeature* possible = [window appendFeature:denseFeatureVector];
                if(possible != nil)
                {
                    [self.windowAverages addObject:possible];
                    [self.windowAverageTimes addObject:[NSValue valueWithCMTime:frame.presentationTimeStamp]];
                }
            }];
            
            metadata[kSynopsisStandardMetadataFeatureVectorDictKey] = vec;
//            metadata[kSynopsisStandardMetadataDescriptionDictKey] = labels;
            
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
    NSMutableArray* windowAverages = [NSMutableArray arrayWithCapacity:self.windowAverages.count];
    
    [self.windowAverages enumerateObjectsUsingBlock:^(SynopsisDenseFeature * _Nonnull feature, NSUInteger idx, BOOL * _Nonnull stop) {
        NSValue* windowTime = [self.windowAverageTimes objectAtIndex:idx];
        
        [windowAverages addObject: @{ @"Feature" : [feature arrayValue],
                                      @"Time" : (NSDictionary*) CFBridgingRelease(CMTimeCopyAsDictionary([windowTime CMTimeValue], kCFAllocatorDefault)),
                                      }];
    }];
    
    return @{
             kSynopsisStandardMetadataFeatureVectorDictKey : (self.averageFeatureVec) ? self.averageFeatureVec : @[ ],
             kSynopsisStandardMetadataInterestingFeaturesAndTimesDictKey  : (windowAverages) ? windowAverages : @[ ],
             kSynopsisStandardMetadataDescriptionDictKey: (self.labels) ? self.labels : @[ ],
             };
}

@end
