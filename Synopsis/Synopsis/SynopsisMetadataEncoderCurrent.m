//
//  SynopsisMetadataEncoderVersion2.m
//  Synopsis-Framework
//
//  Created by vade on 7/21/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import "SynopsisMetadataEncoderCurrent.h"
#import "SynopsisMetadataDecoder.h"
#import <Synopsis/Synopsis.h>

#import "zstd.h"


@interface SynopsisMetadataEncoderCurrent ()
{
    ZSTD_CCtx* compressionContext;
}
@end

@implementation SynopsisMetadataEncoderCurrent

- (instancetype) init
{
    self = [super init];
    if(self)
    {
        compressionContext = nil;
        
        compressionContext = ZSTD_createCCtx();
        
        if(compressionContext == nil)
        {
            return nil;
        }
#if defined(ZSTD_MULTITHREAD)
        ZSTD_CCtx_setParameter(compressionContext, ZSTD_p_nbWorkers, 2);
#endif
        
    }
    return self;
}

- (void) dealloc
{
    if(compressionContext != nil)
    {
        ZSTD_freeCCtx(compressionContext);
        compressionContext = nil;
    }
}


- (AVMetadataItem*) encodeSynopsisMetadataToMetadataItem:(NSData*)metadata timeRange:(CMTimeRange)timeRange
{
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.identifier = kSynopsisMetadataIdentifier;
    item.dataType = (__bridge NSString *)kCMMetadataBaseDataType_RawData;
    item.value = metadata;
    item.time = kCMTimeInvalid;//timeRange.start;
    item.duration = kCMTimeInvalid;//timeRange.duration;
    item.startDate = nil;
        
    // See https://github.com/Synopsis/Synopsis-Framework/issues/30 ?
    NSMutableDictionary<AVMetadataExtraAttributeKey, id> * extraAttributes = [NSMutableDictionary dictionaryWithDictionary:item.extraAttributes];
    extraAttributes[AVMetadataExtraAttributeInfoKey] = @{ kSynopsisMetadataVersionKey : @(kSynopsisMetadataVersionCurrent) };
    item.extraAttributes = extraAttributes;
        
    return item;
}

- (AVTimedMetadataGroup*) encodeSynopsisMetadataToTimedMetadataGroup:(NSData*)metadata timeRange:(CMTimeRange)timeRange
{
    AVMetadataItem* item = [self encodeSynopsisMetadataToMetadataItem:metadata timeRange:timeRange];
    
    AVTimedMetadataGroup *group = [[AVTimedMetadataGroup alloc] initWithItems:@[item] timeRange:timeRange];
    
    return group;
}

- (NSData*) encodeSynopsisMetadataToData:(NSData*)metadata
{
    const size_t expectedCompressionSize = ZSTD_compressBound(metadata.length);
    
    UInt8* compressionBuffer = malloc(expectedCompressionSize);

    size_t const compressedSize = ZSTD_compressCCtx(compressionContext, compressionBuffer, expectedCompressionSize, metadata.bytes, (size_t) metadata.length, 1);
    
    // Hit error on compression use ZSTD_getErrorName for error reporting eventually.
    if(ZSTD_isError(compressedSize))
    {
        free(compressionBuffer);
        return nil;
    }
    
    NSData* zstdCompressedData = [[NSData alloc] initWithBytesNoCopy:compressionBuffer length:compressedSize freeWhenDone:YES];
    
    return zstdCompressedData;
}

@end
