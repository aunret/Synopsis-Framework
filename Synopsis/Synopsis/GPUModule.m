//
//  GPUModule.m
//  Synopsis-Framework
//
//  Created by vade on 10/25/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import "GPUModule.h"


@interface GPUModule ()
@property (readwrite, strong) id<MTLDevice> device;
@property (readwrite, assign) SynopsisAnalysisQualityHint qualityHint;
@property (readwrite, strong) dispatch_queue_t completionQueue;
@end

@implementation GPUModule

// GPU backed modules init with an options dict for Metal Device bullshit
- (instancetype) initWithQualityHint:(SynopsisAnalysisQualityHint)qualityHint device:(id<MTLDevice>)device
{
    self = [super init];
    if(self)
    {
        self.device = device;
        self.qualityHint = qualityHint;
        self.completionQueue = dispatch_queue_create("gpumodule.completionqueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (NSString*) moduleName
{
    [NSObject doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (SynopsisVideoBacking) requiredVideoBacking
{
    return SynopsisVideoBackingNone;
}

+ (SynopsisVideoFormat) requiredVideoFormat
{
    [NSObject doesNotRecognizeSelector:_cmd];
    return SynopsisVideoFormatUnknown;
}

- (void) beginAndClearCachedResults
{
    [NSObject doesNotRecognizeSelector:_cmd];
}

- (void) analyzedMetadataForCurrentFrame:(id<SynopsisVideoFrame>)frame previousFrame:(id<SynopsisVideoFrame>)lastFrame commandBuffer:(id<MTLCommandBuffer>)buffer completionBlock:(GPUModuleCompletionBlock)completionBlock
{
    [NSObject doesNotRecognizeSelector:_cmd];
}

- (NSDictionary*) finalizedAnalysisMetadata
{
    [NSObject doesNotRecognizeSelector:_cmd];
    return nil;
}
@end
