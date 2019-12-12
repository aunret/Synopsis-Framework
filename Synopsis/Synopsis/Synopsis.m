//
//  Synopsis.m
//  Synopsis-Framework
//
//  Created by vade on 8/5/16.
//  Copyright © 2016 v002. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Synopsis.h"

// Top Level Metadata key for AVFoundation used in both Summary (global) and per frame metadata
// See AVMetdataItem.h / AVMetdataIdentifier.h
NSString* const kSynopsisMetadataIdentifier = @"mdta/info.synopsis.metadata";
NSString* const kSynopsisMetadataVersionKey = @"info.synopsis.metadata.version";
NSUInteger const kSynopsisMetadataVersionValue = SYNOPSIS_VERSION_NUMBER;

NSUInteger const kSynopsisMetadataVersionAlpha3 = 3;
NSUInteger const kSynopsisMetadataVersionAlpha2 = 2;
NSUInteger const kSynopsisMetadataVersionAlpha1 = 1;
NSUInteger const kSynopsisMetadataVersionPreAlpha = 0;

// HFS+ Extended attribute keys and values
NSString* const kSynopsisMetadataHFSAttributeVersionKey = @"info_synopsis_version";
NSUInteger const kSynopsisMetadataHFSAttributeVersionValue = SYNOPSIS_VERSION_NUMBER;
NSString* const kSynopsisMetadataHFSAttributeDescriptorKey = @"info_synopsis_descriptors";

// Sort keys can't use reverse dns due to Cocoa assumption of object hierarchy travelsal by '.'
NSString* const kSynopsisMetadataIdentifierSortKey = @"mdta_info_synopsis_metadata";

// TODO: Should be Standard Analyzer no?

NSString* const kSynopsisStandardMetadataDictKey = @"StandardMetadata";
//NSString* const kSynopsisStandardMetadataSortKey = @"info_synopsis_standardanalyzer";

// Keys for standard modules:

// Global Only Keys
NSString* const kSynopsisStandardMetadataDescriptionDictKey = @"Description"; // Global Only, no per frame strings of predicted tags
// A time domain signature of inter frame similarities of per frame features below:
NSString* const kSynopsisStandardMetadataSimilarityFeatureVectorDictKey = @"FeatureSimilrity"; // ImageNet embedding features differences per frame
NSString* const kSynopsisStandardMetadataSimilarityProbabilitiesDictKey = @"ProbabilitySimilarity"; // CinemaNet predicted probablities differences per frame
NSString* const kSynopsisStandardMetadataSimilarityDominantColorValuesDictKey = @"DominantColorSimilarity"; // CinemaNet predicted dominant colors differences per frame

// Per frame features, as well
NSString* const kSynopsisStandardMetadataFeatureVectorDictKey = @"Features"; // ImageNet embedding features - per frame / global average
NSString* const kSynopsisStandardMetadataProbabilitiesDictKey = @"Probabilities"; // CinemaNet predicted probablities - per frame / global average
NSString* const kSynopsisStandardMetadataDominantColorValuesDictKey = @"DominantColors"; // CinemaNet predicted dominant colors - per frame / global average
NSString* const kSynopsisStandardMetadataHistogramDictKey = @"Histogram"; // Cinemanet

// Not currently in use:
//NSString* const kSynopsisStandardMetadataMotionDictKey = @"Motion";
//NSString* const kSynopsisStandardMetadataMotionVectorDictKey = @"MotionVector";
//NSString* const kSynopsisStandardMetadataSaliencyDictKey = @"Saliency";
//NSString* const kSynopsisStandardMetadataTrackerDictKey = @"Tracker";
//
//
//NSString* const kSynopsisStandardMetadataAttentionDictKey = @"Attention";
//NSString* const kSynopsisStandardMetadataInterestingAttentionAndTimesDictKey = @"InterestingAttentionAndTimes";
//
//NSString* const kSynopsisStandardMetadataLabelsDictKey = @"Labels";

//NSString* const kSynopsisStandardMetadataFeatureVectorSortKey = @"info_synopsis_features";
//NSString* const kSynopsisStandardMetadataDominantColorValuesSortKey = @"info_synopsis_dominant_colors";
//NSString* const kSynopsisStandardMetadataHistogramSortKey = @"info_synopsis_histogram";
//NSString* const kSynopsisStandardMetadataMotionSortKey = @"info_synopsis_motion";
//NSString* const kSynopsisStandardMetadataSaliencySorttKey = @"info_synopsis_saliency";
//NSString* const kSynopsisStandardMetadataDescriptionSortKey = @"info_synopsis_description";

DEPRECATED_ATTRIBUTE NSString* const kSynopsisStandardMetadataPerceptualHashDictKey = @"PerceptualHash";
//DEPRECATED_ATTRIBUTE NSString* const kSynopsisStandardMetadataPerceptualHashSortKey = @"info_synopsis_perceptual_hash";

NSArray* SynopsisSupportedFileTypes(void)
{

#if TARGET_OS_OSX

    NSString * mxfUTI = (NSString *)CFBridgingRelease(UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                                                            (CFStringRef)@"MXF",
                                                                                            NULL));
    
    NSArray* types = [[AVMovie movieTypes] arrayByAddingObject:mxfUTI];
    return types;

#else

    return [AVURLAsset audiovisualTypes];

#endif
}

