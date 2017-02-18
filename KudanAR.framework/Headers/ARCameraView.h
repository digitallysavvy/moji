#import <Foundation/Foundation.h>
#import <KudanAR/ARView.h>
#import <KudanAR/ARCameraStream.h>

@class ARTexture;
@class ARCameraViewController;
@class ARViewPort;

/**
 A view that automatically renders the camera image and contains viewports for content rendering.
 */
@interface ARCameraView : ARView <ARCameraStreamEvent>

/**
 The camera texture.
 */
@property (nonatomic) ARTexture *cameraTexture;

/**
 Pause AR.
 */
- (void)resume;

/**
 Resume AR.
 */
- (void)pause;

/**
 A new camera frame was received.
 @param data The data in greyscale.
 @param timeStamp the time the frame was received.
 */
- (void)didReceiveNewFrame:(NSData *)data timeStamp:(NSTimeInterval)timeStamp;

/**
 The ARCameraViewController that contains this view.
 */
@property (nonatomic, weak) ARCameraViewController *cameraViewController;

/**
 The viewport containing the camera image. This has an orthographic projection.
 */
@property (nonatomic) ARViewPort *cameraViewPort;

/**
 The viewport containing 3D content. This has a perspective projection.
 */
@property (nonatomic) ARViewPort *contentViewPort;
@property (nonatomic) ARViewPort *pointsViewPort;

@end
