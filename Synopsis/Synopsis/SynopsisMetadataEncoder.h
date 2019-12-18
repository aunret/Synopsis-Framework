//
//  SynopsisMetadataEncoder.h
//  Synopsis-Framework
//
//  Created by vade on 6/20/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import <Synopsis/Synopsis.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

typedef enum : NSInteger {
    // Dont write out any JSON
    SynopsisMetadataEncoderExportOptionNone = 0,
    // Single sidecar file
    SynopsisMetadataEncoderExportOptionJSONContiguous = 1,
    // Global metadata only sidecar file (no per frame)
    SynopsisMetadataEncoderExportOptionJSONGlobalOnly = 2,
    // GLobal metadata as well as individial per frame sequences
    SynopsisMetadataEncoderExportOptionJSONSequence = 3,
    // Export training data used to make new dictionary files for ZSTD
    SynopsisMetadataEncoderExportOptionZSTDTraining = -1,

} SynopsisMetadataEncoderExportOption;


@interface SynopsisMetadataEncoder : NSObject

+ (CMFormatDescriptionRef) copyMetadataFormatDesc;

@property (readonly) NSUInteger version;
@property (readonly) SynopsisMetadataEncoderExportOption exportOption;

- (instancetype) initWithVersion:(NSUInteger)version exportOption:(SynopsisMetadataEncoderExportOption)exportOption;
- (AVTimedMetadataGroup*) encodeSynopsisSampleMetadataToTimedMetadataGroup:(NSDictionary*)metadata timeRange:(CMTimeRange)timeRange;
- (AVMetadataItem*) encodeSynopsisGlobalMetadataToMetadataItem:(NSDictionary*)metadata timeRange:(CMTimeRange)timeRange;
- (NSData*) encodeSynopsisMetadataToData:(NSDictionary*)metadata forMetadataType:(SynopsisMetadataType)type;
- (BOOL) exportToURL:(NSURL*)fileURL;

@end
