//
//  SynopsisVideoFrameConformSession.m
//  Synopsis-Framework
//
//  Created by vade on 10/24/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import "SynopsisVideoFrameConformSession.h"
#import "SynopsisVideoFrameConformHelperCPU.h"
#import "SynopsisVideoFrameConformHelperGPU.h"

#import "SynopsisVideoFrameCVPixelBuffer.h"

@interface SynopsisVideoFrameConformSession ()
@property (readwrite, atomic, assign) NSUInteger frameSkipCount;
@property (readwrite, atomic, assign) NSUInteger frameSkipStride;
@property (readwrite, strong) SynopsisVideoFrameConformHelperCPU* conformCPUHelper;
@property (readwrite, strong) SynopsisVideoFrameConformHelperGPU* conformGPUHelper;

@property (readwrite, strong) NSSet<SynopsisVideoFormatSpecifier*>* openCVOnlyFormatSpecifiers;
@property (readwrite, strong) NSSet<SynopsisVideoFormatSpecifier*>* mpsOnlyFormatSpecifiers;
@property (readwrite, strong) NSSet<SynopsisVideoFormatSpecifier*>* cvPixelBufferOnlyFormatSpecifiers;

@property (readwrite, strong) id<MTLDevice>device;
@property (readwrite, strong) id<MTLCommandQueue> commandQueue;
@property (readwrite, strong) dispatch_semaphore_t inFlightBuffers;

@property (readwrite, strong) dispatch_queue_t serialCompletionQueue;

@end

@implementation SynopsisVideoFrameConformSession

- (instancetype) initWithRequiredFormatSpecifiers:(NSArray<SynopsisVideoFormatSpecifier*>*)formatSpecifiers device:(id<MTLDevice>)device inFlightBuffers:(NSUInteger)bufferCount frameSkipStride:(NSInteger)frameSkipStride
{
    self = [super init];
    if(self)
    {
        self.frameSkipCount = 0;
        self.frameSkipStride = frameSkipStride;
        self.device = device;
        self.commandQueue = [self.device newCommandQueue];
        self.inFlightBuffers = dispatch_semaphore_create(bufferCount);

        self.conformCPUHelper = [[SynopsisVideoFrameConformHelperCPU alloc] initWithFlightBuffers:bufferCount];
        self.conformGPUHelper = [[SynopsisVideoFrameConformHelperGPU alloc] initWithCommandQueue:self.commandQueue inFlightBuffers:bufferCount];

        self.serialCompletionQueue = dispatch_queue_create("info.synopsis.formatConversion", DISPATCH_QUEUE_SERIAL);
        
        NSMutableSet<SynopsisVideoFormatSpecifier*>* openCV = [NSMutableSet new];
        NSMutableSet<SynopsisVideoFormatSpecifier*>* mps = [NSMutableSet new];
        NSMutableSet<SynopsisVideoFormatSpecifier*>* pixelBuffer = [NSMutableSet new];

        for(SynopsisVideoFormatSpecifier* format in formatSpecifiers)
        {
            switch(format.backing)
            {
                case SynopsisVideoBackingMPSImage:
                    [mps addObject:format];
                    break;
                case SynopsisVideoBackingOpenCV:
                    [openCV addObject:format];
                    break;
                case SynopsisVideoBackingCVPixelbuffer:
                    [pixelBuffer addObject:format];
                    break;
                case SynopsisVideoBackingNone:
                    break;
            }
        }
        
        self.openCVOnlyFormatSpecifiers = openCV;
        self.mpsOnlyFormatSpecifiers = mps;
        self.cvPixelBufferOnlyFormatSpecifiers = pixelBuffer;
    }
    
    return self;
}

- (void) resetConformSession
{
    self.frameSkipCount = 0;
}

- (void) conformPixelBuffer:(CVPixelBufferRef)pixelBuffer atTime:(CMTime)time withTransform:(CGAffineTransform)transform rect:(CGRect)rect               
 completionBlock:(SynopsisVideoFrameConformSessionCompletionBlock)completionBlock
{
    
    // Early bail on frame skip
    if(self.frameSkipCount % self.frameSkipStride)
    {
        if(completionBlock)
        {
            completionBlock(true, nil, nil, nil);
        }

        self.frameSkipCount = 0;
        
        return;
    }
    
    self.frameSkipCount++;
    
    // Because we have 2 different completion blocks we must coalesce into one, we use
    // dispatch notify to tell us when we are actually done.
    
    id<MTLCommandBuffer> commandBuffer = self.commandQueue.commandBuffer;

    NSArray<SynopsisVideoFormatSpecifier*>* localOpenCVFormats = [self.openCVOnlyFormatSpecifiers allObjects];
    NSArray<SynopsisVideoFormatSpecifier*>* localMPSFormats = [self.mpsOnlyFormatSpecifiers allObjects];
//    NSArray<SynopsisVideoFormatSpecifier*>* localGPUFormats = [self.mpsOnlyFormatSpecifiers allObjects];

    SynopsisVideoFrameCache* allFormatCache = [[SynopsisVideoFrameCache alloc] init];
    
    dispatch_group_t formatConversionGroup = dispatch_group_create();
    dispatch_group_enter(formatConversionGroup);
    
//    __block SynopsisVideoFrameCache* cpuCache = nil;
//    __block NSError* cpuError = nil;
//
//    __block SynopsisVideoFrameCache* gpuCache = nil;
//    __block NSError* gpuError = nil;
    
    // We can one-shot add the our CVPixelBuffer
    
    if(self.cvPixelBufferOnlyFormatSpecifiers.count)
    {
        SynopsisVideoFormatSpecifier* formatSpec = [[SynopsisVideoFormatSpecifier alloc] initWithFormat:SynopsisVideoFormatBGR8 backing:SynopsisVideoBackingCVPixelbuffer];
        SynopsisVideoFrameCVPixelBuffer* frame = [[SynopsisVideoFrameCVPixelBuffer alloc] initWithPixelBuffer:pixelBuffer formatSpecifier:formatSpec presentationTimeStamp:time];
        [allFormatCache cacheFrame:frame];
    }
    
    
    dispatch_group_notify(formatConversionGroup, self.serialCompletionQueue, ^{
        
        dispatch_semaphore_signal(self.inFlightBuffers);

        if(completionBlock)
        {
            completionBlock(false, commandBuffer, allFormatCache, nil);
        }

        [commandBuffer commit];

    });
    
    dispatch_semaphore_wait(self.inFlightBuffers, DISPATCH_TIME_FOREVER);
    
    if(localMPSFormats.count)
    {
        dispatch_group_enter(formatConversionGroup);
        [self.conformGPUHelper conformPixelBuffer:pixelBuffer
                                           atTime:time
                                        toFormats:localMPSFormats
                                    withTransform:transform
                                             rect:rect
                                    commandBuffer:commandBuffer
                                  completionBlock:^(BOOL didSkipFrame, id<MTLCommandBuffer> commandBuffer, SynopsisVideoFrameCache * gpuCache, NSError *err) {
                                      
                                      for(SynopsisVideoFormatSpecifier* format in localMPSFormats)
                                      {
                                          id<SynopsisVideoFrame> frame = [gpuCache cachedFrameForFormatSpecifier:format];
                                          
                                          if(frame)
                                          {
                                              [allFormatCache cacheFrame:frame];
                                          }
                                      }
                                      
                                      dispatch_group_leave(formatConversionGroup);
                                  }];
    }
    
    if(localOpenCVFormats.count)
    {
        dispatch_group_enter(formatConversionGroup);
        [self.conformCPUHelper conformPixelBuffer:pixelBuffer
                                           atTime:time
                                        toFormats:localOpenCVFormats
                                    withTransform:transform
                                             rect:rect
                                  completionBlock:^(BOOL didSkipFrame, id<MTLCommandBuffer> commandBuffer, SynopsisVideoFrameCache * cpuCache, NSError *err) {

                                      for(SynopsisVideoFormatSpecifier* format in localOpenCVFormats)
                                      {
                                          id<SynopsisVideoFrame> frame = [cpuCache cachedFrameForFormatSpecifier:format];
                                          
                                          if(frame)
                                          {
                                              [allFormatCache cacheFrame:frame];
                                          }
                                      }
                                      
                                      dispatch_group_leave(formatConversionGroup);
                                  }];
    }

    dispatch_group_leave(formatConversionGroup);
    
}


- (void) blockForPendingConforms
{
    [self.conformCPUHelper.conformQueue waitUntilAllOperationsAreFinished];
}

- (void) cancelPendingConforms
{
    [self.conformCPUHelper.conformQueue cancelAllOperations];
}


@end
