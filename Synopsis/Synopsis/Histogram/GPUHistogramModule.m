//
//  MPSHistogramModule.m
//  Synopsis-Framework
//
//  Created by vade on 10/25/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import "GPUHistogramModule.h"
#import "SynopsisVideoFrameMPImage.h"
#import "Synopsis-Private.h"

@interface GPUHistogramModule ()
@property (readwrite, strong) MPSImageHistogram* histogramOp;
@property (readwrite, assign) MPSImageHistogramInfo* histogramInfo;

@property (readwrite, strong) SynopsisDenseFeature* averageRHistogram;
@property (readwrite, strong) SynopsisDenseFeature* averageGHistogram;
@property (readwrite, strong) SynopsisDenseFeature* averageBHistogram;
@property (readwrite, assign) NSUInteger frameCount;

@end

#define kGPUHistogramModuleHistogramSize 256

@implementation GPUHistogramModule

// GPU backed modules init with an options dict for Metal Device bullshit
- (instancetype) initWithQualityHint:(SynopsisAnalysisQualityHint)qualityHint device:(id<MTLDevice>)device
{
    self = [super initWithQualityHint:qualityHint device:device];
    if(self)
    {
        self.histogramInfo = malloc(sizeof(MPSImageHistogramInfo));
        
        vector_float4 max = {1, 1, 1, 1};
        vector_float4 min = {0, 0, 0, 0};
        self.histogramInfo->numberOfHistogramEntries = kGPUHistogramModuleHistogramSize;
        self.histogramInfo->maxPixelValue = max;
        self.histogramInfo->minPixelValue = min;
        self.histogramInfo->histogramForAlpha = NO;
    
        self.histogramOp = [[MPSImageHistogram alloc] initWithDevice:device histogramInfo:self.histogramInfo];
    }
    return self;
}

- (void)dealloc
{
    if(self.histogramInfo)
        free(self.histogramInfo);
}

- (NSString*) moduleName
{
    return kSynopsisMetadataIdentifierVisualHistogram;
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
    self.averageRHistogram = nil;
    self.averageGHistogram = nil;
    self.averageBHistogram = nil;

    self.frameCount = 0;
}

- (void) analyzedMetadataForCurrentFrame:(id<SynopsisVideoFrame>)frame previousFrame:(id<SynopsisVideoFrame>)lastFrame commandBuffer:(id<MTLCommandBuffer>)buffer completionBlock:(GPUModuleCompletionBlock)completionBlock;
{
    SynopsisVideoFrameMPImage* frameMPImage = (SynopsisVideoFrameMPImage*)frame;
    
    id<MTLBuffer> histogramResult = [buffer.device newBufferWithLength:[self.histogramOp histogramSizeForSourceFormat:MTLPixelFormatBGRA8Unorm] options:MTLResourceStorageModeShared];
        
    [self.histogramOp encodeToCommandBuffer:buffer
                              sourceTexture:frameMPImage.mpsImage.texture
                                  histogram:histogramResult
                            histogramOffset:0];
    
    [buffer addCompletedHandler:^(id<MTLCommandBuffer> commandBuffer)
     {
         //specifically dispatch work away from encode thread - so we dont block enqueueing new work
         // by reading old work and doing dumb math
         dispatch_async(self.completionQueue, ^{
             
             self.frameCount++;

             
             NSMutableArray<NSNumber*>* frameRHistogram = [NSMutableArray arrayWithCapacity:kGPUHistogramModuleHistogramSize];
             NSMutableArray<NSNumber*>* frameGHistogram = [NSMutableArray arrayWithCapacity:kGPUHistogramModuleHistogramSize];
             NSMutableArray<NSNumber*>* frameBHistogram = [NSMutableArray arrayWithCapacity:kGPUHistogramModuleHistogramSize];

             NSMutableArray<NSArray<NSNumber*>*>* histoGramTuples = [NSMutableArray arrayWithCapacity:kGPUHistogramModuleHistogramSize];

             
             uint32_t* start = [histogramResult contents];
             NSUInteger buffLength = [histogramResult length];
                          
             size_t uint32tsize = sizeof(uint32_t);
             
             // 4 bytes for uint32tsize typically
             buffLength = buffLength / uint32tsize;
             
             //3 Channels
             buffLength = buffLength / 3;
             
             assert(buffLength == kGPUHistogramModuleHistogramSize);
             
             float rMax = 0.0;
             float gMax = 0.0;
             float bMax = 0.0;

             for(int i = 0; i < buffLength; i++)
             {
                 // Planar histogram offsets?
                 uint32_t rUI = start[i];
                 uint32_t gUI = start[i + 256];
                 uint32_t bUI = start[i + 512];
                 
                 float r = (float)rUI;
                 float g = (float)gUI;
                 float b = (float)bUI;

                 rMax = MAX(r, rMax);
                 gMax = MAX(g, gMax);
                 bMax = MAX(b, bMax);
                                  
                 [frameRHistogram addObject: @(r)];
                 [frameGHistogram addObject: @(g)];
                 [frameBHistogram addObject: @(b)];
             }

             for(int i = 0; i < buffLength; i++)
             {
                 frameRHistogram[i] = @( frameRHistogram[i].floatValue / rMax );
                 frameGHistogram[i] = @( frameGHistogram[i].floatValue / gMax );
                 frameBHistogram[i] = @( frameBHistogram[i].floatValue / bMax );
             }
             
             if(self.averageRHistogram == nil)
             {
                 self.averageRHistogram = [[SynopsisDenseFeature alloc] initWithFeatureArray:frameRHistogram forMetadataKey:@"AvgR"];
             }
             else
             {
                  self.averageRHistogram = [SynopsisDenseFeature denseFeatureByCumulativeMovingAveragingCurrentFeature:[[SynopsisDenseFeature alloc] initWithFeatureArray:frameRHistogram forMetadataKey:@"AvgR"] previousAverage:self.averageRHistogram sampleCount:self.frameCount];

                 
//                 self.averageRHistogram = [SynopsisDenseFeature denseFeatureByAveragingFeature:self.averageRHistogram withFeature:];
             }
             
             if(self.averageGHistogram == nil)
             {
                 self.averageGHistogram = [[SynopsisDenseFeature alloc] initWithFeatureArray:frameGHistogram forMetadataKey:@"AvgG"];
             }
             else
             {
                 self.averageGHistogram = [SynopsisDenseFeature denseFeatureByCumulativeMovingAveragingCurrentFeature:[[SynopsisDenseFeature alloc] initWithFeatureArray:frameGHistogram forMetadataKey:@"AvgG"] previousAverage:self.averageGHistogram sampleCount:self.frameCount];
             }
             
            if(self.averageBHistogram == nil)
            {
              self.averageBHistogram = [[SynopsisDenseFeature alloc] initWithFeatureArray:frameBHistogram forMetadataKey:@"AvgB"];
            }
            else
            {
                self.averageBHistogram = [SynopsisDenseFeature denseFeatureByCumulativeMovingAveragingCurrentFeature:[[SynopsisDenseFeature alloc] initWithFeatureArray:frameBHistogram forMetadataKey:@"AvgB"] previousAverage:self.averageBHistogram sampleCount:self.frameCount];            }
             
            for(int i = 0; i < buffLength; i++)
            {
                [histoGramTuples addObject: @[ frameRHistogram[i], frameGHistogram[i], frameBHistogram[i] ] ];
            }
            
            if(completionBlock)
            {
                completionBlock( @{[self moduleName] : histoGramTuples} , nil);
            }
         });
     }];
}


- (NSDictionary*) finalizedAnalysisMetadata;
{
    
    NSArray<NSNumber*>* rHistogram = self.averageRHistogram.arrayValue;
    NSArray<NSNumber*>* gHistogram = self.averageGHistogram.arrayValue;
    NSArray<NSNumber*>* bHistogram = self.averageBHistogram.arrayValue;

    NSMutableArray<NSArray<NSNumber*>*>* histoGramTuples = [NSMutableArray arrayWithCapacity:kGPUHistogramModuleHistogramSize];
	
	if (rHistogram != nil && gHistogram != nil && bHistogram != nil)
	{
		for(int i = 0; i < kGPUHistogramModuleHistogramSize; i++)
		{
			[histoGramTuples addObject: @[ rHistogram[i], gHistogram[i], bHistogram[i] ] ];
		}
    }
    
    return @{[self moduleName] : histoGramTuples};
}

@end

