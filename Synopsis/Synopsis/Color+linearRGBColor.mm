//
//  NSColor+linearRGBColor.m
//  Synopsis-Framework
//
//  Created by vade on 8/26/16.
//  Copyright © 2016 v002. All rights reserved.
//

#include <opencv2/opencv.hpp>

#import "Color+linearRGBColor.h"

//#include <opencv2/core.hpp>
//#import "opencv2/opencv.hpp"

@implementation ColorHelper

+ (CGColorRef) newColorWithLinearRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat) alpha
{
    CGColorSpaceRef linear = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGBLinear);
    
    CGFloat components[4] = {red, green, blue, alpha};
    
    CGColorRef color = CGColorCreate(linear, components);
    
    CGColorSpaceRelease(linear);

    return color;
}

+ (CGColorRef) newColorWithLinearRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    return [self newColorWithLinearRed:red green:green blue:blue alpha:1.0];
}

+ (NSArray*) newLinearColorsWithArraysOfRGBComponents:(NSArray*)colorComponentsArray
{
	//NSLog(@"%s",__func__);
	//NSLog(@"\t\tcolorComponentsArray is %@",colorComponentsArray);
    
    NSUInteger count = [colorComponentsArray count];
    
	if (colorComponentsArray == nil || count < 1)
		return nil;

//    CGColorSpaceRef linear = CGColorSpaceCreateDeviceRGB();
    CGColorSpaceRef linear = CGColorSpaceCreateWithName(kCGColorSpaceSRGB);
    
    NSMutableArray* colors = [NSMutableArray arrayWithCapacity:colorComponentsArray.count];
    
    for(int i = 0; i < count;)
    {
        
        CGFloat components[4];
        components[0] = [colorComponentsArray[i + 0] floatValue];
        components[1] = [colorComponentsArray[i + 1] floatValue];
        components[2] = [colorComponentsArray[i + 2] floatValue];
        components[3] = 1;
        
//        if(colorComponents.count > 3)
//        {
//            components[3] = [colorComponents[3] floatValue];
//        }
        
        CGColorRef color = CGColorCreate(linear, components);

         [colors addObject:(id)CFBridgingRelease(color)];
        
        i += 3;
    }
    
    CGColorSpaceRelease(linear);

    return colors;
}


+ (void) convertHSVtoRGBFloat:(float *)c	{
	if (c == nullptr)
		return;
	
	cv::Mat inputColor = cv::Mat(1,1,CV_32FC3);
    
    inputColor.at<cv::Vec3f>(0,0) = cv::Vec3f(*(c), *(c+1), *(c+2));
    
    cv::Mat outputColor = cv::Mat(1,1,CV_32FC3);
	cv::cvtColor(inputColor, outputColor, cv::COLOR_HSV2RGB);

    cv::Vec3f output = outputColor.at<cv::Vec3f>(0,0);
	*(c) = output[0];
	*(c+1) = output[1];
	*(c+2) = output[2];
}

+ (void) convertRGBtoHSVFloat:(float *)c
{
	if (c == nullptr)
		return;
	
    cv::Mat inputColor = cv::Mat(1,1,CV_32FC3);
    
    inputColor.at<cv::Vec3f>(0,0) = cv::Vec3f(*(c), *(c+1), *(c+2));
    
    cv::Mat outputColor = cv::Mat(1,1,CV_32FC3);
    cv::cvtColor(inputColor, outputColor, cv::COLOR_RGB2HSV);
    
    cv::Vec3f output = outputColor.at<cv::Vec3f>(0,0);
    *(c) = output[0];
    *(c+1) = output[1];
    *(c+2) = output[2];
}


@end
