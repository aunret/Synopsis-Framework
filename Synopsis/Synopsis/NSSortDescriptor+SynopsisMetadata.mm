//
//  NSSortDescriptor+Synopsis_NSSortDescriptor.m
//  Synopsis-Framework
//
//  Created by vade on 8/5/16.
//  Copyright © 2016 v002. All rights reserved.
//

#import "Synopsis.h"
#import "SynopsisDenseFeature.h"
#import "MetadataComparisons.h"

#import "NSSortDescriptor+SynopsisMetadata.h"
#import "Color+linearRGBColor.h"
#import <CoreGraphics/CoreGraphics.h>


@implementation NSSortDescriptor (SynopsisMetadata)

//+ (NSSortDescriptor*)synopsisSortViaKey:(NSString*)key
//{
//
//
//}


+ (NSSortDescriptor*)synopsisBestMatchSortDescriptorRelativeTo:(NSDictionary*)standardMetadata
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        NSDictionary* global1 = (NSDictionary*)obj1;
        NSDictionary* global2 = (NSDictionary*)obj2;
        
        __block float distance1 = FLT_MAX;
        __block float distance2 = FLT_MAX;
        
        SynopsisDenseFeature* probabilityVec1 = [global1 valueForKey:kSynopsisStandardMetadataProbabilitiesDictKey];
        SynopsisDenseFeature* probabilityVec2 = [global2 valueForKey:kSynopsisStandardMetadataProbabilitiesDictKey];
        SynopsisDenseFeature* relativeProb = [standardMetadata valueForKey:kSynopsisStandardMetadataProbabilitiesDictKey];

        // Parellelize sorting math
        //        dispatch_group_t sortGroup = dispatch_group_create();

        if(probabilityVec1 && probabilityVec2 && relativeProb)
        {
            //        dispatch_group_enter(sortGroup);
            //        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            distance1 = compareFeatureVector(probabilityVec1, relativeProb);
            distance2 = compareFeatureVector(probabilityVec2, relativeProb);
            
            //            dispatch_group_leave(sortGroup);
            //        });
        }
        else
        {
            // All metadata should have this fallback yea?
            SynopsisDenseFeature* featureVec1 = [global1 valueForKey:kSynopsisStandardMetadataFeatureVectorDictKey];
            SynopsisDenseFeature* featureVec2 = [global2 valueForKey:kSynopsisStandardMetadataFeatureVectorDictKey];
            SynopsisDenseFeature* relativeVec = [standardMetadata valueForKey:kSynopsisStandardMetadataFeatureVectorDictKey];
          
            //            dispatch_group_enter(sortGroup);
            //            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            distance1 = compareFeatureVector(featureVec1, relativeVec);
            distance2 = compareFeatureVector(featureVec2, relativeVec);
            //                dispatch_group_leave(sortGroup);
            //            });
        }

//         dispatch_wait(sortGroup, DISPATCH_TIME_FOREVER)
      

        if(distance1 > distance2)
            return  NSOrderedAscending;
        if(distance1 < distance2)
            return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
    return sortDescriptor;
}

+ (NSSortDescriptor*)synopsisFeatureSortDescriptorRelativeTo:(SynopsisDenseFeature*)featureVector
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataFeatureVectorDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        SynopsisDenseFeature* fVec1 = (SynopsisDenseFeature*) obj1;
        SynopsisDenseFeature* fVec2 = (SynopsisDenseFeature*) obj2;
        
        float percent1 = compareFeatureVector(fVec1, featureVector);
        float percent2 = compareFeatureVector(fVec2, featureVector);
        
        if(percent1 > percent2)
            return  NSOrderedAscending;
        if(percent1 < percent2)
            return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
    return sortDescriptor;
}

+ (NSSortDescriptor*)synopsisHashSortDescriptorRelativeTo:(NSString*)relativeHash
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataPerceptualHashDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        NSString* hash1 = (NSString*) obj1;
        NSString* hash2 = (NSString*) obj2;
        
        float percent1 = compareGlobalHashes(hash1, relativeHash);
        float percent2 = compareGlobalHashes(hash2, relativeHash);
        
        if(percent1 > percent2)
        return  NSOrderedAscending;
        if(percent1 < percent2)
        return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
    return sortDescriptor;
}

+ (NSSortDescriptor*)synopsisDominantRGBDescriptorRelativeTo:(NSArray*)colors
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataDominantColorValuesDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        NSArray* color1 = (NSArray*) obj1;
        NSArray* color2 = (NSArray*) obj2;
        
		NSSortDescriptor	*tmpSD = [NSSortDescriptor synopsisColorHueSortDescriptor];
		NSSortDescriptor	*hueSD = [NSSortDescriptor sortDescriptorWithKey:nil ascending:[tmpSD ascending] comparator:[tmpSD comparator]];
        NSArray* acolors = [colors sortedArrayUsingDescriptors:@[hueSD]];
        color1 = [color1 sortedArrayUsingDescriptors:@[hueSD]];
        color2 = [color2 sortedArrayUsingDescriptors:@[hueSD]];
        
        float		percent1 = compareDominantColorsRGB(acolors, color1);
        float		percent2 = compareDominantColorsRGB(acolors, color2);
        
        if(percent1 > percent2)
            return  NSOrderedAscending;
        if(percent1 < percent2)
            return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
    return sortDescriptor;
 
}

+ (NSSortDescriptor*)synopsisDominantHSBDescriptorRelativeTo:(NSArray*)colors;
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataDominantColorValuesDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        NSArray* color1 = (NSArray*) obj1;
        NSArray* color2 = (NSArray*) obj2;
        
        float percent1 = compareDominantColorsHSB(colors, color1);
        float percent2 = compareDominantColorsHSB(colors, color2);
        
        if(percent1 > percent2)
            return  NSOrderedAscending;
        if(percent1 < percent2)
            return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
    return sortDescriptor;
}

// See which two objects are closest to the relativeHash
+ (NSSortDescriptor*)synopsisMotionVectorSortDescriptorRelativeTo:(SynopsisDenseFeature*)motionVector;
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataMotionVectorDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        SynopsisDenseFeature* hist1 = (SynopsisDenseFeature*) obj1;
        SynopsisDenseFeature* hist2 = (SynopsisDenseFeature*) obj2;
        
        float percent1 = fabsf(compareFeatureVector(hist1, motionVector));
        float percent2 = fabsf(compareFeatureVector(hist2, motionVector));
        
        if(percent1 > percent2)
            return  NSOrderedAscending;
        if(percent1 < percent2)
            return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
    return sortDescriptor;
}

+ (NSSortDescriptor*)synopsisMotionSortDescriptorRelativeTo:(NSNumber*)motion
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataMotionDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        NSNumber* motion1 = (NSNumber*) obj1;
        NSNumber* motion2 = (NSNumber*) obj2;
        
        float diff1 = fabsf([motion1 floatValue] - [motion floatValue]);
        float diff2 = fabsf([motion2 floatValue] - [motion floatValue]);
        
        if(diff2 > diff1)
        return  NSOrderedAscending;
        if(diff2 < diff1)
        return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
    return sortDescriptor;
}



+ (NSSortDescriptor*)synopsisHistogramSortDescriptorRelativeTo:(SynopsisDenseFeature*)histogram
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataHistogramDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        
        SynopsisDenseFeature* hist1 = (SynopsisDenseFeature*) obj1;
        SynopsisDenseFeature* hist2 = (SynopsisDenseFeature*) obj2;
        
        float percent1 = compareHistogtams(hist1, histogram);
        float percent2 = compareHistogtams(hist2, histogram);
        
        if(percent1 > percent2)
            return  NSOrderedAscending;
        if(percent1 < percent2)
            return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
    return sortDescriptor;
}


+ (NSSortDescriptor*)synopsisColorCIESortDescriptorRelativeTo:(CGColorRef)color;
{
    [NSObject doesNotRecognizeSelector:_cmd];
    return nil;
}


// TODO: Assert all colors are RGB prior to accessing components
+ (NSSortDescriptor*)synopsisColorSaturationSortDescriptor
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataDominantColorValuesDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
		CGFloat sum1 = weightSaturationDominantColors(@[obj1]);
		CGFloat sum2 = weightSaturationDominantColors(@[obj2]);
		
        if(sum1 > sum2)
            return NSOrderedAscending;
        if(sum1 < sum2)
            return NSOrderedDescending;
        
        return NSOrderedSame;

    }];
    
    return sortDescriptor;
}

+ (NSSortDescriptor*)synopsisColorHueSortDescriptor
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataDominantColorValuesDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
    	
    	CGFloat sum1 = weightHueDominantColors(@[obj1]);
        CGFloat sum2 = weightHueDominantColors(@[obj2]);
    	
        if(sum1 > sum2)
            return NSOrderedAscending;
        if(sum1 < sum2)
            return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
    return sortDescriptor;
}

+ (NSSortDescriptor*)synopsisColorBrightnessSortDescriptor
{
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:kSynopsisStandardMetadataDominantColorValuesDictKey ascending:YES comparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        CGFloat sum1 = weightBrightnessDominantColors(@[obj1]);
		CGFloat sum2 = weightBrightnessDominantColors(@[obj2]);
		
        if(sum1 > sum2)
            return NSOrderedAscending;
        if(sum1 < sum2)
            return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
    return sortDescriptor;
}


@end
