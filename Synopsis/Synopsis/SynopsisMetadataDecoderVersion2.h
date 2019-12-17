//
//  SynopsisMetadataDecoderVersion2.h
//  Synopsis-Framework
//
//  Created by vade on 7/21/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Synopsis-Legacy.h"
#import "SynopsisMetadataDecoder.h"

@interface SynopsisMetadataDecoderVersion2 : NSObject<SynopsisMetadataDecoder>
@property (readwrite, assign) BOOL vendOptimizedMetadata;

@end
