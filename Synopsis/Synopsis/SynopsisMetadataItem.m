//
//  SynopsisMetadataItem.m
//  Synopslight
//
//  Created by vade on 7/28/16.
//  Copyright © 2016 v002. All rights reserved.
//

#import <Synopsis/Synopsis.h>
#import <AVFoundation/AVFoundation.h>
#import "SynopsisMetadataItem.h"

#import "Color+linearRGBColor.h"




@interface SynopsisMetadataItem ()
{
    CGImageRef cachedImage;
}
@property (readwrite) NSURL* url;
@property (readwrite, strong) AVAsset* asset;
@property (readwrite, strong) NSDictionary* globalSynopsisMetadata;
@property (readwrite, strong) SynopsisMetadataDecoder* decoder;
@property (readwrite, assign) BOOL loaded;
@end




@implementation SynopsisMetadataItem

- (instancetype) initWithURL:(NSURL *)url
{
    self = [super init];
    if(self)
    {
        self.url = url;
        self.asset = [AVURLAsset URLAssetWithURL:url options:@{AVURLAssetPreferPreciseDurationAndTimingKey : @YES}];
        self.loaded = NO;
        if(! [self commonLoad] )
        {
            NSLog(@"SynopsisMetadataItem : Unable to load metadata - bailing on init");
            return nil;
        }
    }
    
    return self;
}
//	removed b/c it doesn't init the 'url' property (can't be guaranteed init'ed unless using AVURLAsset) and it doesn't appear to be used at all by anything in this codebase
/*
- (instancetype) initWithAsset:(AVAsset *)asset
{
    self = [super init];
    if(self)
    {
        self.asset = asset;
        if(! [self commonLoad] )
        {
            NSLog(@"SynopsisMetadataItem : Unable to load metadata - bailing on init");
            return nil;
        }
    }
    
    return self;
}
*/
- (instancetype) initWithURL:(NSURL *)url onQueue:(dispatch_queue_t)q completionHandler:(SynopsisMetadataItemCompletionHandler)ch	{
	self = [super init];
	if (self != nil)	{
		self.url = url;
		self.asset = [AVURLAsset URLAssetWithURL:url options:@{AVURLAssetPreferPreciseDurationAndTimingKey : @YES}];
		self.loaded = NO;
		if (![self canBeLoaded])	{
			NSLog(@"ERR: cannot be loaded, %s",__func__);
			if (ch != nil)	{
				ch(self);
			}
			self = nil;
			return self;
		}
		if (q == nil)	{
			[self commonLoad];
			if (ch != nil)	{
				ch(self);
			}
		}
		else	{
			dispatch_async(q, ^{
				[self commonLoad];
				if (ch != nil)	{
					ch(self);
				}
			});
		}
	}
	return self;
}
- (NSString *) description	{
	return [NSString stringWithFormat:@"<SynopsisMetadataItem %@>",self.url.lastPathComponent];
}
- (BOOL) canBeLoaded	{
	BOOL			returnMe = NO;
	if (self.asset == nil)
		return returnMe;
	NSArray* metadataItems = [self.asset metadata];
    
    for(AVMetadataItem* metadataItem in metadataItems)
    {
        if([metadataItem.identifier isEqualToString:kSynopsisMetadataIdentifier])
        {
            returnMe = YES;
            break;
        }
    }
	return returnMe;
}
- (BOOL) commonLoad	{
    NSArray* metadataItems = [self.asset metadata];
    
    AVMetadataItem* synopsisMetadataItem = nil;
    
    for(AVMetadataItem* metadataItem in metadataItems)
    {
        if([metadataItem.identifier isEqualToString:kSynopsisMetadataIdentifier])
        {
            synopsisMetadataItem = metadataItem;
            break;
        }
    }
    
    if(synopsisMetadataItem)
    {
        self.decoder = [[SynopsisMetadataDecoder alloc] initWithMetadataItem:synopsisMetadataItem];
        
        self.globalSynopsisMetadata = [self.decoder decodeSynopsisMetadata:synopsisMetadataItem];
        
        self.loaded = YES;
        
        return YES;
    }
    
    self.loaded = YES;
    
    return NO;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    if(self.url)
    {
        return [[SynopsisMetadataItem alloc] initWithURL:self.url];
    }
    else
    {
        //return [[SynopsisMetadataItem alloc] initWithAsset:[self.asset copy]];
        return [[SynopsisMetadataItem alloc] initWithURL:self.url];
    }
}

- (id) valueForKey:(NSString *)key
{
    NSDictionary* standardDictionary = [self.globalSynopsisMetadata objectForKey:kSynopsisStandardMetadataDictKey];

    if([key isEqualToString:kSynopsisMetadataIdentifier])
        return self.globalSynopsisMetadata;
    
    else if([key isEqualToString:kSynopsisStandardMetadataDictKey])
    {
       return standardDictionary;
    }

    else if(standardDictionary[key])
    {
        return standardDictionary[key];
    }
    else
    {
        return [super valueForKey:key];
    }
}

- (id) valueForUndefinedKey:(NSString *)key
{
    return nil;
}

@end
