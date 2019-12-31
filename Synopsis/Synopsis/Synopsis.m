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
    
#pragma mark - CinemaNet Groups, Concepts and Labels
    
NSString* const kCinemaNetClassLabelColorKeyBlueKey = @"color.key.blue";
NSString* const kCinemaNetClassLabelColorKeyGreenKey = @"color.key.green";
NSString* const kCinemaNetClassLabelColorKeyLumaKey = @"color.key.luma";
NSString* const kCinemaNetClassLabelColorKeyMatteKey = @"color.key.matte";
NSString* const kCinemaNetClassLabelColorKeyNaKey = @"color.key.na";

NSString* const kCinemaNetClassLabelColorSaturationDesaturatedKey = @"color.saturation.desaturated";
NSString* const kCinemaNetClassLabelColorSaturationNeutralKey = @"color.saturation.neutral";
NSString* const kCinemaNetClassLabelColorSaturationPastelKey = @"color.saturation.pastel";
NSString* const kCinemaNetClassLabelColorSaturationSaturatedKey = @"color.saturation.saturated";

NSString* const kCinemaNetClassLabelColorTheoryAnalagousKey = @"color.theory.analagous";
NSString* const kCinemaNetClassLabelColorTheoryComplementaryKey = @"color.theory.complementary";
NSString* const kCinemaNetClassLabelColorTheoryMonochromeKey = @"color.theory.monochrome";

NSString* const kCinemaNetClassLabelColorTonesBlackWhiteKey = @"color.tones.blackwhite";
NSString* const kCinemaNetClassLabelColorTonesCoolKey = @"color.tones.cool";
NSString* const kCinemaNetClassLabelColorTonesWarmKey = @"color.tones.warm";
    
NSString* const kCinemaNetClassLabelShotAngleAerialKey = @"shot.angle.aerial";
NSString* const kCinemaNetClassLabelShotAngleEyeLevelKey = @"shot.angle.eyelevel";
NSString* const kCinemaNetClassLabelShotAngleHighKey = @"shot.angle.high";
NSString* const kCinemaNetClassLabelShotAngleLowKey = @"shot.angle.low";
NSString* const kCinemaNetClassLabelShotAngleNaKey = @"shot.angle.na";

NSString* const kCinemaNetClassLabelShotFocusDeepKey = @"shot.focus.deep";
NSString* const kCinemaNetClassLabelShotFocusOutKey = @"shot.focus.out";
NSString* const kCinemaNetClassLabelShotFocusShallowKey = @"shot.focus.shallow";
NSString* const kCinemaNetClassLabelShotFocusNaKey = @"shot.focus.na";

NSString* const kCinemaNetClassLabelShotFramingCloseupKey = @"shot.framing.closeup";
NSString* const kCinemaNetClassLabelShotFramingExtremeCloseupKey = @"shot.framing.extremecloseup";
NSString* const kCinemaNetClassLabelShotFramingExtremeLongKey = @"shot.framing.extremelong";
NSString* const kCinemaNetClassLabelShotFramingLongKey = @"shot.framing.long";
NSString* const kCinemaNetClassLabelShotFramingMediumKey = @"shot.framing.medium";
NSString* const kCinemaNetClassLabelShotFramingNaKey = @"shot.framing.na";

NSString* const kCinemaNetClassLabelShotLevelLevelKey = @"shot.level.level";
NSString* const kCinemaNetClassLabelShotLevelTiltedKey = @"shot.level.tilted";
NSString* const kCinemaNetClassLabelShotLevelNaKey = @"shot.level.na";

NSString* const kCinemaNetClassLabelShotLightingHardKey = @"shot.lighting.hard";
NSString* const kCinemaNetClassLabelShotLightingKeyHighKey = @"shot.lighting.key.high";
NSString* const kCinemaNetClassLabelShotLightingKeyLowKey = @"shot.lighting.key.low";
NSString* const kCinemaNetClassLabelShotLightingNeutralKey = @"shot.lighting.neutral";
NSString* const kCinemaNetClassLabelShotLightingSilhouetteKey = @"shot.lighting.silhouette";
NSString* const kCinemaNetClassLabelShotLightingSoftKey = @"shot.lighting.soft";
NSString* const kCinemaNetClassLabelShotLightingNaKey = @"shot.lighting.na";

NSString* const kCinemaNetClassLabelShotLocationExteriorKey = @"shot.location.exterior";
NSString* const kCinemaNetClassLabelShotLocationExteriorNatureBeachKey = @"shot.location.exterior.nature.beach";
NSString* const kCinemaNetClassLabelShotLocationExteriorNatureCanyonKey = @"shot.location.exterior.nature.canyon";
NSString* const kCinemaNetClassLabelShotLocationExteriorNatureCaveKey = @"shot.location.exterior.nature.cave";
NSString* const kCinemaNetClassLabelShotLocationExteriorNatureDesertKey = @"shot.location.exterior.nature.desert";
NSString* const kCinemaNetClassLabelShotLocationExteriorNatureForestKey = @"shot.location.exterior.nature.forest";
NSString* const kCinemaNetClassLabelShotLocationExteriorNatureGlacierKey = @"shot.location.exterior.nature.glacier";
NSString* const kCinemaNetClassLabelShotLocationExteriorNatureLakeKey = @"shot.location.exterior.nature.lake";
NSString* const kCinemaNetClassLabelShotLocationExteriorNatureMountainsKey = @"shot.location.exterior.nature.mountains";
NSString* const kCinemaNetClassLabelShotLocationExteriorNatureOceanKey = @"shot.location.exterior.nature.ocean";
NSString* const kCinemaNetClassLabelShotLocationExteriorNaturePlainsKey = @"shot.location.exterior.nature.plains";
NSString* const kCinemaNetClassLabelShotLocationExteriorNaturePolarKey = @"shot.location.exterior.nature.polar";
NSString* const kCinemaNetClassLabelShotLocationExteriorNatureRiverKey = @"shot.location.exterior.nature.river";
NSString* const kCinemaNetClassLabelShotLocationExteriorNatureSkyKey = @"shot.location.exterior.nature.sky";
NSString* const kCinemaNetClassLabelShotLocationExteriorNatureSpaceKey = @"shot.location.exterior.nature.space";
NSString* const kCinemaNetClassLabelShotLocationExteriorNatureWetlandsKey = @"shot.location.exterior.nature.wetlands";
NSString* const kCinemaNetClassLabelShotLocationExteriorSettlementCityKey = @"shot.location.exterior.settlement.city";
NSString* const kCinemaNetClassLabelShotLocationExteriorSettlementSuburbKey = @"shot.location.exterior.settlement.suburb";
NSString* const kCinemaNetClassLabelShotLocationExteriorSettlementTownKey = @"shot.location.exterior.settlement.town";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBridgeKey = @"shot.location.exterior.structure.bridge";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingAirportKey = @"shot.location.exterior.structure.building.airport";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingAutoBodyKey = @"shot.location.exterior.structure.building.auto.body";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingCastleKey = @"shot.location.exterior.structure.building.castle";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingHospitalKey = @"shot.location.exterior.structure.building.hospital";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingHouseofworshipKey = @"shot.location.exterior.structure.building.houseofworship";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingLibraryKey = @"shot.location.exterior.structure.building.library";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingMallKey = @"shot.location.exterior.structure.building.mall";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingOfficeKey = @"shot.location.exterior.structure.building.office";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceApartmentKey = @"shot.location.exterior.structure.building.residence.apartment";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceHouseKey = @"shot.location.exterior.structure.building.residence.house";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMansionKey = @"shot.location.exterior.structure.building.residence.mansion";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMonasteryKey = @"shot.location.exterior.structure.building.residence.monastery";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingResidencePalaceKey = @"shot.location.exterior.structure.building.residence.palace";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingRestaurantKey = @"shot.location.exterior.structure.building.restaurant";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingSchoolKey = @"shot.location.exterior.structure.building.school";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingSkyscraperKey = @"shot.location.exterior.structure.building.skyscraper";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingStadiumKey = @"shot.location.exterior.structure.building.stadium";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingStationGasKey = @"shot.location.exterior.structure.building.station.gas";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingStationSubwayKey = @"shot.location.exterior.structure.building.station.subway";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingStationTrainKey = @"shot.location.exterior.structure.building.station.train";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingStoreKey = @"shot.location.exterior.structure.building.store";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingTheaterKey = @"shot.location.exterior.structure.building.theater";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBuildingWarehouseKey = @"shot.location.exterior.structure.building.warehouse";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureBusStopKey = @"shot.location.exterior.structure.bus.stop";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureFarmKey = @"shot.location.exterior.structure.farm";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureIndustrialKey = @"shot.location.exterior.structure.industrial";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureParkKey = @"shot.location.exterior.structure.park";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureParkinglotKey = @"shot.location.exterior.structure.parkinglot";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructurePierKey = @"shot.location.exterior.structure.pier";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructurePlaygroundKey = @"shot.location.exterior.structure.playground";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructurePortKey = @"shot.location.exterior.structure.port";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureRoadKey = @"shot.location.exterior.structure.road";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureRuinsKey = @"shot.location.exterior.structure.ruins";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureSidewalkKey = @"shot.location.exterior.structure.sidewalk";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureTunnelKey = @"shot.location.exterior.structure.tunnel";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureVehicleAirplaneKey = @"shot.location.exterior.structure.vehicle.airplane";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureVehicleBicycleKey = @"shot.location.exterior.structure.vehicle.bicycle";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureVehicleBoatKey = @"shot.location.exterior.structure.vehicle.boat";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureVehicleBusKey = @"shot.location.exterior.structure.vehicle.bus";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureVehicleCarKey = @"shot.location.exterior.structure.vehicle.car";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureVehicleHelicopterKey = @"shot.location.exterior.structure.vehicle.helicopter";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureVehicleMotorcycleKey = @"shot.location.exterior.structure.vehicle.motorcycle";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureVehicleSpacecraftKey = @"shot.location.exterior.structure.vehicle.spacecraft";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureVehicleTrainKey = @"shot.location.exterior.structure.vehicle.train";
NSString* const kCinemaNetClassLabelShotLocationExteriorStructureVehicleTruckKey = @"shot.location.exterior.structure.vehicle.truck";
NSString* const kCinemaNetClassLabelShotLocationInteriorKey = @"shot.location.interior";
NSString* const kCinemaNetClassLabelShotLocationInteriorNatureCaveKey = @"shot.location.interior.nature.cave";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingAirportKey = @"shot.location.interior.structure.building.airport";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingArenaKey = @"shot.location.interior.structure.building.arena";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingAuditoriumKey = @"shot.location.interior.structure.building.auditorium";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingAutoRepairShopKey = @"shot.location.interior.structure.building.auto.repair.shop";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingBarKey = @"shot.location.interior.structure.building.bar";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingBarnKey = @"shot.location.interior.structure.building.barn";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingCafeKey = @"shot.location.interior.structure.building.cafe";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingCafeteriaKey = @"shot.location.interior.structure.building.cafeteria";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingCommandCenterKey = @"shot.location.interior.structure.building.command.center";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingCryptKey = @"shot.location.interior.structure.building.crypt";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingDancefloorKey = @"shot.location.interior.structure.building.dancefloor";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingDungeonKey = @"shot.location.interior.structure.building.dungeon";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingElevatorKey = @"shot.location.interior.structure.building.elevator";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingFactoryKey = @"shot.location.interior.structure.building.factory";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingFoyerKey = @"shot.location.interior.structure.building.foyer";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingGymKey = @"shot.location.interior.structure.building.gym";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingHallwayKey = @"shot.location.interior.structure.building.hallway";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingHospitalKey = @"shot.location.interior.structure.building.hospital";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingHouseofworshipKey = @"shot.location.interior.structure.building.houseofworship";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingLobbyKey = @"shot.location.interior.structure.building.lobby";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingMallKey = @"shot.location.interior.structure.building.mall";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingOfficeKey = @"shot.location.interior.structure.building.office";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingOfficeCubicleKey = @"shot.location.interior.structure.building.office.cubicle";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingOpenOfficeKey = @"shot.location.interior.structure.building.open.office";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingPrisonKey = @"shot.location.interior.structure.building.prison";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingRestaurantKey = @"shot.location.interior.structure.building.restaurant";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBathKey = @"shot.location.interior.structure.building.room.bath";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBedKey = @"shot.location.interior.structure.building.room.bed";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomClassKey = @"shot.location.interior.structure.building.room.class";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomClosetKey = @"shot.location.interior.structure.building.room.closet";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomConferenceKey = @"shot.location.interior.structure.building.room.conference";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomCourtKey = @"shot.location.interior.structure.building.room.court";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomDiningKey = @"shot.location.interior.structure.building.room.dining";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchenKey = @"shot.location.interior.structure.building.room.kitchen";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchenCommercialKey = @"shot.location.interior.structure.building.room.kitchen.commercial";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomLivingKey = @"shot.location.interior.structure.building.room.living";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomStudyKey = @"shot.location.interior.structure.building.room.study";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomThroneKey = @"shot.location.interior.structure.building.room.throne";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingStageKey = @"shot.location.interior.structure.building.stage";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingStairwellKey = @"shot.location.interior.structure.building.stairwell";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingStationBusKey = @"shot.location.interior.structure.building.station.bus";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingStationFireKey = @"shot.location.interior.structure.building.station.fire";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingStationPoliceKey = @"shot.location.interior.structure.building.station.police";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingStationSubwayKey = @"shot.location.interior.structure.building.station.subway";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingStationTrainKey = @"shot.location.interior.structure.building.station.train";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingStoreKey = @"shot.location.interior.structure.building.store";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingStoreAisleKey = @"shot.location.interior.structure.building.store.aisle";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingStoreCheckoutKey = @"shot.location.interior.structure.building.store.checkout";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureBuildingWarehouseKey = @"shot.location.interior.structure.building.warehouse";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCabinKey = @"shot.location.interior.structure.vehicle.airplane.cabin";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCockpitKey = @"shot.location.interior.structure.vehicle.airplane.cockpit";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureVehicleBoatKey = @"shot.location.interior.structure.vehicle.boat";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureVehicleBusKey = @"shot.location.interior.structure.vehicle.bus";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureVehicleCarKey = @"shot.location.interior.structure.vehicle.car";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureVehicleHelicopterKey = @"shot.location.interior.structure.vehicle.helicopter";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureVehicleSpacecraftKey = @"shot.location.interior.structure.vehicle.spacecraft";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureVehicleSubwayKey = @"shot.location.interior.structure.vehicle.subway";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureVehicleTrainKey = @"shot.location.interior.structure.vehicle.train";
NSString* const kCinemaNetClassLabelShotLocationInteriorStructureVehicleTruckKey = @"shot.location.interior.structure.vehicle.truck";
NSString* const kCinemaNetClassLabelShotLocationNaKey = @"shot.location.na";

NSString* const kCinemaNetClassLabelShotSubjectAnimalKey = @"shot.subject.animal";
NSString* const kCinemaNetClassLabelShotSubjectLocationKey = @"shot.subject.location";
NSString* const kCinemaNetClassLabelShotSubjectObjectKey = @"shot.subject.object";
NSString* const kCinemaNetClassLabelShotSubjectPersonKey = @"shot.subject.person";
NSString* const kCinemaNetClassLabelShotSubjectPersonBodyKey = @"shot.subject.person.body";
NSString* const kCinemaNetClassLabelShotSubjectPersonFaceKey = @"shot.subject.person.face";
NSString* const kCinemaNetClassLabelShotSubjectPersonFeetKey = @"shot.subject.person.feet";
NSString* const kCinemaNetClassLabelShotSubjectPersonHandsKey = @"shot.subject.person.hands";
NSString* const kCinemaNetClassLabelShotSubjectTextKey = @"shot.subject.text";
NSString* const kCinemaNetClassLabelShotSubjectNaKey = @"shot.subject.na";

NSString* const kCinemaNetClassLabelShotTimeofdayDayKey = @"shot.timeofday.day";
NSString* const kCinemaNetClassLabelShotTimeofdayNightKey = @"shot.timeofday.night";
NSString* const kCinemaNetClassLabelShotTimeofdayTwilightKey = @"shot.timeofday.twilight";
NSString* const kCinemaNetClassLabelShotTimeofdayNaKey = @"shot.timeofday.na";

NSString* const kCinemaNetClassLabelShotTypeMasterKey = @"shot.type.master";
NSString* const kCinemaNetClassLabelShotTypeOvertheshoulderKey = @"shot.type.overtheshoulder";
NSString* const kCinemaNetClassLabelShotTypePortraitKey = @"shot.type.portrait";
NSString* const kCinemaNetClassLabelShotTypeTwoshotKey = @"shot.type.twoshot";
NSString* const kCinemaNetClassLabelShotTypeNaKey = @"shot.type.na";

NSString* const kCinemaNetClassLabelTextureBandedKey = @"texture.banded";
NSString* const kCinemaNetClassLabelTextureBlotchyKey = @"texture.blotchy";
NSString* const kCinemaNetClassLabelTextureBraidedKey = @"texture.braided";
NSString* const kCinemaNetClassLabelTextureBubblyKey = @"texture.bubbly";
NSString* const kCinemaNetClassLabelTextureBumpyKey = @"texture.bumpy";
NSString* const kCinemaNetClassLabelTextureChequeredKey = @"texture.chequered";
NSString* const kCinemaNetClassLabelTextureCobwebbedKey = @"texture.cobwebbed";
NSString* const kCinemaNetClassLabelTextureCrackedKey = @"texture.cracked";
NSString* const kCinemaNetClassLabelTextureCrosshatchedKey = @"texture.crosshatched";
NSString* const kCinemaNetClassLabelTextureCrystallineKey = @"texture.crystalline";
NSString* const kCinemaNetClassLabelTextureDottedKey = @"texture.dotted";
NSString* const kCinemaNetClassLabelTextureFibrousKey = @"texture.fibrous";
NSString* const kCinemaNetClassLabelTextureFleckedKey = @"texture.flecked";
NSString* const kCinemaNetClassLabelTextureFrillyKey = @"texture.frilly";
NSString* const kCinemaNetClassLabelTextureGauzyKey = @"texture.gauzy";
NSString* const kCinemaNetClassLabelTextureGridKey = @"texture.grid";
NSString* const kCinemaNetClassLabelTextureGroovedKey = @"texture.grooved";
NSString* const kCinemaNetClassLabelTextureHoneycombedKey = @"texture.honeycombed";
NSString* const kCinemaNetClassLabelTextureInterlacedKey = @"texture.interlaced";
NSString* const kCinemaNetClassLabelTextureKnittedKey = @"texture.knitted";
NSString* const kCinemaNetClassLabelTextureLacelikeKey = @"texture.lacelike";
NSString* const kCinemaNetClassLabelTextureLinedKey = @"texture.lined";
NSString* const kCinemaNetClassLabelTextureMarbledKey = @"texture.marbled";
NSString* const kCinemaNetClassLabelTextureMattedKey = @"texture.matted";
NSString* const kCinemaNetClassLabelTextureMeshedKey = @"texture.meshed";
NSString* const kCinemaNetClassLabelTexturePaisleyKey = @"texture.paisley";
NSString* const kCinemaNetClassLabelTexturePerforatedKey = @"texture.perforated";
NSString* const kCinemaNetClassLabelTexturePittedKey = @"texture.pitted";
NSString* const kCinemaNetClassLabelTexturePleatedKey = @"texture.pleated";
NSString* const kCinemaNetClassLabelTexturePorousKey = @"texture.porous";
NSString* const kCinemaNetClassLabelTexturePotholedKey = @"texture.potholed";
NSString* const kCinemaNetClassLabelTextureScalyKey = @"texture.scaly";
NSString* const kCinemaNetClassLabelTextureSmearedKey = @"texture.smeared";
NSString* const kCinemaNetClassLabelTextureSpiralledKey = @"texture.spiralled";
NSString* const kCinemaNetClassLabelTextureSprinkledKey = @"texture.sprinkled";
NSString* const kCinemaNetClassLabelTextureStainedKey = @"texture.stained";
NSString* const kCinemaNetClassLabelTextureStratifiedKey = @"texture.stratified";
NSString* const kCinemaNetClassLabelTextureStripedKey = @"texture.striped";
NSString* const kCinemaNetClassLabelTextureStuddedKey = @"texture.studded";
NSString* const kCinemaNetClassLabelTextureSwirlyKey = @"texture.swirly";
NSString* const kCinemaNetClassLabelTextureVeinedKey = @"texture.veined";
NSString* const kCinemaNetClassLabelTextureWaffledKey = @"texture.waffled";
NSString* const kCinemaNetClassLabelTextureWovenKey = @"texture.woven";
NSString* const kCinemaNetClassLabelTextureWrinkledKey = @"texture.wrinkled";
NSString* const kCinemaNetClassLabelTextureZigzaggedKey = @"texture.zigzagged";
    
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
    
NSString* CinemanetLabelKeyForClassLabel(CinemaNetClassLabel label)
{
//    Use the String Label Keys

    switch (label)
    {
        case CinemaNetClassLabelColorKeyBlue:
            return kCinemaNetClassLabelColorKeyBlueKey;
        case CinemaNetClassLabelColorKeyGreen:
            return kCinemaNetClassLabelColorKeyGreenKey;
        case CinemaNetClassLabelColorKeyLuma:
            return kCinemaNetClassLabelColorKeyLumaKey;
        case CinemaNetClassLabelColorKeyMatte:
            return kCinemaNetClassLabelColorKeyMatteKey;
        case CinemaNetClassLabelColorKeyNa:
            return kCinemaNetClassLabelColorKeyNaKey;
            
        case CinemaNetClassLabelColorSaturationDesaturated:
            return kCinemaNetClassLabelColorSaturationDesaturatedKey;
        case CinemaNetClassLabelColorSaturationNeutral:
            return kCinemaNetClassLabelColorSaturationNeutralKey;
        case CinemaNetClassLabelColorSaturationPastel:
            return kCinemaNetClassLabelColorSaturationPastelKey;
        case CinemaNetClassLabelColorSaturationSaturated:
            return kCinemaNetClassLabelColorSaturationSaturatedKey;
            
        case CinemaNetClassLabelColorTheoryAnalagous:
            return kCinemaNetClassLabelColorTheoryAnalagousKey;
        case CinemaNetClassLabelColorTheoryComplementary:
            return kCinemaNetClassLabelColorTheoryComplementaryKey;
        case CinemaNetClassLabelColorTheoryMonochrome:
            return kCinemaNetClassLabelColorTheoryMonochromeKey;
            
        case CinemaNetClassLabelColorTonesBlackWhite:
            return kCinemaNetClassLabelColorTonesBlackWhiteKey;
        case CinemaNetClassLabelColorTonesCool:
            return kCinemaNetClassLabelColorTonesCoolKey;
        case CinemaNetClassLabelColorTonesWarm:
            return kCinemaNetClassLabelColorTonesWarmKey;
            
        case CinemaNetClassLabelShotAngleAerial:
            return kCinemaNetClassLabelShotAngleAerialKey;
        case CinemaNetClassLabelShotAngleEyeLevel:
            return kCinemaNetClassLabelShotAngleEyeLevelKey;
        case CinemaNetClassLabelShotAngleHigh:
            return kCinemaNetClassLabelShotAngleHighKey;
        case CinemaNetClassLabelShotAngleLow:
            return kCinemaNetClassLabelShotAngleLowKey;
        case CinemaNetClassLabelShotAngleNa:
            return kCinemaNetClassLabelShotAngleNaKey;
            
        case CinemaNetClassLabelShotFocusDeep:
            return kCinemaNetClassLabelShotFocusDeepKey;
        case CinemaNetClassLabelShotFocusOut:
            return kCinemaNetClassLabelShotFocusOutKey;
        case CinemaNetClassLabelShotFocusShallow:
            return kCinemaNetClassLabelShotFocusShallowKey;
        case CinemaNetClassLabelShotFocusNa:
            return kCinemaNetClassLabelShotFocusNaKey;
            
        case CinemaNetClassLabelShotFramingCloseup:
            return kCinemaNetClassLabelShotFramingCloseupKey;
        case CinemaNetClassLabelShotFramingExtremeCloseup:
            return kCinemaNetClassLabelShotFramingExtremeCloseupKey;
        case CinemaNetClassLabelShotFramingExtremeLong:
            return kCinemaNetClassLabelShotFramingExtremeLongKey;
        case CinemaNetClassLabelShotFramingLong:
            return kCinemaNetClassLabelShotFramingLongKey;
        case CinemaNetClassLabelShotFramingMedium:
            return kCinemaNetClassLabelShotFramingMediumKey;
        case CinemaNetClassLabelShotFramingNa:
            return kCinemaNetClassLabelShotFramingNaKey;
            
        case CinemaNetClassLabelShotLevelLevel:
            return kCinemaNetClassLabelShotLevelLevelKey;
        case CinemaNetClassLabelShotLevelTilted:
            return kCinemaNetClassLabelShotLevelTiltedKey;
        case CinemaNetClassLabelShotLevelNa:
            return kCinemaNetClassLabelShotLevelNaKey;
            
        case CinemaNetClassLabelShotLightingHard:
            return kCinemaNetClassLabelShotLightingHardKey;
        case CinemaNetClassLabelShotLightingKeyHigh:
            return kCinemaNetClassLabelShotLightingKeyHighKey;
        case CinemaNetClassLabelShotLightingKeyLow:
            return kCinemaNetClassLabelShotLightingKeyLowKey;
        case CinemaNetClassLabelShotLightingNeutral:
            return kCinemaNetClassLabelShotLightingNeutralKey;
        case CinemaNetClassLabelShotLightingSilhouette:
            return kCinemaNetClassLabelShotLightingSilhouetteKey;
        case CinemaNetClassLabelShotLightingSoft:
            return kCinemaNetClassLabelShotLightingSoftKey;
        case CinemaNetClassLabelShotLightingNa:
            return kCinemaNetClassLabelShotLightingNaKey;
            
        case CinemaNetClassLabelShotLocationExterior:
            return kCinemaNetClassLabelShotLocationExteriorKey;
        case CinemaNetClassLabelShotLocationExteriorNatureBeach:
            return kCinemaNetClassLabelShotLocationExteriorNatureBeachKey;
        case CinemaNetClassLabelShotLocationExteriorNatureCanyon:
            return kCinemaNetClassLabelShotLocationExteriorNatureCanyonKey;
        case CinemaNetClassLabelShotLocationExteriorNatureCave:
            return kCinemaNetClassLabelShotLocationExteriorNatureCaveKey;
        case CinemaNetClassLabelShotLocationExteriorNatureDesert:
            return kCinemaNetClassLabelShotLocationExteriorNatureDesertKey;
        case CinemaNetClassLabelShotLocationExteriorNatureForest:
            return kCinemaNetClassLabelShotLocationExteriorNatureForestKey;
        case CinemaNetClassLabelShotLocationExteriorNatureGlacier:
            return kCinemaNetClassLabelShotLocationExteriorNatureGlacierKey;
        case CinemaNetClassLabelShotLocationExteriorNatureLake:
            return kCinemaNetClassLabelShotLocationExteriorNatureLakeKey;
        case CinemaNetClassLabelShotLocationExteriorNatureMountains:
            return kCinemaNetClassLabelShotLocationExteriorNatureMountainsKey;
        case CinemaNetClassLabelShotLocationExteriorNatureOcean:
            return kCinemaNetClassLabelShotLocationExteriorNatureOceanKey;
        case CinemaNetClassLabelShotLocationExteriorNaturePlains:
            return kCinemaNetClassLabelShotLocationExteriorNaturePlainsKey;
        case CinemaNetClassLabelShotLocationExteriorNaturePolar:
            return kCinemaNetClassLabelShotLocationExteriorNaturePolarKey;
        case CinemaNetClassLabelShotLocationExteriorNatureRiver:
            return kCinemaNetClassLabelShotLocationExteriorNatureRiverKey;
        case CinemaNetClassLabelShotLocationExteriorNatureSky:
            return kCinemaNetClassLabelShotLocationExteriorNatureSkyKey;
        case CinemaNetClassLabelShotLocationExteriorNatureSpace:
            return kCinemaNetClassLabelShotLocationExteriorNatureSpaceKey;
        case CinemaNetClassLabelShotLocationExteriorNatureWetlands:
            return kCinemaNetClassLabelShotLocationExteriorNatureWetlandsKey;
        case CinemaNetClassLabelShotLocationExteriorSettlementCity:
            return kCinemaNetClassLabelShotLocationExteriorSettlementCityKey;
        case CinemaNetClassLabelShotLocationExteriorSettlementSuburb:
            return kCinemaNetClassLabelShotLocationExteriorSettlementSuburbKey;
        case CinemaNetClassLabelShotLocationExteriorSettlementTown:
            return kCinemaNetClassLabelShotLocationExteriorSettlementTownKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBridge:
            return kCinemaNetClassLabelShotLocationExteriorStructureBridgeKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingAirport:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingAirportKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingAutoBody:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingAutoBodyKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingCastle:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingCastleKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingHospital:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingHospitalKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingHouseofworship:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingHouseofworshipKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingLibrary:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingLibraryKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingMall:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingMallKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingOffice:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingOfficeKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceApartment:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceApartmentKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceHouse:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceHouseKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMansion:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMansionKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMonastery:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMonasteryKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingResidencePalace:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingResidencePalaceKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingRestaurant:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingRestaurantKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingSchool:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingSchoolKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingSkyscraper:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingSkyscraperKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingStadium:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingStadiumKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingStationGas:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingStationGasKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingStationSubway:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingStationSubwayKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingStationTrain:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingStationTrainKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingStore:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingStoreKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingTheater:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingTheaterKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingWarehouse:
            return kCinemaNetClassLabelShotLocationExteriorStructureBuildingWarehouseKey;
        case CinemaNetClassLabelShotLocationExteriorStructureBusStop:
            return kCinemaNetClassLabelShotLocationExteriorStructureBusStopKey;
        case CinemaNetClassLabelShotLocationExteriorStructureFarm:
            return kCinemaNetClassLabelShotLocationExteriorStructureFarmKey;
        case CinemaNetClassLabelShotLocationExteriorStructureIndustrial:
            return kCinemaNetClassLabelShotLocationExteriorStructureIndustrialKey;
        case CinemaNetClassLabelShotLocationExteriorStructurePark:
            return kCinemaNetClassLabelShotLocationExteriorStructureParkKey;
        case CinemaNetClassLabelShotLocationExteriorStructureParkinglot:
            return kCinemaNetClassLabelShotLocationExteriorStructureParkinglotKey;
        case CinemaNetClassLabelShotLocationExteriorStructurePier:
            return kCinemaNetClassLabelShotLocationExteriorStructurePierKey;
        case CinemaNetClassLabelShotLocationExteriorStructurePlayground:
            return kCinemaNetClassLabelShotLocationExteriorStructurePlaygroundKey;
        case CinemaNetClassLabelShotLocationExteriorStructurePort:
            return kCinemaNetClassLabelShotLocationExteriorStructurePortKey;
        case CinemaNetClassLabelShotLocationExteriorStructureRoad:
            return kCinemaNetClassLabelShotLocationExteriorStructureRoadKey;
        case CinemaNetClassLabelShotLocationExteriorStructureRuins:
            return kCinemaNetClassLabelShotLocationExteriorStructureRuinsKey;
        case CinemaNetClassLabelShotLocationExteriorStructureSidewalk:
            return kCinemaNetClassLabelShotLocationExteriorStructureSidewalkKey;
        case CinemaNetClassLabelShotLocationExteriorStructureTunnel:
            return kCinemaNetClassLabelShotLocationExteriorStructureTunnelKey;
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleAirplane:
            return kCinemaNetClassLabelShotLocationExteriorStructureVehicleAirplaneKey;
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleBicycle:
            return kCinemaNetClassLabelShotLocationExteriorStructureVehicleBicycleKey;
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleBoat:
            return kCinemaNetClassLabelShotLocationExteriorStructureVehicleBoatKey;
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleBus:
            return kCinemaNetClassLabelShotLocationExteriorStructureVehicleBusKey;
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleCar:
            return kCinemaNetClassLabelShotLocationExteriorStructureVehicleCarKey;
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleHelicopter:
            return kCinemaNetClassLabelShotLocationExteriorStructureVehicleHelicopterKey;
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleMotorcycle:
            return kCinemaNetClassLabelShotLocationExteriorStructureVehicleMotorcycleKey;
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleSpacecraft:
            return kCinemaNetClassLabelShotLocationExteriorStructureVehicleSpacecraftKey;
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleTrain:
            return kCinemaNetClassLabelShotLocationExteriorStructureVehicleTrainKey;
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleTruck:
            return kCinemaNetClassLabelShotLocationExteriorStructureVehicleTruckKey;
        case CinemaNetClassLabelShotLocationInterior:
            return kCinemaNetClassLabelShotLocationInteriorKey;
        case CinemaNetClassLabelShotLocationInteriorNatureCave:
            return kCinemaNetClassLabelShotLocationInteriorNatureCaveKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingAirport:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingAirportKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingArena:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingArenaKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingAuditorium:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingAuditoriumKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingAutoRepairShop:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingAutoRepairShopKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingBar:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingBarKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingBarn:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingBarnKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingCafe:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingCafeKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingCafeteria:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingCafeteriaKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingCommandCenter:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingCommandCenterKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingCrypt:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingCryptKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingDancefloor:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingDancefloorKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingDungeon:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingDungeonKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingElevator:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingElevatorKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingFactory:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingFactoryKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingFoyer:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingFoyerKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingGym:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingGymKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingHallway:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingHallwayKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingHospital:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingHospitalKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingHouseofworship:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingHouseofworshipKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingLobby:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingLobbyKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingMall:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingMallKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingOffice:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingOfficeKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingOfficeCubicle:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingOfficeCubicleKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingOpenOffice:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingOpenOfficeKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingPrison:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingPrisonKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRestaurant:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingRestaurantKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBath:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBathKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBed:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBedKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomClass:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomClassKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomCloset:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomClosetKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomConference:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomConferenceKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomCourt:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomCourtKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomDining:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomDiningKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchen:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchenKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchenCommercial:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchenCommercialKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomLiving:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomLivingKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomStudy:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomStudyKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomThrone:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomThroneKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStage:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingStageKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStairwell:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingStairwellKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStationBus:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingStationBusKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStationFire:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingStationFireKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStationPolice:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingStationPoliceKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStationSubway:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingStationSubwayKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStationTrain:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingStationTrainKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStore:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingStoreKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStoreAisle:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingStoreAisleKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStoreCheckout:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingStoreCheckoutKey;
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingWarehouse:
            return kCinemaNetClassLabelShotLocationInteriorStructureBuildingWarehouseKey;
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCabin:
            return kCinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCabinKey;
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCockpit:
            return kCinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCockpitKey;
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleBoat:
            return kCinemaNetClassLabelShotLocationInteriorStructureVehicleBoatKey;
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleBus:
            return kCinemaNetClassLabelShotLocationInteriorStructureVehicleBusKey;
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleCar:
            return kCinemaNetClassLabelShotLocationInteriorStructureVehicleCarKey;
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleHelicopter:
            return kCinemaNetClassLabelShotLocationInteriorStructureVehicleHelicopterKey;
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleSpacecraft:
            return kCinemaNetClassLabelShotLocationInteriorStructureVehicleSpacecraftKey;
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleSubway:
            return kCinemaNetClassLabelShotLocationInteriorStructureVehicleSubwayKey;
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleTrain:
            return kCinemaNetClassLabelShotLocationInteriorStructureVehicleTrainKey;
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleTruck:
            return kCinemaNetClassLabelShotLocationInteriorStructureVehicleTruckKey;
        case CinemaNetClassLabelShotLocationNa:
            return kCinemaNetClassLabelShotLocationNaKey;
        
            
        case CinemaNetClassLabelShotSubjectAnimal:
            return kCinemaNetClassLabelShotSubjectAnimalKey;
        case CinemaNetClassLabelShotSubjectLocation:
            return kCinemaNetClassLabelShotSubjectLocationKey;
        case CinemaNetClassLabelShotSubjectObject:
            return kCinemaNetClassLabelShotSubjectObjectKey;
        case CinemaNetClassLabelShotSubjectPerson:
            return kCinemaNetClassLabelShotSubjectPersonKey;
        case CinemaNetClassLabelShotSubjectPersonBody:
            return kCinemaNetClassLabelShotSubjectPersonBodyKey;
        case CinemaNetClassLabelShotSubjectPersonFace:
            return kCinemaNetClassLabelShotSubjectPersonFaceKey;
        case CinemaNetClassLabelShotSubjectPersonFeet:
            return kCinemaNetClassLabelShotSubjectPersonFeetKey;
        case CinemaNetClassLabelShotSubjectPersonHands:
            return kCinemaNetClassLabelShotSubjectPersonHandsKey;
        case CinemaNetClassLabelShotSubjectText:
            return kCinemaNetClassLabelShotSubjectTextKey;
        case CinemaNetClassLabelShotSubjectNa:
            return kCinemaNetClassLabelShotSubjectNaKey;
            
        case CinemaNetClassLabelShotTimeofdayDay:
            return kCinemaNetClassLabelShotTimeofdayDayKey;
        case CinemaNetClassLabelShotTimeofdayNight:
            return kCinemaNetClassLabelShotTimeofdayNightKey;
        case CinemaNetClassLabelShotTimeofdayTwilight:
            return kCinemaNetClassLabelShotTimeofdayTwilightKey;
        case CinemaNetClassLabelShotTimeofdayNa:
            return kCinemaNetClassLabelShotTimeofdayNaKey;
            
        case CinemaNetClassLabelShotTypeMaster:
            return kCinemaNetClassLabelShotTypeMasterKey;
        case CinemaNetClassLabelShotTypeOvertheshoulder:
            return kCinemaNetClassLabelShotTypeOvertheshoulderKey;
        case CinemaNetClassLabelShotTypePortrait:
            return kCinemaNetClassLabelShotTypePortraitKey;
        case CinemaNetClassLabelShotTypeTwoshot:
            return kCinemaNetClassLabelShotTypeTwoshotKey;
        case CinemaNetClassLabelShotTypeNa:
            return kCinemaNetClassLabelShotTypeNaKey;
            
        case CinemaNetClassLabelTextureBanded:
            return kCinemaNetClassLabelTextureBandedKey;
        case CinemaNetClassLabelTextureBlotchy:
            return kCinemaNetClassLabelTextureBlotchyKey;
        case CinemaNetClassLabelTextureBraided:
            return kCinemaNetClassLabelTextureBraidedKey;
        case CinemaNetClassLabelTextureBubbly:
            return kCinemaNetClassLabelTextureBubblyKey;
        case CinemaNetClassLabelTextureBumpy:
            return kCinemaNetClassLabelTextureBumpyKey;
        case CinemaNetClassLabelTextureChequered:
            return kCinemaNetClassLabelTextureChequeredKey;
        case CinemaNetClassLabelTextureCobwebbed:
            return kCinemaNetClassLabelTextureCobwebbedKey;
        case CinemaNetClassLabelTextureCracked:
            return kCinemaNetClassLabelTextureCrackedKey;
        case CinemaNetClassLabelTextureCrosshatched:
            return kCinemaNetClassLabelTextureCrosshatchedKey;
        case CinemaNetClassLabelTextureCrystalline:
            return kCinemaNetClassLabelTextureCrystallineKey;
        case CinemaNetClassLabelTextureDotted:
            return kCinemaNetClassLabelTextureDottedKey;
        case CinemaNetClassLabelTextureFibrous:
            return kCinemaNetClassLabelTextureFibrousKey;
        case CinemaNetClassLabelTextureFlecked:
            return kCinemaNetClassLabelTextureFleckedKey;
        case CinemaNetClassLabelTextureFrilly:
            return kCinemaNetClassLabelTextureFrillyKey;
        case CinemaNetClassLabelTextureGauzy:
            return kCinemaNetClassLabelTextureGauzyKey;
        case CinemaNetClassLabelTextureGrid:
            return kCinemaNetClassLabelTextureGridKey;
        case CinemaNetClassLabelTextureGrooved:
            return kCinemaNetClassLabelTextureGroovedKey;
        case CinemaNetClassLabelTextureHoneycombed:
            return kCinemaNetClassLabelTextureHoneycombedKey;
        case CinemaNetClassLabelTextureInterlaced:
            return kCinemaNetClassLabelTextureInterlacedKey;
        case CinemaNetClassLabelTextureKnitted:
            return kCinemaNetClassLabelTextureKnittedKey;
        case CinemaNetClassLabelTextureLacelike:
            return kCinemaNetClassLabelTextureLacelikeKey;
        case CinemaNetClassLabelTextureLined:
            return kCinemaNetClassLabelTextureLinedKey;
        case CinemaNetClassLabelTextureMarbled:
            return kCinemaNetClassLabelTextureMarbledKey;
        case CinemaNetClassLabelTextureMatted:
            return kCinemaNetClassLabelTextureMattedKey;
        case CinemaNetClassLabelTextureMeshed:
            return kCinemaNetClassLabelTextureMeshedKey;
        case CinemaNetClassLabelTexturePaisley:
            return kCinemaNetClassLabelTexturePaisleyKey;
        case CinemaNetClassLabelTexturePerforated:
            return kCinemaNetClassLabelTexturePerforatedKey;
        case CinemaNetClassLabelTexturePitted:
            return kCinemaNetClassLabelTexturePittedKey;
        case CinemaNetClassLabelTexturePleated:
            return kCinemaNetClassLabelTexturePleatedKey;
        case CinemaNetClassLabelTexturePorous:
            return kCinemaNetClassLabelTexturePorousKey;
        case CinemaNetClassLabelTexturePotholed:
            return kCinemaNetClassLabelTexturePotholedKey;
        case CinemaNetClassLabelTextureScaly:
            return kCinemaNetClassLabelTextureScalyKey;
        case CinemaNetClassLabelTextureSmeared:
            return kCinemaNetClassLabelTextureSmearedKey;
        case CinemaNetClassLabelTextureSpiralled:
            return kCinemaNetClassLabelTextureSpiralledKey;
        case CinemaNetClassLabelTextureSprinkled:
            return kCinemaNetClassLabelTextureSprinkledKey;
        case CinemaNetClassLabelTextureStained:
            return kCinemaNetClassLabelTextureStainedKey;
        case CinemaNetClassLabelTextureStratified:
            return kCinemaNetClassLabelTextureStratifiedKey;
        case CinemaNetClassLabelTextureStriped:
            return kCinemaNetClassLabelTextureStripedKey;
        case CinemaNetClassLabelTextureStudded:
            return kCinemaNetClassLabelTextureStuddedKey;
        case CinemaNetClassLabelTextureSwirly:
            return kCinemaNetClassLabelTextureSwirlyKey;
        case CinemaNetClassLabelTextureVeined:
            return kCinemaNetClassLabelTextureVeinedKey;
        case CinemaNetClassLabelTextureWaffled:
            return kCinemaNetClassLabelTextureWaffledKey;
        case CinemaNetClassLabelTextureWoven:
            return kCinemaNetClassLabelTextureWovenKey;
        case CinemaNetClassLabelTextureWrinkled:
            return kCinemaNetClassLabelTextureWrinkledKey;
        case CinemaNetClassLabelTextureZigzagged:
            return kCinemaNetClassLabelTextureZigzaggedKey;
            
            // Proxy for returning an unknown label - for unsupported versions or invalid keys
        case CinemaNetClassLabelUnknown:
            return nil;
    }
}
    
// Valid key to CinemaNetClassLabel enum. Invalid keys return CinemaNetClassLabelUnknown.
// This sucks:
CinemaNetClassLabel CinemanetClassLabelForLabelKey(NSString* key)
{
    if ([kCinemaNetClassLabelColorKeyBlueKey isEqualToString:key])
    {
        return CinemaNetClassLabelColorKeyBlue;
    }
    else if ([kCinemaNetClassLabelColorKeyGreenKey isEqualToString:key])
    {
        return CinemaNetClassLabelColorKeyGreen;
    }
    else if ([kCinemaNetClassLabelColorKeyLumaKey isEqualToString:key])
    {
        return CinemaNetClassLabelColorKeyLuma;
    }
    else if ([kCinemaNetClassLabelColorKeyMatteKey isEqualToString:key])
    {
        return CinemaNetClassLabelColorKeyMatte;
    }
    else if ([kCinemaNetClassLabelColorKeyNaKey isEqualToString:key])
    {
        return CinemaNetClassLabelColorKeyNa;
    }
    else if ([kCinemaNetClassLabelColorSaturationDesaturatedKey isEqualToString:key])
    {
        return CinemaNetClassLabelColorSaturationDesaturated;
    }
    else if ([kCinemaNetClassLabelColorSaturationNeutralKey isEqualToString:key])
    {
        return CinemaNetClassLabelColorSaturationNeutral;
    }
    else if ([kCinemaNetClassLabelColorSaturationPastelKey isEqualToString:key])
    {
        return CinemaNetClassLabelColorSaturationPastel;
    }
    else if ([kCinemaNetClassLabelColorSaturationSaturatedKey isEqualToString:key])
    {
        return CinemaNetClassLabelColorSaturationSaturated;
    }
    else if ([kCinemaNetClassLabelColorTheoryAnalagousKey isEqualToString:key])
    {
        return CinemaNetClassLabelColorTheoryAnalagous;
    }
    else if ([kCinemaNetClassLabelColorTheoryComplementaryKey isEqualToString:key])
    {
        return CinemaNetClassLabelColorTheoryComplementary;
    }
    else if ([kCinemaNetClassLabelColorTheoryMonochromeKey isEqualToString:key])
    {
        return CinemaNetClassLabelColorTheoryMonochrome;
    }
    else if ([kCinemaNetClassLabelColorTonesBlackWhiteKey isEqualToString:key])
    {
        return CinemaNetClassLabelColorTonesBlackWhite;
    }
    else if ([kCinemaNetClassLabelColorTonesCoolKey isEqualToString:key])
    {
        return CinemaNetClassLabelColorTonesCool;
    }
    else if ([kCinemaNetClassLabelColorTonesWarmKey isEqualToString:key])
    {
        return CinemaNetClassLabelColorTonesWarm;
    }
    else if ([kCinemaNetClassLabelShotAngleAerialKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotAngleAerial;
    }
    else if ([kCinemaNetClassLabelShotAngleEyeLevelKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotAngleEyeLevel;
    }
    else if ([kCinemaNetClassLabelShotAngleHighKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotAngleHigh;
    }
    else if ([kCinemaNetClassLabelShotAngleLowKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotAngleLow;
    }
    else if ([kCinemaNetClassLabelShotAngleNaKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotAngleNa;
    }
    else if ([kCinemaNetClassLabelShotFocusDeepKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotFocusDeep;
    }
    else if ([kCinemaNetClassLabelShotFocusOutKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotFocusOut;
    }
    else if ([kCinemaNetClassLabelShotFocusShallowKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotFocusShallow;
    }
    else if ([kCinemaNetClassLabelShotFocusNaKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotFocusNa;
    }
    else if ([kCinemaNetClassLabelShotFramingCloseupKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotFramingCloseup;
    }
    else if ([kCinemaNetClassLabelShotFramingExtremeCloseupKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotFramingExtremeCloseup;
    }
    else if ([kCinemaNetClassLabelShotFramingExtremeLongKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotFramingExtremeLong;
    }
    else if ([kCinemaNetClassLabelShotFramingLongKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotFramingLong;
    }
    else if ([kCinemaNetClassLabelShotFramingMediumKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotFramingMedium;
    }
    else if ([kCinemaNetClassLabelShotFramingNaKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotFramingNa;
    }
    else if ([kCinemaNetClassLabelShotLevelLevelKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLevelLevel;
    }
    else if ([kCinemaNetClassLabelShotLevelTiltedKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLevelTilted;
    }
    else if ([kCinemaNetClassLabelShotLevelNaKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLevelNa;
    }
    else if ([kCinemaNetClassLabelShotLightingHardKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLightingHard;
    }
    else if ([kCinemaNetClassLabelShotLightingKeyHighKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLightingKeyHigh;
    }
    else if ([kCinemaNetClassLabelShotLightingKeyLowKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLightingKeyLow;
    }
    else if ([kCinemaNetClassLabelShotLightingNeutralKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLightingNeutral;
    }
    else if ([kCinemaNetClassLabelShotLightingSilhouetteKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLightingSilhouette;
    }
    else if ([kCinemaNetClassLabelShotLightingSoftKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLightingSoft;
    }
    else if ([kCinemaNetClassLabelShotLightingNaKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLightingNa;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExterior;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorNatureBeachKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorNatureBeach;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorNatureCanyonKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorNatureCanyon;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorNatureCaveKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorNatureCave;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorNatureDesertKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorNatureDesert;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorNatureForestKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorNatureForest;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorNatureGlacierKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorNatureGlacier;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorNatureLakeKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorNatureLake;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorNatureMountainsKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorNatureMountains;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorNatureOceanKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorNatureOcean;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorNaturePlainsKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorNaturePlains;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorNaturePolarKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorNaturePolar;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorNatureRiverKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorNatureRiver;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorNatureSkyKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorNatureSky;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorNatureSpaceKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorNatureSpace;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorNatureWetlandsKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorNatureWetlands;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorSettlementCityKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorSettlementCity;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorSettlementSuburbKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorSettlementSuburb;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorSettlementTownKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorSettlementTown;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBridgeKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBridge;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingAirportKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingAirport;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingAutoBodyKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingAutoBody;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingCastleKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingCastle;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingHospitalKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingHospital;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingHouseofworshipKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingHouseofworship;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingLibraryKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingLibrary;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingMallKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingMall;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingOfficeKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingOffice;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceApartmentKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceApartment;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceHouseKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceHouse;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMansionKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMansion;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMonasteryKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMonastery;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingResidencePalaceKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingResidencePalace;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingRestaurantKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingRestaurant;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingSchoolKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingSchool;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingSkyscraperKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingSkyscraper;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingStadiumKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingStadium;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingStationGasKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingStationGas;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingStationSubwayKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingStationSubway;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingStationTrainKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingStationTrain;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingStoreKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingStore;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingTheaterKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingTheater;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBuildingWarehouseKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBuildingWarehouse;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureBusStopKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureBusStop;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureFarmKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureFarm;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureIndustrialKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureIndustrial;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureParkKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructurePark;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureParkinglotKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureParkinglot;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructurePierKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructurePier;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructurePlaygroundKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructurePlayground;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructurePortKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructurePort;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureRoadKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureRoad;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureRuinsKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureRuins;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureSidewalkKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureSidewalk;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureTunnelKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureTunnel;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureVehicleAirplaneKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureVehicleAirplane;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureVehicleBicycleKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureVehicleBicycle;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureVehicleBoatKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureVehicleBoat;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureVehicleBusKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureVehicleBus;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureVehicleCarKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureVehicleCar;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureVehicleHelicopterKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureVehicleHelicopter;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureVehicleMotorcycleKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureVehicleMotorcycle;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureVehicleSpacecraftKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureVehicleSpacecraft;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureVehicleTrainKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureVehicleTrain;
    }
    else if ([kCinemaNetClassLabelShotLocationExteriorStructureVehicleTruckKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationExteriorStructureVehicleTruck;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInterior;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorNatureCaveKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorNatureCave;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingAirportKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingAirport;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingArenaKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingArena;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingAuditoriumKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingAuditorium;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingAutoRepairShopKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingAutoRepairShop;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingBarKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingBar;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingBarnKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingBarn;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingCafeKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingCafe;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingCafeteriaKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingCafeteria;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingCommandCenterKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingCommandCenter;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingCryptKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingCrypt;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingDancefloorKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingDancefloor;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingDungeonKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingDungeon;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingElevatorKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingElevator;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingFactoryKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingFactory;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingFoyerKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingFoyer;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingGymKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingGym;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingHallwayKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingHallway;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingHospitalKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingHospital;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingHouseofworshipKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingHouseofworship;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingLobbyKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingLobby;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingMallKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingMall;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingOfficeKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingOffice;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingOfficeCubicleKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingOfficeCubicle;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingOpenOfficeKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingOpenOffice;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingPrisonKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingPrison;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingRestaurantKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingRestaurant;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBathKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBath;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBedKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBed;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomClassKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomClass;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomClosetKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomCloset;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomConferenceKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomConference;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomCourtKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomCourt;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomDiningKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomDining;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchenKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchen;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchenCommercialKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchenCommercial;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomLivingKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomLiving;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomStudyKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomStudy;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingRoomThroneKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomThrone;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingStageKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingStage;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingStairwellKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingStairwell;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingStationBusKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingStationBus;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingStationFireKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingStationFire;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingStationPoliceKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingStationPolice;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingStationSubwayKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingStationSubway;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingStationTrainKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingStationTrain;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingStoreKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingStore;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingStoreAisleKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingStoreAisle;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingStoreCheckoutKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingStoreCheckout;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureBuildingWarehouseKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureBuildingWarehouse;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCabinKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCabin;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCockpitKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCockpit;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureVehicleBoatKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureVehicleBoat;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureVehicleBusKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureVehicleBus;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureVehicleCarKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureVehicleCar;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureVehicleHelicopterKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureVehicleHelicopter;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureVehicleSpacecraftKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureVehicleSpacecraft;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureVehicleSubwayKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureVehicleSubway;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureVehicleTrainKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureVehicleTrain;
    }
    else if ([kCinemaNetClassLabelShotLocationInteriorStructureVehicleTruckKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationInteriorStructureVehicleTruck;
    }
    else if ([kCinemaNetClassLabelShotLocationNaKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotLocationNa;
    }
    else if ([kCinemaNetClassLabelShotSubjectAnimalKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotSubjectAnimal;
    }
    else if ([kCinemaNetClassLabelShotSubjectLocationKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotSubjectLocation;
    }
    else if ([kCinemaNetClassLabelShotSubjectObjectKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotSubjectObject;
    }
    else if ([kCinemaNetClassLabelShotSubjectPersonKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotSubjectPerson;
    }
    else if ([kCinemaNetClassLabelShotSubjectPersonBodyKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotSubjectPersonBody;
    }
    else if ([kCinemaNetClassLabelShotSubjectPersonFaceKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotSubjectPersonFace;
    }
    else if ([kCinemaNetClassLabelShotSubjectPersonFeetKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotSubjectPersonFeet;
    }
    else if ([kCinemaNetClassLabelShotSubjectPersonHandsKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotSubjectPersonHands;
    }
    else if ([kCinemaNetClassLabelShotSubjectTextKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotSubjectText;
    }
    else if ([kCinemaNetClassLabelShotSubjectNaKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotSubjectNa;
    }
    else if ([kCinemaNetClassLabelShotTimeofdayDayKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotTimeofdayDay;
    }
    else if ([kCinemaNetClassLabelShotTimeofdayNightKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotTimeofdayNight;
    }
    else if ([kCinemaNetClassLabelShotTimeofdayTwilightKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotTimeofdayTwilight;
    }
    else if ([kCinemaNetClassLabelShotTimeofdayNaKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotTimeofdayNa;
    }
    else if ([kCinemaNetClassLabelShotTypeMasterKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotTypeMaster;
    }
    else if ([kCinemaNetClassLabelShotTypeOvertheshoulderKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotTypeOvertheshoulder;
    }
    else if ([kCinemaNetClassLabelShotTypePortraitKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotTypePortrait;
    }
    else if ([kCinemaNetClassLabelShotTypeTwoshotKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotTypeTwoshot;
    }
    else if ([kCinemaNetClassLabelShotTypeNaKey isEqualToString:key])
    {
        return CinemaNetClassLabelShotTypeNa;
    }
    else if ([kCinemaNetClassLabelTextureBandedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureBanded;
    }
    else if ([kCinemaNetClassLabelTextureBlotchyKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureBlotchy;
    }
    else if ([kCinemaNetClassLabelTextureBraidedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureBraided;
    }
    else if ([kCinemaNetClassLabelTextureBubblyKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureBubbly;
    }
    else if ([kCinemaNetClassLabelTextureBumpyKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureBumpy;
    }
    else if ([kCinemaNetClassLabelTextureChequeredKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureChequered;
    }
    else if ([kCinemaNetClassLabelTextureCobwebbedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureCobwebbed;
    }
    else if ([kCinemaNetClassLabelTextureCrackedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureCracked;
    }
    else if ([kCinemaNetClassLabelTextureCrosshatchedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureCrosshatched;
    }
    else if ([kCinemaNetClassLabelTextureCrystallineKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureCrystalline;
    }
    else if ([kCinemaNetClassLabelTextureDottedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureDotted;
    }
    else if ([kCinemaNetClassLabelTextureFibrousKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureFibrous;
    }
    else if ([kCinemaNetClassLabelTextureFleckedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureFlecked;
    }
    else if ([kCinemaNetClassLabelTextureFrillyKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureFrilly;
    }
    else if ([kCinemaNetClassLabelTextureGauzyKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureGauzy;
    }
    else if ([kCinemaNetClassLabelTextureGridKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureGrid;
    }
    else if ([kCinemaNetClassLabelTextureGroovedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureGrooved;
    }
    else if ([kCinemaNetClassLabelTextureHoneycombedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureHoneycombed;
    }
    else if ([kCinemaNetClassLabelTextureInterlacedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureInterlaced;
    }
    else if ([kCinemaNetClassLabelTextureKnittedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureKnitted;
    }
    else if ([kCinemaNetClassLabelTextureLacelikeKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureLacelike;
    }
    else if ([kCinemaNetClassLabelTextureLinedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureLined;
    }
    else if ([kCinemaNetClassLabelTextureMarbledKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureMarbled;
    }
    else if ([kCinemaNetClassLabelTextureMattedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureMatted;
    }
    else if ([kCinemaNetClassLabelTextureMeshedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureMeshed;
    }
    else if ([kCinemaNetClassLabelTexturePaisleyKey isEqualToString:key])
    {
        return CinemaNetClassLabelTexturePaisley;
    }
    else if ([kCinemaNetClassLabelTexturePerforatedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTexturePerforated;
    }
    else if ([kCinemaNetClassLabelTexturePittedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTexturePitted;
    }
    else if ([kCinemaNetClassLabelTexturePleatedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTexturePleated;
    }
    else if ([kCinemaNetClassLabelTexturePorousKey isEqualToString:key])
    {
        return CinemaNetClassLabelTexturePorous;
    }
    else if ([kCinemaNetClassLabelTexturePotholedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTexturePotholed;
    }
    else if ([kCinemaNetClassLabelTextureScalyKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureScaly;
    }
    else if ([kCinemaNetClassLabelTextureSmearedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureSmeared;
    }
    else if ([kCinemaNetClassLabelTextureSpiralledKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureSpiralled;
    }
    else if ([kCinemaNetClassLabelTextureSprinkledKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureSprinkled;
    }
    else if ([kCinemaNetClassLabelTextureStainedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureStained;
    }
    else if ([kCinemaNetClassLabelTextureStratifiedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureStratified;
    }
    else if ([kCinemaNetClassLabelTextureStripedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureStriped;
    }
    else if ([kCinemaNetClassLabelTextureStuddedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureStudded;
    }
    else if ([kCinemaNetClassLabelTextureSwirlyKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureSwirly;
    }
    else if ([kCinemaNetClassLabelTextureVeinedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureVeined;
    }
    else if ([kCinemaNetClassLabelTextureWaffledKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureWaffled;
    }
    else if ([kCinemaNetClassLabelTextureWovenKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureWoven;
    }
    else if ([kCinemaNetClassLabelTextureWrinkledKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureWrinkled;
    }
    else if ([kCinemaNetClassLabelTextureZigzaggedKey isEqualToString:key])
    {
        return CinemaNetClassLabelTextureZigzagged;
    }
    
    
    return CinemaNetClassLabelUnknown;
}

// Human Readable descriptor for a class label:
extern NSString* CinemaNetLabelDescriptorForClassLabel(CinemaNetClassLabel label)
{
    switch(label)
    {
        case CinemaNetClassLabelColorKeyBlue:
            return @"Blue Screen";
        case CinemaNetClassLabelColorKeyGreen:
            return @"Green Screen";
        case CinemaNetClassLabelColorKeyLuma:
            return @"Luma Key";
        case CinemaNetClassLabelColorKeyMatte:
            return @"Matte";
        case CinemaNetClassLabelColorKeyNa:
            return nil;
      
        case CinemaNetClassLabelColorSaturationDesaturated:
            return @"Desaturated Colors";
        case CinemaNetClassLabelColorSaturationNeutral:
            return @"Neutral Colors";
        case CinemaNetClassLabelColorSaturationPastel:
            return @"Pastel Colors";
        case CinemaNetClassLabelColorSaturationSaturated:
            return @"Saturated Colors";

        case CinemaNetClassLabelColorTheoryAnalagous:
            return @"Analgous Colors";
        case CinemaNetClassLabelColorTheoryComplementary:
            return @"Complementary Colors";
        case CinemaNetClassLabelColorTheoryMonochrome:
            return @"Monochromatic Colors";

        case CinemaNetClassLabelColorTonesBlackWhite:
            return @"Black and White Colors";
        case CinemaNetClassLabelColorTonesCool:
            return @"Cool Colors";
        case CinemaNetClassLabelColorTonesWarm:
            return @"Warm Colors";

        case CinemaNetClassLabelShotAngleAerial:
            return @"Aerial Shot";
        case CinemaNetClassLabelShotAngleEyeLevel:
            return @"Eye Level Shot";
        case CinemaNetClassLabelShotAngleHigh:
            return @"High Angle Shot";
        case CinemaNetClassLabelShotAngleLow:
            return @"Low Angle Shot";
        case CinemaNetClassLabelShotAngleNa:
            return nil;

        case CinemaNetClassLabelShotFocusDeep:
            return @"Deep Focus Shot";
        case CinemaNetClassLabelShotFocusOut:
            return @"Out of Focus Shot";
        case CinemaNetClassLabelShotFocusShallow:
            return @"Shallow Focus Shot";
        case CinemaNetClassLabelShotFocusNa:
            return nil;
      
        case CinemaNetClassLabelShotFramingCloseup:
            return @"Close Up Shot";
        case CinemaNetClassLabelShotFramingExtremeCloseup:
            return @"Extreme Close Up Shot";
        case CinemaNetClassLabelShotFramingExtremeLong:
            return @"Extreme Long Shot";
        case CinemaNetClassLabelShotFramingLong:
            return @"Long Shot";
        case CinemaNetClassLabelShotFramingMedium:
            return @"Medium Shot";
        case CinemaNetClassLabelShotFramingNa:
            return nil;
            
        case CinemaNetClassLabelShotLevelLevel:
            return @"Level Shot";
        case CinemaNetClassLabelShotLevelTilted:
            return @"Tilted (Canted) Shot";
        case CinemaNetClassLabelShotLevelNa:
            return nil;
      
        case CinemaNetClassLabelShotLightingHard:
            return @"Hard Lighting";
        case CinemaNetClassLabelShotLightingKeyHigh:
            return @"High Key Lighting";
        case CinemaNetClassLabelShotLightingKeyLow:
            return @"Low Key Lighting";
        case CinemaNetClassLabelShotLightingNeutral:
            return @"Neutral (Natural) Lighting";
        case CinemaNetClassLabelShotLightingSilhouette:
            return @"Silhouette Lighting";
        case CinemaNetClassLabelShotLightingSoft:
            return @"Soft Lighting";
        case CinemaNetClassLabelShotLightingNa:
            return nil;

        case CinemaNetClassLabelShotLocationExterior:
            return @"Exterior Shot";
        case CinemaNetClassLabelShotLocationExteriorNatureBeach:
            return @"Exterior Beach";
        case CinemaNetClassLabelShotLocationExteriorNatureCanyon:
            return @"Exterior Canyon";
        case CinemaNetClassLabelShotLocationExteriorNatureCave:
            return @"Exterior Cave";
        case CinemaNetClassLabelShotLocationExteriorNatureDesert:
            return @"Exterior Desert";
        case CinemaNetClassLabelShotLocationExteriorNatureForest:
            return @"Exterior Forest";
        case CinemaNetClassLabelShotLocationExteriorNatureGlacier:
            return @"Exterior Glacier";
        case CinemaNetClassLabelShotLocationExteriorNatureLake:
            return @"Exterior Lake";
        case CinemaNetClassLabelShotLocationExteriorNatureMountains:
            return @"Exterior Mountains";
        case CinemaNetClassLabelShotLocationExteriorNatureOcean:
            return @"Exterior Ocean";
        case CinemaNetClassLabelShotLocationExteriorNaturePlains:
            return @"Exterior Plains";
        case CinemaNetClassLabelShotLocationExteriorNaturePolar:
            return @"Exterior Polar";
        case CinemaNetClassLabelShotLocationExteriorNatureRiver:
            return @"Exterior River";
        case CinemaNetClassLabelShotLocationExteriorNatureSky:
            return @"Exterior Sky";
        case CinemaNetClassLabelShotLocationExteriorNatureSpace:
            return @"Exterior Space";
        case CinemaNetClassLabelShotLocationExteriorNatureWetlands:
            return @"Exterior Wetlands";
        case CinemaNetClassLabelShotLocationExteriorSettlementCity:
            return @"Exterior City";
        case CinemaNetClassLabelShotLocationExteriorSettlementSuburb:
            return @"Exterior Suburb";
        case CinemaNetClassLabelShotLocationExteriorSettlementTown:
            return @"Exterior Town";
        case CinemaNetClassLabelShotLocationExteriorStructureBridge:
            return @"Exterior Bridge";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingAirport:
            return @"Exterior Airport";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingAutoBody:
            return @"Exterior Auto Body Shop";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingCastle:
            return @"Exterior Castle";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingHospital:
            return @"Exterior Hospital";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingHouseofworship:
            return @"Exterior House of Worship";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingLibrary:
            return @"Exterior Library";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingMall:
            return @"Exterior Mall";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingOffice:
            return @"Exterior Office Building";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceApartment:
            return @"Exterior Apartment Building";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceHouse:
            return @"Exterior House";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMansion:
            return @"Exterior Mansion";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMonastery:
            return @"Exterior Monastery";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingResidencePalace:
            return @"Exterior Palace";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingRestaurant:
            return @"Exterior Restaurant";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingSchool:
            return @"Exterior School";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingSkyscraper:
            return @"Exterior Skyscraper";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingStadium:
            return @"Exterior Stadium";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingStationGas:
            return @"Exterior Gas Station";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingStationSubway:
            return @"Exterior Subway Station";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingStationTrain:
            return @"Exterior Train Station";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingStore:
            return @"Exterior Store";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingTheater:
            return @"Exterior Theater";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingWarehouse:
            return @"Exterior Warehouse";
        case CinemaNetClassLabelShotLocationExteriorStructureBusStop:
            return @"Exterior Bus Stop";
        case CinemaNetClassLabelShotLocationExteriorStructureFarm:
            return @"Exterior Farm";
        case CinemaNetClassLabelShotLocationExteriorStructureIndustrial:
            return @"Exterior Industrial Building";
        case CinemaNetClassLabelShotLocationExteriorStructurePark:
            return @"Exterior Park";
        case CinemaNetClassLabelShotLocationExteriorStructureParkinglot:
            return @"Exterior Parking Lot";
        case CinemaNetClassLabelShotLocationExteriorStructurePier:
            return @"Exterior Pier";
        case CinemaNetClassLabelShotLocationExteriorStructurePlayground:
            return @"Exterior Playground";
        case CinemaNetClassLabelShotLocationExteriorStructurePort:
            return @"Exterior Port";
        case CinemaNetClassLabelShotLocationExteriorStructureRoad:
            return @"Exterior Road";
        case CinemaNetClassLabelShotLocationExteriorStructureRuins:
            return @"Exterior Ruins";
        case CinemaNetClassLabelShotLocationExteriorStructureSidewalk:
            return @"Exterior Sidewalk";
        case CinemaNetClassLabelShotLocationExteriorStructureTunnel:
            return @"Exterior Tunnel";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleAirplane:
            return @"Exterior Airplane";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleBicycle:
            return @"Exterior Bicycle";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleBoat:
            return @"Exterior Boat";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleBus:
            return @"Exterior Bus";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleCar:
            return @"Exterior Car";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleHelicopter:
            return @"Exterior Helicopter";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleMotorcycle:
            return @"Exterior Motorcycle";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleSpacecraft:
            return @"Exterior Spacecraft";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleTrain:
            return @"Exterior Train";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleTruck:
            return @"Exterior Truck";
        case CinemaNetClassLabelShotLocationInterior:
            return @"Interior Shot";
        case CinemaNetClassLabelShotLocationInteriorNatureCave:
            return @"Interior Cave";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingAirport:
            return @"Interior Airport";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingArena:
            return @"Interior Arena";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingAuditorium:
            return @"Interior Auditorium";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingAutoRepairShop:
            return @"Interior Auto Repair Shop";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingBar:
            return @"Interior Bar";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingBarn:
            return @"Interior Barn";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingCafe:
            return @"Interior Cafe";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingCafeteria:
            return @"Interior Cafeteria";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingCommandCenter:
            return @"Interior Command Center";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingCrypt:
            return @"Interior Crypt";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingDancefloor:
            return @"Interior Dance Floor";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingDungeon:
            return @"Interior Dungeon";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingElevator:
            return @"Interior Elevator";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingFactory:
            return @"Interior Factory";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingFoyer:
            return @"Interior Foyer";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingGym:
            return @"Interior Gym";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingHallway:
            return @"Interior Hallway";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingHospital:
            return @"Interior Hospital";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingHouseofworship:
            return @"Interior House of Worship";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingLobby:
            return @"Interior Lobby";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingMall:
            return @"Interior Mall";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingOffice:
            return @"Interior Office";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingOfficeCubicle:
            return @"Interior Office Cubicle";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingOpenOffice:
            return @"Interior Open Office";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingPrison:
            return @"Interior Prison";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRestaurant:
            return @"Interior Restaurant";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBath:
            return @"Interior Bathroom";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBed:
            return @"Interior Bedroom";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomClass:
            return @"Interior Classroom";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomCloset:
            return @"Interior Closet";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomConference:
            return @"Interior Conference Room";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomCourt:
            return @"Interior Courtroom";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomDining:
            return @"Interior Dining Room";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchen:
            return @"Interior Kitchen";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchenCommercial:
            return @"Interior Commercial Kitchen";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomLiving:
            return @"Interior Living Room";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomStudy:
            return @"Interior Study";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomThrone:
            return @"Interior Throne Room";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStage:
            return @"Interior Stage";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStairwell:
            return @"Interior Stairwell";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStationBus:
            return @"Interior Bus Station";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStationFire:
            return @"Interior Fire Station";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStationPolice:
            return @"Interior Police Station";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStationSubway:
            return @"Interior Subway Station";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStationTrain:
            return @"Interior Train Station";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStore:
            return @"Interior Store";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStoreAisle:
            return @"Interior Store Aisle";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStoreCheckout:
            return @"Interior Store Checkout";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingWarehouse:
            return @"Interior Warehouse";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCabin:
            return @"Interior Airplane Cabin";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCockpit:
            return @"Interior Airplane Cockpit";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleBoat:
            return @"Interior Boat";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleBus:
            return @"Interior Bus";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleCar:
            return @"Interior Car";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleHelicopter:
            return @"Interior Helicopter";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleSpacecraft:
            return @"Interior Spacecraft";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleSubway:
            return @"Interior Subway";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleTrain:
            return @"Interior Train";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleTruck:
            return @"Interior Truck";
        case CinemaNetClassLabelShotLocationNa:
            return nil;

        case CinemaNetClassLabelShotSubjectAnimal:
            return @"Shot Subject Animal";
        case CinemaNetClassLabelShotSubjectLocation:
            return @"Shot Subject Location";
        case CinemaNetClassLabelShotSubjectObject:
            return @"Shot Subject Object";
        case CinemaNetClassLabelShotSubjectPerson:
            return @"Shot Subject Person/People";
        case CinemaNetClassLabelShotSubjectPersonBody:
            return @"Shot Subject Body/Bodies";
        case CinemaNetClassLabelShotSubjectPersonFace:
            return @"Shot Subject Face/Faces";
        case CinemaNetClassLabelShotSubjectPersonFeet:
            return @"Shot Subject Feet";
        case CinemaNetClassLabelShotSubjectPersonHands:
            return @"Shot Subject Hand/Hands";
        case CinemaNetClassLabelShotSubjectText:
            return @"Shot Subject Text";
        case CinemaNetClassLabelShotSubjectNa:
            return nil;
            
        case CinemaNetClassLabelShotTimeofdayDay:
            return @"Day";
        case CinemaNetClassLabelShotTimeofdayNight:
            return @"Night";
        case CinemaNetClassLabelShotTimeofdayTwilight:
            return @"Twilight";
        case CinemaNetClassLabelShotTimeofdayNa:
            return nil;
      
        case CinemaNetClassLabelShotTypeMaster:
            return @"Master Shot";
        case CinemaNetClassLabelShotTypeOvertheshoulder:
            return @"Over the Shoulder Shot";
        case CinemaNetClassLabelShotTypePortrait:
            return @"Portrait Shot";
        case CinemaNetClassLabelShotTypeTwoshot:
            return @"Two Shot";
        case CinemaNetClassLabelShotTypeNa:
            return nil;

        case CinemaNetClassLabelTextureBanded:
            return @"Banded";
        case CinemaNetClassLabelTextureBlotchy:
            return @"Blotchy";
        case CinemaNetClassLabelTextureBraided:
            return @"Braided";
        case CinemaNetClassLabelTextureBubbly:
            return @"Bubbly";
        case CinemaNetClassLabelTextureBumpy:
            return @"Bumpy";
        case CinemaNetClassLabelTextureChequered:
            return @"Chequered";
        case CinemaNetClassLabelTextureCobwebbed:
            return @"Cobwebbed";
        case CinemaNetClassLabelTextureCracked:
            return @"Cracked";
        case CinemaNetClassLabelTextureCrosshatched:
            return @"Crosshatched";
        case CinemaNetClassLabelTextureCrystalline:
            return @"Crystalline";
        case CinemaNetClassLabelTextureDotted:
            return @"Dotted";
        case CinemaNetClassLabelTextureFibrous:
            return @"Fibrous";
        case CinemaNetClassLabelTextureFlecked:
            return @"Flecked";
        case CinemaNetClassLabelTextureFrilly:
            return @"Frilly";
        case CinemaNetClassLabelTextureGauzy:
            return @"Gauzy";
        case CinemaNetClassLabelTextureGrid:
            return @"Grid";
        case CinemaNetClassLabelTextureGrooved:
            return @"Grooved";
        case CinemaNetClassLabelTextureHoneycombed:
            return @"Honeycombed";
        case CinemaNetClassLabelTextureInterlaced:
            return @"Interlaced";
        case CinemaNetClassLabelTextureKnitted:
            return @"Knitted";
        case CinemaNetClassLabelTextureLacelike:
            return @"Lacelike";
        case CinemaNetClassLabelTextureLined:
            return @"Lined";
        case CinemaNetClassLabelTextureMarbled:
            return @"Marbled";
        case CinemaNetClassLabelTextureMatted:
            return @"Matted";
        case CinemaNetClassLabelTextureMeshed:
            return @"Meshed";
        case CinemaNetClassLabelTexturePaisley:
            return @"Paisley";
        case CinemaNetClassLabelTexturePerforated:
            return @"Perforated";
        case CinemaNetClassLabelTexturePitted:
            return @"Pitted";
        case CinemaNetClassLabelTexturePleated:
            return @"Pleated";
        case CinemaNetClassLabelTexturePorous:
            return @"Porous";
        case CinemaNetClassLabelTexturePotholed:
            return @"Potholed";
        case CinemaNetClassLabelTextureScaly:
            return @"Scaly";
        case CinemaNetClassLabelTextureSmeared:
            return @"Smeared";
        case CinemaNetClassLabelTextureSpiralled:
            return @"Spiralled";
        case CinemaNetClassLabelTextureSprinkled:
            return @"Sprinkled";
        case CinemaNetClassLabelTextureStained:
            return @"Stained";
        case CinemaNetClassLabelTextureStratified:
            return @"Stratified";
        case CinemaNetClassLabelTextureStriped:
            return @"Striped";
        case CinemaNetClassLabelTextureStudded:
            return @"Studded";
        case CinemaNetClassLabelTextureSwirly:
            return @"Swirly";
        case CinemaNetClassLabelTextureVeined:
            return @"Veined";
        case CinemaNetClassLabelTextureWaffled:
            return @"Waffled";
        case CinemaNetClassLabelTextureWoven:
            return @"Woven";
        case CinemaNetClassLabelTextureWrinkled:
            return @"Wrinkled";
        case CinemaNetClassLabelTextureZigzagged:
            return @"Zigzagged";
      
      // Proxy for returning an unknown label - for unsupported versions or invalid keys
        case CinemaNetClassLabelUnknown:
            return nil;
    }
}


    
#ifdef __cplusplus
}
#endif
