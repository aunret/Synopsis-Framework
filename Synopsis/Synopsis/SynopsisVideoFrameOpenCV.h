//
//  SynopsisVideoFrameOpenCV.h
//  Synopsis-Framework
//
//  Created by vade on 10/24/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import "SynopsisVideoFrame.h"
#import "opencv2/core/mat.hpp"
#import <CoreFoundation/CoreFoundation.h>

@interface SynopsisVideoFrameOpenCV : NSObject<SynopsisVideoFrame>
@property (readonly) SynopsisVideoFormatSpecifier* videoFormatSpecifier;
@property (readonly) CMTime presentationTimeStamp;
@property (readonly, nullable) CGColorSpaceRef colorSpace;

- (instancetype) initWithCVMat:(cv::Mat)mat formatSpecifier:(SynopsisVideoFormatSpecifier*)formatSpecifier presentationTimeStamp:(CMTime)pts colorspace:(CGColorSpaceRef) colorspace;

- (cv::Mat)mat;
@end
