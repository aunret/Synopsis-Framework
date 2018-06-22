//
//  SynopsisMetadataDecoder.m
//  Synopsis-Framework
//
//  Created by vade on 4/12/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import <Synopsis/Synopsis.h>

#import "SynopsisMetadataDecoder.h"
#import "SynopsisMetadataDecoderVersion0.h"
#import "SynopsisMetadataDecoderVersion2.h"
#import "SynopsisMetadataDecoderVersion3.h"


@interface SynopsisMetadataDecoder ()
@property (readwrite, strong) NSObject<SynopsisMetadataDecoder>* decoder;
@property (readwrite, assign) NSUInteger version;
@end

@implementation SynopsisMetadataDecoder

+ (NSUInteger) metadataVersionOfMetadataItem:(AVMetadataItem*)metadataItem
{
    NSMutableDictionary* extraAttributes = [NSMutableDictionary dictionaryWithDictionary:metadataItem.extraAttributes];
    
    // Versions later versions may not have had extra attributes, so we default to 0 (beta)
    NSUInteger version = 0;

    if(extraAttributes[AVMetadataExtraAttributeInfoKey])
    {
        NSDictionary* synopsisVersionDict = extraAttributes[AVMetadataExtraAttributeInfoKey];
        
        NSNumber* vNum = synopsisVersionDict[kSynopsisMetadataVersionKey];
        version = vNum.unsignedIntegerValue;
    }
    
    return version;
}

+ (Class) decoderForVersion:(NSUInteger)version
{
//    if(version <= kSynopsisMetadataVersionAlpha1)
//        return [SynopsisMetadataDecoderVersion0 class];
//    
//    else
        return [SynopsisMetadataDecoderVersion2 class];
}

- (instancetype) initWithVersion:(NSUInteger)version
{
    self = [super init];
    if(self)
    {
        Class decoderClass = [SynopsisMetadataDecoder decoderForVersion:version];
        {
            self.vendOptimizedMetadata = YES;
            self.decoder = [[decoderClass alloc] init];
            self.decoder.vendOptimizedMetadata = self.vendOptimizedMetadata;
        }
        
        self.version = version;
    }
    
    return self;
}

- (instancetype) initWithMetadataItem:(AVMetadataItem*)metadataItem
{
    return  [self initWithVersion:[SynopsisMetadataDecoder metadataVersionOfMetadataItem:metadataItem]];
}

- (id) decodeSynopsisMetadata:(AVMetadataItem*)metadataItem
{
    id metadata = [self.decoder decodeSynopsisMetadata:metadataItem];
    
    if(metadata == nil)
    {
        // try an different decoder
        NSArray<Class>* availableDecoderClasses = @[[SynopsisMetadataDecoderVersion3 class],
                                                    [SynopsisMetadataDecoderVersion2 class],
                                                    [SynopsisMetadataDecoderVersion0 class],
                                                    ];
        
        for(Class decoderClass in availableDecoderClasses)
        {
            self.decoder = [[decoderClass alloc] init];
            self.decoder.vendOptimizedMetadata = self.vendOptimizedMetadata;
            
            metadata = [self.decoder decodeSynopsisMetadata:metadataItem];
            
            if(metadata)
                break;
        }
    
        if(metadata == nil)
        {
            NSLog(@"Cant find a viable decoder for this metadata");
            return nil;
        }
    }
    
    
    return metadata;
    
//    NSUInteger version = [SynopsisMetadataDecoder metadataVersionOfMetadataItem:metadataItem];
//    if(self.version == version)
//    {
//        return [self.decoder decodeSynopsisMetadata:metadataItem];
//    }
//    // Version mis-match, re-init our internal decoder
//    else
//    {
//        Class decoderClass = [SynopsisMetadataDecoder decoderForVersion:version];
//        {
//            self.decoder = [[decoderClass alloc] init];
//        }
//        
//        self.version = version;
//        
//        return [self.decoder decodeSynopsisMetadata:metadataItem];
//    }
}

- (id) decodeSynopsisData:(NSData*) data
{
    return [self.decoder decodeSynopsisData:data];
}

@end
