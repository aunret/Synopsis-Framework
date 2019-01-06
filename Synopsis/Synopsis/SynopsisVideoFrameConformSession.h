//
//  SynopsisVideoFrameConformSession.h
//  Synopsis-Framework
//
//  Created by vade on 10/24/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import <CoreVideo/CoreVideo.h>
#import <Synopsis/SynopsisVideoFrameCache.h>
#import <Metal/Metal.h>
#import <CoreMedia/CoreMedia.h>

typedef void(^SynopsisVideoFrameConformSessionCompletionBlock)(bool didSkipFrame, id<MTLCommandBuffer> commandBuffer, SynopsisVideoFrameCache*, NSError*);

@interface SynopsisVideoFrameConformSession : NSObject

// Inform the conform session what format conversion and backing we will require
// This allows us to only create the resources we need, only do the conversions required, and not waste any time doing anything else.

- (instancetype) initWithRequiredFormatSpecifiers:(NSArray<SynopsisVideoFormatSpecifier*>*)formatSpecifiers device:(id<MTLDevice>)device inFlightBuffers:(NSUInteger)bufferCount frameSkipStride:(NSInteger)frameSkipStride;

@property (readonly, strong) id<MTLDevice>device;

// Call to re-set frame skip if you re-use the conform session but have a new-analysis session
- (void) resetConformSession;
- (void) conformPixelBuffer:(CVPixelBufferRef)pixelbuffer atTime:(CMTime)time withTransform:(CGAffineTransform)transform rect:(CGRect)rect completionBlock:(SynopsisVideoFrameConformSessionCompletionBlock)completionBlock;

- (void) blockForPendingConforms;
- (void) cancelPendingConforms;

@end
