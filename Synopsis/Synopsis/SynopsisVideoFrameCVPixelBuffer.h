//
//  SynopsisVideoFrameCVPixelBuffer.h
//  Synopsis-macOS
//
//  Created by vade on 8/24/18.
//  Copyright © 2018 v002. All rights reserved.
//

#import "SynopsisVideoFrame.h"
#import <CoreVideo/CoreVideo.h>

@interface SynopsisVideoFrameCVPixelBuffer : NSObject

@property (readonly) SynopsisVideoFormatSpecifier* videoFormatSpecifier;
@property (readonly) CMTime presentationTimeStamp;

- (instancetype) initWithPixelBuffer:(CVPixelBufferRef)pixelBuffer formatSpecifier:(SynopsisVideoFormatSpecifier*)formatSpecifier presentationTimeStamp:(CMTime)pts;

- (CVPixelBufferRef) pixelBuffer;

@end
