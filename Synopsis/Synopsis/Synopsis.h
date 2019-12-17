//
//  Synopsis.h
//  Synopsis
//
//  Created by vade on 8/5/16.
//  Copyright © 2016 v002. All rights reserved.
//



#include "TargetConditionals.h"
#import <Foundation/Foundation.h>

#define SYNOPSIS_VERSION_MAJOR 1
#define SYNOPSIS_VERSION_MINOR 0
#define SYNOPSIS_VERSION_PATCH 0

#define SYNOPSIS_VERSION_NUMBER  ((SYNOPSIS_VERSION_MAJOR * 100 * 100) + (SYNOPSIS_VERSION_MINOR * 100) + SYNOPSIS_VERSION_PATCH)
#define SYNOPSIS_LIB_VERSION SYNOPSIS_VERSION_MAJOR.SYNOPSIS_VERSION_MINOR.SYNOPSIS_VERSION_PATCH

// Identifier Synopsis for AVMetadataItems
extern NSString* const kSynopsisMetadataIdentifier;
extern NSString* const kSynopsisMetadataVersionKey;

// Current Metadata Version (for this framework)
extern NSUInteger const kSynopsisMetadataVersionValue;

// Only useful for pre public beta Analyzer and Inspector code bases
// Legacy Synopsis Metadata used a different top level domain, info, not video
// This needs to be public if folks want to test against it
extern NSString* const kSynopsisMetadataIdentifierLegacy;
extern NSString* const kSynopsisMetadataVersionKeyLegacy;


// Major Metadata versions : 
extern NSUInteger const kSynopsisMetadataVersionPrivateBeta;
extern NSUInteger const kSynopsisMetadataVersionAlpha3;
extern NSUInteger const kSynopsisMetadataVersionAlpha2;
extern NSUInteger const kSynopsisMetadataVersionAlpha1;
extern NSUInteger const kSynopsisMetadataVersionPreAlpha;

// HFS+ Extended Attribute tag for Spotlight search
// Version Key / Dict
extern NSString* const kSynopsisMetadataHFSAttributeVersionKey;
extern NSUInteger const kSynopsisMetadataHFSAttributeVersionValue;
extern NSString* const kSynopsisMetadataHFSAttributeDescriptorKey;

// For all other keys, use the Enums and functions below:

// The characteristic of the media the metadata represents
// SynopsisMetadataTypeSample refers to metadata that represents a specific sample (video frame for example).

// SynopsisMetadataTypeGlobal refers to metadata that represents an aggregate summary (Synopsis) of all sample based metadata
// How the summary is calculated is up to the specific plugin

typedef NS_ENUM(NSUInteger, SynopsisMetadataType) {

    SynopsisMetadataTypeGlobal = 0,
    SynopsisMetadataTypeSample = 1,
};

// TODO:
// Audible Metadata
// Text ??????
// ??
typedef NS_ENUM(NSUInteger, SynopsisMetadataIdentifier) {
    
    // Human readable tags from classifiers -
    // SynopsisMetadataTypeGlobal only - no SynopsisMetadataTypeFrame based metadata
    SynopsisMetadataIdentifierGlobalVisualDescription = 10,
    
    // Embedding vector based off of MobileNetV2 1.0 224 trained on ImageNet
    SynopsisMetadataIdentifierVisualEmbedding = 20,
    
    // Probabilty vector (0 - 1) for eacb class CinemaNet can predict
    SynopsisMetadataIdentifierVisualProbabilities = 30,
    
    // RGB histogram,
    SynopsisMetadataIdentifierVisualHistogram = 40,

    // 10 RGB triplets (vector of 30 elements) of the most dominant colors - ordered by luminosity
    SynopsisMetadataIdentifierVisualDominantColors = 50,
    
    
    // Time Series Identifiers
    
    // All time series identifiers are SynopsisMetadataTypeGlobal only - no SynopsisMetadataTypeFrame based metadata
    
    // A fixed length vector of frame emedding similarities
    // For every frame a similarity score of the vector SynopsisMetadataIdentifierVisualEmbedding for frame n and frame n+1 is produced
    SynopsisMetadataIdentifierTimeSeriesVisualEmbedding = 120,

    // A fixed length vector of frame probabilities similarities
    // For every frame a similarity score of the vector SynopsisMetadataIdentifierVisualProbabilities for frame n and frame n+1 is produced
    SynopsisMetadataIdentifierTimeSeriesVisualProbabilities = 130,
} ;


// Pass in a version for an appropriate key for the type or identifier
// The Version number is an NSUInteger stored in the dictionary top level under the key kSynopsisMetadataVersionKey
#ifdef __cplusplus
extern "C" {
#endif
extern NSString* SynopsisKeyForMetadataTypeVersion(SynopsisMetadataType type, NSUInteger version);
extern NSString* SynopsisKeyForMetadataIdentifierVersion(SynopsisMetadataIdentifier identifier, NSUInteger version);
extern NSArray* SynopsisSupportedFileTypes(void);
#ifdef __cplusplus
}
#endif

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
//#import <Synopsis/Analyzer.h>
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
#import <Synopsis/SynopsisCache.h>
#import <Synopsis/Color+linearRGBColor.h>

#if TARGET_OS_OSX
// Method to check support files types for metadata introspection
#import <Synopsis/SynopsisDirectoryWatcher.h>
#import <Synopsis/SynopsisRemoteFileHelper.h>
#import <Synopsis/SynopsisPythonHelper.h>
#endif
