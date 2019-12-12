//
//  SynopsisVideoFrame.h
//  Synopsis-macOS
//
//  Created by vade on 10/24/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : unsigned int {
    SynopsisVideoFormatUnknown = 0,
    SynopsisVideoFormatBGR8,
    SynopsisVideoFormatBGRF32,
    SynopsisVideoFormatGray8,
    SynopsisVideoFormatPerceptual
} SynopsisVideoFormat;

typedef enum : unsigned int {
    SynopsisVideoBackingNone = 0,
    SynopsisVideoBackingCVPixelbuffer,
    SynopsisVideoBackingOpenCV,
    SynopsisVideoBackingMPSImage,
} SynopsisVideoBacking;

@interface SynopsisVideoFormatSpecifier : NSObject<NSCopying>
- (nullable instancetype) initWithFormat:(SynopsisVideoFormat)format backing:(SynopsisVideoBacking)backing;
@property (readonly, assign) SynopsisVideoFormat format;
@property (readonly, assign) SynopsisVideoBacking backing;
@end

// 
@protocol SynopsisVideoFrame <NSObject>
@property (readonly) SynopsisVideoFormatSpecifier* videoFormatSpecifier;
@property (readonly) NSString* label;
@property (readonly) CMTime presentationTimeStamp;
@property (readonly, nullable) CGColorSpaceRef colorSpace;
@end

NS_ASSUME_NONNULL_END

