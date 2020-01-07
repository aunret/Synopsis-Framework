//
//  AVAsset+SynopsisMetadata.m
//  Synopsis-Framework
//
//  Created by testAdmin on 1/7/20.
//  Copyright © 2020 v002. All rights reserved.
//

#import "AVAsset+SynopsisMetadata.h"
#import "AVAssetTrack+SynopsisMetadata.h"
#import "Synopsis.h"




@implementation AVAsset (SynopsisMetadata)

- (AVAssetTrack *) synopsisMetadataTrack	{
	AVAssetTrack		*returnMe = nil;
	for (AVAssetTrack * track in self.tracks)	{
		if (![track.mediaType isEqualToString:AVMediaTypeMetadata])
			continue;
		
		if (![track isSynopsisMetadataTrack])
			continue;
		else	{
			returnMe = track;
			break;
		}
	}
	return returnMe;
}
- (NSUInteger) synopsisMetadataVersion	{
	NSUInteger			returnMe = 0;
	NSArray<AVMetadataItem*>		*items = [self metadata];
	for (AVMetadataItem *item in items)	{
		returnMe = [SynopsisMetadataDecoder metadataVersionOfMetadataItem:item];
	}
	return returnMe;
}

@end
