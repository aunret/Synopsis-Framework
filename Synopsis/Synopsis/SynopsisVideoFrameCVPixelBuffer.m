//
//  SynopsisVideoFrameCVPixelBuffer.m
//  Synopsis-macOS
//
//  Created by vade on 8/24/18.
//  Copyright © 2018 v002. All rights reserved.
//

#import "SynopsisVideoFrameCVPixelBuffer.h"

@interface SynopsisVideoFrameCVPixelBuffer ( )
{
    CVPixelBufferRef pixelBuffer;
}

@property (readwrite, strong) SynopsisVideoFormatSpecifier* videoFormatSpecifier;
@property (readwrite, assign) CMTime presentationTimeStamp;

@end

@implementation SynopsisVideoFrameCVPixelBuffer

- (instancetype) initWithPixelBuffer:(CVPixelBufferRef)buffer formatSpecifier:(SynopsisVideoFormatSpecifier*)formatSpecifier presentationTimeStamp:(CMTime)pts
{
    self = [super init];
    if(self)
    {
        pixelBuffer = CVPixelBufferRetain(buffer);
        self.videoFormatSpecifier = formatSpecifier;
        self.presentationTimeStamp = pts;
    }
    return self;
        
}

- (CVPixelBufferRef) pixelBuffer
{
    return pixelBuffer;
}

- (void) dealloc
{
    if(pixelBuffer)
    {
        CVPixelBufferRelease(pixelBuffer);
        pixelBuffer = NULL;
    }
}


@end
