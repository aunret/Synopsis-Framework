//
//  NSValue+NSValue_OpenCV.m
//  Synopsis-Framework
//
//  Created by vade on 3/26/17.
//  Copyright © 2017 v002. All rights reserved.
//


#import "opencv2/core/mat.hpp"
#import "opencv2/core/utility.hpp"

#import "SynopsisDenseFeature+Private.h"
#import "SynopsisDenseFeature.h"


@interface SynopsisDenseFeature ()
@property (assign) cv::Mat OpenCVMat;
@property (readwrite, copy) NSString* metadataKey;
@end

@implementation SynopsisDenseFeature (Private)

- (instancetype) initWithCVMat:(cv::Mat)mat forMetadataKey:(NSString*)key
{
    self = [self init];
    if(self)
    {
        self.metadataKey = key;
        self.OpenCVMat = mat;
//        self.OpenCVMat.addref();
    }
    return self;
}

- (void) dealloc
{
    self.OpenCVMat.release();
}


+ (SynopsisDenseFeature*) valueWithCVMat:(cv::Mat)mat forMetadataKey:(NSString*)key
{
    return [[SynopsisDenseFeature alloc] initWithCVMat:mat forMetadataKey:key];
}

- (cv::Mat) cvMatValue
{
    return self.OpenCVMat;
}

@end

@implementation SynopsisDenseFeature

- (instancetype) initWithFeatureArray:(NSArray*)featureArray forMetadataKey:(NSString*)key
{
    cv::Mat featureVec = cv::Mat((int)featureArray.count, (int)1, CV_32FC1);
    
    for(int i = 0; i < featureArray.count; i++)
    {
        NSNumber* fVec = featureArray[i];
        
        featureVec.at<float>(i,0) = fVec.floatValue;
    }

    self = [self initWithCVMat:featureVec forMetadataKey:key];
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] initWithCVMat:self.OpenCVMat forMetadataKey:self.metadataKey];
    if (copy)
    {
        return copy;
    }

    return nil;
}

+ (instancetype) denseFeatureByAppendingFeature:(SynopsisDenseFeature*)feature withFeature:(SynopsisDenseFeature*)feature2;
{
    cv::Mat newMat;
    [feature cvMatValue].copyTo(newMat);
    newMat.push_back([feature2 cvMatValue]);
    
    SynopsisDenseFeature* newfeature = [SynopsisDenseFeature valueWithCVMat:newMat forMetadataKey:feature.metadataKey];
    
    return newfeature;
}

+ (instancetype) denseFeatureByAveragingFeature:(SynopsisDenseFeature*)feature withFeature:(SynopsisDenseFeature*)feature2
{
    cv::Mat newMat;
    
    cv::add([feature cvMatValue], [feature2 cvMatValue], newMat);
    
    newMat *= 0.5;
    
    return [[SynopsisDenseFeature alloc] initWithCVMat:newMat forMetadataKey:feature.metadataKey];
}

// ( (previous * average)) + next  / (previous + 1.0)
+ (instancetype) denseFeatureByCumulativeMovingAveragingCurrentFeature:(SynopsisDenseFeature*)next previousAverage:(SynopsisDenseFeature*)average sampleCount:(NSUInteger)sampleCount
{
    cv::Mat ones = cv::Mat::ones([next cvMatValue].size(), CV_32FC1);
    
    // must do element wise multiplcation. * is matrix multiplication
    cv::Mat newMat;
    cv::multiply(sampleCount,  [average cvMatValue], newMat);
    
    newMat = newMat + [next cvMatValue];
    
    cv::Mat divisionResult;
    cv::divide( newMat,  sampleCount + 1, divisionResult );
    
    return [[SynopsisDenseFeature alloc] initWithCVMat:divisionResult forMetadataKey:average.metadataKey];
}


+ (instancetype) denseFeatureByMaximizingFeature:(SynopsisDenseFeature*)feature withFeature:(SynopsisDenseFeature*)feature2
{
    cv::Mat newMat;
    
    cv::max([feature cvMatValue], [feature2 cvMatValue], newMat);
    
    return [[SynopsisDenseFeature alloc] initWithCVMat:newMat forMetadataKey:feature.metadataKey];
}

// Inspired by jit.slide - performs cellwise temporal envelope following using the formula y (n) = y (n-1) + ((x (n) - y (n-1))/slide).
+ (instancetype) denseFeatureByTemporalEnvelopeAveraging:(SynopsisDenseFeature*)feature withFeature:(SynopsisDenseFeature*)feature2
{
    //    cv::Mat newMat = [feature cvMatValue] + ( ([feature2 cvMatValue] -  [feature cvMatValue]) / 1000.0);

    cv::Mat newMat;
    cv::max([feature cvMatValue], [feature2 cvMatValue], newMat);
    
    newMat = newMat + ( ([feature2 cvMatValue] -  [feature cvMatValue]) / 1000.0);

    return [[SynopsisDenseFeature alloc] initWithCVMat:newMat forMetadataKey:feature.metadataKey];
}


- (void) resizeTo:(NSUInteger)numElements
{
    cv::Mat newMat;
    cv::resize([self OpenCVMat], newMat, cv::Size(1, (int)numElements), cv::INTER_LINEAR);
    
    self.OpenCVMat = newMat;
}

- (instancetype) subFeaturebyReferencingRange:(NSRange)subRange
{
    int begin = (int) subRange.location;
    int end = (int) subRange.length;
  
//    Rect_(_Tp _x, _Tp _y, _Tp _width, _Tp _height);
    cv::Rect cropRect = cv::Rect( 0, begin,  1, end ) ;
    
    cv::Mat subMat = [self OpenCVMat]( cropRect );

    return [[SynopsisDenseFeature alloc] initWithCVMat:subMat forMetadataKey:[self.metadataKey stringByAppendingString:NSStringFromRange(subRange)]];
}


- (NSUInteger) featureCount
{
    cv::Size matSize = self.OpenCVMat.size();
    return matSize.width * matSize.height;
}

- (NSNumber*)objectAtIndexedSubscript:(NSUInteger)idx
{
    float val = self.OpenCVMat.at<float>( (int) idx, 0);
    return @(val);
}

- (NSArray<NSNumber*>*) arrayValue
{
    NSUInteger featureCount = [self featureCount];
    NSMutableArray<NSNumber*>* arrayValue = [NSMutableArray arrayWithCapacity:featureCount];
    
    for(int i = 0; i < featureCount; i++)
    {
        [arrayValue addObject: @(self.OpenCVMat.at<float>(i,0) )];
    }

    return  arrayValue;    
}


@end

