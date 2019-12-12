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
@property (readwrite, strong) SynopsisDenseFeature* averageProbabilities;

// Compute the frame similarity between consecutive frames
// On completion of the film,normalize the number of vector elements to match
// This gives us a 'similarity vector' of the time domain features
// Although we do lose what it is we are similar about
// Its a feature thats useful to knowing how the temporal structure changes over time
@property (readwrite, strong) SynopsisDenseFeature* similarityFeatureVec;
@property (readwrite, strong) SynopsisDenseFeature* similarityProbabilities;

// In order ot do the above, we have to cache the last frames features
@property (readwrite, strong) SynopsisDenseFeature* lastFrameFeatureVec;
@property (readwrite, strong) SynopsisDenseFeature* lastFrameProbabilities;

@property (readwrite, strong) NSArray<NSString*>* labels;
@property (readwrite, strong) NSArray<NSValue*>* labelGroupRanges;

@end

@implementation CinemaNetModuleV1

- (instancetype) initWithQualityHint:(SynopsisAnalysisQualityHint)qualityHint device:(id<MTLDevice>)device
{
    self = [super initWithQualityHint:qualityHint device:device];
    if(self)
    {
        stride = 5;
        numWindows = 2;
        
//        linear = CGColorSpaceCreateWithName(kCGColorSpaceExtendedLinearSRGB);
//
//        NSDictionary* opt = @{ kCIContextWorkingColorSpace : (__bridge id)linear,
//                               kCIContextOutputColorSpace : (__bridge id)linear,
//                               };
        
        self.context = [CIContext contextWithMTLDevice:device ];
        
        NSError* error = nil;

        if (@available(macOS 10.14, *)) {
            
            MLModelConfiguration* modelConfig = [[MLModelConfiguration alloc] init];
            modelConfig.computeUnits = MLComputeUnitsAll;
			
            if (@available(macOS 10.15, *))
            {
                modelConfig.preferredMetalDevice = device;
            }
            
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

        // Fix to load labels from model
        self.labels = nil;
//        NSString* allLabelStringsPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"synopsis.interim.model.dict" ofType:@"txt"];
//
//        NSString* allLabelsString = [NSString stringWithContentsOfFile:allLabelStringsPath encoding:NSUTF8StringEncoding error:&error];
//
//        if(error)
//        {
//            NSLog(@"Error: %@", error);
//        }
//
//        self.labels = [allLabelsString componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        
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
    self.averageProbabilities = nil;
    
    self.similarityFeatureVec  = nil;
    self.similarityProbabilities  = nil;
    
    self.lastFrameFeatureVec  = nil;
    self.lastFrameProbabilities  = nil;
}


// TODO: This should be optimized
- (NSArray<NSNumber*>*) nsarrayFromMLMultiArray:(MLMultiArray*)multiArray
{
    
    NSMutableArray<NSNumber*>* array = [NSMutableArray new];
    for (int i = 0; i < multiArray.count; i++)
    {
        // Keyed Subscript returns NSNumbers:
        [array addObject: multiArray[i] ];
    }

    return array;
}

- (void) analyzedMetadataForCurrentFrame:(id<SynopsisVideoFrame>)frame previousFrame:(id<SynopsisVideoFrame>)lastFrame commandBuffer:(id<MTLCommandBuffer>)buffer completionBlock:(GPUModuleCompletionBlock)completionBlock
{
    CIImage* imageForRequest = nil;
    if([frame isKindOfClass:[SynopsisVideoFrameMPImage class]])
    {
        SynopsisVideoFrameMPImage* frameMPImage = (SynopsisVideoFrameMPImage*)frame;
        MPSImage* frameMPSImage = frameMPImage.mpsImage;
//        imageForRequest = [CIImage imageWithMTLTexture:frameMPSImage.texture options:(frameMPImage.colorSpace==nil) ? nil : @{ kCIImageColorSpace: (id) frameMPImage.colorSpace }];
        imageForRequest = [CIImage imageWithMTLTexture:frameMPSImage.texture options: @{ kCIImageColorSpace: (id) [NSNull null] }];

    }
    
    else if ([frame isKindOfClass:[SynopsisVideoFrameCVPixelBuffer class]])
    {
        SynopsisVideoFrameCVPixelBuffer* frameCVPixelBuffer = (SynopsisVideoFrameCVPixelBuffer*)frame;
        
//        imageForRequest = [CIImage imageWithCVImageBuffer:[frameCVPixelBuffer pixelBuffer]];
        imageForRequest = [CIImage imageWithCVImageBuffer:[frameCVPixelBuffer pixelBuffer] options: @{ kCIImageColorSpace: (id) [NSNull null] }];
}
    
    VNCoreMLRequest* mobileRequest = [[VNCoreMLRequest alloc] initWithModel:self.vnModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        
        NSMutableDictionary* metadata = [NSMutableDictionary dictionary];

        // TODO: Strcictly Necessary anymore
        NSArray* results = [request results];
       
        if([request results].count)
        {
            // Subtract one since we are going to remove our embedding space and treat that separately
            NSUInteger countOfPredictionGroups = [results count] - 1;
            
            NSMutableArray* labels = [NSMutableArray arrayWithCapacity:countOfPredictionGroups];
            NSMutableArray* probabilities = [NSMutableArray arrayWithCapacity:countOfPredictionGroups];

#pragma mark - Sort Features
            // TODO: For 10.15 we can make this nicer:
            // 10.15 adds .featureName to VNCoreMLFeatureValueObservation

            // This is so fucking stupid
            // Vision / CoreML does not return out features in the order of our outputs / labels as we so carefully described them
            // We MUST TAKE CARE that our .NA (not applicable) fields are last for every category
            // We cant just do an alphabetical sort.
            // Oh lord why is this so dumb.
                        
            // Ensure our output dictionaries are in the proper order
            // Put our embedded space / feature vector one first always:
            
            results = [results sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {

                VNCoreMLFeatureValueObservation* one = (VNCoreMLFeatureValueObservation *)obj1;
                NSDictionary* oneDict = [one.featureValue dictionaryValue];

                // If we dont have a dictionaryValue its our embedding space VNCoreMLFeatureValueObservation
                if (oneDict == nil)
                {
                    return NSOrderedAscending;
                }
                NSString* oneFirstKey = [[oneDict allKeys] firstObject];

                VNCoreMLFeatureValueObservation* two = (VNCoreMLFeatureValueObservation *)obj2;
                NSDictionary* twoDict = [two.featureValue dictionaryValue];

                // If we dont have a dictionaryValue its our embedding space VNCoreMLFeatureValueObservation
                if (twoDict == nil)
                {
                    return NSOrderedDescending;
                }

                NSString* twoFirstKey = [[twoDict allKeys] firstObject];
                return [oneFirstKey compare:twoFirstKey options:NSNumericSearch];
            }];
            
            VNCoreMLFeatureValueObservation* embeddingSpaceObservation = [results firstObject];
            NSArray* embeddingSpaceArray = [self nsarrayFromMLMultiArray:embeddingSpaceObservation.featureValue.multiArrayValue];

            //VNCoreMLFeatureValueObservation* dominantColorObservation = [results objectAtIndex:1];
            //NSArray* dominantColorArray = [self nsarrayFromMLMultiArray:dominantColorObservation.featureValue.multiArrayValue];
            
#pragma mark - Labels / Tags
            
            // Remove our embedding and our dominant color resultss
            results = [results subarrayWithRange:NSMakeRange(2, results.count - 2)];
            
            // Track the ranges of our label concept groups:
            NSUInteger location = 0;
            NSMutableArray<NSValue*>* labelGroupRanges = nil;
            
            if (self.labelGroupRanges == nil)
            {
                labelGroupRanges = [NSMutableArray arrayWithCapacity:results.count];
            }
            
            // Now that tjhey are in order, unroll the dicts and values ensuring .na suffix is last
            for (VNCoreMLFeatureValueObservation* observation in results)
            {
                NSDictionary* observationDict = [observation.featureValue dictionaryValue];
                
                // Force our NA key to be last (THIS IS SO FUCKING ANNOYING)
                NSString* naKey = nil;
                NSMutableArray* allKeys = [[observationDict allKeys] mutableCopy];
                for (NSString* key in allKeys)
                {
                    if ( [key hasSuffix:@".na"])
                    {
                        naKey = key;
                        break;
                    }
                }
                
                if (naKey != nil)
                {
                    [allKeys removeObject:naKey];
                    [allKeys addObject:naKey];
                    
                    NSArray* orderedObservations = [observationDict objectsForKeys:allKeys notFoundMarker:[NSNull null]];
                    
                    [labels addObjectsFromArray:allKeys];
                    [probabilities addObjectsFromArray:orderedObservations];
                }
                else
                {
                    [labels addObjectsFromArray:allKeys];
                    [probabilities addObjectsFromArray:[observationDict allValues]];
                }
                
                
                if (labelGroupRanges != nil)
                {
                    NSRange currentLabelRange = NSMakeRange(location, allKeys.count);
                    location = NSMaxRange(currentLabelRange);
                    NSValue* rangeValue = [NSValue valueWithRange:currentLabelRange];
                    [labelGroupRanges addObject:rangeValue];
                }
                
            }

            if (self.labels == nil)
                self.labels = [labels copy];
            
            if (self.labelGroupRanges == nil && labelGroupRanges != nil)
            {
                self.labelGroupRanges  = [labelGroupRanges copy];
            }
            
#pragma mark - Compute Features

            SynopsisDenseFeature* denseFeature = [[SynopsisDenseFeature alloc] initWithFeatureArray:embeddingSpaceArray forMetadataKey:kSynopsisStandardMetadataFeatureVectorDictKey];

            if(self.averageFeatureVec == nil)
            {
                self.averageFeatureVec = denseFeature;
            }
            else
            {
                // Probabilities get maximized
                self.averageFeatureVec = [SynopsisDenseFeature denseFeatureByAveragingFeature:self.averageFeatureVec withFeature:denseFeature];
            }

            SynopsisDenseFeature* denseProbabilities = [[SynopsisDenseFeature alloc] initWithFeatureArray:probabilities forMetadataKey:kSynopsisStandardMetadataProbabilitiesDictKey];

            if(self.averageProbabilities == nil)
            {
                self.averageProbabilities = denseProbabilities;
            }
            else
            {
                // Probabilities get maximized
                self.averageProbabilities = [SynopsisDenseFeature denseFeatureByAveragingFeature:self.averageProbabilities withFeature:denseProbabilities];
            }
            

#pragma mark - Compute Similarities
            
            if ( denseFeature && self.lastFrameFeatureVec )
            {
                float featureSimilarity = compareFeaturesCosineSimilarity(self.lastFrameFeatureVec, denseFeature);
                
                SynopsisDenseFeature* denseSimilarity = [[SynopsisDenseFeature alloc] initWithFeatureArray:@[@(featureSimilarity)] forMetadataKey:kSynopsisStandardMetadataSimilarityFeatureVectorDictKey];
                
                if ( self.similarityFeatureVec )
                {
                    self.similarityFeatureVec = [SynopsisDenseFeature denseFeatureByAppendingFeature:self.similarityFeatureVec withFeature:denseSimilarity];
                }
                else
                {
                    self.similarityFeatureVec = denseSimilarity;
                }
            }
            
            if ( denseProbabilities && self.lastFrameProbabilities )
            {
                float featureSimilarity = compareFeaturesCosineSimilarity(self.lastFrameProbabilities, denseProbabilities);
                               
                SynopsisDenseFeature* denseSimilarity = [[SynopsisDenseFeature alloc] initWithFeatureArray:@[@(featureSimilarity)] forMetadataKey:kSynopsisStandardMetadataSimilarityProbabilitiesDictKey];
                
                if ( self.similarityProbabilities )
                {
                    self.similarityProbabilities = [SynopsisDenseFeature denseFeatureByAppendingFeature:self.similarityProbabilities withFeature:denseSimilarity];
                }
                else
                {
                    self.similarityProbabilities = denseSimilarity;
                }
            }
           
            metadata[kSynopsisStandardMetadataFeatureVectorDictKey] = embeddingSpaceArray;
            metadata[kSynopsisStandardMetadataProbabilitiesDictKey] = probabilities;

            // Cache our last frames for the next frame
            self.lastFrameFeatureVec = denseFeature;
            self.lastFrameProbabilities = denseProbabilities;
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
    // Compute the most likely labels from each label category
    NSArray<NSNumber*>* averageProbabilities = [self.averageProbabilities arrayValue];
    NSArray<NSNumber*>* averageFeatures = [self.averageFeatureVec arrayValue];

    NSMutableArray<NSString*>* predictedLabels = [NSMutableArray new];
    
    [self.labelGroupRanges enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange range = obj.rangeValue;
        
        NSArray<NSString*>* topLabels = [self topLabelsForRange:range inArray:averageProbabilities greaterThanConfidence:0.35];

        [predictedLabels addObjectsFromArray:topLabels];
    }];
    

    [self.similarityFeatureVec resizeTo:1024];
    [self.similarityProbabilities resizeTo:1024];

    NSArray<NSNumber*>* similarFeatures = [self.similarityFeatureVec arrayValue];
    NSArray<NSNumber*>* similarProbabilities =  [self.similarityProbabilities arrayValue];

    
    return @{
             kSynopsisStandardMetadataProbabilitiesDictKey : (averageProbabilities) ? averageProbabilities : @[ ],
             kSynopsisStandardMetadataFeatureVectorDictKey : (averageFeatures) ? averageFeatures : @[ ],

             kSynopsisStandardMetadataDescriptionDictKey: ([predictedLabels count]) ? predictedLabels : @[ ],
             
             kSynopsisStandardMetadataSimilarityFeatureVectorDictKey : (similarFeatures) ? similarFeatures : @ [ ],
             kSynopsisStandardMetadataSimilarityProbabilitiesDictKey : (similarProbabilities) ? similarProbabilities : @[ ],
             };
}

- (nullable NSArray<NSString*>*) topLabelsForRange:(NSRange)range inArray:(NSArray*)probabilities greaterThanConfidence:(float)confidenceThresh
{
    NSArray* subProbabilities = [probabilities subarrayWithRange:range];
    NSArray* subLabels = [self.labels subarrayWithRange:range];

    // Note we switch keys and objects. We key off of the probabilty SCORE which is odd but helpful:
    NSDictionary* subLabelsAndProbs = [NSDictionary dictionaryWithObjects:subProbabilities forKeys:subLabels];
    
    NSArray* sortedSubProbs = [subProbabilities sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSNumber* confidence1 = obj1;
        NSNumber* confidence2 = obj2;
        
        if (confidence1.floatValue > confidence2.floatValue)
            return NSOrderedAscending;
        if (confidence1.floatValue < confidence2.floatValue)
            return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
    NSMutableOrderedSet* sortedLabels = [NSMutableOrderedSet new];
    
    for (NSNumber* prob in sortedSubProbs)
    {
        NSArray* labelsForProb = [subLabelsAndProbs allKeysForObject:prob];
        
        [sortedLabels addObjectsFromArray:labelsForProb];
    }
    
//    NSArray* sortedLabels = [subLabelsAndProbs objectsForKeys:sortedSubProbs notFoundMarker:[NSNull null]];
    
    NSUInteger countOfTopPredictionsToUse = 1;
    
    // For locations for example, we want more than 1 (not just a prediction of interior or exterior for example)
    if (sortedLabels.count > 100)
        countOfTopPredictionsToUse = 5;

    // Texture - helpful? I dont know.
    else if (sortedLabels.count >= 40)
        countOfTopPredictionsToUse = 3;

    // Helps with Shot Subject - if its person it might be body too
    else if (sortedLabels.count >= 10)
        countOfTopPredictionsToUse = 2;

    
    NSMutableArray* topLabels = [NSMutableArray new];
    
    for (NSUInteger i = 0; i < countOfTopPredictionsToUse; i++ )
    {
        NSString* label = sortedLabels[i];
        NSNumber* confidence = sortedSubProbs[i];
        
        if (confidence.floatValue >= confidenceThresh && ![label hasSuffix:@".na"] )
        {
            [topLabels addObject:label];
        }
    }
    
    return topLabels;
    
//    float maxConfidence = FLT_MIN;
//    NSUInteger chosenIndex = NSNotFound;
//    for( NSNumber* confidence in subProbabilities )
//    {
//        if( confidence.floatValue >= maxConfidence )
//        {
//            maxConfidence = confidence.floatValue;
//            chosenIndex = [subProbabilities indexOfObject:confidence];
//        }
//    }
    

//    if(chosenIndex != NSNotFound && maxConfidence >= confidenceThresh)
//    {
//        return subLabels[chosenIndex];
//    }
    
    return nil;
}

@end
