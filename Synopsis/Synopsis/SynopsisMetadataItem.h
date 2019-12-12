//
//  SynopsisMetadataItem.h
//  Synopslight
//
//  Created by vade on 7/28/16.
//  Copyright © 2016 v002. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class SynopsisMetadataDecoder;
@class SynopsisMetadataItem;



typedef void(^SynopsisMetadataItemCompletionHandler)(SynopsisMetadataItem *completedItem);




// Thin wrapper for NSMetadataItem to implement Key Value access to HFS + Extended attribute's (which Synopsis Can leverage)




@interface SynopsisMetadataItem : NSObject<NSCopying>

- (instancetype) initWithURL:(NSURL *)url;
//- (instancetype) initWithAsset:(AVAsset *)asset;


- (instancetype) initWithURL:(NSURL *)url loadMetadataAsyncOnQueue:(dispatch_queue_t)q completionHandler:(SynopsisMetadataItemCompletionHandler)ch;

@property (readonly) NSURL* url;
@property (readonly) AVAsset* asset;
@property (readonly) BOOL loaded;

// Re-use this during playback if you can!
@property (readonly) SynopsisMetadataDecoder* decoder;

@end
