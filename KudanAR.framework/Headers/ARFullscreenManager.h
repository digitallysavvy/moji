#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ARRenderer.h"

@class ARWorld;
@class ARViewPort;
@class ARQuaternion;
@class ARVideoNode;

@interface ARFullscreenManager : NSObject <ARRendererDelegate>

#pragma mark - Properties

/**
 The width of the camera near plane.
 */
@property (nonatomic, readonly) float nearPlaneWidth;

/**
 The height of the camera near plane.
 */
@property (nonatomic, readonly) float nearPlaneHeight;

/**
 Correctional term to account for the difference in viewport width to it's associated render target.
 */
@property (nonatomic, readonly) float renderTargetCorrection;

/**
 The offset of the camera principle point from the screen centre.
 */
@property (nonatomic, readonly) CGPoint principlePointOffset;

/**
 Rotation of the screen from default state of UIInterfaceOrientationLandscapeLeft.
 */
@property (nonatomic, readonly) ARQuaternion *screenOrientation;

/**
 World containing the fullscreen node.
 */
@property (nonatomic, readonly) ARWorld *world;

/**
 The current node in fullscreen.
 */
@property (nonatomic, readonly) ARVideoNode *fullscreenNode;

/**
 Time taken for fullscreen enable and disable animations in seconds.
 */
@property (nonatomic) NSTimeInterval fullscreenAnimationTime;

/**
 Time taken for orientation change animations in seconds.
 */
@property (nonatomic) NSTimeInterval rotationAnimationTime;

/**
 Time taken for background fade in animation in seconds.
 */
@property (nonatomic) NSTimeInterval backgroundFadeAnimationTime;

/**
 Toggles whether a black placeholder box will be left in the place of a node when fullscreen is enabled.
 */
@property (nonatomic) BOOL showPlaceholder;

/**
 Toggles whether the node will have a black background that fades in to obsure the rest of the scene after enabling fullscreen.
 */
@property (nonatomic) BOOL showBackground;

#pragma mark - Methods

+ (ARFullscreenManager *)getInstance;

/**
 Initialises the manager to enable fullscreen in the desired viewport. Must be called for fullscreen to occur.
 */
- (void)initialiseWithViewport:(ARViewPort *)viewport;

/**
 Disables fullscreen and purges manager.
 */
- (void)deinitialise;

/**
 Called when the orientation of the device changes. Used to keep fullscreen nodes in the correct orientation.
 */
- (void)setDeviceOrientation:(UIInterfaceOrientation)orientation;

/**
 Makes the specified ARVideoNode transition to fullscreen view. Can only be called if no other node is currently fullscreen.
 */
- (void)makeNodeFullscreen:(ARVideoNode *)node;

/**
 Transitions the current fullscreen node back to it's original transformation in it's parent.
 */
- (void)disableFullscreen;

@end