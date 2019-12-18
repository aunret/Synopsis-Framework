//
//  Synopsis-Legacy.m
//  Synopsis-macOS
//
//  Created by vade on 12/16/19.
//  Copyright © 2019 v002. All rights reserved.
//

#import "Synopsis-Legacy.h"

NSString* const kSynopsisMetadataIdentifierLegacy = @"mdta/info.synopsis.metadata";
NSString* const kSynopsisMetadataVersionKeyLegacy = @"info.synopsis.metadata.version";


NSString* const kSynopsisStandardMetadataDictKey = @"StandardMetadata";
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
