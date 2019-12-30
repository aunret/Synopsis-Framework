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
            return @"color.key.blue";
        case CinemaNetClassLabelColorKeyGreen:
            return @"color.key.green";
        case CinemaNetClassLabelColorKeyLuma:
            return @"color.key.luma";
        case CinemaNetClassLabelColorKeyMatte:
            return @"color.key.matte";
        case CinemaNetClassLabelColorKeyNa:
            return @"color.key.na";
            
        case CinemaNetClassLabelColorSaturationDesaturated:
            return @"color.saturation.desaturated";
        case CinemaNetClassLabelColorSaturationNeutral:
            return @"color.saturation.neutral";
        case CinemaNetClassLabelColorSaturationPastel:
            return @"color.saturation.pastel";
        case CinemaNetClassLabelColorSaturationSaturated:
            return @"color.saturation.saturated";
            
        case CinemaNetClassLabelColorTheoryAnalagous:
            return @"color.theory.analagous";
        case CinemaNetClassLabelColorTheoryComplementary:
            return @"color.theory.complementary";
        case CinemaNetClassLabelColorTheoryMonochrome:
            return @"color.theory.monochrome";
            
        case CinemaNetClassLabelColorTonesBlackWhite:
            return @"color.tones.blackwhite";
        case CinemaNetClassLabelColorTonesCool:
            return @"color.tones.cool";
        case CinemaNetClassLabelColorTonesWarm:
            return @"color.tones.warm";
            
        case CinemaNetClassLabelShotAngleAerial:
            return @"shot.angle.aerial";
        case CinemaNetClassLabelShotAngleEyeLevel:
            return @"shot.angle.eyelevel";
        case CinemaNetClassLabelShotAngleHigh:
            return @"shot.angle.high";
        case CinemaNetClassLabelShotAngleLow:
            return @"shot.angle.low";
        case CinemaNetClassLabelShotAngleNa:
            return @"shot.angle.na";
            
        case CinemaNetClassLabelShotFocusDeep:
            return @"shot.focus.deep";
        case CinemaNetClassLabelShotFocusOut:
            return @"shot.focus.out";
        case CinemaNetClassLabelShotFocusShallow:
            return @"shot.focus.shallow";
        case CinemaNetClassLabelShotFocusNa:
            return @"shot.focus.na";
            
        case CinemaNetClassLabelShotFramingCloseup:
            return @"shot.framing.closeup";
        case CinemaNetClassLabelShotFramingExtremeCloseup:
            return @"shot.framing.extremecloseup";
        case CinemaNetClassLabelShotFramingExtremeLong:
            return @"shot.framing.extremelong";
        case CinemaNetClassLabelShotFramingLong:
            return @"shot.framing.long";
        case CinemaNetClassLabelShotFramingMedium:
            return @"shot.framing.medium";
        case CinemaNetClassLabelShotFramingNa:
            return @"shot.framing.na";
            
        case CinemaNetClassLabelShotLevelLevel:
            return @"shot.level.level";
        case CinemaNetClassLabelShotLevelTilted:
            return @"shot.level.tilted";
        case CinemaNetClassLabelShotLevelNa:
            return @"shot.level.na";
            
        case CinemaNetClassLabelShotLightingHard:
            return @"shot.lighting.hard";
        case CinemaNetClassLabelShotLightingKeyHigh:
            return @"shot.lighting.key.high";
        case CinemaNetClassLabelShotLightingKeyLow:
            return @"shot.lighting.key.low";
        case CinemaNetClassLabelShotLightingNeutral:
            return @"shot.lighting.neutral";
        case CinemaNetClassLabelShotLightingSilhouette:
            return @"shot.lighting.silhouette";
        case CinemaNetClassLabelShotLightingSoft:
            return @"shot.lighting.soft";
        case CinemaNetClassLabelShotLightingNa:
            return @"shot.lighting.na";
            
        case CinemaNetClassLabelShotLocationExterior:
            return @"shot.location.exterior";
        case CinemaNetClassLabelShotLocationExteriorNatureBeach:
            return @"shot.location.exterior.nature.beach";
        case CinemaNetClassLabelShotLocationExteriorNatureCanyon:
            return @"shot.location.exterior.nature.canyon";
        case CinemaNetClassLabelShotLocationExteriorNatureCave:
            return @"shot.location.exterior.nature.cave";
        case CinemaNetClassLabelShotLocationExteriorNatureDesert:
            return @"shot.location.exterior.nature.desert";
        case CinemaNetClassLabelShotLocationExteriorNatureForest:
            return @"shot.location.exterior.nature.forest";
        case CinemaNetClassLabelShotLocationExteriorNatureGlacier:
            return @"shot.location.exterior.nature.glacier";
        case CinemaNetClassLabelShotLocationExteriorNatureLake:
            return @"shot.location.exterior.nature.lake";
        case CinemaNetClassLabelShotLocationExteriorNatureMountains:
            return @"shot.location.exterior.nature.mountains";
        case CinemaNetClassLabelShotLocationExteriorNatureOcean:
            return @"shot.location.exterior.nature.ocean";
        case CinemaNetClassLabelShotLocationExteriorNaturePlains:
            return @"shot.location.exterior.nature.plains";
        case CinemaNetClassLabelShotLocationExteriorNaturePolar:
            return @"shot.location.exterior.nature.polar";
        case CinemaNetClassLabelShotLocationExteriorNatureRiver:
            return @"shot.location.exterior.nature.river";
        case CinemaNetClassLabelShotLocationExteriorNatureSky:
            return @"shot.location.exterior.nature.sky";
        case CinemaNetClassLabelShotLocationExteriorNatureSpace:
            return @"shot.location.exterior.nature.space";
        case CinemaNetClassLabelShotLocationExteriorNatureWetlands:
            return @"shot.location.exterior.nature.wetlands";
        case CinemaNetClassLabelShotLocationExteriorSettlementCity:
            return @"shot.location.exterior.settlement.city";
        case CinemaNetClassLabelShotLocationExteriorSettlementSuburb:
            return @"shot.location.exterior.settlement.suburb";
        case CinemaNetClassLabelShotLocationExteriorSettlementTown:
            return @"shot.location.exterior.settlement.town";
        case CinemaNetClassLabelShotLocationExteriorStructureBridge:
            return @"shot.location.exterior.structure.bridge";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingAirport:
            return @"shot.location.exterior.structure.building.airport";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingAutoBody:
            return @"shot.location.exterior.structure.building.auto.body";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingCastle:
            return @"shot.location.exterior.structure.building.castle";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingHospital:
            return @"shot.location.exterior.structure.building.hospital";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingHouseofworship:
            return @"shot.location.exterior.structure.building.houseofworship";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingLibrary:
            return @"shot.location.exterior.structure.building.library";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingMall:
            return @"shot.location.exterior.structure.building.mall";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingOffice:
            return @"shot.location.exterior.structure.building.office";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceApartment:
            return @"shot.location.exterior.structure.building.residence.apartment";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceHouse:
            return @"shot.location.exterior.structure.building.residence.house";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMansion:
            return @"shot.location.exterior.structure.building.residence.mansion";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingResidenceMonastery:
            return @"shot.location.exterior.structure.building.residence.monastery";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingResidencePalace:
            return @"shot.location.exterior.structure.building.residence.palace";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingRestaurant:
            return @"shot.location.exterior.structure.building.restaurant";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingSchool:
            return @"shot.location.exterior.structure.building.school";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingSkyscraper:
            return @"shot.location.exterior.structure.building.skyscraper";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingStadium:
            return @"shot.location.exterior.structure.building.stadium";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingStationGas:
            return @"shot.location.exterior.structure.building.station.gas";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingStationSubway:
            return @"shot.location.exterior.structure.building.station.subway";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingStationTrain:
            return @"shot.location.exterior.structure.building.station.train";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingStore:
            return @"shot.location.exterior.structure.building.store";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingTheater:
            return @"shot.location.exterior.structure.building.theater";
        case CinemaNetClassLabelShotLocationExteriorStructureBuildingWarehouse:
            return @"shot.location.exterior.structure.building.warehouse";
        case CinemaNetClassLabelShotLocationExteriorStructureBusStop:
            return @"shot.location.exterior.structure.bus.stop";
        case CinemaNetClassLabelShotLocationExteriorStructureFarm:
            return @"shot.location.exterior.structure.farm";
        case CinemaNetClassLabelShotLocationExteriorStructureIndustrial:
            return @"shot.location.exterior.structure.industrial";
        case CinemaNetClassLabelShotLocationExteriorStructurePark:
            return @"shot.location.exterior.structure.park";
        case CinemaNetClassLabelShotLocationExteriorStructureParkinglot:
            return @"shot.location.exterior.structure.parkinglot";
        case CinemaNetClassLabelShotLocationExteriorStructurePier:
            return @"shot.location.exterior.structure.pier";
        case CinemaNetClassLabelShotLocationExteriorStructurePlayground:
            return @"shot.location.exterior.structure.playground";
        case CinemaNetClassLabelShotLocationExteriorStructurePort:
            return @"shot.location.exterior.structure.port";
        case CinemaNetClassLabelShotLocationExteriorStructureRoad:
            return @"shot.location.exterior.structure.road";
        case CinemaNetClassLabelShotLocationExteriorStructureRuins:
            return @"shot.location.exterior.structure.ruins";
        case CinemaNetClassLabelShotLocationExteriorStructureSidewalk:
            return @"shot.location.exterior.structure.sidewalk";
        case CinemaNetClassLabelShotLocationExteriorStructureTunnel:
            return @"shot.location.exterior.structure.tunnel";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleAirplane:
            return @"shot.location.exterior.structure.vehicle.airplane";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleBicycle:
            return @"shot.location.exterior.structure.vehicle.bicycle";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleBoat:
            return @"shot.location.exterior.structure.vehicle.boat";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleBus:
            return @"shot.location.exterior.structure.vehicle.bus";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleCar:
            return @"shot.location.exterior.structure.vehicle.car";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleHelicopter:
            return @"shot.location.exterior.structure.vehicle.helicopter";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleMotorcycle:
            return @"shot.location.exterior.structure.vehicle.motorcycle";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleSpacecraft:
            return @"shot.location.exterior.structure.vehicle.spacecraft";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleTrain:
            return @"shot.location.exterior.structure.vehicle.train";
        case CinemaNetClassLabelShotLocationExteriorStructureVehicleTruck:
            return @"shot.location.exterior.structure.vehicle.truck";
        case CinemaNetClassLabelShotLocationInterior:
            return @"shot.location.interior";
        case CinemaNetClassLabelShotLocationInteriorNatureCave:
            return @"shot.location.interior.nature.cave";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingAirport:
            return @"shot.location.interior.structure.building.airport";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingArena:
            return @"shot.location.interior.structure.building.arena";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingAuditorium:
            return @"shot.location.interior.structure.building.auditorium";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingAutoRepairShop:
            return @"shot.location.interior.structure.building.auto.repair.shop";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingBar:
            return @"shot.location.interior.structure.building.bar";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingBarn:
            return @"shot.location.interior.structure.building.barn";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingCafe:
            return @"shot.location.interior.structure.building.cafe";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingCafeteria:
            return @"shot.location.interior.structure.building.cafeteria";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingCommandCenter:
            return @"shot.location.interior.structure.building.command.center";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingCrypt:
            return @"shot.location.interior.structure.building.crypt";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingDancefloor:
            return @"shot.location.interior.structure.building.dancefloor";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingDungeon:
            return @"shot.location.interior.structure.building.dungeon";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingElevator:
            return @"shot.location.interior.structure.building.elevator";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingFactory:
            return @"shot.location.interior.structure.building.factory";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingFoyer:
            return @"shot.location.interior.structure.building.foyer";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingGym:
            return @"shot.location.interior.structure.building.gym";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingHallway:
            return @"shot.location.interior.structure.building.hallway";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingHospital:
            return @"shot.location.interior.structure.building.hospital";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingHouseofworship:
            return @"shot.location.interior.structure.building.houseofworship";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingLobby:
            return @"shot.location.interior.structure.building.lobby";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingMall:
            return @"shot.location.interior.structure.building.mall";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingOffice:
            return @"shot.location.interior.structure.building.office";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingOfficeCubicle:
            return @"shot.location.interior.structure.building.office.cubicle";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingOpenOffice:
            return @"shot.location.interior.structure.building.open.office";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingPrison:
            return @"shot.location.interior.structure.building.prison";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRestaurant:
            return @"shot.location.interior.structure.building.restaurant";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBath:
            return @"shot.location.interior.structure.building.room.bath";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomBed:
            return @"shot.location.interior.structure.building.room.bed";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomClass:
            return @"shot.location.interior.structure.building.room.class";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomCloset:
            return @"shot.location.interior.structure.building.room.closet";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomConference:
            return @"shot.location.interior.structure.building.room.conference";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomCourt:
            return @"shot.location.interior.structure.building.room.court";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomDining:
            return @"shot.location.interior.structure.building.room.dining";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchen:
            return @"shot.location.interior.structure.building.room.kitchen";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomKitchenCommercial:
            return @"shot.location.interior.structure.building.room.kitchen.commercial";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomLiving:
            return @"shot.location.interior.structure.building.room.living";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomStudy:
            return @"shot.location.interior.structure.building.room.study";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingRoomThrone:
            return @"shot.location.interior.structure.building.room.throne";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStage:
            return @"shot.location.interior.structure.building.stage";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStairwell:
            return @"shot.location.interior.structure.building.stairwell";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStationBus:
            return @"shot.location.interior.structure.building.station.bus";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStationFire:
            return @"shot.location.interior.structure.building.station.fire";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStationPolice:
            return @"shot.location.interior.structure.building.station.police";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStationSubway:
            return @"shot.location.interior.structure.building.station.subway";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStationTrain:
            return @"shot.location.interior.structure.building.station.train";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStore:
            return @"shot.location.interior.structure.building.store";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStoreAisle:
            return @"shot.location.interior.structure.building.store.aisle";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingStoreCheckout:
            return @"shot.location.interior.structure.building.store.checkout";
        case CinemaNetClassLabelShotLocationInteriorStructureBuildingWarehouse:
            return @"shot.location.interior.structure.building.warehouse";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCabin:
            return @"shot.location.interior.structure.vehicle.airplane.cabin";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleAirplaneCockpit:
            return @"shot.location.interior.structure.vehicle.airplane.cockpit";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleBoat:
            return @"shot.location.interior.structure.vehicle.boat";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleBus:
            return @"shot.location.interior.structure.vehicle.bus";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleCar:
            return @"shot.location.interior.structure.vehicle.car";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleHelicopter:
            return @"shot.location.interior.structure.vehicle.helicopter";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleSpacecraft:
            return @"shot.location.interior.structure.vehicle.spacecraft";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleSubway:
            return @"shot.location.interior.structure.vehicle.subway";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleTrain:
            return @"shot.location.interior.structure.vehicle.train";
        case CinemaNetClassLabelShotLocationInteriorStructureVehicleTruck:
            return @"shot.location.interior.structure.vehicle.truck";
        case CinemaNetClassLabelShotLocationNa:
            return @"shot.location.na";
            
        case CinemaNetClassLabelShotSubjectAnimal:
            return @"shot.subject.animal";
        case CinemaNetClassLabelShotSubjectLocation:
            return @"shot.subject.location";
        case CinemaNetClassLabelShotSubjectObject:
            return @"shot.subject.object";
        case CinemaNetClassLabelShotSubjectPerson:
            return @"shot.subject.person";
        case CinemaNetClassLabelShotSubjectPersonBody:
            return @"shot.subject.person.body";
        case CinemaNetClassLabelShotSubjectPersonFace:
            return @"shot.subject.person.face";
        case CinemaNetClassLabelShotSubjectPersonFeet:
            return @"shot.subject.person.feet";
        case CinemaNetClassLabelShotSubjectPersonHands:
            return @"shot.subject.person.hands";
        case CinemaNetClassLabelShotSubjectText:
            return @"shot.subject.text";
        case CinemaNetClassLabelShotSubjectNa:
            return @"shot.subject.na";
            
        case CinemaNetClassLabelShotTimeofdayDay:
            return @"shot.timeofday.day";
        case CinemaNetClassLabelShotTimeofdayNight:
            return @"shot.timeofday.night";
        case CinemaNetClassLabelShotTimeofdayTwilight:
            return @"shot.timeofday.twilight";
        case CinemaNetClassLabelShotTimeofdayNa:
            return @"shot.timeofday.na";
            
        case CinemaNetClassLabelShotTypeMaster:
            return @"shot.type.master";
        case CinemaNetClassLabelShotTypeOvertheshoulder:
            return @"shot.type.overtheshoulder";
        case CinemaNetClassLabelShotTypePortrait:
            return @"shot.type.portrait";
        case CinemaNetClassLabelShotTypeTwoshot:
            return @"shot.type.twoshot";
        case CinemaNetClassLabelShotTypeNa:
            return @"shot.type.na";
            
        case CinemaNetClassLabelTextureBanded:
            return @"texture.banded";
        case CinemaNetClassLabelTextureBlotchy:
            return @"texture.blotchy";
        case CinemaNetClassLabelTextureBraided:
            return @"texture.braided";
        case CinemaNetClassLabelTextureBubbly:
            return @"texture.bubbly";
        case CinemaNetClassLabelTextureBumpy:
            return @"texture.bumpy";
        case CinemaNetClassLabelTextureChequered:
            return @"texture.chequered";
        case CinemaNetClassLabelTextureCobwebbed:
            return @"texture.cobwebbed";
        case CinemaNetClassLabelTextureCracked:
            return @"texture.cracked";
        case CinemaNetClassLabelTextureCrosshatched:
            return @"texture.crosshatched";
        case CinemaNetClassLabelTextureCrystalline:
            return @"texture.crystalline";
        case CinemaNetClassLabelTextureDotted:
            return @"texture.dotted";
        case CinemaNetClassLabelTextureFibrous:
            return @"texture.fibrous";
        case CinemaNetClassLabelTextureFlecked:
            return @"texture.flecked";
        case CinemaNetClassLabelTextureFrilly:
            return @"texture.frilly";
        case CinemaNetClassLabelTextureGauzy:
            return @"texture.gauzy";
        case CinemaNetClassLabelTextureGrid:
            return @"texture.grid";
        case CinemaNetClassLabelTextureGrooved:
            return @"texture.grooved";
        case CinemaNetClassLabelTextureHoneycombed:
            return @"texture.honeycombed";
        case CinemaNetClassLabelTextureInterlaced:
            return @"texture.interlaced";
        case CinemaNetClassLabelTextureKnitted:
            return @"texture.knitted";
        case CinemaNetClassLabelTextureLacelike:
            return @"texture.lacelike";
        case CinemaNetClassLabelTextureLined:
            return @"texture.lined";
        case CinemaNetClassLabelTextureMarbled:
            return @"texture.marbled";
        case CinemaNetClassLabelTextureMatted:
            return @"texture.matted";
        case CinemaNetClassLabelTextureMeshed:
            return @"texture.meshed";
        case CinemaNetClassLabelTexturePaisley:
            return @"texture.paisley";
        case CinemaNetClassLabelTexturePerforated:
            return @"texture.perforated";
        case CinemaNetClassLabelTexturePitted:
            return @"texture.pitted";
        case CinemaNetClassLabelTexturePleated:
            return @"texture.pleated";
        case CinemaNetClassLabelTexturePorous:
            return @"texture.porous";
        case CinemaNetClassLabelTexturePotholed:
            return @"texture.potholed";
        case CinemaNetClassLabelTextureScaly:
            return @"texture.scaly";
        case CinemaNetClassLabelTextureSmeared:
            return @"texture.smeared";
        case CinemaNetClassLabelTextureSpiralled:
            return @"texture.spiralled";
        case CinemaNetClassLabelTextureSprinkled:
            return @"texture.sprinkled";
        case CinemaNetClassLabelTextureStained:
            return @"texture.stained";
        case CinemaNetClassLabelTextureStratified:
            return @"texture.stratified";
        case CinemaNetClassLabelTextureStriped:
            return @"texture.striped";
        case CinemaNetClassLabelTextureStudded:
            return @"texture.studded";
        case CinemaNetClassLabelTextureSwirly:
            return @"texture.swirly";
        case CinemaNetClassLabelTextureVeined:
            return @"texture.veined";
        case CinemaNetClassLabelTextureWaffled:
            return @"texture.waffled";
        case CinemaNetClassLabelTextureWoven:
            return @"texture.woven";
        case CinemaNetClassLabelTextureWrinkled:
            return @"texture.wrinkled";
        case CinemaNetClassLabelTextureZigzagged:
            return @"texture.zigzagged";
            
            // Proxy for returning an unknown label - for unsupported versions or invalid keys
        case CinemaNetClassLabelUnknown:
            return nil;
    }
}
    
// Valid key to CinemaNetClassLabel enum. Invalid keys return CinemaNetClassLabelUnknown.
CinemaNetClassLabel CinemanetClassLabelForLabelKey(NSString* key)
{
//     Use the String Label Keys
    
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
            return @"Blue Matte";
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
