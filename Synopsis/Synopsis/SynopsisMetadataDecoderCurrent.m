//
//  SynopsisMetadataDecoderVersion2.m
//  Synopsis-Framework
//
//  Created by vade on 7/21/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import "SynopsisMetadataDecoderCurrent.h"
#import <Synopsis/Synopsis.h>
#import "Synopsis-Private.h"
#import "zstd.h"
#import "Color+linearRGBColor.h"

@interface SynopsisMetadataDecoderCurrent ()
{
    ZSTD_DCtx* decompressionContext;
}
@end

@implementation SynopsisMetadataDecoderCurrent

- (instancetype) init
{
    self = [super init];
    if(self)
    {
        decompressionContext = nil;
        
        decompressionContext = ZSTD_createDCtx();
        
        if(decompressionContext == nil)
        {
            return nil;
        }
    }
    
    return self;
}

- (void) dealloc
{
    if(decompressionContext != nil)
    {
        ZSTD_freeDCtx(decompressionContext);
    }
}


- (id) decodeSynopsisMetadata:(AVMetadataItem*)metadataItem
{
    NSString* key = metadataItem.identifier;
    
    if([key isEqualToString:kSynopsisMetadataIdentifier])
    {
        return [self decodeSynopsisData: (NSData*)metadataItem.value];
    }
    
    return nil;
}

- (id) decodeSynopsisData:(NSData*) data
{
    unsigned long long expectedDecompressedSize = ZSTD_getFrameContentSize(data.bytes, data.length);
    
    // Not compressed with zstd
    if( expectedDecompressedSize == ZSTD_CONTENTSIZE_ERROR)
    {
        return nil;
    }
    
    // unable to determine destination size
    if( expectedDecompressedSize == ZSTD_CONTENTSIZE_UNKNOWN)
    {
        return nil;
    }
    
    void* decompressionBuffer = malloc(expectedDecompressedSize);

    size_t decompressedSize = ZSTD_decompressDCtx(decompressionContext, decompressionBuffer, expectedDecompressedSize, data.bytes, data.length);
    
    // if our expected size and actual size dont match, we had a decompression issue.
    if(decompressedSize != expectedDecompressedSize)
    {
        free(decompressionBuffer);
        
        return nil;
    }
    
    NSData* decompressedData = [[NSData alloc] initWithBytesNoCopy:decompressionBuffer length:decompressedSize freeWhenDone:YES];
    
    id decodedJSON = nil;
    @try
    {
        decodedJSON  = [NSJSONSerialization JSONObjectWithData:decompressedData options:kNilOptions error:nil];
        
    }
    @catch (NSException *exception)
    {
        
        
    }
    @finally
    {
        if(decodedJSON)
        {
            if(self.vendOptimizedMetadata)
                return [self metadataWithOptimizedObjects:decodedJSON];
            else
                return decodedJSON;
        }
    }
    
    return nil;
}

- (NSDictionary*) metadataWithOptimizedObjects:(NSDictionary*)global
{
    // manually switch out our target types
    NSMutableDictionary* optimizedStandardDictionary = [NSMutableDictionary dictionaryWithDictionary:global];
    
    // Convert all arrays of NSNumbers into linear RGB NSColors once, and only once
    NSArray* colors = [optimizedStandardDictionary valueForKey:kSynopsisMetadataIdentifierVisualDominantColors];
    if(colors)
    {
        NSArray* domColors = [ColorHelper newLinearColorsWithArraysOfRGBComponents:colors];
        
        optimizedStandardDictionary[kSynopsisMetadataIdentifierVisualDominantColors] = domColors;
    }
    // Convert all feature vectors to cv::Mat, and set cv::Mat value appropriately
    NSArray* ebmeddingArray = [optimizedStandardDictionary valueForKey:kSynopsisMetadataIdentifierVisualEmbedding];
    if(ebmeddingArray)
    {
        SynopsisDenseFeature* featureValue = [[SynopsisDenseFeature alloc] initWithFeatureArray:ebmeddingArray forMetadataKey:kSynopsisMetadataIdentifierVisualEmbedding];
        
        optimizedStandardDictionary[kSynopsisMetadataIdentifierVisualEmbedding] = featureValue;
    }
    // Convert all feature vectors to cv::Mat, and set cv::Mat value appropriately
    NSArray* probabilityArray = [optimizedStandardDictionary valueForKey:kSynopsisMetadataIdentifierVisualProbabilities];
    if(probabilityArray)
    {
        SynopsisDenseFeature* probabilityValue = [[SynopsisDenseFeature alloc] initWithFeatureArray:probabilityArray forMetadataKey:kSynopsisMetadataIdentifierVisualProbabilities];
        
        optimizedStandardDictionary[kSynopsisMetadataIdentifierVisualProbabilities] = probabilityValue;
    }
    
    // Convert histogram bins to cv::Mat
    NSArray* histogramArray = [optimizedStandardDictionary valueForKey:kSynopsisMetadataIdentifierVisualHistogram];
    
    if(histogramArray != nil && histogramArray.count == 256)
    {
        // Make 3 mutable arrays for R/G/B
        // We then flatten by making planar r followed by planar g, then b to a single dimensional array
        NSMutableArray* histogramR = [NSMutableArray arrayWithCapacity:256];
        NSMutableArray* histogramG = [NSMutableArray arrayWithCapacity:256];
        NSMutableArray* histogramB = [NSMutableArray arrayWithCapacity:256];
        
        for(int i = 0; i < 256; i++)
        {
            NSArray<NSNumber *>* rgbHist = histogramArray[i];
            
            // Min / Max fixes some NAN errors
            [histogramR addObject: @( MIN(1.0, MAX(0.0,  rgbHist[0].floatValue)) )];
            [histogramG addObject: @( MIN(1.0, MAX(0.0,  rgbHist[1].floatValue)) )];
            [histogramB addObject: @( MIN(1.0, MAX(0.0,  rgbHist[2].floatValue)) )];
        }
        
        NSArray* histogramFeatures = [[[NSArray arrayWithArray:histogramR] arrayByAddingObjectsFromArray:histogramG] arrayByAddingObjectsFromArray:histogramB];
        
        SynopsisDenseFeature* histValue = [[SynopsisDenseFeature alloc] initWithFeatureArray:histogramFeatures forMetadataKey:kSynopsisMetadataIdentifierVisualHistogram];
        
        optimizedStandardDictionary[kSynopsisMetadataIdentifierVisualHistogram] = histValue;
    }
    else	{
    	NSLog(@"ERR: histogramArray only had %ld elements in %s",(unsigned long)histogramArray.count,__func__);
	}
    
    // Convert all feature vectors to cv::Mat, and set cv::Mat value appropriately
    NSArray* tsVEArray = [optimizedStandardDictionary valueForKey:kSynopsisMetadataIdentifierTimeSeriesVisualEmbedding];
    if(tsVEArray)
    {
        SynopsisDenseFeature* denseFeature = [[SynopsisDenseFeature alloc] initWithFeatureArray:tsVEArray forMetadataKey:kSynopsisMetadataIdentifierTimeSeriesVisualEmbedding];
        
        optimizedStandardDictionary[kSynopsisMetadataIdentifierTimeSeriesVisualEmbedding] = denseFeature;
    }
    
    // Convert all feature vectors to cv::Mat, and set cv::Mat value appropriately
    NSArray* tsVPArray = [optimizedStandardDictionary valueForKey:kSynopsisMetadataIdentifierTimeSeriesVisualProbabilities];
    if(tsVPArray)
    {
        SynopsisDenseFeature* denseFeature = [[SynopsisDenseFeature alloc] initWithFeatureArray:tsVPArray forMetadataKey:kSynopsisMetadataIdentifierTimeSeriesVisualProbabilities];
        
        optimizedStandardDictionary[kSynopsisMetadataIdentifierTimeSeriesVisualProbabilities] = denseFeature;
    }
    
    // Convert all feature vectors to cv::Mat, and set cv::Mat value appropriately
    NSArray* tsVHArray = [optimizedStandardDictionary valueForKey:kSynopsisMetadataIdentifierTimeSeriesVisualHistogram];
    if(tsVHArray)
    {
        SynopsisDenseFeature* denseFeature = [[SynopsisDenseFeature alloc] initWithFeatureArray:tsVHArray forMetadataKey:kSynopsisMetadataIdentifierTimeSeriesVisualHistogram];
        
        optimizedStandardDictionary[kSynopsisMetadataIdentifierTimeSeriesVisualHistogram] = denseFeature;
    }
    
    // Convert all feature vectors to cv::Mat, and set cv::Mat value appropriately
    NSArray* tsVDCArray = [optimizedStandardDictionary valueForKey:kSynopsisMetadataIdentifierTimeSeriesVisualDominantColors];
    if(tsVDCArray)
    {
        SynopsisDenseFeature* denseFeature = [[SynopsisDenseFeature alloc] initWithFeatureArray:tsVDCArray forMetadataKey:kSynopsisMetadataIdentifierTimeSeriesVisualDominantColors];
        
        optimizedStandardDictionary[kSynopsisMetadataIdentifierTimeSeriesVisualDominantColors] = denseFeature;
    }

    return optimizedStandardDictionary;
}

@end
