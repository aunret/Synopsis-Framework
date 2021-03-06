//
//  SynopsisMetadataEncoder.m
//  Synopsis-Framework
//
//  Created by vade on 6/20/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import <Synopsis/Synopsis.h>
#import "Synopsis-Private.h"
#import "SynopsisMetadata-Private.h"
#import "SynopsisMetadataEncoder.h"
#import "SynopsisMetadataEncoderCurrent.h"
//#import "SynopsisMetadataEncoderVersion0.h"
//#import "SynopsisMetadataEncoderVersion2.h"
//#import "SynopsisMetadataEncoderVersion3.h"
#import "NSDictionary+JSONString.h"

@interface SynopsisMetadataEncoder ()
@property (readwrite, strong) id<SynopsisVersionedMetadataEncoder>encoder;
@property (readwrite, assign) NSUInteger version;
@property (readwrite, assign) SynopsisMetadataEncoderExportOption exportOption;

@property (readwrite, strong) NSDictionary* cachedGlobalMetadata;
@property (readwrite, strong) NSMutableArray* cachedPerFrameMetadata;

@end

@implementation SynopsisMetadataEncoder

+ (CMFormatDescriptionRef) copyMetadataFormatDesc
{
    CMFormatDescriptionRef metadataFormatDescriptionValid = NULL;
    NSArray *specs = @[@{(__bridge NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_Identifier : kSynopsisMetadataIdentifier,
                         (__bridge NSString *)kCMMetadataFormatDescriptionMetadataSpecificationKey_DataType : (__bridge NSString *)kCMMetadataBaseDataType_RawData,
                         }];
    
    OSStatus err = CMMetadataFormatDescriptionCreateWithMetadataSpecifications(kCFAllocatorDefault, kCMMetadataFormatType_Boxed, (__bridge CFArrayRef)specs, &metadataFormatDescriptionValid);
    if(err)
    {
        NSLog(@"Error creating CMMetdataFormatDesc");
    }
    
    return metadataFormatDescriptionValid;
}

- (instancetype) initWithVersion:(NSUInteger)version exportOption:(SynopsisMetadataEncoderExportOption)exportOption
{
    self = [super init];
    if(self)
    {
        self.encoder = [[SynopsisMetadataEncoderCurrent alloc] init];

        self.version = version;
        self.exportOption = exportOption;
        self.cachedPerFrameMetadata = [NSMutableArray array];
    }
    
    return self;
}

- (AVMetadataItem*) encodeSynopsisGlobalMetadataToMetadataItem:(NSDictionary*)metadata timeRange:(CMTimeRange)timeRange
{
    if(self.exportOption)
    {
        // encodeSynopsisMetadataToMetadataItem is our global metadata
        // we set this to item 0 in our array, without any time range
        self.cachedGlobalMetadata = metadata;
    }
    
    NSData* jsonData = [self encodeSynopsisMetadataToData:metadata forMetadataType:SynopsisMetadataTypeGlobal];
    return [self.encoder encodeSynopsisMetadataToMetadataItem:jsonData timeRange:timeRange];
}

- (AVTimedMetadataGroup*) encodeSynopsisSampleMetadataToTimedMetadataGroup:(NSDictionary*)metadata timeRange:(CMTimeRange)timeRange
{
    if(self.exportOption)
    {
        [self.cachedPerFrameMetadata addObject:@[ @{ @"PTS" : @(CMTimeGetSeconds(timeRange.start)) },
                                                 metadata,]
         ];
    }
    
    NSData* jsonData = [self encodeSynopsisMetadataToData:metadata forMetadataType:SynopsisMetadataTypeSample];
    
    return [self.encoder encodeSynopsisMetadataToTimedMetadataGroup:jsonData timeRange:timeRange];
}

- (NSData*) encodeSynopsisMetadataToData:(NSDictionary*)metadata forMetadataType:(SynopsisMetadataType)type
{
    // Add any type specific top level metadata here:
    
    NSMutableDictionary* topLevel = [[NSMutableDictionary alloc] init];;
    
    switch (type)
    {
        case SynopsisMetadataTypeGlobal:
        {
            topLevel[kSynopsisMetadataTypeGlobal] = metadata;
            topLevel[kSynopsisMetadataVersionKey] = @(kSynopsisMetadataVersionCurrent);
            break;
        }
        case SynopsisMetadataTypeSample:
        {
            topLevel[kSynopsisMetadataTypeSample] = metadata;
            break;
        }
    }

    NSString* aggregateMetadataAsJSON = [topLevel jsonStringWithPrettyPrint:NO];
    NSData* jsonData = [aggregateMetadataAsJSON dataUsingEncoding:NSUTF8StringEncoding];
    
    if(!jsonData)
    {
        return nil;
    }
    return [self.encoder encodeSynopsisMetadataToData:jsonData];
}

- (BOOL) exportToURL:(NSURL*)fileURL
{
    switch(self.exportOption)
    {
        case SynopsisMetadataEncoderExportOptionNone:
            return NO;
            
        case SynopsisMetadataEncoderExportOptionJSONContiguous:
        {
            NSArray* jsonDict = @[self.cachedGlobalMetadata,
                                  self.cachedPerFrameMetadata,
                                  ];
            
            NSString* aggregateMetadataAsJSON = [jsonDict jsonStringWithPrettyPrint:NO];
            NSData* jsonData = [aggregateMetadataAsJSON dataUsingEncoding:NSUTF8StringEncoding];
            [jsonData writeToURL:fileURL atomically:YES];
            
            return YES;
        }
            
        case SynopsisMetadataEncoderExportOptionJSONGlobalOnly:
        {
            NSString* aggregateMetadataAsJSON = [self.cachedGlobalMetadata jsonStringWithPrettyPrint:NO];
            NSData* jsonData = [aggregateMetadataAsJSON dataUsingEncoding:NSUTF8StringEncoding];
            [jsonData writeToURL:fileURL atomically:YES];
            
            return YES;
        }
            
        case SynopsisMetadataEncoderExportOptionJSONSequence:
        {
            NSString* aggregateMetadataAsJSON = [self.cachedGlobalMetadata jsonStringWithPrettyPrint:NO];
            NSData* jsonData = [aggregateMetadataAsJSON dataUsingEncoding:NSUTF8StringEncoding];
            [jsonData writeToURL:fileURL atomically:YES];
            
            [self.cachedPerFrameMetadata enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSArray* frameArray = (NSArray*)obj;
                
                NSString* framePath = [fileURL path];
                framePath = [framePath stringByDeletingPathExtension];
                framePath = [framePath stringByAppendingString:[NSString stringWithFormat:@"_Frame_%lu.json", idx]];
                
                NSString* aggregateMetadataAsJSON = [frameArray jsonStringWithPrettyPrint:NO];
                NSData* jsonData = [aggregateMetadataAsJSON dataUsingEncoding:NSUTF8StringEncoding];
                [jsonData writeToFile:framePath atomically:NO];
            }];
            
            return YES;
        }
         
        case SynopsisMetadataEncoderExportOptionZSTDTraining:
        {
            NSString* aggregateMetadataAsJSON = [self.cachedGlobalMetadata jsonStringWithPrettyPrint:NO];
            NSData* jsonData = [aggregateMetadataAsJSON dataUsingEncoding:NSUTF8StringEncoding];
            [jsonData writeToURL:fileURL atomically:YES];
            
            [self.cachedPerFrameMetadata enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                NSArray* frameArray = (NSArray*)obj;
                
                // remove the PTS, we only ever encode the training data anyway
                if(frameArray.count == 2)
                {
                    NSDictionary* frameMetadata = frameArray[1];
                    
                    NSString* framePath = [fileURL path];
                    framePath = [framePath stringByDeletingPathExtension];
                    framePath = [framePath stringByAppendingString:[NSString stringWithFormat:@"_Frame_%lu.json", (unsigned long)idx]];
                    
                    NSString* aggregateMetadataAsJSON = [frameMetadata jsonStringWithPrettyPrint:NO];
                    NSData* jsonData = [aggregateMetadataAsJSON dataUsingEncoding:NSUTF8StringEncoding];
                    [jsonData writeToFile:framePath atomically:NO];
                }
            }];
            
            return YES;
        }
    }
    
    return NO;
}

@end
