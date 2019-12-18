//
//  SynopsisMetadataEncoder-Private.h
//  Synopsis-Framework
//
//  Created by vade on 12/18/19.
//  Copyright © 2019 v002. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

// Internal Metadata Codec Protocol

@protocol SynopsisMetadataDecoder <NSObject>
- (id) decodeSynopsisMetadata:(AVMetadataItem*)metadataItem;
- (id) decodeSynopsisData:(NSData*) data;
@property (readwrite, assign) BOOL vendOptimizedMetadata;
@end

@protocol SynopsisVersionedMetadataEncoder <NSObject>
- (AVTimedMetadataGroup*) encodeSynopsisMetadataToTimedMetadataGroup:(NSData*)metadata timeRange:(CMTimeRange)timeRange;
- (AVMetadataItem*) encodeSynopsisMetadataToMetadataItem:(NSData*)metadata timeRange:(CMTimeRange)timeRange;
- (NSData*) encodeSynopsisMetadataToData:(NSData*)metadata;
@end

