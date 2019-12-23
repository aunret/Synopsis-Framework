//
//  Synopsis.m
//  Synopsis-Framework
//
//  Created by vade on 8/5/16.
//  Copyright © 2016 v002. All rights reserved.
//

#import "Synopsis.h"
#import "Synopsis-Private.h"
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "Synopsis.h"
#import "Synopsis-Legacy.h"

// Top Level Metadata key for AVFoundation used in both Summary (global) and per frame metadata
// See AVMetdataItem.h / AVMetdataIdentifier.h
NSString* const kSynopsisMetadataDomain = @"video.synopsis.metadata";
NSString* const kSynopsisMetadataIdentifier = @"mdta/video.synopsis.metadata";
NSString* const kSynopsisMetadataVersionKey = @"video.synopsis.metadata.version";

NSUInteger const kSynopsisMetadataVersionCurrent = SYNOPSIS_VERSION_NUMBER;
NSUInteger const kSynopsisMetadataVersionBeta1 = 10000;
NSUInteger const kSynopsisMetadataVersionUnknown = NSUIntegerMax;

// HFS+ Extended attribute keys and values
NSString* const kSynopsisMetadataHFSAttributeVersionKey = @"video_synopsis_version";
NSUInteger const kSynopsisMetadataHFSAttributeVersionValue = SYNOPSIS_VERSION_NUMBER;
NSString* const kSynopsisMetadataHFSAttributeDescriptorKey = @"video_synopsis_descriptors";

// FYI : We keep these strings short to "help" with file sizes...

// Metadata Type Key Strings:
NSString* const kSynopsisMetadataTypeGlobal = @"GM";
NSString* const kSynopsisMetadataTypeSample = @"SM";

// Visual identifier Key Strings
NSString* const kSynopsisMetadataIdentifierGlobalVisualDescription = @"VD";

NSString* const kSynopsisMetadataIdentifierVisualEmbedding = @"VE";
NSString* const kSynopsisMetadataIdentifierVisualProbabilities = @"VP";
NSString* const kSynopsisMetadataIdentifierVisualHistogram = @"VH";
NSString* const kSynopsisMetadataIdentifierVisualDominantColors = @"VDC";

NSString* const kSynopsisMetadataIdentifierTimeSeriesVisualEmbedding = @"TSVE";
NSString* const kSynopsisMetadataIdentifierTimeSeriesVisualProbabilities = @"TSVP";
NSString* const kSynopsisMetadataIdentifierTimeSeriesVisualHistogram = @"TSVH";
NSString* const kSynopsisMetadataIdentifierTimeSeriesVisualDominantColors = @"TSVDC";


// Metadata Type Versioning

#ifdef __cplusplus
extern "C" {
#endif

NSString* SynopsisKeyForMetadataTypeCurrentVersion(SynopsisMetadataType type)
{
    switch(type)
    {
        case SynopsisMetadataTypeGlobal:
            return kSynopsisMetadataTypeGlobal;
            
        case SynopsisMetadataTypeSample:
            return kSynopsisMetadataTypeSample;
    }
}

NSString* SynopsisKeyForMetadataTypeVersion(SynopsisMetadataType type, NSUInteger version)
{
    if ( version == SYNOPSIS_VERSION_NUMBER)
    {
        return SynopsisKeyForMetadataTypeCurrentVersion(type);
    }
    else
    {
        return nil;
    }
}

// Metadata Identifier Versioning

NSString* SynopsisKeyForMetadataIdentifierCurrentVersion(SynopsisMetadataIdentifier identifier)
{
    switch (identifier)
    {
        case SynopsisMetadataIdentifierGlobalVisualDescription:
            return kSynopsisMetadataIdentifierGlobalVisualDescription;
            
        case SynopsisMetadataIdentifierVisualEmbedding:
            return kSynopsisMetadataIdentifierVisualEmbedding;
            
        case SynopsisMetadataIdentifierVisualProbabilities:
            return kSynopsisMetadataIdentifierVisualProbabilities;
            
        case SynopsisMetadataIdentifierVisualHistogram:
            return kSynopsisMetadataIdentifierVisualHistogram;
        
        case SynopsisMetadataIdentifierVisualDominantColors:
            return kSynopsisMetadataIdentifierVisualDominantColors;
            
        case SynopsisMetadataIdentifierTimeSeriesVisualEmbedding:
            return kSynopsisMetadataIdentifierTimeSeriesVisualEmbedding;
            
        case SynopsisMetadataIdentifierTimeSeriesVisualProbabilities:
            return kSynopsisMetadataIdentifierTimeSeriesVisualProbabilities;
    }
}



NSString* SynopsisKeyForMetadataIdentifierVersion(SynopsisMetadataIdentifier identifier, NSUInteger version)
{
    if ( version == SYNOPSIS_VERSION_NUMBER)
    {
        return SynopsisKeyForMetadataIdentifierCurrentVersion(identifier);
    }
    else
    {
        return nil;
    }
}

NSArray* SynopsisSupportedFileTypes(void)
{

#if TARGET_OS_OSX

    NSString * mxfUTI = (NSString *)CFBridgingRelease(UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                                                            (CFStringRef)@"MXF",
                                                                                            NULL));
    
    NSArray* types = [[AVMovie movieTypes] arrayByAddingObject:mxfUTI];
    return types;

#else

    return [AVURLAsset audiovisualTypes];

#endif
}

NSRange CinemaNetRangeForConceptGroup(CinemaNetConceptGroup conceptGroup)
{
    switch (conceptGroup)
    {
        case CinemaNetConceptGroupColor:
            return NSMakeRange(CinemaNetClassLabelColorKeyStart, CinemaNetClassLabelColorTonesEnd - CinemaNetClassLabelColorKeyStart + 1);
            
        case CinemaNetConceptGroupShot:
            return NSMakeRange(CinemaNetClassLabelShotAngleStart, CinemaNetClassLabelShotTypeEnd - CinemaNetClassLabelShotAngleStart + 1);

        case CinemaNetConceptGroupTexture:
            return NSMakeRange(CinemaNetClassLabelTextureStart, CinemaNetClassLabelTextureEnd - CinemaNetClassLabelTextureStart + 1);


    }
}

    
NSRange CinemaNetRangeForClassGroup(CinemaNetClassGroup classGroup)
{
    switch (classGroup)
    {
        case CinemaNetClassGroupColorKey:
            return NSMakeRange(CinemaNetClassLabelColorKeyStart, CinemaNetClassLabelColorKeyEnd - CinemaNetClassLabelColorKeyStart + 1);

        case CinemaNetClassGroupColorSaturation:
            return NSMakeRange(CinemaNetClassLabelColorSaturationStart, CinemaNetClassLabelColorSaturationEnd - CinemaNetClassLabelColorSaturationStart + 1);

        case CinemaNetClassGroupColorTheory:
            return NSMakeRange(CinemaNetClassLabelColorTheoryStart, CinemaNetClassLabelColorTheoryEnd - CinemaNetClassLabelColorTheoryStart + 1);

        case CinemaNetClassGroupColorTones:
            return NSMakeRange(CinemaNetClassLabelColorTonesStart, CinemaNetClassLabelColorTonesEnd - CinemaNetClassLabelColorTonesStart + 1);

        case CinemaNetClassGroupShotAngle:
            return NSMakeRange(CinemaNetClassLabelShotAngleStart, CinemaNetClassLabelShotAngleEnd - CinemaNetClassLabelShotAngleStart + 1);

        case CinemaNetClassGroupShotFocus:
            return NSMakeRange(CinemaNetClassLabelShotFocusStart, CinemaNetClassLabelShotFocusEnd - CinemaNetClassLabelShotFocusStart + 1);

        case CinemaNetClassGroupShotFraming:
            return NSMakeRange(CinemaNetClassLabelShotFramingStart, CinemaNetClassLabelShotFramingEnd - CinemaNetClassLabelShotFramingStart + 1);

        case CinemaNetClassGroupShotLevel:
            return NSMakeRange(CinemaNetClassLabelShotLevelStart, CinemaNetClassLabelShotLevelEnd - CinemaNetClassLabelShotLevelStart + 1);

        case CinemaNetClassGroupShotLighting:
            return NSMakeRange(CinemaNetClassLabelShotLightingStart, CinemaNetClassLabelShotLightingEnd - CinemaNetClassLabelShotLightingStart + 1);

        case CinemaNetClassGroupShotLocation:
            return NSMakeRange(CinemaNetClassLabelShotLocationStart, CinemaNetClassLabelShotLocationEnd - CinemaNetClassLabelShotLocationStart + 1);

        case CinemaNetClassGroupShotSubject:
            return NSMakeRange(CinemaNetClassLabelShotSubjectStart, CinemaNetClassLabelShotSubjectEnd - CinemaNetClassLabelShotSubjectStart + 1);

        case CinemaNetClassGroupShotTimeOfDay:
            return NSMakeRange(CinemaNetClassLabelShotTimeofdayStart, CinemaNetClassLabelShotTimeofdayEnd - CinemaNetClassLabelShotTimeofdayStart + 1);

        case CinemaNetClassGroupShotType:
            return NSMakeRange(CinemaNetClassLabelShotTypeStart, CinemaNetClassLabelShotTypeEnd - CinemaNetClassLabelShotTypeStart + 1);

        case CinemaNetClassGroupTexture:
            return NSMakeRange(CinemaNetClassLabelTextureStart, CinemaNetClassLabelTextureEnd - CinemaNetClassLabelTextureStart + 1);
    }
}

    
#ifdef __cplusplus
}
#endif
