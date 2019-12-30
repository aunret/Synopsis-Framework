//
//  MetadataComparisons.m
//  Synopsis-Framework
//
//  Created by vade on 8/6/16.
//  Copyright © 2016 v002. All rights reserved.
//

#import "dtw.h"
#import <opencv2/opencv.hpp>

#import "SynopsisDenseFeature+Private.h"

#import "MetadataComparisons.h"


#import "Color+linearRGBColor.h"


/*
static inline NSString* toBinaryRepresentation(unsigned long long value)
{
    long nibbleCount = sizeof(value) * 2;
    NSMutableString *bitString = [NSMutableString stringWithCapacity:nibbleCount * 5];
    
    for (long index = 4 * nibbleCount - 1; index >= 0; index--)
    {
        [bitString appendFormat:@"%i", value & ((long)1 << index) ? 1 : 0];
    }
    
    return bitString;
}
*/
static inline float cosineSimilarity(const cv::Mat a, const cv::Mat b)
{
    float ab = a.dot(b);
    float da = cv::norm(a);
    float db = cv::norm(b);
    
    float sim = (ab / (da * db));
    
    if (isnan(sim))
        return 1.0;
    
    return sim;
}

static inline float inverseL1Distance(const cv::Mat a, const cv::Mat b)
{
    return  1.0 - cv::norm(a, b, cv::NORM_L1 | cv::NORM_RELATIVE);
}

static inline float inverseL2Distance(const cv::Mat a, const cv::Mat b)
{
    float d = cv::norm(a, b, cv::NORM_L2 | cv::NORM_RELATIVE);
    return  1.0 - d;
}

static inline float inverseL2SQRDistance(const cv::Mat a, const cv::Mat b)
{
    float d = cv::norm(a, b, cv::NORM_L2SQR | cv::NORM_RELATIVE);
    
    return  1.0 - d;
}

static inline float inverseHamming(const cv::Mat a, const cv::Mat b)
{
    float d = cv::norm(a, b, cv::NORM_HAMMING | cv::NORM_RELATIVE);
    
    return  1.0 - d;
}

float compareFeaturesWithMetric(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2, SynopsisMetadataSimilarityMetric metric)
{
    switch (metric)
    {
        case SynopsisMetadataSimilarityMetricCosine:
            return compareFeaturesCosineSimilarity(featureVec1, featureVec2);

        case SynopsisMetadataSimilarityMetricInverseL1:
            return compareFeatureVectorInverseL1(featureVec1, featureVec2);

        case SynopsisMetadataSimilarityMetricInverseL2:
            return compareFeatureVectorInverseL2(featureVec1, featureVec2);

        case SynopsisMetadataSimilarityMetricInverseL2Squared:
            return compareFeatureVectorInverseL2Squared(featureVec1, featureVec2);

        case SynopsisMetadataSimilarityMetricBhattacharyya:
            return compareHistogtams(featureVec1, featureVec2);
    }
}

static inline  BOOL earlyBailOnFeatureCompare(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2)
{
    // If our features are nil, then early bail with 0 similarity
    if(!featureVec1 || ! featureVec2)
        return TRUE;
    
    // if our features dont represent the same key, early bail with 0 similarity
    if( [featureVec1.metadataKey isNotEqualTo:featureVec2.metadataKey] )
        return TRUE;
    
    // If our features are exist but dont have compariable results early bail with 0 similarity
    if(featureVec1.featureCount != featureVec2.featureCount)
        return TRUE;
    
    return FALSE;
}



float compareFeaturesCosineSimilarity(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2)
{
   if (earlyBailOnFeatureCompare(featureVec1,featureVec2))
       return 0.0;
    
    @autoreleasepool
    {
        const cv::Mat vec1 = [featureVec1 cvMatValue];
        const cv::Mat vec2 = [featureVec2 cvMatValue];

        float s = cosineSimilarity(vec1, vec2);
        
        return s;
    }
}

float compareFeatureVectorInverseL1(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2)
{
    if (earlyBailOnFeatureCompare(featureVec1,featureVec2))
        return 0.0;

    @autoreleasepool
    {
        const cv::Mat vec1 = [featureVec1 cvMatValue];
        const cv::Mat vec2 = [featureVec2 cvMatValue];
        
        float s = inverseL1Distance(vec1, vec2);
        
        return s;
    }
}

float compareFeatureVectorInverseL2(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2)
{
    if (earlyBailOnFeatureCompare(featureVec1,featureVec2))
        return 0.0;

    @autoreleasepool
    {
        const cv::Mat vec1 = [featureVec1 cvMatValue];
        const cv::Mat vec2 = [featureVec2 cvMatValue];
        
        float s = inverseL2Distance(vec1, vec2);
        
        return s;
    }
}

float compareFeatureVectorInverseL2Squared(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2)
{
    if (earlyBailOnFeatureCompare(featureVec1,featureVec2))
        return 0.0;

    @autoreleasepool
    {
        const cv::Mat vec1 = [featureVec1 cvMatValue];
        const cv::Mat vec2 = [featureVec2 cvMatValue];
        
        float s = inverseL2SQRDistance(vec1, vec2);
        
        return s;
    }
}

float compareHistogtams(SynopsisDenseFeature* hist1Feature, SynopsisDenseFeature* hist2Feature)
{
      if (earlyBailOnFeatureCompare(hist1Feature, hist2Feature))
        return 0.0;


    @autoreleasepool
    {
//             HISTCMP_CHISQR_ALT is for texture comparison - which seems useful for us here?
//             Looks like HISTCMP_CORREL is better ?

        float dR = (float) cv::compareHist([hist1Feature cvMatValue], [hist2Feature cvMatValue], cv::HistCompMethods::HISTCMP_BHATTACHARYYA);
        if( isnan(dR))
            dR = 1.0;

        return 1.0 - dR;
        
//        // Does cosineSimilarity do anything similar to HistComp?
//        // Not quite? Worth checking again
//        float dR = cosineSimilarity([hist1Feature cvMatValue],  [hist2Feature cvMatValue]);
//
//        if( isnan(dR))
//            dR = 1.0;
//
//        return dR;
    }
}

float compareFeatureVectorHamming(SynopsisDenseFeature* featureVec1, SynopsisDenseFeature* featureVec2)
{
    if (earlyBailOnFeatureCompare(featureVec1,featureVec2))
        return 0.0;

    @autoreleasepool
    {
        const cv::Mat vec1 = [featureVec1 cvMatValue];
        const cv::Mat vec2 = [featureVec2 cvMatValue];
        
        float s = inverseHamming(vec1, vec2);
        
        return s;
    }
}

@interface DTWFilterWrapper ()
{
    LB_Improved* filter;
}
@end

@implementation DTWFilterWrapper 
- (instancetype) initWithFeature:(SynopsisDenseFeature*)featureVector
{
    self = [super init];
    if(self)
    {
        // we first need to initialize a filter on our featureVector of vector::floats
        const cv::Mat feature = [featureVector cvMatValue];
        
        const vector<float> featureAsVector(feature.begin<float>(), feature.end<float>());

        self->filter = new LB_Improved(featureAsVector, (int) ( [featureVector featureCount] / 20)); // we use the DTW with a tolerance of 10% (size/10)
    }
    return self;
}

- (LB_Improved*) filter;
{
    return self->filter;
}

- (void) dealloc
{
    if (filter != NULL)
    {
        delete filter;
        filter = NULL;
    }
}
@end


float compareFeatureVectorDTW(DTWFilterWrapper* filterFromFeatureToCompareAgainst, SynopsisDenseFeature* featureVec)
{
//    if (earlyBailOnFeatureCompare(featureVec1,featureVec2))
//        return 0.0;

    LB_Improved* filter =  [filterFromFeatureToCompareAgainst filter];
    
    @autoreleasepool
    {
        const cv::Mat feature = [featureVec cvMatValue];
        
        const vector<float>featureAsVector(feature.begin<float>(), feature.end<float>());

        double sim1 = filter->justlb( featureAsVector );
        
        return 1.0/sim1;
    }
}


//// kind of dumb - maybe we represent our hashes as numbers? whatever
//float compareGlobalHashes(NSString* hash1, NSString* hash2)
//{
//    if(hash1.length != hash2.length)
//        return 0.0;
//
//    // Split our strings into 4 64 bit ints each.
//    // has looks like int64_t-int64_t-int64_t-int64_t-
//    @autoreleasepool
//    {
//        NSArray* hash1Strings = [hash1 componentsSeparatedByString:@"-"];
//        NSArray* hash2Strings = [hash2 componentsSeparatedByString:@"-"];
//
//        //    Assert(hash1Strings.count == hash2Strings.count, @"Unable to match Hash Counts");
//        //    NSString* allBinaryResult = @"";
//
//        float percentPerHash[4] = {0.0, 0.0, 0.0, 0.0};
//
//        for(NSUInteger i = 0; i < hash1Strings.count; i++)
//        {
//            NSString* hash1String = hash1Strings[i];
//            NSString* hash2String = hash2Strings[i];
//
//            NSScanner *scanner1 = [NSScanner scannerWithString:hash1String];
//            unsigned long long result1 = 0;
//            [scanner1 setScanLocation:0]; // bypass '#' character
//            [scanner1 scanHexLongLong:&result1];
//
//            NSScanner *scanner2 = [NSScanner scannerWithString:hash2String];
//            unsigned long long result2 = 0;
//            [scanner2 setScanLocation:0]; // bypass '#' character
//            [scanner2 scanHexLongLong:&result2];
//
//            unsigned long long result = result1 ^ result2;
//
//            NSString* resultAsBinaryString = toBinaryRepresentation(result);
//
//            NSUInteger characterCount = [[resultAsBinaryString componentsSeparatedByString:@"1"] count] - 1;
//
//            float percent = ((64.0 - characterCount) * 100.0) / 64.0;
//
//            percentPerHash[i] = percent / 100.0;
//        }
//
//        float totalPercent = percentPerHash[0] + percentPerHash[1] + percentPerHash[2] + percentPerHash[3];
//
//        totalPercent *= 0.25;
//
//        return totalPercent;
//
//        // Euclidean distance between vector of correlation of each hash?
//
//        //    return sqrtf( ( percentPerHash[0] * percentPerHash[0] ) + ( percentPerHash[1] * percentPerHash[1] ) + ( percentPerHash[2] * percentPerHash[2] ) + ( percentPerHash[3] * percentPerHash[3] ) );
//    }
//}

//float compareFrameHashes(NSString* hash1, NSString* hash2)
//{
//    if(hash1.length != hash2.length)
//        return 0.0;
//
//    @autoreleasepool
//    {
//        NSScanner *scanner1 = [NSScanner scannerWithString:hash1];
//        unsigned long long result1 = 0;
//        [scanner1 setScanLocation:0]; // bypass '#' character
//        [scanner1 scanHexLongLong:&result1];
//
//        NSScanner *scanner2 = [NSScanner scannerWithString:hash2];
//        unsigned long long result2 = 0;
//        [scanner2 setScanLocation:0]; // bypass '#' character
//        [scanner2 scanHexLongLong:&result2];
//
//        unsigned long long result = result1 ^ result2;
//
//        NSString* resultAsBinaryString = toBinaryRepresentation(result);
//
//        NSUInteger characterCount = [[resultAsBinaryString componentsSeparatedByString:@"1"] count] - 1;
//
//        float percent = ((64.0 - characterCount) * 100.0) / 64.0;
//
//        return (percent / 100.0);
//    }
//}

float compareDominantColorsRGB(NSArray* colors1, NSArray* colors2)
{
    if(colors1.count != colors2.count)
        return 0.0;
    
    @autoreleasepool
    {
        cv::Mat dominantColors1 = cv::Mat( (int) colors1.count, 3, CV_32FC1);
        cv::Mat dominantColors2 = cv::Mat( (int) colors2.count, 3, CV_32FC1);
        
        for(int i = 0; i < colors1.count; i++)
        {
            CGColorRef rgbColor1 = (__bridge CGColorRef)colors1[i];
            CGColorRef rgbColor2 = (__bridge CGColorRef)colors2[i];
            
            const CGFloat* components1 = CGColorGetComponents(rgbColor1);
            const CGFloat* components2 = CGColorGetComponents(rgbColor2);
            
            dominantColors1.at<float>(i,0) = (float)components1[0];
            dominantColors1.at<float>(i,1) = (float)components1[1];
            dominantColors1.at<float>(i,2) = (float)components1[2];
            
            dominantColors2.at<float>(i,0) = (float)components2[0];
            dominantColors2.at<float>(i,1) = (float)components2[1];
            dominantColors2.at<float>(i,2) = (float)components2[2];
        }

        float sim = cosineSimilarity(dominantColors1, dominantColors2);
        
        dominantColors1.release();
        dominantColors2.release();
        
        return sim;
    }
}

float compareDominantColorsHSB(NSArray* colors1, NSArray* colors2)
{
    if(colors1.count != colors2.count)
        return 0.0;

    @autoreleasepool
    {
        cv::Mat dominantColors1 = cv::Mat( (int) colors1.count, 3, CV_32FC1);
        cv::Mat dominantColors2 = cv::Mat( (int) colors1.count, 3, CV_32FC1);
        cv::Mat hsvDominantColors1 = cv::Mat( (int) colors1.count, 3, CV_32FC1);
        cv::Mat hsvDominantColors2 = cv::Mat( (int) colors1.count, 3, CV_32FC1);
        
        for(int i = 0; i < colors1.count; i++)
        {
            CGColorRef rgbColor1 = (__bridge CGColorRef)colors1[i];
            CGColorRef rgbColor2 = (__bridge CGColorRef)colors2[i];
            
            const CGFloat* components1 = CGColorGetComponents(rgbColor1);
            const CGFloat* components2 = CGColorGetComponents(rgbColor2);
            
            dominantColors1.at<float>(i,0) = (float)components1[0];
            dominantColors1.at<float>(i,1) = (float)components1[1];
            dominantColors1.at<float>(i,2) = (float)components1[2];
            
            dominantColors2.at<float>(i,0) = (float)components2[0];
            dominantColors2.at<float>(i,1) = (float)components2[1];
            dominantColors2.at<float>(i,2) = (float)components2[2];
        }
        
        // Convert our mats to HSV
        cv::cvtColor(dominantColors1, hsvDominantColors1, cv::COLOR_RGB2HSV);
        cv::cvtColor(dominantColors2, hsvDominantColors2, cv::COLOR_RGB2HSV);
        
        dominantColors1.release();
        dominantColors2.release();
        
        float sim = cosineSimilarity(hsvDominantColors1, hsvDominantColors2);

        hsvDominantColors1.release();
        hsvDominantColors2.release();
        
        return sim;
    }
}

float weightHueDominantColors(NSArray* colors)
{
    CGFloat sum = 0;
    
    for (id colorObj in colors)
    {
    	CGColorRef color = (__bridge CGColorRef)colorObj;
    	float tmpComps[] = { 0., 0., 0., 1. };
        const CGFloat *colorComps = CGColorGetComponents(color);
        
        int max = fminl(4,CGColorGetNumberOfComponents(color));
        for (int i = 0; i < max; ++i)
        {
    		tmpComps[i] = *(colorComps + i);
    	}
    	
        [ColorHelper convertRGBtoHSVFloat:tmpComps];
    	sum += (tmpComps[0]) / 360.0;
    }

    sum /= colors.count;
    return sum;

}

float weightSaturationDominantColors(NSArray* colors)
{
    CGFloat sum = 0;
    
    for (id colorObj in colors)
    {
    	CGColorRef color = (__bridge CGColorRef)colorObj;
    	float tmpComps[] = { 0., 0., 0., 1. };
    	const CGFloat *colorComps = CGColorGetComponents(color);
        
        int max = fminl(4,CGColorGetNumberOfComponents(color));
    	for (int i = 0; i < max; ++i)
        {
    		tmpComps[i] = *(colorComps + i);
    	}
        
    	[ColorHelper convertRGBtoHSVFloat:tmpComps];
    	sum += tmpComps[1];
    }
    
    sum /= colors.count;
    return sum;
}

float weightBrightnessDominantColors(NSArray* colors)
{
	CGFloat sum = 0;
    
	for (id colorObj in colors)
    {
    	CGColorRef color = (__bridge CGColorRef)colorObj;
    	float tmpComps[] = { 0., 0., 0., 1. };
    	const CGFloat *colorComps = CGColorGetComponents(color);
        
        int max = fminl(4,CGColorGetNumberOfComponents(color));
        for (int i = 0; i < max; ++i)
        {
    		tmpComps[i] = *(colorComps + i);
    	}
        
    	[ColorHelper convertRGBtoHSVFloat:tmpComps];
    	sum += tmpComps[2];
    }
    
    sum /= colors.count;
    return sum;
}


