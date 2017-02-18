#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

/**
 Protocol for camera events.
 */
@protocol ARCameraStreamEvent <NSObject>

@optional
/**
 The camera received a new frame.
 
 @param data Contains the camera image data buffer in the format defined by cameraDataFormat.
 @param timeStamp the time the frame was captured.
 */
- (void)didReceiveNewFrame:(NSData *)data timeStamp:(NSTimeInterval)timeStamp;

/**
 The camera received a new colour frame.
 
 @param lumaData Contains the camera image data buffer containing the luma component channel.
 @param chromaData Contains the camera image data buffer containing the blue-difference and red-difference chroma component interleaved channels in a biplanar buffer.
 @param timeStamp the time the frame was captured.
 */
- (void)didReceiveNewFrameWithLuma:(NSData *)lumaData chroma:(NSData *)chromaData timeStamp:(NSTimeInterval)timeStamp;

@end

@class ARTexture;
@class ARColour;

/**
 A manager class for handling the camera stream.
 */
@interface ARCameraStream : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate>

/**
 Get the manager singleton.
 @return the singleton instance.
 */
+ (ARCameraStream *)getInstance;

/**
 Returns the average colour of an image expressed as a byte array. Image will be downsized before computation of average. Smaller images will compute faster at the expense of accuracy. It is recommended to reduce image size as much as possible.
 
 @param data NSData containing the image data
 @param channels Number of channels contained within the image data. For example, RGB data would contain 3 channels.
 @param width Pixel width size to which the image will be scaled before computing average.
 @param height Pixel height size to which the image will be scaled before computing average.
 
 @return Average colour of image.
 */
- (ARColour *)averageColourFromData:(NSData *)data withChannels:(int)channels downsamplingWidth:(int)width height:(int)height;

/**
 Initialise the camera. This is usually handled automatically.
 */
- (void)initialise;

/**
 Deinitialise the camera. This is usually handled automatically.
 */
- (void)deinitialise;

/**
 Start the camera stream. This is usually handled automatically.
 */
- (void)start;

/**
 Stop the camera stream. This is usually handled automatically.
 */
- (void)stop;

- (void)addDelegate:(id<ARCameraStreamEvent>)delegate;
- (void)removeDelegate:(id<ARCameraStreamEvent>)delegate;

/**
 The width of the camera image in pixels.
 */
@property (nonatomic) float width;

/**
 The height of the camera image in pixels.
 */
@property (nonatomic) float height;

@property (nonatomic) float padding;

@property (nonatomic) ARTexture *cameraTexture;

/**
 Array containing the ARCameraStreamEvent delegates.
 */
@property (nonatomic) NSArray *delegates;

@property (nonatomic) ARTexture *cameraTextureY;
@property (nonatomic) ARTexture *cameraTextureUV;

/**
 Removes delegates for ARCameraStream Event
 */
- (void) removeDelegates;

@end
