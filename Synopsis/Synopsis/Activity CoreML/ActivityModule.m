//
//  ActivityModule.m
//  Synopsis-macOS
//
//  Created by vade on 12/3/18.
//  Copyright © 2018 v002. All rights reserved.
//

#import "ActivityModule.h"
#import <CoreML/CoreML.h>
#import <Vision/Vision.h>

#import "SynopsisVideoFrameMPImage.h"
#import "SynopsisVideoFrameCVPixelBuffer.h"
#import "SynopsisSlidingWindow.h"

#import "autoencoder_img_out.h"

@interface ActivityModule ()
{
    CGColorSpaceRef linear;
}

@property (readwrite, strong) CIContext* context;
@property (readwrite, strong) CIBlendKernel* squaredDiff;
@property (readwrite, strong) CIFilter* areaAVG;
@property (readwrite, strong) VNCoreMLModel* visionModel;
@property (readwrite, strong) autoencoder_img_out* classifier;

@end

@implementation ActivityModule

- (instancetype) initWithQualityHint:(SynopsisAnalysisQualityHint)qualityHint device:(id<MTLDevice>)device
{
    self = [super initWithQualityHint:qualityHint device:device];
    if(self)
    {
        linear = CGColorSpaceCreateWithName(kCGColorSpaceExtendedLinearSRGB);
        
        NSDictionary* opt = @{ kCIContextWorkingColorSpace : (__bridge id)linear,
                               kCIContextOutputColorSpace : (__bridge id)linear,
                               };
        
        self.context = [CIContext contextWithMTLDevice:device options:opt];
        
        NSError* error = nil;

        NSURL*metalLibURL = [[NSBundle bundleForClass:[ActivityModule class]] URLForResource:@"default" withExtension:@"metallib"];
        NSData* metalLib = [NSData dataWithContentsOfURL:metalLibURL];
        self.squaredDiff = [CIBlendKernel kernelWithFunctionName:@"squaredDiff" fromMetalLibraryData:metalLib error:&error];
        self.areaAVG = [CIFilter filterWithName:@"CIAreaAverage"];
        self.classifier = [[autoencoder_img_out alloc] init];

        self.visionModel = [VNCoreMLModel modelForMLModel:self.classifier.model error:&error];
        
        if(error)
        {
            NSLog(@"Error: %@", error);
        }
    }
    
    return self;
}

- (void)dealloc
{
    if(linear)
    {
        CGColorSpaceRelease(linear);
        linear = NULL;
    }
}


- (NSString*) moduleName
{
    return kSynopsisStandardMetadataAttentionDictKey;
}

+ (SynopsisVideoBacking) requiredVideoBacking
{
    return SynopsisVideoBackingMPSImage;
    //    return SynopsisVideoBackingCVPixelbuffer;
}

+ (SynopsisVideoFormat) requiredVideoFormat
{
    return SynopsisVideoFormatBGR8;
}

- (void) beginAndClearCachedResults
{
}

- (void) analyzedMetadataForCurrentFrame:(id<SynopsisVideoFrame>)frame previousFrame:(id<SynopsisVideoFrame>)lastFrame commandBuffer:(id<MTLCommandBuffer>)buffer completionBlock:(GPUModuleCompletionBlock)completionBlock
{
    CIImage* imageForRequest = nil;
    if([frame isKindOfClass:[SynopsisVideoFrameMPImage class]])
    {
        SynopsisVideoFrameMPImage* frameMPImage = (SynopsisVideoFrameMPImage*)frame;
        MPSImage* frameMPSImage = frameMPImage.mpsImage;
        imageForRequest = [CIImage imageWithMTLTexture:frameMPSImage.texture options:nil];
    }
    
    else if ([frame isKindOfClass:[SynopsisVideoFrameCVPixelBuffer class]])
    {
        SynopsisVideoFrameCVPixelBuffer* frameCVPixelBuffer = (SynopsisVideoFrameCVPixelBuffer*)frame;
        
        imageForRequest = [CIImage imageWithCVImageBuffer:[frameCVPixelBuffer pixelBuffer]];
    }
    
    CGFloat scaleFactor = imageForRequest.extent.size.width / 28.0;
    
    imageForRequest = [imageForRequest imageByApplyingTransform:CGAffineTransformMakeScale(1.0 / scaleFactor, 1.0 / scaleFactor)];
    
    VNCoreMLRequest* mobileRequest = [[VNCoreMLRequest alloc] initWithModel:self.visionModel completionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        
        VNPixelBufferObservation* featureOutput = [[request results] firstObject];
        
//        NSDictionary* opts = @{ kCIImageColorSpace : (__bridge id)self->linear,
////                                kCIImageApplyOrientationProperty : @YES,
//                                };
        
        CIImage* result = [CIImage imageWithCVPixelBuffer:featureOutput.pixelBuffer] ;
        
        CIImage* diff = [self.squaredDiff applyWithForeground:result background:imageForRequest];
        
        [self.areaAVG setValue:diff forKey:kCIInputImageKey];
        
        CIImage* mean = self.areaAVG.outputImage;
        
        // this is stupid as fuck
        unsigned char* pixel = malloc(sizeof(char) * 4);
        
        [self.context render:mean toBitmap:pixel rowBytes:32 bounds:CGRectMake(0, 0, 1, 1) format:kCIFormatBGRA8 colorSpace:self->linear];
        
        unsigned char b = pixel[0];
        unsigned char g = pixel[1];
        unsigned char r = pixel[2];
        
        float avgError =  ((float)r + (float)b + (float)g) / 3.0;
        
        NSLog(@"mean: %f" avgError);
        
        free(pixel);
    }];
    
    mobileRequest.imageCropAndScaleOption = VNImageCropAndScaleOptionScaleFill;
    mobileRequest.preferBackgroundProcessing = NO;
    
    // Works fine:
    CGImagePropertyOrientation orientation = kCGImagePropertyOrientationUp;
    VNImageRequestHandler* imageRequestHandler = [[VNImageRequestHandler alloc] initWithCIImage:imageForRequest orientation:orientation options:@{
                                                                                                                                                  VNImageOptionCIContext : self.context
                                                                                                                                                  }];
    
    NSError* submitError = nil;
    if(![imageRequestHandler performRequests:@[mobileRequest] error:&submitError] )
        //    if(![self.sequenceRequestHandler performRequests:@[mobileNetRequest] onCIImage:imageForRequest error:&submitError])
    {
        NSLog(@"Error submitting request: %@", submitError);
    }
}

- (NSDictionary*) finalizedAnalysisMetadata
{
    return nil;
}


@end
