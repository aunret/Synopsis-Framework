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

// The characteristic of the media the metadata represents
// Global metadata is an average (or similar) consolidation of all per sample metadata
typedef NS_ENUM(NSUInteger, SynopsisMetadataType) {

    // Rarely used outside of internal API
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

// Return the internal private string for our metadata dictionaries
NSString* SynopsisKeyForMetadataType(SynopsisMetadataType type);
NSString* SynopsisKeyForMetadataIdentifier(SynopsisMetadataIdentifier identifier);

NSArray* SynopsisSupportedFileTypes(void);

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
