//
//  Module.m
//  Synopsis
//
//  Created by vade on 11/10/16.
//  Copyright © 2016 metavisual. All rights reserved.
//

#import "CPUModule.h"

@interface CPUModule ()
@property (readwrite) SynopsisAnalysisQualityHint qualityHint;
@end

@implementation CPUModule

- (instancetype) initWithQualityHint:(SynopsisAnalysisQualityHint)qualityHint
{
    self = [super init];
    {
        self.qualityHint = qualityHint;
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithQualityHint:SynopsisAnalysisQualityHintMedium];
    return self;
}

- (NSString*) moduleName
{
    [NSObject doesNotRecognizeSelector:_cmd];
    return nil;
}

+ (SynopsisVideoBacking) requiredVideoBacking
{
    return SynopsisVideoBackingNone;
}

+ (SynopsisVideoFormat) requiredVideoFormat
{
    [NSObject doesNotRecognizeSelector:_cmd];
    return SynopsisVideoFormatUnknown;
}

- (void) beginAndClearCachedResults
{
    [NSObject doesNotRecognizeSelector:_cmd];
}

- (NSDictionary*) analyzedMetadataForCurrentFrame:(id<SynopsisVideoFrame>)frame previousFrame:(id<SynopsisVideoFrame>)lastFrame;
{
    [NSObject doesNotRecognizeSelector:_cmd];
    return nil;
}

- (NSDictionary*) finaledAnalysisMetadata;
{
    [NSObject doesNotRecognizeSelector:_cmd];
    return nil;
}

@end
