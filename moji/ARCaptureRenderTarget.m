//
//  ARCaptureRenderTarget.m
//
//  Created by Shyngys Kassymov on 18.05.17.
//

#import "ARCaptureRenderTarget.h"
#import "moji-Swift.h"
#import <CoreVideo/CoreVideo.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES3/glext.h>

@implementation ARCaptureRenderTarget {
    CVOpenGLESTextureCacheRef cvTextureCache;
    BOOL didSetup;
}

- (instancetype)initWithWidth:(float)width height:(float)height {
    self = [super initWithWidth:width height:height];
    
    if (self) {        
        // Account for the scaling factor associated with some iOS devices.
        self.width *= [UIScreen mainScreen].scale;
        self.height *= [UIScreen mainScreen].scale;
        
        _isVideoFinishing = true;
        _recordEncoding = ENC_AAC;
    }
    return self;
}

- (void)setupAssetWriterInputs {
    // Set up asset writer inputs.
    
    // Set up the asset writer to encode video in the H.264 format, with the height and width equal to that
    // of the framebuffer object.
    NSDictionary *assetWriterInputAttributesDictionary =
    [NSDictionary dictionaryWithObjectsAndKeys:
     AVVideoCodecH264, AVVideoCodecKey,
     [NSNumber numberWithInt:self.width], AVVideoWidthKey,
     [NSNumber numberWithInt:self.height], AVVideoHeightKey,
     nil];
    
    _assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo
                                                                              outputSettings:assetWriterInputAttributesDictionary];
    _assetWriterInput.expectsMediaDataInRealTime = true;
    
    // Assume the input pixel buffer is in BGRA format, the iOS standard format.
    NSDictionary *sourcePixelBufferAttributesDictionary =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
     [NSNumber numberWithInt:self.width], kCVPixelBufferWidthKey,
     [NSNumber numberWithInt:self.height], kCVPixelBufferHeightKey,
     nil];
    
    _assetWriterPixelBufferInput = [[AVAssetWriterInputPixelBufferAdaptor alloc]
                                    initWithAssetWriterInput: _assetWriterInput
                                    sourcePixelBufferAttributes: sourcePixelBufferAttributesDictionary];
}

- (void)setupAssetWriter {
    // Set up asset writer.
    NSError *outError;
    
    // Write the video file to the application's library directory
    NSURL *outputURL = [self videoURL];
    _currentVideoURL = outputURL;
    
    // Delete a file with the same path if one exists.
    if ([[NSFileManager defaultManager] fileExistsAtPath:[outputURL path]]){
        
        [[NSFileManager defaultManager] removeItemAtURL:outputURL error:nil];
    }
    
    _assetWriter = [AVAssetWriter assetWriterWithURL:outputURL
                                            fileType:AVFileTypeQuickTimeMovie
                                               error:&outError];
    
    if (outError) {
        NSAssert(NO, @"Error creating AVAssetWriter");
    }
    
    // Add the input to the writer if possible.
    if ([_assetWriter canAddInput:_assetWriterInput]) {
        [_assetWriter addInput:_assetWriterInput];
    } else {
        NSAssert(NO, @"Error adding asset writer input");
    }
    
    // Start the asset writer immediately for this simple example.
    [_assetWriter startWriting];
    [_assetWriter startSessionAtSourceTime:kCMTimeZero];
    
    // Store the date when the asset writer started recording video.
    _startDate = [NSDate date];
    
    // Check the asset writer has started.
    if (_assetWriter.status == AVAssetWriterStatusFailed) {
        NSAssert(NO, @"Error starting asset writer %@", _assetWriter.error);
    }
}

- (void)setupFBO {
    // Make the renderer context current, necessary to create any new OpenGL objects.
    [[ARRenderer getInstance] useContext];
    
    // Create the FBO.
    glActiveTexture(GL_TEXTURE1);
    glGenFramebuffers(1, &_fbo);
    [self bindBuffer];
    
    // Create the OpenGL texture cache.
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, [EAGLContext currentContext], NULL, &cvTextureCache);
    
    if (err) {
        NSAssert(NO, @"Error creating CVOpenGLESTextureCacheCreate %d", err);
    }
    
    // Create the OpenGL texture we will be rendering to.
    CVPixelBufferPoolRef pixelBufferPool = [_assetWriterPixelBufferInput pixelBufferPool];
    
    err = CVPixelBufferPoolCreatePixelBuffer (kCFAllocatorDefault, pixelBufferPool, &_pixelBuffer);
    
    if (err) {
        NSAssert(NO, @"Error creating CVPixelBufferPoolCreatePixelBuffer %d", err);
    }
    
    CVOpenGLESTextureRef renderTexture;
    CVOpenGLESTextureCacheCreateTextureFromImage (kCFAllocatorDefault, cvTextureCache, _pixelBuffer,
                                                  NULL, // texture attributes
                                                  GL_TEXTURE_2D,
                                                  GL_RGBA, // opengl format
                                                  (int)self.width,
                                                  (int)self.height,
                                                  GL_BGRA, // native iOS format
                                                  GL_UNSIGNED_BYTE,
                                                  0,
                                                  &renderTexture);
    
    // Attach the OpenGL texture to the framebuffer.
    glBindTexture(CVOpenGLESTextureGetTarget(renderTexture), CVOpenGLESTextureGetName(renderTexture));
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(renderTexture), 0);
    
    // Create a depth buffer for correct drawing.
    GLuint depthRenderbuffer;
    
    glGenRenderbuffers(1, &depthRenderbuffer);
    
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8_OES, self.width, self.height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);
    
    // Check the FBO is complete and ready for rendering
    [self checkFBO];
}

- (void)bindBuffer {
    glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
}

- (void)draw {
    // Draw content to the framebuffer as normal.
    [super draw];
    
    if (self.assetWriter == nil) {
        return;
    }
    
    // Prevent encoding of a new frame if the AVAssetWriter is not writing or if the video is completed.
    if (self.assetWriter.status != AVAssetWriterStatusWriting || _isVideoFinishing) {
        return;
    }
    
    // Wait for all OpenGL commands to finish.
    glFinish();
    
    // Lock the pixel buffer to allow it to be used for encoding.
    CVPixelBufferLockBaseAddress(_pixelBuffer, 0);
    
    // Submit the pixel buffer for the current frame to the asset writer with the correct timestamp.
    _currentTime = CMTimeMakeWithSeconds([[NSDate date] timeIntervalSinceDate:_startDate],120);
    
    if (![_assetWriterPixelBufferInput appendPixelBuffer:_pixelBuffer withPresentationTime:_currentTime]) {
        NSLog(@"Problem appending pixel buffer at time: %lld", _currentTime.value);
    }
    
    // Unlock the pixel buffer to free it.
    CVPixelBufferUnlockBaseAddress(_pixelBuffer, 0);
    
    if (_needStopVideoRecording) {
        _isVideoFinishing = true;
        _needStopVideoRecording = false;
        
        [self.assetWriter finishWritingWithCompletionHandler:^{
            NSLog(@"Finished writing video.");
            
            if (_onDidStop != nil) {
                _onDidStop(_currentVideoURL, _currentAudioURL, CMTimeGetSeconds(_currentTime));
            }
            NSString *previewURL = [_currentVideoURL absoluteString];
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            if (standardUserDefaults) {
                [standardUserDefaults setObject:previewURL forKey:@"previewURL"];
                [standardUserDefaults synchronize];
                ViewController *controller = [[ViewController alloc]init];
                [controller previewVideo];
            }
            [self resetResources];
        }];
        
        [self stopAudioRecording];
    } else {
        if (_onProgressChange != nil) {
            _onProgressChange(CMTimeGetSeconds(_currentTime));
        }
    }
}

- (void)resetResources {
    _assetWriter = nil;
    _startDate = nil;
    _currentVideoURL = nil;
    _currentAudioURL = nil;
    _currentTime = kCMTimeZero;
}

#pragma mark - Helpers

- (NSURL *)videoURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *documentsDirectory = paths[0];
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *filePath = [NSString stringWithFormat:@"%@/video_%08f.mov", documentsDirectory, timestamp];
    return [NSURL fileURLWithPath:filePath];
}

- (NSURL *)audioURL {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true);
    NSString *documentsDirectory = paths[0];
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *filePath = [NSString stringWithFormat:@"%@/audio_%08f.m4a", documentsDirectory, timestamp];
    return [NSURL fileURLWithPath:filePath];
}

#pragma mark - Methods

- (void)startRecording {
    // Set up the required render target assets.
    if (!didSetup) {
        [self setupAssetWriterInputs];
        [self setupAssetWriter];
        [self setupFBO];
        
        didSetup = true;
    } else {
        [self setupAssetWriter];
    }
    
    _isVideoFinishing = false;
    
    [self startAudioRecording];
}

- (void)startAudioRecording {
    NSError *error = nil;

    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:true error:&error];
    
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] initWithCapacity:10];
    if (_recordEncoding == ENC_PCM) {
        [recordSettings setObject:[NSNumber numberWithInt: kAudioFormatLinearPCM] forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
        [recordSettings setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    } else {
        NSNumber *formatObject;
        
        switch (_recordEncoding) {
            case (ENC_AAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatMPEG4AAC];
                break;
            case (ENC_ALAC):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleLossless];
                break;
            case (ENC_IMA4):
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
                break;
            case (ENC_ILBC):
                formatObject = [NSNumber numberWithInt: kAudioFormatiLBC];
                break;
            case (ENC_ULAW):
                formatObject = [NSNumber numberWithInt: kAudioFormatULaw];
                break;
            default:
                formatObject = [NSNumber numberWithInt: kAudioFormatAppleIMA4];
        }
        
        [recordSettings setObject:formatObject forKey: AVFormatIDKey];
        [recordSettings setObject:[NSNumber numberWithFloat:44100.0] forKey: AVSampleRateKey];
        [recordSettings setObject:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];
//        [recordSettings setObject:[NSNumber numberWithInt:12800] forKey:AVEncoderBitRateKey];
//        [recordSettings setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
//        [recordSettings setObject:[NSNumber numberWithInt: AVAudioQualityHigh] forKey: AVEncoderAudioQualityKey];
    }
    
    NSURL *url = [self audioURL];
    _currentAudioURL = url;
    
    _audioRecorder = [[ AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    
    if ([_audioRecorder prepareToRecord]) {
        [_audioRecorder record];
    } else {
        int errorCode = CFSwapInt32HostToBig ([error code]); 
        NSLog(@"Error: %@ [%4.4s])" , [error localizedDescription], (char*)&errorCode);
    }
    
    NSLog(@"Recording audio ...");
}

- (void)stopRecording {
    _needStopVideoRecording = true;
}

- (void)stopAudioRecording {
    NSLog(@"Stop recording audio ...");
    [_audioRecorder stop];
    NSLog(@"Stopped recording audio ...");
}

@end
