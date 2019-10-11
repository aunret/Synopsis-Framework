//
//  SynopsisVideoFrameMPImage.m
//  Synopsis-Framework
//
//  Created by vade on 10/24/17.
//  Copyright © 2017 v002. All rights reserved.
//


#import "SynopsisVideoFrameMPImage.h"
#import <CoreMedia/CoreMedia.h>

@interface SynopsisVideoFrameMPImage ()
@property (readwrite, strong) SynopsisVideoFormatSpecifier* videoFormatSpecifier;
@property (readwrite, assign) CMTime presentationTimeStamp;
@property (readwrite, strong) MPSImage* image;
@property (readwrite, assign) CGColorSpaceRef colorSpace;
@end

@implementation SynopsisVideoFrameMPImage
- (instancetype) initWithMPSImage:(MPSImage*)image formatSpecifier:(SynopsisVideoFormatSpecifier*)formatSpecifier presentationTimeStamp:(CMTime)pts colorspace:(CGColorSpaceRef)colorspace
{
    self = [super init];
    if(self)
    {
        self.image = image;
        self.presentationTimeStamp = pts;
        self.videoFormatSpecifier = formatSpecifier;
        self.colorSpace = CGColorSpaceRetain(colorspace);
    }
    return self;
}

- (void) dealloc
{
    if (self.colorSpace != nil)
    {
        CGColorSpaceRelease(self.colorSpace);
    }
}

- (MPSImage*) mpsImage
{
    return self.image;
}

- (NSString*) label
{
    return self.image.label;
}


@end
