//
//  SynopsisVideoFrameConformHelperGPU.m
//  Synopsis-Framework
//
//  Created by vade on 10/24/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import "SynopsisVideoFrameConformHelperGPU.h"
#import "SynopsisVideoFrameMPImage.h"

#import <CoreImage/CoreImage.h>
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>
#import <Metal/Metal.h>
#import <CoreVideo/CVMetalTexture.h>
#import <CoreVideo/CVMetalTextureCache.h>

@interface SynopsisVideoFrameConformHelperGPU ()

@property (readwrite, strong) CIContext* ciContext;

@property (readwrite, strong, atomic) dispatch_queue_t serialCompletionQueue;
@property (readwrite, strong) id<MTLCommandQueue>commandQueue;

//@property (readwrite, atomic, assign) NSUInteger frameSubmit;
//@property (readwrite, atomic, assign) NSUInteger frameComplete;

@end

@implementation SynopsisVideoFrameConformHelperGPU
- (instancetype) initWithCommandQueue:(id<MTLCommandQueue>)queue inFlightBuffers:(NSUInteger)bufferCount;

{
    self = [super init];
    if(self)
    {
        self.commandQueue = queue;
        self.serialCompletionQueue = dispatch_queue_create("info.synopsis.gpu.conformQueue", DISPATCH_QUEUE_SERIAL);
        
        self.ciContext = [CIContext contextWithMTLDevice:self.commandQueue.device];
    }
    
    return self;
}


- (void) conformPixelBuffer:(CVPixelBufferRef)pixelBuffer
                     atTime:(CMTime)time
                  toFormats:(NSArray<SynopsisVideoFormatSpecifier*>*)formatSpecifiers
              withTransform:(CGAffineTransform)transform
                       rect:(CGRect)destinationRect
              commandBuffer:(id<MTLCommandBuffer>)commandBuffer
            completionBlock:(SynopsisVideoFrameConformSessionCompletionBlock)completionBlock;
{

    id<MTLCommandBuffer> conformBuffer = self.commandQueue.commandBuffer;

    CVPixelBufferRetain(pixelBuffer);
    
    CIImage* inputImage = [CIImage imageWithCVImageBuffer:pixelBuffer];
    
    CIImage* transformedImage = [inputImage imageByApplyingTransform:transform];
    
    CGFloat originalWidth = transformedImage.extent.size.width;
    CGFloat originalHeight = transformedImage.extent.size.height;
    
    CGFloat scaleX = originalWidth/destinationRect.size.width;
    CGFloat scaleY = originalHeight/destinationRect.size.height;

    transformedImage = [transformedImage imageByApplyingTransform:CGAffineTransformMakeScale(1.0/scaleX, 1.0/scaleY)];
    
    size_t width = transformedImage.extent.size.width;
    size_t height = transformedImage.extent.size.height;

    MTLTextureDescriptor* descriptor = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm width:width height:height mipmapped:NO];
    descriptor.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderWrite | MTLTextureUsageShaderRead;
    
    id<MTLTexture> texture = [self.commandQueue.device newTextureWithDescriptor:descriptor];

    CIRenderDestination* renderDestination = [[CIRenderDestination alloc] initWithMTLTexture:texture commandBuffer:conformBuffer];
    
    CGColorSpaceRef linear = CGColorSpaceCreateWithName(kCGColorSpaceExtendedLinearSRGB);
    renderDestination.colorSpace = linear;
    CGColorSpaceRelease(linear);
    
    [self.ciContext startTaskToRender:transformedImage toDestination:renderDestination error:nil];

    MPSImage* image = [[MPSImage alloc] initWithTexture:texture featureChannels:3];
    
    [conformBuffer addScheduledHandler:^(id<MTLCommandBuffer> conformBuffer) {
    
        dispatch_async(self.serialCompletionQueue, ^{
            if(completionBlock)
            {
                //                self.frameComplete++;
                //                NSLog(@"Conform Completed frame %lu", frameComplete);
                SynopsisVideoFrameCache* cache = [[SynopsisVideoFrameCache alloc] init];
                SynopsisVideoFormatSpecifier* resultFormat = [[SynopsisVideoFormatSpecifier alloc] initWithFormat:SynopsisVideoFormatBGR8 backing:SynopsisVideoBackingMPSImage];
                SynopsisVideoFrameMPImage* result = [[SynopsisVideoFrameMPImage alloc] initWithMPSImage:image formatSpecifier:resultFormat presentationTimeStamp:time];
                
                [cache cacheFrame:result];
                
                completionBlock(commandBuffer, cache, nil);
                
                // We always have to release our pixel buffer
                CVPixelBufferRelease(pixelBuffer);
            }
        });
        
    }];

    [conformBuffer commit];

}


@end
