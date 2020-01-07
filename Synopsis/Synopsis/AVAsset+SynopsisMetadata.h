//
//  AVAsset+SynopsisMetadata.h
//  Synopsis-Framework
//
//  Created by testAdmin on 1/7/20.
//  Copyright © 2020 v002. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN




@interface AVAsset (SynopsisMetadata)

- (AVAssetTrack *) synopsisMetadataTrack;
- (NSUInteger) synopsisMetadataVersion;

@end




NS_ASSUME_NONNULL_END
