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
#import "Synopsis-Private.h"

// TODO Pass this in via initializer
static NSUInteger inFlightBuffers = 3;

@interface GPUDominantColorModule ()
{
    int inFlightBufferIndex;

}

@property (readwrite, strong) NSMutableArray<id<MTLBuffer>> *inFlightSamples;
@property (readwrite, strong) id<MTLComputePipelineState> pass1PipelineState;

@property (readwrite, strong) SynopsisDenseFeature* averageDominantColors;
@property (readwrite, strong) SynopsisDenseFeature* similairityDominantColors;
@property (readwrite, strong) SynopsisDenseFeature* lastFrameDominantColors;
@property (readwrite, assign) NSUInteger frameCount;

@end


@implementation GPUDominantColorModule

// GPU backed modules init with an options dict for Metal Device bullshit
- (instancetype) initWithQualityHint:(SynopsisAnalysisQualityHint)qualityHint device:(id<MTLDevice>)device
{
    self = [super initWithQualityHint:qualityHint device:device];
    if(self)
    {
        NSError* error;
        
        self->inFlightBufferIndex = 0;
        
        id<MTLLibrary> defaultLibrary = [device newDefaultLibraryWithBundle:[NSBundle bundleForClass:[self class]]
                                      error:&error];
        
        id<MTLFunction> pass1Function = [defaultLibrary newFunctionWithName:@"dominantColorPass1"];
        self.pass1PipelineState = [device newComputePipelineStateWithFunction:pass1Function error:&error];

        // Samples is a buffer that stores a packed count of our colors
        NSUInteger sampleLength = sizeof(unsigned int) * 16384;
        
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
    return kSynopsisMetadataIdentifierVisualDominantColors;
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
    self.averageDominantColors = nil;
    self.similairityDominantColors  = nil;
    self.lastFrameDominantColors  = nil;
    self.frameCount = 0;
}


- (void) analyzedMetadataForCurrentFrame:(id<SynopsisVideoFrame>)frame previousFrame:(id<SynopsisVideoFrame>)lastFrame commandBuffer:(id<MTLCommandBuffer>)buffer completionBlock:(GPUModuleCompletionBlock)completionBlock
{
    SynopsisVideoFrameMPImage* frameMPImage = (SynopsisVideoFrameMPImage*)frame;
    MPSImage* frameMPSImage = frameMPImage.mpsImage;

    id<MTLComputeCommandEncoder> pass1Encoder = [buffer computeCommandEncoder];
    
    [pass1Encoder setComputePipelineState:self.pass1PipelineState];

    [pass1Encoder setTexture:frameMPSImage.texture atIndex:0];

    id<MTLBuffer> currentInFlightColorSampleBuffer = self.inFlightSamples[inFlightBufferIndex];
    
    self->inFlightBufferIndex++;
    self->inFlightBufferIndex = self->inFlightBufferIndex % inFlightBuffers;

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
        self.frameCount++;
        
        NSMutableArray* used = [NSMutableArray new];
        
        // Pass 2 -
        unsigned int* sampleData = (unsigned int*)[currentInFlightColorSampleBuffer contents];

        for (unsigned int i = 0; i < (16384 / 4); )
        {
            unsigned int count = sampleData[i + 3];
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
        
        for (unsigned int i = 0; i < numColors;)
        {
            // Be careful to use unsigned int (32 bit sized) not unsigned integer which is an unsigned long
            NSUInteger count = [used[i][0] unsignedIntValue];
            NSUInteger index = [used[i][1] unsignedIntValue];

            pixels += count;

            float r = (floorf( (float) sampleData[index] /  (float) count)) / 255.0;
            float g = (floorf( (float) sampleData[index + 1] /  (float) count)) / 255.0;
            float b = (floorf( (float) sampleData[index + 2] /  (float) count)) / 255.0;

            [colors addObject: @( r )];
            [colors addObject: @( g )];
            [colors addObject: @( b )];

            i++;
        }
        
        // Order Colors
        
// TODO: What to do if we dont have enough colors ?
        if(colors.count < 30)
        {
            NSUInteger delta = 30 - colors.count;
            for (NSUInteger i = 0; i < delta; i++)
            {
                [colors insertObject:@( 0.0 ) atIndex:0];
            }
        }
        
        SynopsisDenseFeature* denseDominantColors = [[SynopsisDenseFeature alloc] initWithFeatureArray:colors forMetadataKey:kSynopsisMetadataIdentifierVisualDominantColors];

        if(self.averageDominantColors == nil)
        {
            self.averageDominantColors = denseDominantColors;
        }
        else
        {
            self.averageDominantColors = [SynopsisDenseFeature denseFeatureByCumulativeMovingAveragingCurrentFeature:denseDominantColors previousAverage:self.averageDominantColors sampleCount:self.frameCount];

        }

#pragma mark - Compute Similarities
        if ( denseDominantColors && self.lastFrameDominantColors )
        {
            float featureSimilarity = 1.0 - compareFeaturesCosineSimilarity(self.lastFrameDominantColors, denseDominantColors);
            
            SynopsisDenseFeature* denseSimilarity = [[SynopsisDenseFeature alloc] initWithFeatureArray:@[@(featureSimilarity)] forMetadataKey:kSynopsisMetadataIdentifierVisualDominantColors];
            
            if ( self.similairityDominantColors )
            {
                self.similairityDominantColors = [SynopsisDenseFeature denseFeatureByAppendingFeature:self.similairityDominantColors withFeature:denseSimilarity];
            }
            else
            {
                self.similairityDominantColors = denseSimilarity;
            }
        }
        
        self.lastFrameDominantColors = denseDominantColors;

        // Clear our buffer - Is this stupid?
        memset(sampleData, 0, 16384);
        
        if (completionBlock)
        {
            completionBlock(@{ kSynopsisMetadataIdentifierVisualDominantColors : colors }, nil);
        }
    }];
}

- (NSDictionary*) finalizedAnalysisMetadata;
{
        [self.similairityDominantColors resizeTo:1024];
        NSArray<NSNumber*>* similarDominantColors = [self.similairityDominantColors arrayValue];
        NSArray<NSNumber*>* averageDominantColors = [self.averageDominantColors arrayValue];
    
        return @{
                 kSynopsisMetadataIdentifierVisualDominantColors : (averageDominantColors) ? averageDominantColors : @[],
                 kSynopsisMetadataIdentifierTimeSeriesVisualDominantColors : (similarDominantColors) ? similarDominantColors : @[ ]
                 };
}
@end
