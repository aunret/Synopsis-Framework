//
//  MPSMobileNetFeatureExtractor.m
//  Synopsis-macOS
//
//  Created by vade on 10/27/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import <Vision/Vision.h>

// Apple Model:
//#import "MobileNet.h"

// Our Models + Classifiers
#import "CinemaNetFeatureExtractor_FP16.h"
#import "CinemaNetShotAnglesClassifier_FP16.h"
#import "CinemaNetShotFramingClassifier_FP16.h"
#import "CinemaNetShotSubjectClassifier_FP16.h"
#import "CinemaNetShotTypeClassifier_FP16.h"
#import "PlacesNetClassifier_FP16.h"

#import "GPUVisionMobileNet.h"

#import "SynopsisVideoFrameMPImage.h"
#import "SynopsisVideoFrameCVPixelBuffer.h"

#import "SynopsisSlidingWindow.h"

@interface GPUVisionMobileNet ()
{
    CGColorSpaceRef linear;
}

@property (readwrite, strong) CIContext* context;

@property (readwrite, strong) VNCoreMLModel* cinemaNetCoreVNModel;
@property (readwrite, strong) CinemaNetFeatureExtractor_FP16* cinemaNetCoreMLModel;
@property (readwrite, strong) CinemaNetShotAnglesClassifier_FP16* cinemaNetShotAnglesClassifierMLModel;
@property (readwrite, strong) CinemaNetShotFramingClassifier_FP16* cinemaNetShotFramingClassifierMLModel;
@property (readwrite, strong) CinemaNetShotSubjectClassifier_FP16* cinemaNetShotSubjectClassifierMLModel;
@property (readwrite, strong) CinemaNetShotTypeClassifier_FP16* cinemaNetShotTypeClassifierMLModel;
@property (readwrite, strong) PlacesNetClassifier_FP16* placesNetClassifierMLModel;

@property (readwrite, strong) NSMutableArray<NSNumber*>* averageFeatureVec;
@property (readwrite, strong) NSMutableArray<SynopsisDenseFeature*>* windowAverages;
@property (readwrite, strong) NSMutableArray<NSValue*>* windowAverageTimes;
@property (readwrite, strong) NSArray* labels;

//_Nullable@property (readwrite, strong) NSMutableArray<SynopsisDenseFeature*> slidingWindowAverage;

//@property (readwrite, strong) SynopsisSlidingWindow* windowA;
//@property (readwrite, strong) SynopsisSlidingWindow* windowB;

@property (readwrite, strong) NSMutableArray<SynopsisSlidingWindow*>* windows;


@end

const NSUInteger stride = 5;
const NSUInteger numWindows = 2;

@implementation GPUVisionMobileNet

// GPU backed modules init with an options dict for Metal Device bullshit
- (instancetype) initWithQualityHint:(SynopsisAnalysisQualityHint)qualityHint device:(id<MTLDevice>)device
{
    self = [super initWithQualityHint:qualityHint device:device];
    if(self)
    {
        
        linear = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear);

        NSDictionary* opt = @{ kCIContextWorkingColorSpace : (__bridge id)linear,
                               kCIContextOutputColorSpace : (__bridge id)linear,
                                };
        self.context = [CIContext contextWithMTLDevice:device options:opt];

        NSError* error = nil;
        self.cinemaNetCoreMLModel = [[CinemaNetFeatureExtractor_FP16 alloc] init];
        self.cinemaNetShotAnglesClassifierMLModel = [[CinemaNetShotAnglesClassifier_FP16 alloc] init];
        self.cinemaNetShotFramingClassifierMLModel = [[CinemaNetShotFramingClassifier_FP16 alloc] init];
        self.cinemaNetShotSubjectClassifierMLModel = [[CinemaNetShotSubjectClassifier_FP16 alloc] init];
        self.cinemaNetShotTypeClassifierMLModel = [[CinemaNetShotTypeClassifier_FP16 alloc] init];
        self.placesNetClassifierMLModel = [[PlacesNetClassifier_FP16 alloc] init];
        
        self.cinemaNetCoreVNModel = [VNCoreMLModel modelForMLModel:self.cinemaNetCoreMLModel.model error:&error];
        
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
    
    VNCoreMLRequest* mobileRequest = [[VNCoreMLRequest alloc] initWithModel:self.cinemaNetCoreVNModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
                
        NSMutableDictionary* metadata = nil;
        if([request results].count)
        {
            VNCoreMLFeatureValueObservation* featureOutput = [[request results] firstObject];
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
            
            __block CinemaNetShotAnglesClassifier_FP16Output* anglesOutput = nil;
            __block CinemaNetShotFramingClassifier_FP16Output* framingOutput = nil;
            __block CinemaNetShotSubjectClassifier_FP16Output* subjectOutput = nil;
            __block CinemaNetShotTypeClassifier_FP16Output* typeOutput = nil;
            __block PlacesNetClassifier_FP16Output* placesOutput = nil;
            
            dispatch_group_t classifierGroup = dispatch_group_create();
            
            dispatch_group_enter(classifierGroup);
            
            dispatch_group_notify(classifierGroup, self.completionQueue, ^{
                
                NSString* topAngleLabel = anglesOutput.classLabel;
                NSString* topFrameLabel = framingOutput.classLabel;
                NSString* topSubjectLabel = subjectOutput.classLabel;
                NSString* topTypeLabel = typeOutput.classLabel;
                NSString* placesNetLabel = placesOutput.classLabel;
                
                topAngleLabel = [topAngleLabel capitalizedString];
                topFrameLabel = [topFrameLabel capitalizedString];
                topSubjectLabel = [topSubjectLabel capitalizedString];
                topTypeLabel = [topTypeLabel capitalizedString];
                placesNetLabel = [placesNetLabel capitalizedString];

                NSMutableArray<NSString*>* labels = [NSMutableArray new];
                
                if(topAngleLabel)
                {
                    [labels addObject:@"Shot Angle:"];
                    [labels addObject:topAngleLabel];
                }
                if(topFrameLabel)
                {
                    [labels addObject:@"Shot Framing:"];
                    [labels addObject:topFrameLabel];
                }
                if(topSubjectLabel)
                {
                    [labels addObject:@"Shot Subject:"];
                    [labels addObject:topSubjectLabel];
                }
                if(topTypeLabel)
                {
                    [labels addObject:@"Shot Type:"];
                    [labels addObject:topTypeLabel];
                }
//                if(imageNetLabel)
//                {
//                    [labels addObject:@"Objects:"];
//                    [labels addObjectsFromArray:imageNetLabel];
//                }
                if(placesNetLabel)
                {
                    [labels addObject:@"Location:"];
                    [labels addObject:placesNetLabel];
                }

                metadata[kSynopsisStandardMetadataFeatureVectorDictKey] = vec;
                metadata[kSynopsisStandardMetadataDescriptionDictKey] = labels;

                self.labels = labels;

                if(completionBlock)
                {
                    completionBlock(metadata, nil);
                }
            });
            
            // If we have a valid feature vector result, parallel classify.
            
            dispatch_group_enter(classifierGroup);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                anglesOutput = [self.cinemaNetShotAnglesClassifierMLModel predictionFromInput_1__BottleneckInputPlaceholder__0:featureVector  error:nil];
                dispatch_group_leave(classifierGroup);
            });
            
            dispatch_group_enter(classifierGroup);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                framingOutput = [self.cinemaNetShotFramingClassifierMLModel predictionFromInput_1__BottleneckInputPlaceholder__0:featureVector  error:nil];
                dispatch_group_leave(classifierGroup);
            });
            
            dispatch_group_enter(classifierGroup);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                subjectOutput = [self.cinemaNetShotSubjectClassifierMLModel predictionFromInput_1__BottleneckInputPlaceholder__0:featureVector  error:nil];
                dispatch_group_leave(classifierGroup);
            });
            
            dispatch_group_enter(classifierGroup);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                typeOutput = [self.cinemaNetShotTypeClassifierMLModel predictionFromInput_1__BottleneckInputPlaceholder__0:featureVector  error:nil];
                dispatch_group_leave(classifierGroup);
            });
            
            dispatch_group_enter(classifierGroup);
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                placesOutput = [self.placesNetClassifierMLModel predictionFromInput_1__BottleneckInputPlaceholder__0:featureVector  error:nil];
                dispatch_group_leave(classifierGroup);
            });
            
            dispatch_group_leave(classifierGroup);
        }
    }];
    
    mobileRequest.imageCropAndScaleOption = VNImageCropAndScaleOptionScaleFill;
    mobileRequest.preferBackgroundProcessing = NO;

    // Works fine:
    CGImagePropertyOrientation orientation = kCGImagePropertyOrientationDownMirrored;
    VNImageRequestHandler* imageRequestHandler = [[VNImageRequestHandler alloc] initWithCIImage:imageForRequest orientation:orientation options:@{}];

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
