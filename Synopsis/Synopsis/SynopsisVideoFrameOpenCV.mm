//
//  SynopsisVideoFrameOpenCV.m
//  Synopsis-Framework
//
//  Created by vade on 10/24/17.
//  Copyright © 2017 v002. All rights reserved.
//
#import "opencv2/core/mat.hpp"
#import "opencv2/core/utility.hpp"

#import "SynopsisVideoFrameOpenCV.h"

@interface SynopsisVideoFrameOpenCV ()
@property (readwrite, strong) SynopsisVideoFormatSpecifier* videoFormatSpecifier;
@property (readwrite, assign) cv::Mat openCVMatrix;
@property (readwrite, assign) CMTime presentationTimeStamp;
@property (readwrite, strong) NSString* label;
@property (readwrite, assign) CGColorSpaceRef colorSpace;

@end

@implementation SynopsisVideoFrameOpenCV

- (instancetype) initWithCVMat:(cv::Mat)mat formatSpecifier:(SynopsisVideoFormatSpecifier*)formatSpecifier presentationTimeStamp:(CMTime)pts colorspace:(CGColorSpaceRef) colorspace
{
    self = [super init];
    if(self)
    {
        self.openCVMatrix = mat;
        self.videoFormatSpecifier = formatSpecifier;
        self.presentationTimeStamp = pts;
        self.colorSpace = CGColorSpaceRetain(colorspace);
    }
    
    return self;
}

- (cv::Mat)mat;
{
    return self.openCVMatrix;
}

- (void) dealloc
{
    CGColorSpaceRelease(self.colorSpace);
    self.openCVMatrix.release();
}

@end
