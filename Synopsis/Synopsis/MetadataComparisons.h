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


typedef NS_ENUM(NSUInteger, SynopsisMetadataSimilarityMetric) {

    SynopsisMetadataSimilarityMetricCosine = 0,
    SynopsisMetadataSimilarityMetricInverseL1,
    SynopsisMetadataSimilarityMetricInverseL2,
    SynopsisMetadataSimilarityMetricInverseL2Squared,
    // Hisrogram Similarity - see cv::HistCompMethods::HISTCMP_BHATTACHARYYA
    SynopsisMetadataSimilarityMetricBhattacharyya,
    
    // Todo: DTW
    // Todo: CIEDeltaE
};



#ifdef __cplusplus


extern "C" {
#endif

float compareFeaturesWithMetric(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2, SynopsisMetadataSimilarityMetric metric);



// Compare Similarity of two feature vectors.
// Must have the same metadataKey and length
float compareFeaturesCosineSimilarity(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2);
float compareFeatureVectorInverseL1(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2);
float compareFeatureVectorInverseL2(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2);
float compareFeatureVectorInverseL2Squared(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2);
float compareHistogtams(SynopsisDenseFeature* hist1Mat, SynopsisDenseFeature* hist2Mat);

// For time series - this object wraps internal dynamic time warping C++ filter class
// This class should be initialized with a time domain feature you wish to compare other features to
// See NSSortDescriptor+SynopsisMetadataItem

@interface DTWFilterWrapper : NSObject
- (instancetype) initWithFeature:(SynopsisDenseFeature*)feature;
@end

float compareFeatureVectorDTW(DTWFilterWrapper* filterFromFeatureToCompareAgainst, SynopsisDenseFeature* featureVec);

// For Binary / UINT8 features only.
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
