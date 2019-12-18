//
//  SynopsisMetadataEncoderVersion0.m
//  Synopsis-Framework
//
//  Created by vade on 6/20/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import "SynopsisMetadataEncoderVersion0.h"
#import <Synopsis/Synopsis.h>
#import "Synopsis-Legacy.h"
#import "GZIP.h"

@implementation SynopsisMetadataEncoderVersion0

- (AVMetadataItem*) encodeSynopsisMetadataToMetadataItem:(NSData*)metadata timeRange:(CMTimeRange)timeRange
{
    AVMutableMetadataItem *item = [AVMutableMetadataItem metadataItem];
    item.identifier = kSynopsisMetadataIdentifierLegacy;
    item.dataType = (__bridge NSString *)kCMMetadataBaseDataType_RawData;
    item.value = metadata;
    item.time = timeRange.start;
    item.duration = timeRange.duration;
    
    NSMutableDictionary* extraAttributes = [NSMutableDictionary dictionaryWithDictionary:item.extraAttributes];
    extraAttributes[AVMetadataExtraAttributeInfoKey] = @{ kSynopsisMetadataVersionKey : @(kSynopsisMetadataVersionAlpha1) };
    item.extraAttributes = extraAttributes;

    return item;
}

- (AVTimedMetadataGroup*) encodeSynopsisMetadataToTimesMetadataGroup:(NSData*)metadata timeRange:(CMTimeRange)timeRange
{
    AVMetadataItem* item = [self encodeSynopsisMetadataToMetadataItem:metadata timeRange:timeRange];
    
    AVTimedMetadataGroup *group = [[AVTimedMetadataGroup alloc] initWithItems:@[item] timeRange:timeRange];
    
    return group;
}

- (NSData*) encodeSynopsisMetadataToData:(NSData*)metadata
{
    NSData* gzipData = [metadata gzippedData];
    return gzipData;
}


@end
