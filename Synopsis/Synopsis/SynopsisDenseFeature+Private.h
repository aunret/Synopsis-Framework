//
//  SynopsisDenseFeature+Private.h
//  Synopsis-Framework
//
//  Created by vade on 3/27/17.
//  Copyright © 2017 v002. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "SynopsisDenseFeature.h"

@interface SynopsisDenseFeature (Private)

+ (SynopsisDenseFeature*) valueWithCVMat:(cv::Mat)mat forMetadataKey:(NSString*)key;
- (cv::Mat) cvMatValue;


@end
