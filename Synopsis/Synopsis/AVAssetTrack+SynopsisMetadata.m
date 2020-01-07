//
//  AVAssetTrack+SynopsisMetadata.m
//  Synopsis-Framework
//
//  Created by testAdmin on 1/7/20.
//  Copyright © 2020 v002. All rights reserved.
//

#import "AVAssetTrack+SynopsisMetadata.h"
#import "Synopsis.h"




@implementation AVAssetTrack (SynopsisMetadata)

- (BOOL) isSynopsisMetadataTrack	{
	BOOL			returnMe = NO;
	NSArray			*fmtDescs = [self formatDescriptions];
	for (int i=0; i<fmtDescs.count; ++i)	{
		CMFormatDescriptionRef		fmtDesc = (__bridge CMFormatDescriptionRef)fmtDescs[i];
		if (fmtDesc == NULL)
			continue;
		NSArray			*identifiers = CMMetadataFormatDescriptionGetIdentifiers(fmtDesc);
		if (identifiers==nil || identifiers.count<1)
			continue;
		NSString		*identifier = identifiers[0];
		if (![identifier isKindOfClass:[NSString class]] || (![identifier isEqualToString:kSynopsisMetadataIdentifier] && ![identifier isEqualToString:@"mdta/info.synopsis.metadata"]))
			continue;
		returnMe = YES;
		break;
	}
	return returnMe;
}

@end
