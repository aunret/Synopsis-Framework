//
//  NSSortDescriptor+Synopsis_NSSortDescriptor.m
//  Synopsis-Framework
//
//  Created by vade on 8/5/16.
//  Copyright © 2016 v002. All rights reserved.
//

// import our time domain warping header first due to C++ BS

#import "SynopsisMetadataItem.h"
#import "SynopsisDenseFeature.h"
#import "SynopsisDenseFeature+Private.h"
#import "MetadataComparisons.h"

#import "NSSortDescriptor+SynopsisMetadata.h"
#import "Color+linearRGBColor.h"
#import <CoreGraphics/CoreGraphics.h>


@implementation NSSortDescriptor (SynopsisMetadata)

//this should be synopsisSortViaIdentifier:(SynopsisMetadataIdentifier)identifier
//pull out the key via SynopsisKeyForMetadataIdentifier and cache the function pointer for the besty metric for the identifier.
//

+ (NSSortDescriptor*)sortViaSynopsisMetadataIdentifier:(SynopsisMetadataIdentifier)identifier relativeTo:(SynopsisMetadataItem*)item
{
//    NSString* key = SynopsisKeyForMetadataIdentifier(identifier);
    NSString* key = @"asdf";
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {

        SynopsisDenseFeature* vec1 = (SynopsisDenseFeature*) obj1;
        SynopsisDenseFeature* vec2 = (SynopsisDenseFeature*) obj2;

        SynopsisDenseFeature* relative = [item valueForKey:key];

        float distance1 = compareFeaturesCosineSimilarity(vec1, relative);
        float distance2 = compareFeaturesCosineSimilarity(vec2, relative);

        if(distance1 > distance2)
            return  NSOrderedAscending;
        if(distance1 < distance2)
            return NSOrderedDescending;

        return NSOrderedSame;

    }];

    return sortDescriptor;
}


//+ (NSSortDescriptor*)synopsisSortViaKey:(NSString*)key relativeTo:(SynopsisMetadataItem*)item
//{
//    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//
//        SynopsisDenseFeature* vec1 = (SynopsisDenseFeature*) obj1;
//        SynopsisDenseFeature* vec2 = (SynopsisDenseFeature*) obj2;
//
//        SynopsisDenseFeature* relative = [item valueForKey:key];
//
//        float distance1 = compareFeaturesCosineSimilarity(vec1, relative);
//        float distance2 = compareFeaturesCosineSimilarity(vec2, relative);
//
//        if(distance1 > distance2)
//            return  NSOrderedAscending;
//        if(distance1 < distance2)
//            return NSOrderedDescending;
//
//        return NSOrderedSame;
//
//    }];
//
//    return sortDescriptor;
//}
//
//+ (NSSortDescriptor*)synopsisBestMatchSortDescriptorRelativeTo:(NSDictionary*)standardMetadata
//{
//    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//
//        NSDictionary* global1 = (NSDictionary*)obj1;
//        NSDictionary* global2 = (NSDictionary*)obj2;
//
//        __block float distance1 = FLT_MAX;
//        __block float distance2 = FLT_MAX;
//
//        SynopsisDenseFeature* probabilityVec1 = [global1 valueForKey:kSynopsisStandardMetadataProbabilitiesDictKey];
//        SynopsisDenseFeature* probabilityVec2 = [global2 valueForKey:kSynopsisStandardMetadataProbabilitiesDictKey];
//        SynopsisDenseFeature* relativeProb = [standardMetadata valueForKey:kSynopsisStandardMetadataProbabilitiesDictKey];
//
//        SynopsisDenseFeature* featureVec1 = [global1 valueForKey:kSynopsisStandardMetadataFeatureVectorDictKey];
//        SynopsisDenseFeature* featureVec2 = [global2 valueForKey:kSynopsisStandardMetadataFeatureVectorDictKey];
//        SynopsisDenseFeature* relativeVec = [standardMetadata valueForKey:kSynopsisStandardMetadataFeatureVectorDictKey];
//
//        SynopsisDenseFeature* hist1 = [global1 valueForKey:kSynopsisStandardMetadataFeatureVectorDictKey];
//        SynopsisDenseFeature* hist2 = [global2 valueForKey:kSynopsisStandardMetadataFeatureVectorDictKey];
//        SynopsisDenseFeature* relativeHist = [standardMetadata valueForKey:kSynopsisStandardMetadataFeatureVectorDictKey];
//
//        // if we have everything, contatenate the vectors
//        if( probabilityVec1 && probabilityVec2 && relativeProb
//           && featureVec1 && featureVec2 && relativeVec
//           && hist1 && hist2 && relativeHist)
//        {
//            SynopsisDenseFeature* concat1 = [SynopsisDenseFeature denseFeatureByAppendingFeature:featureVec1 withFeature:[SynopsisDenseFeature denseFeatureByAppendingFeature:probabilityVec1 withFeature:hist1]];
//
//            SynopsisDenseFeature* concat2 = [SynopsisDenseFeature denseFeatureByAppendingFeature:featureVec2 withFeature:[SynopsisDenseFeature denseFeatureByAppendingFeature:probabilityVec2 withFeature:hist2]];
//
//            SynopsisDenseFeature* relative = [SynopsisDenseFeature denseFeatureByAppendingFeature:relativeVec withFeature:[SynopsisDenseFeature denseFeatureByAppendingFeature:relativeProb withFeature:relativeHist]];
//
//            distance1 = compareFeaturesCosineSimilarity(concat1, relative);
//            distance2 = compareFeaturesCosineSimilarity(concat2, relative);
//
////            SynopsisDenseFeature* concat1 = [SynopsisDenseFeature denseFeatureByAppendingFeature:featureVec1 withFeature:probabilityVec1];
////            SynopsisDenseFeature* concat2 = [SynopsisDenseFeature denseFeatureByAppendingFeature:featureVec2 withFeature:probabilityVec2];
////            SynopsisDenseFeature* relative = [SynopsisDenseFeature denseFeatureByAppendingFeature:relativeVec withFeature:[SynopsisDenseFeature denseFeatureByAppendingFeature:relativeVec withFeature:relativeHist]];
////
////            distance1 = compareFeatureVector(concat1, relative);
////            distance2 = compareFeatureVector(concat2, relative);
//        }
//
//
//        // Parellelize sorting math
//        //        dispatch_group_t sortGroup = dispatch_group_create();
//
//        else if(probabilityVec1 && probabilityVec2 && relativeProb)
//        {
//            //        dispatch_group_enter(sortGroup);
//            //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            distance1 = compareFeaturesCosineSimilarity(probabilityVec1, relativeProb);
//            distance2 = compareFeaturesCosineSimilarity(probabilityVec2, relativeProb);
//
//            //            dispatch_group_leave(sortGroup);
//            //        });
//        }
//        else
//        {
//
//            //            dispatch_group_enter(sortGroup);
//            //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
//            distance1 = compareFeaturesCosineSimilarity(featureVec1, relativeVec);
//            distance2 = compareFeaturesCosineSimilarity(featureVec2, relativeVec);
//            //                dispatch_group_leave(sortGroup);
//            //            });
//        }
//
////         dispatch_wait(sortGroup, DISPATCH_TIME_FOREVER)
//
//
//        if(distance1 > distance2)
//            return  NSOrderedAscending;
//        if(distance1 < distance2)
//            return NSOrderedDescending;
//
//        return NSOrderedSame;
//    }];
//
//    return sortDescriptor;
//}
//
//+ (NSSortDescriptor*)synopsisFeatureSortDescriptorRelativeTo:(SynopsisDenseFeature*)featureVector
//{
//    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataFeatureVectorDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//
//        SynopsisDenseFeature* fVec1 = (SynopsisDenseFeature*) obj1;
//        SynopsisDenseFeature* fVec2 = (SynopsisDenseFeature*) obj2;
//
//        float percent1 = compareFeaturesCosineSimilarity(fVec1, featureVector);
//        float percent2 = compareFeaturesCosineSimilarity(fVec2, featureVector);
//
//        if(percent1 > percent2)
//            return  NSOrderedAscending;
//        if(percent1 < percent2)
//            return NSOrderedDescending;
//
//        return NSOrderedSame;
//    }];
//
//    return sortDescriptor;
//}
//
//+ (NSSortDescriptor*)synopsisDynamicTimeWarpFeatureSortDescriptorRelativeTo:(SynopsisDenseFeature*)featureVector
//{
//    DTWFilterWrapper* dtwWrapper = [[DTWFilterWrapper alloc] initWithFeature:featureVector];
//
//    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataSimilarityFeatureVectorDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//
//        SynopsisDenseFeature* fVec1 = (SynopsisDenseFeature*) obj1;
//        SynopsisDenseFeature* fVec2 = (SynopsisDenseFeature*) obj2;
//
//        float cost1 = compareFeatureVectorDTW(dtwWrapper, fVec1);
//        float cost2 = compareFeatureVectorDTW(dtwWrapper, fVec2);
//
//        if(cost1 > cost2)
//            return  NSOrderedAscending;
//        if(cost1 < cost2)
//            return NSOrderedDescending;
//
//        return NSOrderedSame;
//    }];
//
//    return sortDescriptor;
//}
//
////+ (NSSortDescriptor*)synopsisHashSortDescriptorRelativeTo:(NSString*)relativeHash
////{
////    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataPerceptualHashDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
////
////        NSString* hash1 = (NSString*) obj1;
////        NSString* hash2 = (NSString*) obj2;
////
////        float percent1 = compareGlobalHashes(hash1, relativeHash);
////        float percent2 = compareGlobalHashes(hash2, relativeHash);
////
////        if(percent1 > percent2)
////        return  NSOrderedAscending;
////        if(percent1 < percent2)
////        return NSOrderedDescending;
////
////        return NSOrderedSame;
////    }];
////
////    return sortDescriptor;
////}
//
//+ (NSSortDescriptor*)synopsisDominantRGBDescriptorRelativeTo:(NSArray*)colors
//{
//    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataDominantColorValuesDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//
//        NSArray* color1 = (NSArray*) obj1;
//        NSArray* color2 = (NSArray*) obj2;
//
//		NSSortDescriptor	*tmpSD = [NSSortDescriptor synopsisColorHueSortDescriptor];
//		NSSortDescriptor	*hueSD = [NSSortDescriptor sortDescriptorWithKey:nil ascending:[tmpSD ascending] comparator:[tmpSD comparator]];
//        NSArray* acolors = [colors sortedArrayUsingDescriptors:@[hueSD]];
//        color1 = [color1 sortedArrayUsingDescriptors:@[hueSD]];
//        color2 = [color2 sortedArrayUsingDescriptors:@[hueSD]];
//
//        float		percent1 = compareDominantColorsRGB(acolors, color1);
//        float		percent2 = compareDominantColorsRGB(acolors, color2);
//
//        if(percent1 > percent2)
//            return  NSOrderedAscending;
//        if(percent1 < percent2)
//            return NSOrderedDescending;
//
//        return NSOrderedSame;
//    }];
//
//    return sortDescriptor;
//
//}
//
//+ (NSSortDescriptor*)synopsisDominantHSBDescriptorRelativeTo:(NSArray*)colors;
//{
//    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataDominantColorValuesDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//
//        NSArray* color1 = (NSArray*) obj1;
//        NSArray* color2 = (NSArray*) obj2;
//
//        float percent1 = compareDominantColorsHSB(colors, color1);
//        float percent2 = compareDominantColorsHSB(colors, color2);
//
//        if(percent1 > percent2)
//            return  NSOrderedAscending;
//        if(percent1 < percent2)
//            return NSOrderedDescending;
//
//        return NSOrderedSame;
//    }];
//
//    return sortDescriptor;
//}
//
//// See which two objects are closest to the relativeHash
////+ (NSSortDescriptor*)synopsisMotionVectorSortDescriptorRelativeTo:(SynopsisDenseFeature*)motionVector;
////{
////    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataMotionVectorDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
////
////        SynopsisDenseFeature* hist1 = (SynopsisDenseFeature*) obj1;
////        SynopsisDenseFeature* hist2 = (SynopsisDenseFeature*) obj2;
////
////        float percent1 = fabsf(compareFeatureVector(hist1, motionVector));
////        float percent2 = fabsf(compareFeatureVector(hist2, motionVector));
////
////        if(percent1 > percent2)
////            return  NSOrderedAscending;
////        if(percent1 < percent2)
////            return NSOrderedDescending;
////
////        return NSOrderedSame;
////    }];
////
////    return sortDescriptor;
////}
////
////+ (NSSortDescriptor*)synopsisMotionSortDescriptorRelativeTo:(NSNumber*)motion
////{
////    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataMotionDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
////
////        NSNumber* motion1 = (NSNumber*) obj1;
////        NSNumber* motion2 = (NSNumber*) obj2;
////
////        float diff1 = fabsf([motion1 floatValue] - [motion floatValue]);
////        float diff2 = fabsf([motion2 floatValue] - [motion floatValue]);
////
////        if(diff2 > diff1)
////        return  NSOrderedAscending;
////        if(diff2 < diff1)
////        return NSOrderedDescending;
////
////        return NSOrderedSame;
////    }];
////
////    return sortDescriptor;
////}
//
//
//
//+ (NSSortDescriptor*)synopsisHistogramSortDescriptorRelativeTo:(SynopsisDenseFeature*)histogram
//{
//    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataHistogramDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//
//        SynopsisDenseFeature* hist1 = (SynopsisDenseFeature*) obj1;
//        SynopsisDenseFeature* hist2 = (SynopsisDenseFeature*) obj2;
//
//        float percent1 = compareHistogtams(hist1, histogram);
//        float percent2 = compareHistogtams(hist2, histogram);
//
//        if(percent1 > percent2)
//            return  NSOrderedAscending;
//        if(percent1 < percent2)
//            return NSOrderedDescending;
//
//        return NSOrderedSame;
//    }];
//
//    return sortDescriptor;
//}
//
//
//+ (NSSortDescriptor*)synopsisColorCIESortDescriptorRelativeTo:(CGColorRef)color;
//{
//    [NSObject doesNotRecognizeSelector:_cmd];
//    return nil;
//}
//
//
//// TODO: Assert all colors are RGB prior to accessing components
//+ (NSSortDescriptor*)synopsisColorSaturationSortDescriptor
//{
//    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataDominantColorValuesDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//		CGFloat sum1 = weightSaturationDominantColors(@[obj1]);
//		CGFloat sum2 = weightSaturationDominantColors(@[obj2]);
//
//        if(sum1 > sum2)
//            return NSOrderedAscending;
//        if(sum1 < sum2)
//            return NSOrderedDescending;
//
//        return NSOrderedSame;
//
//    }];
//
//    return sortDescriptor;
//}
//
//+ (NSSortDescriptor*)synopsisColorHueSortDescriptor
//{
//    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataDominantColorValuesDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//
//    	CGFloat sum1 = weightHueDominantColors(@[obj1]);
//        CGFloat sum2 = weightHueDominantColors(@[obj2]);
//
//        if(sum1 > sum2)
//            return NSOrderedAscending;
//        if(sum1 < sum2)
//            return NSOrderedDescending;
//
//        return NSOrderedSame;
//    }];
//
//    return sortDescriptor;
//}
//
//+ (NSSortDescriptor*)synopsisColorBrightnessSortDescriptor
//{
//    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataDominantColorValuesDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//        CGFloat sum1 = weightBrightnessDominantColors(@[obj1]);
//		CGFloat sum2 = weightBrightnessDominantColors(@[obj2]);
//
//        if(sum1 > sum2)
//            return NSOrderedAscending;
//        if(sum1 < sum2)
//            return NSOrderedDescending;
//
//        return NSOrderedSame;
//    }];
//
//    return sortDescriptor;
//}


@end
