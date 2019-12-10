//
//  MetadataComparisons.h
//  Synopsis-Framework
//
//  Created by vade on 8/6/16.
//  Copyright © 2016 v002. All rights reserved.
//

#ifndef MetadataComparisons_h
#define MetadataComparisons_h

#import <Foundation/Foundation.h>

@class SynopsisDenseFeature;

#ifdef __cplusplus
extern "C" {
#endif

// Compare Similarity of two feature vectors.
// Must have the same metadataKey and length
float compareFeaturesCosineSimilarity(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2);
float compareFeatureVectorInverseL1(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2);
float compareFeatureVectorInverseL2(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2);
float compareFeatureVectorInverseL2Squared(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2);
float compareHistogtams(SynopsisDenseFeature* hist1Mat, SynopsisDenseFeature* hist2Mat);
float compareFeatureVectorHamming(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2);

//
float compareDominantColorsRGB(NSArray* colors1, NSArray* colors2);
float compareDominantColorsHSB(NSArray* colors1, NSArray* colors2);
    
// Independent weights
float weightHueDominantColors(NSArray* colors);
float weightSaturationDominantColors(NSArray* colors);
float weightBrightnessDominantColors(NSArray* colors);
    
#ifdef __cplusplus
}
#endif

#endif /* MetadataComparisons_h */
