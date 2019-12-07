//
//  Synopsis.h
//  Synopsis
//
//  Created by vade on 8/5/16.
//  Copyright © 2016 v002. All rights reserved.
//



#include "TargetConditionals.h"
#import <Foundation/Foundation.h>

#define SYNOPSIS_VERSION_MAJOR 0
#define SYNOPSIS_VERSION_MINOR 0
#define SYNOPSIS_VERSION_PATCH 10

#define SYNOPSIS_VERSION_NUMBER  ((SYNOPSIS_VERSION_MAJOR * 100 * 100) + (SYNOPSIS_VERSION_MINOR * 100) + SYNOPSIS_VERSION_PATCH)
#define SYNOPSIS_LIB_VERSION SYNOPSIS_VERSION_MAJOR.SYNOPSIS_VERSION_MINOR.SYNOPSIS_VERSION_PATCH

// Identifier Synopsis for AVMetadataItems
extern NSString* const kSynopsisMetadataIdentifier;
extern NSString* const kSynopsisMetadataVersionKey;
extern NSUInteger const kSynopsisMetadataVersionValue;

// Major Metadata versions : 
extern NSUInteger const kSynopsisMetadataVersionAlpha3;
extern NSUInteger const kSynopsisMetadataVersionAlpha2;
extern NSUInteger const kSynopsisMetadataVersionAlpha1;
extern NSUInteger const kSynopsisMetadataVersionPreAlpha;

// HFS+ Extended Attribute tag for Spotlight search
// Version Key / Dict
extern NSString* const kSynopsisMetadataHFSAttributeVersionKey;
extern NSUInteger const kSynopsisMetadataHFSAttributeVersionValue;
extern NSString* const kSynopsisMetadataHFSAttributeDescriptorKey;

// The primary key found in both time based (per frame) and summary / global metadata dictionaries
extern NSString* const kSynopsisStandardMetadataDictKey;

// Feature Vector of primary embedding space
extern NSString* const kSynopsisStandardMetadataFeatureVectorDictKey;//
extern NSString* const kSynopsisStandardMetadataInterestingFeaturesAndTimesDictKey;

// An array of scores/probabilities - one per class label or attribute
extern NSString* const kSynopsisStandardMetadataProbabilitiesDictKey;
extern NSString* const kSynopsisStandardMetadataInterestingProbabilitiesAndTimesDictKey;

// For Global Dict, this is the human readable tags that we have confidence exist in the movie
// These are taken from the labels associated with the highest confident values for each concept category
// In kSynopsisStandardMetadataProbabilitiesDictKey.

extern NSString* const kSynopsisStandardMetadataDescriptionDictKey;

// RGB histogram, exists per frame and globally.
extern NSString* const kSynopsisStandardMetadataHistogramDictKey;

//
extern NSString* const kSynopsisStandardMetadataDominantColorValuesDictKey;

// Deprecated??
DEPRECATED_ATTRIBUTE extern NSString* const kSynopsisStandardMetadataAttentionDictKey;
DEPRECATED_ATTRIBUTE extern NSString* const kSynopsisStandardMetadataInterestingAttentionAndTimesDictKey;


//DEPRECATED_ATTRIBUTE extern NSString* const kSynopsisStandardMetadataLabelsDictKey;
DEPRECATED_ATTRIBUTE extern NSString* const kSynopsisStandardMetadataScoreDictKey;
DEPRECATED_ATTRIBUTE extern NSString* const kSynopsisStandardMetadataMotionDictKey;
DEPRECATED_ATTRIBUTE extern NSString* const kSynopsisStandardMetadataMotionVectorDictKey;
DEPRECATED_ATTRIBUTE extern NSString* const kSynopsisStandardMetadataSaliencyDictKey;
DEPRECATED_ATTRIBUTE extern NSString* const kSynopsisStandardMetadataTrackerDictKey;

DEPRECATED_ATTRIBUTE extern NSString* const kSynopsisStandardMetadataPerceptualHashDictKey;

// Rough amount of overhead a particular plugin or module has
// For example very very taxing
typedef enum : NSUInteger {
    SynopsisAnalysisOverheadNone = 0,
    SynopsisAnalysisOverheadLow,
    SynopsisAnalysisOverheadMedium,
    SynopsisAnalysisOverheadHigh,
} SynopsisAnalysisOverhead;


// Should a plugin have configurable quality settings
// Hint the plugin to use a specific quality hint
typedef enum : NSUInteger {
    SynopsisAnalysisQualityHintLow,
    SynopsisAnalysisQualityHintMedium,
    SynopsisAnalysisQualityHintHigh,
    // No downsampling
    SynopsisAnalysisQualityHintOriginal = NSUIntegerMax,
} SynopsisAnalysisQualityHint;

#import <Synopsis/SynopsisVideoFrame.h>
#import <Synopsis/SynopsisVideoFrameCache.h>
#import <Synopsis/SynopsisVideoFrameConformSession.h>
#import <Synopsis/SynopsisDenseFeature.h>
#import <Synopsis/MetadataComparisons.h>

// Spotlight, Metadata, Sorting and Filtering Objects


#ifndef DECODER_ONLY
#import <Synopsis/Analyzer.h>
#import <Synopsis/AnalyzerPluginProtocol.h>
#import <Synopsis/StandardAnalyzerPlugin.h>
#endif

#define ZSTD_STATIC_LINKING_ONLY
#define ZSTD_MULTITHREAD

#ifndef DECODER_ONLY
#import <Synopsis/SynopsisMetadataEncoder.h>
#endif

#import <Synopsis/SynopsisMetadataDecoder.h>
#import <Synopsis/SynopsisMetadataItem.h>
#import <Synopsis/SynopsisMetadataPushDelegate.h>
#import <Synopsis/NSSortDescriptor+SynopsisMetadata.h>
#import <Synopsis/NSPredicate+SynopsisMetadata.h>

// UI
#import <Synopsis/SynopsisLayer.h>
#import <Synopsis/SynopsisDominantColorLayer.h>
#import <Synopsis/SynopsisHistogramLayer.h>
#import <Synopsis/SynopsisDenseFeatureLayer.h>

// Utilities
NSArray* SynopsisSupportedFileTypes(void);
#import <Synopsis/SynopsisCache.h>
#import <Synopsis/Color+linearRGBColor.h>

#if TARGET_OS_OSX
// Method to check support files types for metadata introspection
#import <Synopsis/SynopsisDirectoryWatcher.h>
#import <Synopsis/SynopsisRemoteFileHelper.h>
#import <Synopsis/SynopsisPythonHelper.h>
#endif
