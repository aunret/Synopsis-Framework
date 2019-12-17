//
//  Synopsis-Legacy.h
//  Synopsis-Framework
//
//  Created by vade on 12/16/19.
//  Copyright © 2019 v002. All rights reserved.
//

#include "TargetConditionals.h"
#import <Foundation/Foundation.h>


// The primary key found in both time based (per frame) and summary / global metadata dictionaries

extern NSString* const kSynopsisStandardMetadataDictKey;

// Global Only Keys
extern NSString* const kSynopsisStandardMetadataDescriptionDictKey;

// Global features:
//Time domain signature of inter frame similarities of per frame features below:
extern NSString* const kSynopsisStandardMetadataSimilarityFeatureVectorDictKey; // ImageNet embedding features differences per frame
extern NSString* const kSynopsisStandardMetadataSimilarityProbabilitiesDictKey; // CinemaNet predicted probablities differences per frame
extern NSString* const kSynopsisStandardMetadataSimilarityDominantColorValuesDictKey; // CinemaNet predicted dominant colors differences per frame

// Global and Per Frame frame features
extern NSString* const kSynopsisStandardMetadataFeatureVectorDictKey; // ImageNet embedding features - per frame / global average
extern NSString* const kSynopsisStandardMetadataProbabilitiesDictKey; // CinemaNet predicted probablities - per frame / global average
extern NSString* const kSynopsisStandardMetadataDominantColorValuesDictKey; // CinemaNet predicted dominant colors - per frame / global average
extern NSString* const kSynopsisStandardMetadataHistogramDictKey; // Cinemanet
