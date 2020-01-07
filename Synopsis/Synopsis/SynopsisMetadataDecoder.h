//
//  SynopsisMetadataDecoder.h
//  Synopsis-Framework
//
//  Created by vade on 4/12/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>


@interface SynopsisMetadataDecoder : NSObject

+ (NSUInteger) metadataVersionOfMetadataItem:(AVMetadataItem*)metadataItem;

- (instancetype) initWithMetadataItem:(AVMetadataItem*)metadataItem;
- (instancetype) initWithVersion:(NSUInteger)version;
- (id) decodeSynopsisMetadata:(AVMetadataItem*)metadataItem;

@property (readonly) NSUInteger version;
@property (readwrite, assign) BOOL vendOptimizedMetadata;

@end
