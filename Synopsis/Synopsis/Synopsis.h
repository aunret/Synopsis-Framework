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
extern NSString* const kSynopsisMetadataDomain;
extern NSString* const kSynopsisMetadataIdentifier;
extern NSString* const kSynopsisMetadataVersionKey;

// Current Metadata Version (for this framework)
extern NSUInteger const kSynopsisMetadataVersionCurrent;

// Major Metadata versions : 
// 1.0.0 aka (10000)
extern NSUInteger const kSynopsisMetadataVersionBeta1;

// Used for async loading of metadata or when we have metadata without versions marked for some reason
extern NSUInteger const kSynopsisMetadataVersionUnknown;

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

// The class labels for SynopsisMetadataIdentifierVisualProbabilities output
// See https://synopsis.video/cinemanet/taxonomy/ for info

// NA suffixes for 'not applicable'
typedef NS_ENUM(NSUInteger, CinemaNetClassGroup)
{
    CinemaNetClassGroupColorKey,
    CinemaNetClassGroupColorSaturation,
    CinemaNetClassGroupColorTheory,
    CinemaNetClassGroupColorTones,
    CinemaNetClassGroupShotAngle,
    CinemaNetClassGroupShotFocus,
    CinemaNetClassGroupShotFraming,
    CinemaNetClassGroupShotLevel,
    CinemaNetClassGroupShotLighting,
    CinemaNetClassGroupShotLocation,
    CinemaNetClassGroupShotSubject,
    CinemaNetClassGroupShotTimeOfDay,
    CinemaNetClassGroupShotType,
    CinemaNetClassGroupTexture,
};

typedef NS_ENUM(NSUInteger, CinemaNetClassLabel)
{
    CinemaNetClassLabelColorKeyBlue = 0,
    CinemaNetClassLabelColorKeyGreen,
    CinemaNetClassLabelColorKeyLuma,
    CinemaNetClassLabelColorKeyMatte,
    CinemaNetClassLabelColorKeyNa,
    CinemaNetClassLabelColorKeyStart = CinemaNetClassLabelColorKeyBlue,
    CinemaNetClassLabelColorKeyEnd = CinemaNetClassLabelColorKeyNa,
    
    CinemaNetClassLabelColorSaturationDesaturated,
    CinemaNetClassLabelColorSaturationNeutral,
    CinemaNetClassLabelColorSaturationPastel,
    CinemaNetClassLabelColorSaturationSaturated,
    CinemaNetClassLabelColorSaturationStart = CinemaNetClassLabelColorSaturationDesaturated,
    CinemaNetClassLabelColorSaturationEnd = CinemaNetClassLabelColorSaturationSaturated,

    CinemaNetClassLabelColorTheoryAnalagous,
    CinemaNetClassLabelColorTheoryComplementary,
    CinemaNetClassLabelColorTheoryMonochrome,
    CinemaNetClassLabelColorTheoryStart = CinemaNetClassLabelColorTheoryAnalagous,
    CinemaNetClassLabelColorTheoryEnd = CinemaNetClassLabelColorTheoryMonochrome,
    
    CinemaNetClassLabelColorTonesBlackWhite,
    CinemaNetClassLabelColorTonesCool,
    CinemaNetClassLabelColorTonesWarm,
    CinemaNetClassLabelColorTonesStart = CinemaNetClassLabelColorTonesBlackWhite,
    CinemaNetClassLabelColorTonesEnd = CinemaNetClassLabelColorTonesWarm,

    CinemaNetClassLabelShotAngleAerial,
    CinemaNetClassLabelShotAngleEyeLevel,
    CinemaNetClassLabelShotAngleHigh,
    CinemaNetClassLabelShotAngleLow,
    CinemaNetClassLabelShotAngleNa,
    CinemaNetClassLabelShotAngleStart = CinemaNetClassLabelShotAngleAerial,
    CinemaNetClassLabelShotAngleEnd = CinemaNetClassLabelShotAngleNa,

    CinemaNetClassLabelShotFocusDeep,
    CinemaNetClassLabelShotFocusOut,
    CinemaNetClassLabelShotFocusShallow,
    CinemaNetClassLabelShotFocusNa,
    CinemaNetClassLabelShotFocusStart = CinemaNetClassLabelShotFocusDeep,
    CinemaNetClassLabelShotFocusEnd = CinemaNetClassLabelShotFocusNa,
    
    CinemaNetClassLabelShotFramingCloseup,
    CinemaNetClassLabelShotFramingExtremeCloseup,
    CinemaNetClassLabelShotFramingExtremeLong,
    CinemaNetClassLabelShotFramingLong,
    CinemaNetClassLabelShotFramingMedium,
    CinemaNetClassLabelShotFramingNa,
    CinemaNetClassLabelShotFramingStart = CinemaNetClassLabelShotFramingCloseup,
    CinemaNetClassLabelShotFramingEnd = CinemaNetClassLabelShotFramingNa,
    
    CinemaNetClassLabelShotLevelLevel,
    CinemaNetClassLabelShotLevelTilted,
    CinemaNetClassLabelShotLevelNa,
    CinemaNetClassLabelShotLevelStart = CinemaNetClassLabelShotLevelLevel,
    CinemaNetClassLabelShotLevelEnd = CinemaNetClassLabelShotLevelNa,
    
    CinemaNetClassLabelShotLightingHard,
    CinemaNetClassLabelShotLightingKeyHigh,
    CinemaNetClassLabelShotLightingKeyLow,
    CinemaNetClassLabelShotLightingNeutral,
    CinemaNetClassLabelShotLightingSilhouette,
    CinemaNetClassLabelShotLightingSoft,
    CinemaNetClassLabelShotLightingNa,
    CinemaNetClassLabelShotLightingStart = CinemaNetClassLabelShotLightingHard,
    CinemaNetClassLabelShotLightingEnd = CinemaNetClassLabelShotLightingNa,

    CinemaNetClassLabelShotLocationExterior,
    CinemaNetClassLabelShotLocationExteriorNatureBeach,
    CinemaNetClassLabelShotLocationExteriorNatureCanyon,
    CinemaNetClassLabelShotLocationExteriorNatureCave,
    CinemaNetClassLabelShotLocationExteriorNatureDesert,
    CinemaNetClassLabelShotLocationExteriorNatureForest,
    CinemaNetClassLabelShotLocationExteriorNatureGlacier,
    CinemaNetClassLabelShotLocationExteriorNatureLake,
    CinemaNetClassLabelShotLocationExteriorNatureMountains,
    CinemaNetClassLabelShotLocationExteriorNatureOcean,
    CinemaNetClassLabelShotLocationExteriorNaturePlains,
    CinemaNetClassLabelShotLocationExteriorNaturePolar,
    CinemaNetClassLabelShotLocationExteriorNatureRiver,
    CinemaNetClassLabelShotLocationExteriorNatureSky,
    CinemaNetClassLabelShotLocationExteriorNatureSpace,
    CinemaNetClassLabelShotLocationExteriorNatureWetlands,
    CinemaNetClassLabelShotLocationExteriorSettlementCity,
    CinemaNetClassLabelShotLocationExteriorSettlementSuburb,
    CinemaNetClassLabelShotLocationExteriorSettlementTown,
    CinemaNetClassLabelShotLocationExteriorStructureBridge,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingAirport,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingAutoBody,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingCastle,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingHospital,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingHouseofworship,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingLibrary,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingMall,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingOffice,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceApartment,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceHouse,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMansion,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMonastery,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingResidencePalace,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingRestaurant,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingSchool,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingSkyscraper,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingStadium,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingStationGas,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingStationSubway,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingStationTrain,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingStore,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingTheater,
    CinemaNetClassLabelShotLocationExteriorStructureBuildingWarehouse,
    CinemaNetClassLabelShotLocationExteriorStructureBusStop,
    CinemaNetClassLabelShotLocationExteriorStructureFarm,
    CinemaNetClassLabelShotLocationExteriorStructureIndustrial,
    CinemaNetClassLabelShotLocationExteriorStructurePark,
    CinemaNetClassLabelShotLocationExteriorStructureParkinglot,
    CinemaNetClassLabelShotLocationExteriorStructurePier,
    CinemaNetClassLabelShotLocationExteriorStructurePlayground,
    CinemaNetClassLabelShotLocationExteriorStructurePort,
    CinemaNetClassLabelShotLocationExteriorStructureRoad,
    CinemaNetClassLabelShotLocationExteriorStructureRuins,
    CinemaNetClassLabelShotLocationExteriorStructureSidewalk,
    CinemaNetClassLabelShotLocationExteriorStructureTunnel,
    CinemaNetClassLabelShotLocationExteriorStructureVehicleAirplane,
    CinemaNetClassLabelShotLocationExteriorStructureVehicleBicycle,
    CinemaNetClassLabelShotLocationExteriorStructureVehicleBoat,
    CinemaNetClassLabelShotLocationExteriorStructureVehicleBus,
    CinemaNetClassLabelShotLocationExteriorStructureVehicleCar,
    CinemaNetClassLabelShotLocationExteriorStructureVehicleHelicopter,
    CinemaNetClassLabelShotLocationExteriorStructureVehicleMotorcycle,
    CinemaNetClassLabelShotLocationExteriorStructureVehicleSpacecraft,
    CinemaNetClassLabelShotLocationExteriorStructureVehicleTrain,
    CinemaNetClassLabelShotLocationExteriorStructureVehicleTruck,
    CinemaNetClassLabelShotLocationInterior,
    CinemaNetClassLabelShotLocationInteriorNatureCave,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingAirport,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingArena,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingAuditorium,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingAutoRepairShop,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingBar,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingBarn,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingCafe,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingCafeteria,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingCommandCenter,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingCrypt,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingDancefloor,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingDungeon,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingElevator,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingFactory,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingFoyer,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingGym,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingHallway,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingHospital,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingHouseofworship,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingLobby,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingMall,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingOffice,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingOfficeCubicle,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingOpenOffice,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingPrison,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingRestaurant,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBath,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBed,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomClass,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomCloset,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomConference,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomCourt,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomDining,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchen,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchenCommercial,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomLiving,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomStudy,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomThrone,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingStage,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingStairwell,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingStationBus,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingStationFire,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingStationPolice,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingStationSubway,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingStationTrain,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingStore,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingStoreAisle,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingStoreCheckout,
    CinemaNetClassLabelShotLocationInteriorStructureBuildingWarehouse,
    CinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCabin,
    CinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCockpit,
    CinemaNetClassLabelShotLocationInteriorStructureVehicleBoat,
    CinemaNetClassLabelShotLocationInteriorStructureVehicleBus,
    CinemaNetClassLabelShotLocationInteriorStructureVehicleCar,
    CinemaNetClassLabelShotLocationInteriorStructureVehicleHelicopter,
    CinemaNetClassLabelShotLocationInteriorStructureVehicleSpacecraft,
    CinemaNetClassLabelShotLocationInteriorStructureVehicleSubway,
    CinemaNetClassLabelShotLocationInteriorStructureVehicleTrain,
    CinemaNetClassLabelShotLocationInteriorStructureVehicleTruck,
    CinemaNetClassLabelShotLocationNa,
    CinemaNetClassLabelShotLocationStart = CinemaNetClassLabelShotLocationExterior,
    CinemaNetClassLabelShotLocationEnd = CinemaNetClassLabelShotLocationNa,

    CinemaNetClassLabelShotSubjectAnimal,
    CinemaNetClassLabelShotSubjectLocation,
    CinemaNetClassLabelShotSubjectObject,
    CinemaNetClassLabelShotSubjectPerson,
    CinemaNetClassLabelShotSubjectPersonBody,
    CinemaNetClassLabelShotSubjectPersonFace,
    CinemaNetClassLabelShotSubjectPersonFeet,
    CinemaNetClassLabelShotSubjectPersonHands,
    CinemaNetClassLabelShotSubjectText,
    CinemaNetClassLabelShotSubjectNa,
    CinemaNetClassLabelShotSubjectStart = CinemaNetClassLabelShotSubjectAnimal,
    CinemaNetClassLabelShotSubjectEnd = CinemaNetClassLabelShotSubjectNa,
    
    CinemaNetClassLabelShotTimeofdayDay,
    CinemaNetClassLabelShotTimeofdayNight,
    CinemaNetClassLabelShotTimeofdayTwilight,
    CinemaNetClassLabelShotTimeofdayNa,
    CinemaNetClassLabelShotTimeofdayStart = CinemaNetClassLabelShotTimeofdayDay,
    CinemaNetClassLabelShotTimeofdayEnd = CinemaNetClassLabelShotTimeofdayNa,
    
    CinemaNetClassLabelShotTypeMaster,
    CinemaNetClassLabelShotTypeOvertheshoulder,
    CinemaNetClassLabelShotTypePortrait,
    CinemaNetClassLabelShotTypeTwoshot,
    CinemaNetClassLabelShotTypeNa,
    CinemaNetClassLabelShotTypeStart = CinemaNetClassLabelShotTypeMaster,
    CinemaNetClassLabelShotTypeEnd = CinemaNetClassLabelShotTypeNa,

    CinemaNetClassLabelTextureBanded,
    CinemaNetClassLabelTextureBlotchy,
    CinemaNetClassLabelTextureBraided,
    CinemaNetClassLabelTextureBubbly,
    CinemaNetClassLabelTextureBumpy,
    CinemaNetClassLabelTextureChequered,
    CinemaNetClassLabelTextureCobwebbed,
    CinemaNetClassLabelTextureCracked,
    CinemaNetClassLabelTextureCrosshatched,
    CinemaNetClassLabelTextureCrystalline,
    CinemaNetClassLabelTextureDotted,
    CinemaNetClassLabelTextureFibrous,
    CinemaNetClassLabelTextureFlecked,
    CinemaNetClassLabelTextureFrilly,
    CinemaNetClassLabelTextureGauzy,
    CinemaNetClassLabelTextureGrid,
    CinemaNetClassLabelTextureGrooved,
    CinemaNetClassLabelTextureHoneycombed,
    CinemaNetClassLabelTextureInterlaced,
    CinemaNetClassLabelTextureKnitted,
    CinemaNetClassLabelTextureLacelike,
    CinemaNetClassLabelTextureLined,
    CinemaNetClassLabelTextureMarbled,
    CinemaNetClassLabelTextureMatted,
    CinemaNetClassLabelTextureMeshed,
    CinemaNetClassLabelTexturePaisley,
    CinemaNetClassLabelTexturePerforated,
    CinemaNetClassLabelTexturePitted,
    CinemaNetClassLabelTexturePleated,
    CinemaNetClassLabelTexturePorous,
    CinemaNetClassLabelTexturePotholed,
    CinemaNetClassLabelTextureScaly,
    CinemaNetClassLabelTextureSmeared,
    CinemaNetClassLabelTextureSpiralled,
    CinemaNetClassLabelTextureSprinkled,
    CinemaNetClassLabelTextureStained,
    CinemaNetClassLabelTextureStratified,
    CinemaNetClassLabelTextureStriped,
    CinemaNetClassLabelTextureStudded,
    CinemaNetClassLabelTextureSwirly,
    CinemaNetClassLabelTextureVeined,
    CinemaNetClassLabelTextureWaffled,
    CinemaNetClassLabelTextureWoven,
    CinemaNetClassLabelTextureWrinkled,
    CinemaNetClassLabelTextureZigzagged,
    CinemaNetClassLabelTextureStart = CinemaNetClassLabelTextureBanded,
    CinemaNetClassLabelTextureEnd = CinemaNetClassLabelTextureZigzagged,
    
    // Useful proxy for determining if we have the count of features for our
    CinemaNetClassLabelCount = CinemaNetClassLabelTextureEnd,
};

// Pass in a version for an appropriate key for the type or identifier
// The Version number is an NSUInteger stored in the dictionary top level under the key kSynopsisMetadataVersionKey
#ifdef __cplusplus
extern "C" {
#endif
extern NSString* SynopsisKeyForMetadataTypeVersion(SynopsisMetadataType type, NSUInteger version);
extern NSString* SynopsisKeyForMetadataIdentifierVersion(SynopsisMetadataIdentifier identifier, NSUInteger version);
extern NSArray* SynopsisSupportedFileTypes(void);

// Get the rangr of CinemaNetClassLabels from a specific CinemaNetClassGroup
// This is helpful when wanting to grab ranges from say an array of predictions
extern NSRange CinemaNetClassLabelRangeForLabelGroup(CinemaNetClassGroup classGroup);

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
