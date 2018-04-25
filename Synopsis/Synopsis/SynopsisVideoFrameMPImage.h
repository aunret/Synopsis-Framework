//
//  SynopsisVideoFrameMPImage.h
//  Synopsis-Framework
//
//  Created by vade on 10/24/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import "SynopsisVideoFrame.h"
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>

@interface SynopsisVideoFrameMPImage : NSObject<SynopsisVideoFrame>
@property (readonly) SynopsisVideoFormatSpecifier* videoFormatSpecifier;
@property (readonly) CMTime presentationTimeStamp;
- (instancetype) initWithMPSImage:(MPSImage*)image formatSpecifier:(SynopsisVideoFormatSpecifier*)formatSpecifier presentationTimeStamp:(CMTime)pts;
- (MPSImage*) mpsImage;
@end

