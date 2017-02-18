#import <Foundation/Foundation.h>
#import <KudanAR/ARNode.h>

@class ARViewPort;

/**
 The camera node represents the root of the scenegraph. It is attached to an ARViewPort and controls the projection.
 */
@interface ARCamera : ARNode

/**
 The projection matrix representing the camera intrinsics.
 */
@property (nonatomic) ARMatrix4 *projectionMatrix;

/**
 Camera singleton.
 */
+ (ARCamera *)defaultCamera;


/**
 The far plane distance of the camera frustum.
 */
@property (nonatomic) CGPoint frustumPlaneDistance;
@property (nonatomic) CGPoint principlePoint;
@property (nonatomic) CGPoint fov;

/**
 The viewport this camera is attached to or nil if detached.
 */
@property (nonatomic, weak) ARViewPort *viewPort;

@end
