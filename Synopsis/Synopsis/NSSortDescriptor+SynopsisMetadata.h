//
//  NSSortDescriptor+Synopsis_NSSortDescriptor.h
//  Synopsis-Framework
//
//  Created by vade on 8/5/16.
//  Copyright © 2016 v002. All rights reserved.
//

#include "TargetConditionals.h"
#import <Synopsis/Synopsis.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class SynopsisMetadataItem;


@interface NSSortDescriptor (SynopsisMetadata)

// Sort Metadata Items based on their similarity using the 'standard' metric for a particular metadata identifier.
+ (NSSortDescriptor*)sortViaSynopsisGlobalMetadataUsingIdentifier:(SynopsisMetadataIdentifier)identifier relativeTo:(SynopsisMetadataItem*)item;

// Sort Metadata Items based on their similarity using any framework provided metric for a particular metadata identifier.
+ (NSComparator) comparatorForSynopsisMetadataIdentifier:(SynopsisMetadataIdentifier)identifier relativeToItem:(SynopsisMetadataItem*)item withCustomSimilarityMetric:(SynopsisMetadataSimilarityMetric)metric;

@end
