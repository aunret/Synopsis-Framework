//
//  SynopsisMetadataDecoderVersion2.h
//  Synopsis-Framework
//
//  Created by vade on 7/21/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynopsisMetadataDecoder.h"

@interface SynopsisMetadataDecoderVersion3 : NSObject<SynopsisMetadataDecoder>
@property (readwrite, assign) BOOL vendOptimizedMetadata;

@end
