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
@end

@implementation SynopsisDenseFeature (Private)

- (instancetype) initWithCVMat:(cv::Mat)mat
{
    self = [self init];
    if(self)
    {
        self.OpenCVMat = mat;
//        self.OpenCVMat.addref();
    }
    return self;
}

- (void) dealloc
{
    self.OpenCVMat.release();
}

+ (SynopsisDenseFeature*) valueWithCVMat:(cv::Mat)mat
{
    return [[SynopsisDenseFeature alloc] initWithCVMat:mat];
}

- (cv::Mat) cvMatValue
{
    return self.OpenCVMat;
}

@end

@implementation SynopsisDenseFeature

- (instancetype) initWithFeatureArray:(NSArray*)featureArray

{
    cv::Mat featureVec = cv::Mat((int)featureArray.count, (int)1, CV_32FC1);
    
    for(int i = 0; i < featureArray.count; i++)
    {
        NSNumber* fVec = featureArray[i];
        
        featureVec.at<float>(i,0) = fVec.floatValue;
    }

    self = [self initWithCVMat:featureVec];
    
    return self;
}

+ (instancetype) denseFeatureByAppendingFeature:(SynopsisDenseFeature*)feature withFeature:(SynopsisDenseFeature*)feature2;
{
    cv::Mat newMat;
    [feature cvMatValue].copyTo(newMat);
    newMat.push_back([feature2 cvMatValue]);
    
    SynopsisDenseFeature* newfeature = [SynopsisDenseFeature valueWithCVMat:newMat];
    
    return newfeature;
}

+ (instancetype) denseFeatureByAveragingFeature:(SynopsisDenseFeature*)feature withFeature:(SynopsisDenseFeature*)feature2
{
    cv::Mat newMat;
    
    cv::add([feature cvMatValue], [feature2 cvMatValue], newMat);
    
    newMat *= 0.5;
    
    return [[SynopsisDenseFeature alloc] initWithCVMat:newMat];
}

+ (instancetype) denseFeatureByMaximizingFeature:(SynopsisDenseFeature*)feature withFeature:(SynopsisDenseFeature*)feature2
{
    cv::Mat newMat;
    
    cv::max([feature cvMatValue], [feature2 cvMatValue], newMat);
    
    return [[SynopsisDenseFeature alloc] initWithCVMat:newMat];
}

- (void) resizeTo:(NSUInteger)numElements
{
    cv::Mat newMat;
    cv::resize([self OpenCVMat], newMat, cv::Size(1, (int)numElements), cv::INTER_LINEAR);
    
    self.OpenCVMat = newMat;
    
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

