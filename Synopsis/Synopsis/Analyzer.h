//
//  Analyzer.h
//  Synopsis-macOS
//
//  Created by vade on 6/20/19.
//  Copyright © 2019 v002. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SynopsisMetadataItem;

@interface Analyzer : NSObject

- (void) analyzeItem:(AVAsset*)asset destinationURL:(NSURL*)destinationURL progressHandler:(void (^)(float))progressBlock;

@end

NS_ASSUME_NONNULL_END
