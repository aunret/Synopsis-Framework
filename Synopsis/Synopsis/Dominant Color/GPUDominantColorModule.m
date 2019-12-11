//
//  GPUDominantColorModule.m
//  Synopsis-Framework
//
//  Created by vade on 12/10/19.
//  Copyright © 2019 v002. All rights reserved.
//

#import "GPUDominantColorModule.h"
#import <CoreImage/CoreImage.h>
#import "SynopsisVideoFrameMPImage.h"
#import <CoreImage/CIRenderDestination.h>
#import <Metal/Metal.h>

// TODO Pass this in via initializer
static NSUInteger inFlightBuffers = 3;

@interface GPUDominantColorModule ()

@property (readwrite, strong) NSMutableArray<id<MTLBuffer>> *inFlightSamples;
@property (readwrite, strong) id<MTLComputePipelineState> pass1PipelineState;

@end


@implementation GPUDominantColorModule

// GPU backed modules init with an options dict for Metal Device bullshit
- (instancetype) initWithQualityHint:(SynopsisAnalysisQualityHint)qualityHint device:(id<MTLDevice>)device
{
    self = [super initWithQualityHint:qualityHint device:device];
    if(self)
    {
        NSError* error;
        
        id<MTLLibrary> defaultLibrary = [device newDefaultLibraryWithBundle:[NSBundle bundleForClass:[self class]]
                                      error:&error];
        
        id<MTLFunction> pass1Function = [defaultLibrary newFunctionWithName:@"dominantColorPass1"];
        self.pass1PipelineState = [device newComputePipelineStateWithFunction:pass1Function error:&error];

        // Samples is a buffer that stores a packed count of our colors
        NSUInteger sampleLength = sizeof(uint) * 16384;
        
        self.inFlightSamples = [NSMutableArray new];

        for (NSUInteger i = 0; i < inFlightBuffers; i++)
        {
            id<MTLBuffer> frameColorSamples = [device newBufferWithLength:sampleLength options:MTLResourceStorageModeShared];
            [self.inFlightSamples addObject: frameColorSamples];
        }
    }

    return self;
}

- (void)dealloc
{

}

- (NSString*) moduleName
{
    return kSynopsisStandardMetadataDominantColorValuesDictKey;
}

+ (SynopsisVideoBacking) requiredVideoBacking
{
    return SynopsisVideoBackingMPSImage;
}

+ (SynopsisVideoFormat) requiredVideoFormat
{
    return SynopsisVideoFormatBGR8;
}

- (void) beginAndClearCachedResults
{
}

static inFlightBufferIndex = 0;
- (void) analyzedMetadataForCurrentFrame:(id<SynopsisVideoFrame>)frame previousFrame:(id<SynopsisVideoFrame>)lastFrame commandBuffer:(id<MTLCommandBuffer>)buffer completionBlock:(GPUModuleCompletionBlock)completionBlock
{
    SynopsisVideoFrameMPImage* frameMPImage = (SynopsisVideoFrameMPImage*)frame;
    MPSImage* frameMPSImage = frameMPImage.mpsImage;

    id<MTLComputeCommandEncoder> pass1Encoder = [buffer computeCommandEncoder];
    
    [pass1Encoder setComputePipelineState:self.pass1PipelineState];

    [pass1Encoder setTexture:frameMPSImage.texture atIndex:0];

    id<MTLBuffer> currentInFlightColorSampleBuffer = self.inFlightSamples[inFlightBufferIndex];
    
    [pass1Encoder setBuffer:currentInFlightColorSampleBuffer offset:0 atIndex:1];
    
    // TODO: deduce better thread group & count numbers.
    MTLSize threadgroupSize = MTLSizeMake(16, 16, 1);
    MTLSize threadgroupCount = MTLSizeMake(1, 1, 1);
    
    // Calculate the number of rows and columns of threadgroups given the width of the input image
    // Ensure that you cover the entire image (or more) so you process every pixel
    threadgroupCount.width  = (frameMPSImage.width  + threadgroupSize.width -  1) / threadgroupSize.width;
    threadgroupCount.height = (frameMPSImage.height + threadgroupSize.height - 1);
    
    [pass1Encoder dispatchThreadgroups:threadgroupCount threadsPerThreadgroup:threadgroupSize];

    [pass1Encoder endEncoding];

    [buffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer)
    {
        NSMutableArray* used = [NSMutableArray new];
        
        // Pass 2 -
        uint* sampleData = (uint*)[currentInFlightColorSampleBuffer contents];

        for (NSUInteger i = 0; i < (16384 / 4); )
        {
            uint count = sampleData[i + 3];
            if (count)
            {
                [used addObject: @[ @(count), @(i)] ];
            }
            i += 4;
        }
        
        // Pass 3
        NSUInteger pixels = 0;
        NSUInteger numColors = MIN(10, used.count);
        NSMutableArray* colors = [NSMutableArray new];
        
        for (NSUInteger i = 0; i < numColors;)
        {
            NSUInteger count = [used[i][0] unsignedIntegerValue];
            NSUInteger index = [used[i][1] unsignedIntegerValue];

            pixels += count;

            float r = (floor(sampleData[index] / count)) / 255.0;
            float g = (floor(sampleData[index + 1] / count)) / 255.0;
            float b = (floor(sampleData[index + 2] / count)) / 255.0;

            //
            [colors addObject: @( pow(r, 1.0/2.2) )];
            [colors addObject: @( pow(g, 1.0/2.2) )];
            [colors addObject: @( pow(b, 1.0/2.2) )];

            i++;
        }
        
// TODO: What to do if we dont have enough colors ?
//        if(colors.count < 10)
//        {
//
//        }
        
        
        // Is this stupid?
        memset(sampleData, 0, 16384);
        
        inFlightBufferIndex++;
        inFlightBufferIndex = inFlightBufferIndex % inFlightBuffers;
        if (completionBlock)
        {
            completionBlock(@{ kSynopsisStandardMetadataDominantColorValuesDictKey : colors }, nil);
        }
    }];
     
     
    
    
//    SynopsisVideoFrameMPImage* frameMPImage = (SynopsisVideoFrameMPImage*)frame;
//    MPSImage* frameMPSImage = frameMPImage.mpsImage;
//    //        imageForRequest = [CIImage imageWithMTLTexture:frameMPSImage.texture options:(frameMPImage.colorSpace==nil) ? nil : @{ kCIImageColorSpace: (id) frameMPImage.colorSpace }];
//    CIImage* imageForRequest = [CIImage imageWithMTLTexture:frameMPSImage.texture options: @{ kCIImageColorSpace: (id) [NSNull null] }];
//
//
//    [self.dominantColorFilter setValue:imageForRequest forKey:@"inputImage"];
//    [self.dominantColorFilter setValue: @(imageForRequest.extent) forKey:@"inputExtent"];
//
//    CIImage* outputImage = [self.dominantColorFilter outputImage];
//
////    [buffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer)
////     {
//        CIRenderDestination* destination = [[CIRenderDestination alloc] initWithBitmapData:dominantColorArray
//                                                                                     width:10
//                                                                                    height:1
//                                                                               bytesPerRow:32 * 10
//                                                                                    format:kCIFormatRGBAf];
//
//        CIRenderTask* task = [self.context startTaskToRender:outputImage
//                                               toDestination:destination
//                                                       error:nil];
//
//        //    [task waitUntilCompletedAndReturnError:nil];
//
//        NSMutableArray<NSNumber*>* dominantColors = [NSMutableArray new];
//
//        for ( int i = 0; i < 40;)
//        {
//            float r = dominantColorArray[i];
//            float g = dominantColorArray[i + 1];
//            float b = dominantColorArray[i + 2];
//            float a = dominantColorArray[i + 3];
//
//            [dominantColors addObject: @(r)];
//            [dominantColors addObject: @(g)];
//            [dominantColors addObject: @(b)];
//            i+= 4;
//        }
//        //
//        if (completionBlock)
//        {
//            completionBlock(@{ kSynopsisStandardMetadataDominantColorValuesDictKey : dominantColors }, nil);
//        }
//
////    }];

}

- (NSDictionary*) finalizedAnalysisMetadata;
{
    return nil;
}
@end
