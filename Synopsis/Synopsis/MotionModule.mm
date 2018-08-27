//
//  MotionModule.m
//  Synopsis
//
//  Created by vade on 11/10/16.
//  Copyright © 2016 metavisual. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "SynopsisVideoFrameOpenCV.h"
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/video/tracking.hpp"
#import "MotionModule.h"

@interface MotionModule ()
{
    std::vector<cv::Point2f> frameFeatures[2];
    
    unsigned int frameCount;
    
    float avgVectorMagnitude;
    float avgVectorX;
    float avgVectorY;
}
@end

@implementation MotionModule

- (instancetype) initWithQualityHint:(SynopsisAnalysisQualityHint)qualityHint
{
    self = [super initWithQualityHint:qualityHint];
    {
        avgVectorX = 0.0;
        avgVectorY = 0.0;
        avgVectorMagnitude = 0.0;
    }
    return self;
}

- (NSString*) moduleName
{
    return kSynopsisStandardMetadataMotionDictKey;//@"Motion";
}

+ (SynopsisVideoBacking) requiredVideoBacking
{
    return SynopsisVideoBackingOpenCV;
}

+ (SynopsisVideoFormat) requiredVideoFormat
{
    return SynopsisVideoFormatGray8;
}

- (NSDictionary*) analyzedMetadataForCurrentFrame:(id<SynopsisVideoFrame>)frame previousFrame:(id<SynopsisVideoFrame>)lastFrame;
{
    SynopsisVideoFrameOpenCV* frameCV = (SynopsisVideoFrameOpenCV*)frame;
    SynopsisVideoFrameOpenCV* previousFrameCV = (SynopsisVideoFrameOpenCV*)lastFrame;

    // Empty mat - will be zeros
    cv::Mat flow;
    
    if(!previousFrameCV.mat.empty())
        cv::calcOpticalFlowFarneback(previousFrameCV.mat, frameCV.mat, flow, 0.5, 3, 15, 3, 5, 1.2, 0);
    
    // Avg entire flow field
    cv::Scalar avgMotion = cv::mean(flow);
    
    float xMotion = (float) -avgMotion[0] / (float)frameCV.mat.size().width;
    float yMotion = (float) avgMotion[1] / (float)frameCV.mat.size().height;
    
    float frameVectorMagnitude = sqrtf(  (xMotion * xMotion)
                                          + (yMotion * yMotion)
                                          );
    
    // Add Features to metadata
    NSMutableDictionary* metadata = [NSMutableDictionary new];
    metadata[kSynopsisStandardMetadataMotionVectorDictKey] = @[@(xMotion), @(yMotion)];
    metadata[kSynopsisStandardMetadataMotionDictKey] = @(frameVectorMagnitude);
    
    // sum Direction and speed of aggregate frames
    avgVectorMagnitude += frameVectorMagnitude;
    avgVectorX += xMotion;
    avgVectorY += yMotion;
    
    frameCount++;
    
    return metadata;
}

- (NSDictionary*) finaledAnalysisMetadata
{
    NSMutableDictionary* metadata = [NSMutableDictionary new];

    float frameCountf = (float) frameCount;
    
    metadata[kSynopsisStandardMetadataMotionVectorDictKey] = @[@(avgVectorX / frameCountf ), @(avgVectorY / frameCountf)];
    metadata[kSynopsisStandardMetadataMotionDictKey] = @(avgVectorMagnitude / frameCountf);

    return metadata;
}

@end
