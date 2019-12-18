//
//  Analyzer.m
//  Synopsis-macOS
//
//  Created by vade on 6/20/19.
//  Copyright © 2019 v002. All rights reserved.
//

#import "Analyzer.h"
#import "SynopsisMetadataItem.h"
#import "SynopsisVideoFrameConformSession.h"
#import "SynopsisMetadataEncoder.h"
#import "StandardAnalyzerPlugin.h"

@interface Analyzer ()

@property (readwrite, strong) SynopsisVideoFrameConformSession* conformSession;
@property (readwrite, strong) StandardAnalyzerPlugin* standardAnalyzer;
@property (readwrite, strong) SynopsisMetadataEncoder* metadataEncoder;

@property (readwrite, strong) NSOperationQueue* analysisQueue;

@end

@implementation Analyzer

- (instancetype) init
{
    self = [super init];
    if(self)
    {
        self.analysisQueue = [[NSOperationQueue alloc] init];
        self.analysisQueue.maxConcurrentOperationCount = 1;
        
        self.standardAnalyzer = [[StandardAnalyzerPlugin alloc] init];
        
        self.conformSession = [[SynopsisVideoFrameConformSession alloc] initWithRequiredFormatSpecifiers:[self.standardAnalyzer pluginFormatSpecfiers]
                                                                                                  device:MTLCreateSystemDefaultDevice()
                                                                                         inFlightBuffers:3
                                                                                         frameSkipStride:0];
        
        self.metadataEncoder = [[SynopsisMetadataEncoder alloc] initWithVersion:kSynopsisMetadataVersionValue exportOption:SynopsisMetadataEncoderExportOptionNone];
    }
    
    return self;
}

- (void) analyzeItem:(AVAsset*)asset destinationURL:(NSURL*)destinationURL progressHandler:(void (^)(float))progressBlock
{
    
#pragma mark - Reader
    
    AVAssetReader* assetReader = [[AVAssetReader alloc] initWithAsset:asset error:nil];
    
#pragma mark - Reader Uncompressed Video Decoder
    
    NSArray<AVAssetTrack*>* videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    
    if(videoTracks.count == 0)
        return;
    
    AVAssetTrack* videoTrack = videoTracks.firstObject;
    
    dispatch_queue_t uncompressedVideoDecodeQueue = dispatch_queue_create("uncompressed_video_queue", DISPATCH_QUEUE_SERIAL_WITH_AUTORELEASE_POOL);
    
    // TODO: DO WE NEED TO SET OUR EXPECTED COLOR SPACE ON OUTPUT?
    NSDictionary* uncompressedVideoSettings = @{(NSString*) kCVPixelBufferIOSurfacePropertiesKey : @{},
                                                (NSString*) kCVPixelBufferMetalCompatibilityKey : @(YES),
                                                (NSString*) kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange),
                                                
                                                // DCI-P3!
                                                //                                                AVVideoAllowWideColorKey : @YES,
                                                AVVideoColorPropertiesKey : @{ AVVideoColorPrimariesKey: AVVideoColorPrimaries_P3_D65,
                                                                               AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
                                                                               AVVideoYCbCrMatrixKey : AVVideoYCbCrMatrix_ITU_R_709_2,
                                                                               },
                                                
                                                //                                                // Rec 709!
                                                //                                                AVVideoColorPropertiesKey : @{ AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2,
                                                //                                                                                              AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
                                                //                                                                                              AVVideoYCbCrMatrixKey : AVVideoYCbCrMatrix_ITU_R_709_2,
                                                //                                                                                              };
                                                
                                                };
    
    AVAssetReaderTrackOutput* uncompressedVideoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:uncompressedVideoSettings];
    uncompressedVideoOutput.alwaysCopiesSampleData = NO;
    
    if([assetReader canAddOutput:uncompressedVideoOutput])
    {
        [assetReader addOutput:uncompressedVideoOutput];
    }
    
#pragma mark - Reader Video Passthrough Decoder
    
    dispatch_queue_t passthroughVideoDecodeQueue = dispatch_queue_create("passthrough_video_queue", DISPATCH_QUEUE_SERIAL_WITH_AUTORELEASE_POOL);
    
    AVAssetReaderTrackOutput* passthroughVideoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:nil];
    passthroughVideoOutput.alwaysCopiesSampleData = NO;
    
    if([assetReader canAddOutput:passthroughVideoOutput])
    {
        [assetReader addOutput:passthroughVideoOutput];
    }
    
#pragma mark - Reader Audio Passthrough Decoder
    
    NSArray<AVAssetTrack*>* audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    
    AVAssetReaderTrackOutput* passthroughAudioOutput = nil;
    dispatch_queue_t passthroughAudioDecodeQueue = dispatch_queue_create("passthrough_audio_queue", DISPATCH_QUEUE_SERIAL_WITH_AUTORELEASE_POOL);
    
    if(audioTracks.count)
    {
        AVAssetTrack* audioTrack = audioTracks.firstObject;
        
        passthroughAudioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:nil];
        passthroughVideoOutput.alwaysCopiesSampleData = NO;
        
        if([assetReader canAddOutput:passthroughAudioOutput])
        {
            [assetReader addOutput:passthroughAudioOutput];
        }
    }
    
#pragma mark - Writer
    
    AVAssetWriter* assetWriter = [[AVAssetWriter alloc] initWithURL:destinationURL fileType:AVFileTypeQuickTimeMovie error:nil];
    
#pragma mark - Write Video Passthrough
    
    AVAssetWriterInput* passthroughVideoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:nil];
    passthroughVideoInput.expectsMediaDataInRealTime = NO;
    passthroughVideoInput.transform = videoTrack.preferredTransform;
    
    if([assetWriter canAddInput:passthroughVideoInput])
    {
        [assetWriter addInput:passthroughVideoInput];
    }
    
#pragma mark - Write Audio Passthrough
    
    AVAssetWriterInput* passthroughAudioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:nil];
    passthroughAudioInput.expectsMediaDataInRealTime = NO;
    
    if([assetWriter canAddInput:passthroughAudioInput])
    {
        [assetWriter addInput:passthroughAudioInput];
    }
    
#pragma mark - Write Metadata
    
    CMFormatDescriptionRef synopsisMetadataFormat = [SynopsisMetadataEncoder copyMetadataFormatDesc];
    AVAssetWriterInput* metadataInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeMetadata outputSettings:nil sourceFormatHint:synopsisMetadataFormat];
    CFRelease(synopsisMetadataFormat);
    metadataInput.expectsMediaDataInRealTime = NO;
    
    AVAssetWriterInputMetadataAdaptor* metadataInputAdaptor = [[AVAssetWriterInputMetadataAdaptor alloc] initWithAssetWriterInput:metadataInput];
    
    // See https://developer.apple.com/library/archive/documentation/QuickTime/QTFF/QTFFChap3/qtff3.html
    // and documentation for AVTrackAssociationTypeMetadataReferent
    [metadataInput addTrackAssociationWithTrackOfInput:passthroughVideoInput type:AVTrackAssociationTypeMetadataReferent];
    
    
    if([assetWriter canAddInput:metadataInput])
    {
        [assetWriter addInput:metadataInput];
    }
    
    
#pragma mark - Process
    
    float durationInSeconds = CMTimeGetSeconds(asset.duration);
    
    NSUInteger numInFlightBuffers = 3;
    
    __block float lastPercent = FLT_MIN;
    
    dispatch_group_t analysisGroup = dispatch_group_create();
    
    //    dispatch_group_enter(analysisGroup);
    
    if([assetReader startReading] && [assetWriter startWriting])
    {
        NSLog(@"Start Read and Write");
        [assetWriter startSessionAtSourceTime:kCMTimeZero];
        
        [self.standardAnalyzer beginMetadataAnalysisSessionWithQuality:SynopsisAnalysisQualityHintMedium device:MTLCreateSystemDefaultDevice()];
        
#pragma mark - Process Passthrough Audio
        
        //        dispatch_group_enter(analysisGroup);
        dispatch_semaphore_t inFlightPassthroughAudioBuffers = dispatch_semaphore_create(numInFlightBuffers);
        
        [passthroughAudioInput requestMediaDataWhenReadyOnQueue:passthroughAudioDecodeQueue usingBlock:^{
            
            NSLog(@"Request Pass through audio");
            
            while([passthroughAudioInput isReadyForMoreMediaData])
            {
                @autoreleasepool
                {
                    // Pause to ensure we dont get ahead of ourselves here
                    // ie: ensure we only decode n buffered frames ahead of analysis
                    dispatch_semaphore_wait(inFlightPassthroughAudioBuffers, DISPATCH_TIME_FOREVER);
                    
                    [self copyNextSampleBufferFromOutput:passthroughAudioOutput completionBlock:^(CMSampleBufferRef sampleBufer) {
                        if(sampleBufer)
                        {
                            @try
                            {
                                if(![passthroughAudioInput appendSampleBuffer:sampleBufer])
                                {
                                    NSLog(@"Unable to append passthroughAudioInput: %@", assetWriter.error );
                                }
                            }
                            @catch(NSException* exception)
                            {
                                NSLog(@"Exception thrown in passthroughAudioInput: %@", exception);
                            }
                        }
                        else
                        {
                            NSLog(@"Finished With Passthrough Audio");
                            [passthroughAudioInput markAsFinished];
                            //                            dispatch_group_leave(analysisGroup);
                        }
                        // Unblock decode if we need to
                        dispatch_semaphore_signal(inFlightPassthroughAudioBuffers);
                    }];
                }// End autorelease pool
            }
        }];
        
#pragma mark - Process Passthrough Video
        
        //        dispatch_group_enter(analysisGroup);
        dispatch_semaphore_t inFlightPassthroughVideoBuffers = dispatch_semaphore_create(numInFlightBuffers);
        
        [passthroughVideoInput requestMediaDataWhenReadyOnQueue:passthroughVideoDecodeQueue usingBlock:^{
            
            NSLog(@"Request Pass through video");
            
            while([passthroughVideoInput isReadyForMoreMediaData])
            {
                @autoreleasepool
                {
                    // Pause to ensure we dont get ahead of ourselves here
                    // ie: ensure we only decode n buffered frames ahead of analysis
                    dispatch_semaphore_wait(inFlightPassthroughVideoBuffers, DISPATCH_TIME_FOREVER);
                    
                    [self copyNextSampleBufferFromOutput:passthroughVideoOutput completionBlock:^(CMSampleBufferRef sampleBufer) {
                        if(sampleBufer)
                        {
                            @try
                            {
                                if(![passthroughVideoInput appendSampleBuffer:sampleBufer])
                                {
                                    NSLog(@"Unable to append passthroughVideoInput : %@", assetWriter.error );
                                }
                            }
                            @catch(NSException* exception)
                            {
                                NSLog(@"Exception thrown in passthroughVideoInput: %@", exception);
                            }
                        }
                        else
                        {
                            NSLog(@"Finish Pass through video");
                            [passthroughVideoInput markAsFinished];
                            //                            dispatch_group_leave(analysisGroup);
                        }
                        
                        // Unblock decode if we need to
                        dispatch_semaphore_signal(inFlightPassthroughVideoBuffers);
                        
                    }];
                } // end autorelease pool
            }
        }];
        
#pragma mark - Process Uncompressed Video, Analyze and Write Metadata
        
        dispatch_group_enter(analysisGroup);
        dispatch_semaphore_t inFlightUncompressedVideoBuffers = dispatch_semaphore_create(numInFlightBuffers);
        
        [metadataInput requestMediaDataWhenReadyOnQueue:uncompressedVideoDecodeQueue usingBlock:^{
            
            NSLog(@"Request Metadata");
            
            while([metadataInput isReadyForMoreMediaData])
            {
                @autoreleasepool
                {
                    // Pause to ensure we dont get ahead of ourselves here
                    // ie: ensure we only decode 3 frames ahead of analysis
                    dispatch_semaphore_wait(inFlightUncompressedVideoBuffers, DISPATCH_TIME_FOREVER);
                    
                    //                    NSLog(@"Request Metadata Ready");
                    // Decode our Video
                    [self copyNextSampleBufferFromOutput:uncompressedVideoOutput completionBlock:^(CMSampleBufferRef sampleBufer) {
                        
                        // Extra enter and exit to absorb GPU buffer count latency
                        // This ensures our group is triggered to not leave when we have in flight metadata
                        dispatch_group_enter(analysisGroup);
                        
                        // Analyze our video
                        [self analyzeVideo:sampleBufer withTrackTransform:videoTrack.preferredTransform completionBlock:^(AVTimedMetadataGroup *metadataGroup) {
                            
                            if(sampleBufer && metadataGroup)
                            {
                                float presentationTimeInSeconds = CMTimeGetSeconds( CMSampleBufferGetOutputPresentationTimeStamp(sampleBufer));
                                
                                if(progressBlock)
                                {
                                    float currentPercent = presentationTimeInSeconds/durationInSeconds;
                                    currentPercent += FLT_MIN;
                                    
                                    float delta = currentPercent - lastPercent;
                                    // Rate limit?
                                    if(delta > 0.01)
                                    {
                                        //                                        NSLog(@"Progress::::: %f", delta);
                                        
                                        progressBlock( delta );
                                        lastPercent = currentPercent;
                                    }
                                }
                                
                                @try
                                {
                                    if(! [metadataInputAdaptor appendTimedMetadataGroup:metadataGroup])
                                    {
                                        NSLog(@"Unable to append timed metadata group : %@", assetWriter.error );
                                    }
                                }
                                @catch(NSException* exception)
                                {
                                    NSLog(@"Exception thrown in metadataInputAdaptor: %@", exception);
                                }
                            }
                            // Quick hack to deterine frame drop
                            else if(sampleBufer && metadataGroup == nil)
                            {
                                //                                return;
                            }
                            else
                            {
                                //                                the problem is we have a 2 frame latency on the GPU
                                //                                but we get our metadata is FINISHED WHILE in flight metadata is still encoding
                                //
                                NSLog(@"Metadata Finished");
                                [metadataInput markAsFinished];
                                dispatch_group_leave(analysisGroup);
                            }
                            
                            // Unblock decode if we need to
                            dispatch_semaphore_signal(inFlightUncompressedVideoBuffers);
                            
                            // Extra enter and exit to absorb GPU buffer count latency
                            // This ensures our group is triggered to not leave when we have in flight metadata
                            dispatch_group_leave(analysisGroup);
                            
                            
                        }];
                    }];
                }// end autorelease pool
            }
        }];
    }
    
    //    dispatch_group_leave(analysisGroup);
    
    dispatch_group_wait(analysisGroup, DISPATCH_TIME_FOREVER);
    
    NSDictionary* standardMetadata = [self.standardAnalyzer finalizeMetadataAnalysisSessionWithError:nil];
    NSDictionary* globalMetadata = @{ self.standardAnalyzer.pluginIdentifier : standardMetadata,
                                      kSynopsisMetadataVersionKey : @(kSynopsisMetadataVersionValue),
                                      };
    
    AVMetadataItem* metadataItem = [self.metadataEncoder encodeSynopsisMetadataToMetadataItem:globalMetadata timeRange:kCMTimeRangeZero];
    
    dispatch_group_enter(analysisGroup);
    
    //__block SynopsisMetadataItem* analyzedItem = nil;
    
    [assetWriter finishWritingWithCompletionHandler:^{
        NSLog(@"Finished Writing Asset");

        // Write our global header
        AVMutableMovie* movie = [AVMutableMovie movieWithURL:destinationURL options:nil error:nil];
        
        movie.metadata = @[metadataItem];
        
        dispatch_group_leave(analysisGroup);

//        // Load Pass 1:
//        AVURLAsset* urlAsset = [AVURLAsset URLAssetWithURL:destinationURL options:@{AVURLAssetPreferPreciseDurationAndTimingKey : @YES}];
//
//        NSString* secondPassName = [[[destinationURL lastPathComponent] stringByDeletingPathExtension] stringByAppendingString:@"-pass2"];
//        NSURL* secondPass = [destinationURL URLByDeletingLastPathComponent];
//        secondPass = [[secondPass URLByAppendingPathComponent:secondPassName] URLByAppendingPathExtension:@"mov"];
//
//        AVAssetExportSession* exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPresetPassthrough];
//
//        exportSession.metadata = @[ metadataItem ];
//        exportSession.outputURL = secondPass;
//        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
//
//        if([[NSFileManager defaultManager] fileExistsAtPath:secondPass.path])
//        {
//            [[NSFileManager defaultManager] removeItemAtURL:secondPass error:nil];
//        }
//
//
//        [exportSession exportAsynchronouslyWithCompletionHandler:^{
//
//            // We no longer export to photo library...
//            //            [self exportAssetToPhotoLibraryFromURL:secondPass];
//
//            [[NSFileManager defaultManager] removeItemAtURL:destinationURL error:nil];
//
//            // Rename second pass to our destination ...
//            [[NSFileManager defaultManager] moveItemAtURL:secondPass toURL:destinationURL error:nil];
//
//            analyzedItem = [[SynopsisMetadataItem alloc] initWithURL:destinationURL];
//
//            dispatch_group_leave(analysisGroup);
//        }];
    }];
    
    //    if(progressBlock)
    //    {
    //        progressBlock(1.0);
    //    }
    
    
    
    dispatch_group_wait(analysisGroup, DISPATCH_TIME_FOREVER);
}



- (void) copyNextSampleBufferFromOutput:(AVAssetReaderTrackOutput*)output completionBlock:(void (^)(CMSampleBufferRef sampleBufer))completionBlock
{
    CMSampleBufferRef sample = [output copyNextSampleBuffer];
    
    if(sample)
    {
        if(completionBlock)
        {
            completionBlock(sample);
        }
        
        CFRelease(sample);
    }
    else
    {
        if(completionBlock)
        {
            completionBlock(NULL);
        }
    }
}

- (void) analyzeVideo:(CMSampleBufferRef)videoSampleBuffer withTrackTransform:(CGAffineTransform)transform completionBlock:(void (^)(AVTimedMetadataGroup* metadataGroup))completionBlock
{
    if(videoSampleBuffer)
    {
        CFRetain(videoSampleBuffer);
        
        CMTime samplePresentationTime = CMSampleBufferGetOutputPresentationTimeStamp(videoSampleBuffer);
        CMTime sampleDuration = CMSampleBufferGetOutputDuration(videoSampleBuffer);
        CMTimeRange sampleTimeRange = CMTimeRangeMake(samplePresentationTime, sampleDuration);
        
        CVPixelBufferRef videoPixelBuffer = CMSampleBufferGetImageBuffer(videoSampleBuffer);
        CVPixelBufferRetain(videoPixelBuffer);
        
        [self.conformSession conformPixelBuffer:videoPixelBuffer
                                         atTime:samplePresentationTime
                                  withTransform:transform
                                           rect:CGRectMake(0, 0, 224, 224) // size of Mobilenet Input
                                completionBlock:^(BOOL didSkipFrame, id<MTLCommandBuffer> commandBuffer, SynopsisVideoFrameCache * frameCache, NSError * error) {
                                    
                                    // Early Return on error, or nil
                                    if(didSkipFrame || error != nil || commandBuffer == nil || frameCache == nil)
                                    {
                                        if(completionBlock)
                                        {
                                            completionBlock(nil);
                                        }
                                        
                                        // Free our input sample buffer
                                        CVPixelBufferRelease(videoPixelBuffer);
                                        CFRelease(videoSampleBuffer);
                                        
                                        return;
                                    }
                                    
                                    [self.standardAnalyzer analyzeFrameCache:frameCache commandBuffer:commandBuffer completionHandler:^(NSDictionary *metadata, NSError *error) {
                                        
                                        leaving this comment uncommented to trigger an error should this  compile
                                        this class isnt really used any more
                                        and needs to be replaced ideally by SynopsisJobObject but that means we need to support HAP or other media within the framework?
                                        No idea.
                                        
//                                        NSDictionary* standardMetadata = @{ kSynopsisStandardMetadataDictKey : metadata };
//                                                                                    NSLog(@"........... encoding metadata");
                                        AVTimedMetadataGroup* metadataGroup = [self.metadataEncoder encodeSynopsisMetadataToTimesMetadataGroup:metadata timeRange:sampleTimeRange];
                                        
                                        if(completionBlock)
                                        {
                                            completionBlock(metadataGroup);
                                        }
                                        
                                        // Free our input sample buffer
                                        CVPixelBufferRelease(videoPixelBuffer);
                                        CFRelease(videoSampleBuffer);
                                    }];
                                }];
    }
    else
    {
        if(completionBlock)
        {
            completionBlock(nil);
        }
    }
}

@end
