//
//  NSValue+NSValue_OpenCV.m
//  Synopsis-Framework
//
//  Created by vade on 3/26/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import "opencv2/core/ocl.hpp"
#import "opencv2/core/utility.hpp"

#import "SynopsisDenseFeature.h"
#import "SynopsisDenseFeature+Private.h"

@interface SynopsisDenseFeature ()
@property cv::Mat OpenCVMat;
@end

@implementation SynopsisDenseFeature (Private)

- (instancetype) initWithCVMat:(cv::Mat)mat
{
    self = [self init];
    if(self)
    {
        self.OpenCVMat = mat;
        self.OpenCVMat.addref();
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
    cv::Mat featureVec = cv::Mat((int)featureArray.count, 1, CV_32FC1);
    
    for(int i = 0; i < featureArray.count; i++)
    {
        NSNumber* fVec = featureArray[i];
        
        featureVec.at<float>(i,0) = fVec.floatValue;
    }

    self = [self initWithCVMat:featureVec];
    return self;
}

+ (instancetype) denseFeatureByCombiningFeature:(SynopsisDenseFeature*)feature withFeature:(SynopsisDenseFeature*)feature2;
{
    cv::Mat newMat;
    [feature cvMatValue].copyTo(newMat);
    newMat.push_back([feature cvMatValue]);
    
    return [SynopsisDenseFeature valueWithCVMat:newMat];
}

- (NSUInteger) featureCount
{
    cv::Size matSize = self.OpenCVMat.size();
    return matSize.width * matSize.height;
}

- (NSNumber*)objectAtIndexedSubscript:(NSUInteger)idx
{
    float val = self.OpenCVMat.at<float>(0, (int) idx);
    return @(val);
}


@end

