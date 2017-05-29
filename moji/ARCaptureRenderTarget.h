//
//  ARCaptureRenderTarget.h
//
//  Created by Shyngys Kassymov on 18.05.17.
//

#import <KudanAR/KudanAR.h>
#import <AVFoundation/AVFoundation.h>

@interface ARCaptureRenderTarget : ARRenderTarget {
    enum {
        ENC_AAC = 1,
        ENC_ALAC = 2,
        ENC_IMA4 = 3,
        ENC_ILBC = 4,
        ENC_ULAW = 5,
        ENC_PCM = 6,
    } encodingTypes;
}

@property (nonatomic, strong) AVAssetWriter *assetWriter;
@property (nonatomic, strong) AVAssetWriterInput *assetWriterInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *assetWriterPixelBufferInput;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic) CVPixelBufferRef pixelBuffer;
@property (nonatomic) BOOL isVideoFinishing;
@property (nonatomic) BOOL needStopVideoRecording;
@property (nonatomic) GLuint fbo;

@property (nonatomic, strong) NSURL *currentVideoURL;
@property (nonatomic, strong) NSURL *currentAudioURL;
@property (nonatomic) CMTime currentTime;

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;
@property (nonatomic) int recordEncoding;

@property (nonatomic, copy) void (^onProgressChange)(double duration);
@property (nonatomic, copy) void (^onDidStop)(NSURL *videoURL, NSURL *audioURL, double duration);

#pragma mark - Methods

- (void)startRecording;
- (void)stopRecording;

@end