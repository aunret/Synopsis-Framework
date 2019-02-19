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
//#import "smoosh_5tasks_w_labels_softmax_v2.h"

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

@property (readwrite, strong) SynopsisDenseFeature* averageFeatureVec;
@property (readwrite, strong) NSMutableArray<SynopsisDenseFeature*>* featureVectorWindowAverages;
@property (readwrite, strong) NSMutableArray<NSValue*>* featureVectorWindowAveragesTimes;
@property (readwrite, strong) NSMutableArray<SynopsisSlidingWindow*>* featureVectorWindows;

@property (readwrite, strong) SynopsisDenseFeature* averageProbabilities;
@property (readwrite, strong) NSMutableArray<SynopsisDenseFeature*>* probabilityWindowAverages;
@property (readwrite, strong) NSMutableArray<NSValue*>* probabilityWindowAveragesTimes;
@property (readwrite, strong) NSMutableArray<SynopsisSlidingWindow*>* probabilityWindows;

@property (readwrite, strong) NSArray* labels;
@property (readwrite, strong) NSArray* sceneAttributeLabels;
@property (readwrite, strong) NSArray* styleAttributeLabels;
@property (readwrite, strong) NSArray* placesLabels;
@property (readwrite, strong) NSArray* objectsLabels;
@property (readwrite, strong) NSArray* objectAttributeLabels;

@end

@implementation GPUVisionMobileNetV2

static NSUInteger sceneCount = 102;
static NSUInteger styleCount = 20;
static NSUInteger placesCount = 365;
static NSUInteger objectCount = 80;
static NSUInteger objectAttributeCount = 204;
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
        
        self.smooshNetCoreMLModel = [[smoosh_5tasks_softmax_no_labels_subtasks alloc] init];
        self.smooshNetCoreVNModel = [VNCoreMLModel modelForMLModel:self.smooshNetCoreMLModel.model error:&error];
        
        NSURL* labelsURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"smooshed_labels_5tasks" withExtension:@"txt"];
        
        NSString* allLabelsFlat = [NSString stringWithContentsOfURL:labelsURL encoding:NSUTF8StringEncoding error:&error];
        
        self.labels = [allLabelsFlat componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        self.sceneAttributeLabels = [self.labels subarrayWithRange:NSMakeRange(0, sceneCount)];
        self.styleAttributeLabels = [self.labels subarrayWithRange:NSMakeRange(sceneCount, styleCount)];
        self.placesLabels = [self.labels subarrayWithRange:NSMakeRange(sceneCount + styleCount, placesCount)];
        self.objectsLabels = [self.labels subarrayWithRange:NSMakeRange(sceneCount + styleCount + placesCount, objectCount)];
        self.objectAttributeLabels = [self.labels subarrayWithRange:NSMakeRange(sceneCount + styleCount + placesCount + objectCount, objectAttributeCount)];
//
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
            MLMultiArray* scene_attrs_prob = scene_attrs.featureValue.multiArrayValue;
            MLMultiArray* style_attrs_prob = style_atrs.featureValue.multiArrayValue;
            MLMultiArray* places_prob = places.featureValue.multiArrayValue;
            MLMultiArray* objects_prob = objects.featureValue.multiArrayValue;
            MLMultiArray* objects_attrs_prob = objects_attrs.featureValue.multiArrayValue;
            
            NSMutableArray<NSNumber*>*featureVec_NSNumber = [NSMutableArray new];
            NSMutableArray<NSNumber*>*scene_attrs_prob_NSNumber = [NSMutableArray new];
            NSMutableArray<NSNumber*>*style_atrs_prob_NSNumber = [NSMutableArray new];
            NSMutableArray<NSNumber*>*places_prob_NSNumber = [NSMutableArray new];
            NSMutableArray<NSNumber*>*objects_prob_NSNumber = [NSMutableArray new];
            NSMutableArray<NSNumber*>*objects_attrs_prob_NSNumber = [NSMutableArray new];

#pragma mark - This is beyond wasteful and shitty
           
            for(NSUInteger i = 0; i < featureVectorCount; i++)
            {
                featureVec_NSNumber[i] = [featureVector objectForKeyedSubscript:@[@(0), @(0), @(i), @(0), @(0)] ];
            }
            
            SynopsisDenseFeature* denseFeatureVector = [[SynopsisDenseFeature alloc] initWithFeatureArray:featureVec_NSNumber];
            
            for(NSUInteger i = 0; i < sceneCount; i++)
            {
                scene_attrs_prob_NSNumber[i] = [scene_attrs_prob objectForKeyedSubscript:@[@(0), @(0), @(i), @(0), @(0)] ];
            }
           
            for(NSUInteger i = 0; i < styleCount; i++)
            {
                style_atrs_prob_NSNumber[i] = [style_attrs_prob objectForKeyedSubscript:@[@(0), @(0), @(i), @(0), @(0)] ];
            }
           
            for(NSUInteger i = 0; i < placesCount; i++)
            {
                places_prob_NSNumber[i] = [places_prob objectForKeyedSubscript:@[@(0), @(0), @(i), @(0), @(0)] ];
            }
           
            for(NSUInteger i = 0; i < objectCount; i++)
            {
                objects_prob_NSNumber[i] = [objects_prob objectForKeyedSubscript:@[@(0), @(0), @(i), @(0), @(0)] ];
            }

            for(NSUInteger i = 0; i < objectAttributeCount; i++)
            {
                objects_attrs_prob_NSNumber[i] = [objects_attrs_prob objectForKeyedSubscript:@[@(0), @(0), @(i), @(0), @(0)] ];
            }

            NSArray* allProbabilities_NSNumber = [[[[scene_attrs_prob_NSNumber arrayByAddingObjectsFromArray:style_atrs_prob_NSNumber]
                                           arrayByAddingObjectsFromArray:places_prob_NSNumber]
                                          arrayByAddingObjectsFromArray:objects_prob_NSNumber]
                                         arrayByAddingObjectsFromArray:objects_attrs_prob_NSNumber];
            
            SynopsisDenseFeature* denseAllProbabilities = [[SynopsisDenseFeature alloc] initWithFeatureArray:allProbabilities_NSNumber];

            
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
                self.averageProbabilities = [[SynopsisDenseFeature alloc] initWithFeatureArray:allProbabilities_NSNumber];
            }
            else
            {
                // We max on probabilites because math
                self.averageProbabilities = [SynopsisDenseFeature denseFeatureByMaximizingFeature:self.averageProbabilities withFeature:denseAllProbabilities];
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
                SynopsisDenseFeature* possible = [window appendFeature:denseFeatureVector];
                if(possible != nil)
                {
                    [self.probabilityWindowAverages addObject:possible];
                    [self.probabilityWindowAveragesTimes addObject:[NSValue valueWithCMTime:frame.presentationTimeStamp]];
                }
            }];
            
            NSArray* sceneLabels = [self topLabelForScores:[NSDictionary dictionaryWithObjects:scene_attrs_prob_NSNumber forKeys:self.sceneAttributeLabels]
                                            withThreshhold:0.0
                                             maxLabelCount:5];
            
            NSArray* styleLabels = [self topLabelForScores:[NSDictionary dictionaryWithObjects:style_atrs_prob_NSNumber forKeys:self.styleAttributeLabels]
                                            withThreshhold:0.0
                                             maxLabelCount:5];

            NSArray* placesLabels = [self topLabelForScores:[NSDictionary dictionaryWithObjects:places_prob_NSNumber forKeys:self.placesLabels]
                                            withThreshhold:0.0
                                             maxLabelCount:5];

            NSArray* objLabels = [self topLabelForScores:[NSDictionary dictionaryWithObjects:objects_prob_NSNumber forKeys:self.objectsLabels]
                                             withThreshhold:0.0
                                              maxLabelCount:5];
            
            NSArray* objAttrLabels = [self topLabelForScores:[NSDictionary dictionaryWithObjects:objects_attrs_prob_NSNumber forKeys:self.objectAttributeLabels]
                                          withThreshhold:0.0
                                           maxLabelCount:5];

            NSMutableArray* labels = [NSMutableArray arrayWithObject:@"Scene:"];
            [labels addObjectsFromArray:sceneLabels];
            [labels addObject:@"Style:"];
            [labels addObjectsFromArray:styleLabels];
            [labels addObject:@"Places:"];
            [labels addObjectsFromArray:placesLabels];
            [labels addObject:@"Objects:"];
            [labels addObjectsFromArray:objLabels];
            [labels addObject:@"Attributes:"];
            [labels addObjectsFromArray:objAttrLabels];
            
            metadata = [NSMutableDictionary dictionary];
            metadata[kSynopsisStandardMetadataFeatureVectorDictKey] = featureVec_NSNumber;
            metadata[kSynopsisStandardMetadataProbabilitiesDictKey] = allProbabilities_NSNumber;
            metadata[kSynopsisStandardMetadataDescriptionDictKey] = labels;

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
    
    NSArray* prob_sceneAttributeLabels = [averageProbabilities subarrayWithRange:NSMakeRange(0, sceneCount)];
    NSArray* prob_styleAttributeLabels = [averageProbabilities subarrayWithRange:NSMakeRange(sceneCount, styleCount)];
    NSArray* prob_placesLabels = [averageProbabilities subarrayWithRange:NSMakeRange(sceneCount + styleCount, placesCount)];
    NSArray* prob_objectsLabels = [averageProbabilities subarrayWithRange:NSMakeRange(sceneCount + styleCount + placesCount, objectCount)];
    NSArray* prob_objectAttributeLabels = [averageProbabilities subarrayWithRange:NSMakeRange(sceneCount + styleCount + placesCount + objectCount, objectAttributeCount)];

    
    NSArray* sceneLabels = [self topLabelForScores:[NSDictionary dictionaryWithObjects:prob_sceneAttributeLabels forKeys:self.sceneAttributeLabels]
                                    withThreshhold:0.0
                                     maxLabelCount:5];
    
    NSArray* styleLabels = [self topLabelForScores:[NSDictionary dictionaryWithObjects:prob_styleAttributeLabels forKeys:self.styleAttributeLabels]
                                    withThreshhold:0.0
                                     maxLabelCount:5];
    
    NSArray* placesLabels = [self topLabelForScores:[NSDictionary dictionaryWithObjects:prob_placesLabels forKeys:self.placesLabels]
                                     withThreshhold:0.0
                                      maxLabelCount:5];
    
    NSArray* objLabels = [self topLabelForScores:[NSDictionary dictionaryWithObjects:prob_objectsLabels forKeys:self.objectsLabels]
                                  withThreshhold:0.0
                                   maxLabelCount:5];
    
    NSArray* objAttrLabels = [self topLabelForScores:[NSDictionary dictionaryWithObjects:prob_objectAttributeLabels forKeys:self.objectAttributeLabels]
                                      withThreshhold:0.0
                                       maxLabelCount:5];
    
    NSMutableArray* labels = [NSMutableArray arrayWithObject:@"Scene:"];
    [labels addObjectsFromArray:sceneLabels];
    [labels addObject:@"Style:"];
    [labels addObjectsFromArray:styleLabels];
    [labels addObject:@"Places:"];
    [labels addObjectsFromArray:placesLabels];
    [labels addObject:@"Objects:"];
    [labels addObjectsFromArray:objLabels];
    [labels addObject:@"Attributes:"];
    [labels addObjectsFromArray:objAttrLabels];

    return @{
             kSynopsisStandardMetadataFeatureVectorDictKey : (self.averageFeatureVec) ? self.averageFeatureVec.arrayValue : @[ ],
             kSynopsisStandardMetadataProbabilitiesDictKey : (averageProbabilities) ? averageProbabilities : @[ ],
//             kSynopsisStandardMetadataInterestingFeaturesAndTimesDictKey  : (windowAverages) ? windowAverages : @[ ],
             kSynopsisStandardMetadataDescriptionDictKey: (labels) ? labels : @[ ],
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
