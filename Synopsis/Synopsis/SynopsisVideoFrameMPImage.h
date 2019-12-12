//
//  SynopsisVideoFrameMPImage.h
//  Synopsis-Framework
//
//  Created by vade on 10/24/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import "SynopsisVideoFrame.h"
#import <Foundation/Foundation.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>

NS_ASSUME_NONNULL_BEGIN

@interface SynopsisVideoFrameMPImage : NSObject<SynopsisVideoFrame>
@property (readonly) SynopsisVideoFormatSpecifier* videoFormatSpecifier;
@property (readonly) CMTime presentationTimeStamp;
@property (readonly, nullable) CGColorSpaceRef colorSpace;

- (instancetype) initWithMPSImage:(MPSImage*)image formatSpecifier:(SynopsisVideoFormatSpecifier*)formatSpecifier presentationTimeStamp:(CMTime)pts colorspace:(CGColorSpaceRef)colorspace;
- (MPSImage*) mpsImage;
@end

NS_ASSUME_NONNULL_END
