#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ARMatrix4;
@class ARVector3;
@class ARQuaternion;
@class ARRenderer;

/**
 ARNode represents the base object of the scene-graph. It is responsible for the spatial layout of content.
 */
@interface ARNode : NSObject <NSCopying>

/**
 Different transformation spaces that the various transformation methods can act in.
 */
typedef NS_ENUM(NSInteger, TransformSpace) {
    /**
     Transform is applied relative to the existing local transform. Eg. translations take the local rotation into account.
     */
    ARNodeTransformSpaceLocal,
    /**
     Transform is applied relative to the parent's transform. Eg. translations are unaffected by the local scale and rotation.
     */
    ARNodeTransformSpaceParent,
    /**
     Transform is applied relative to the node's closest ARWorld grandparent. This is useful for moving around in world space.
     */
    ARNodeTransformSpaceWorld,
};

/**
 The node's name.
 */
@property (nonatomic) NSString *name;

/**
 This node's parent node. nil if it is a root node.
 */
@property (nonatomic, weak) ARNode *parent;

/**
 Direct child nodes of this node.
 */
@property (nonatomic, readonly) NSArray<ARNode *> *children;

/**
 All child nodes of this node by triversing the graph.
 */
@property (nonatomic, readonly) NSArray *descendants;

/**
 This node's position relative to its parent.
 */
@property (nonatomic) ARVector3 *position;

/**
 This node's scale relative to its parent.
 */
@property (nonatomic) ARVector3 *scale;

/**
 This node's orientation relative to its parent.
 */
@property (nonatomic) ARQuaternion *orientation;

/**
 The combination of the local position, scale and orientation of this node.
 */
@property (nonatomic, readonly) ARMatrix4 *localTransform;

/**
 The transformation to the nearest ARWorld that this node descends from.
 */
@property (nonatomic, readonly) ARMatrix4 *worldTransform;

/**
 The full transformation of this node in eye space.
 */
@property (nonatomic, readonly) ARMatrix4 *fullTransform;

/**
 The full orientation of this node in eye space.
 */
@property (nonatomic, readonly) ARQuaternion *fullOrientation;

/**
 The orientation of this node in the space of the nearest ARWorld this node descends from.
 */
@property (nonatomic, readonly) ARQuaternion *worldOrientation;

/**
 The scale of this node in the space of the nearest ARWorld this node descends from.
 */
@property (nonatomic, readonly) ARVector3 *worldScale;

/**
 The position of this node in the space of the nearest ARWorld this node descends from.
 */
@property (nonatomic, readonly) ARVector3 *worldPosition;

/**
 The full orientation of this node in eye space.
 */
@property (nonatomic, readonly) ARVector3 *fullPosition;


/**
 The ARWorld this node descends from.
 */
@property (nonatomic) ARNode *world;

/**
 Add a node as a child of this node.
 @param child The node to be added.
 */
- (void)addChild:(ARNode *)child;

/**
 Add a list of nodes as children of this node.
 @param children The nodes to be added.
 */
- (void)addChildren:(NSArray *)children;

/**
 Remove a node from this node's children.
 @param child The node to be removed.
 */
- (void)removeChild:(ARNode *)child;

/**
 Remove all children from this node.
 */
- (void)removeAllChildren;

/**
 Remove this node from its parent node.
 */
- (void)remove;

/**
 Find a child of this node.
 @param name The name of the node to search for.
 @return The ARNode if found, otherwise nil.
 */
- (ARNode *)findChildWithName:(NSString *)name;

/**
 The number of direct children this node has.
 */
@property (nonatomic, readonly) NSUInteger childCount;

- (void)markWorldTransformAsDirty;

/**
 Translate the position of this node.
 @param x units to translate along the x-axis.
 @param y units to translate along the y-axis.
 @param z units to translate along the z-axis.
 */
- (void)translateByX:(float)x y:(float)y z:(float)z;

/**
 Translate the position of this node.
 @param x units to translate along the x-axis.
 @param y units to translate along the y-axis.
 @param z units to translate along the z-axis.
 @param transformSpace the specificed TransformSpace determines the coordinate system of the units.
 */
- (void)translateByX:(float)x y:(float)y z:(float)z transformSpace:(TransformSpace)transformSpace;

/**
 Translate the position of this node.
 @param translation A vector containing the x, y and z units to translate by.
 */
- (void)translateByVector:(ARVector3 *)translation;

/**
 Translate the position of this node.
 @param translation A vector containing the x, y and z units to translate by.
 @param transformSpace the specificed TransformSpace determines the coordinate system of the units.
 */
- (void)translateByVector:(ARVector3 *)translation transformSpace:(TransformSpace)transformSpace;

/**
 Scale this node uniformly across each axis. Scales are accumulated.
 @param scale The amount to scale by.
 */
- (void)scaleByUniform:(float)scale;

/**
 Scale this node separately along each axis. Scale can be non-uniform.
 @param x The amount to scale in the x-axis.
 @param y The amount to scale in the x-axis.
 @param z The amount to scale in the x-axis.
 */
- (void)scaleByX:(float)x y:(float)y z:(float)z;

/**
 Scale this node separately along each axis. Scale can be non-uniform.
 @param scale A vector containing the x, y and z scale factors.
*/
- (void)scaleByVector:(ARVector3 *)scale;

/**
 Rotate this node around an axis.
 @param angle the angle in degrees.
 @param x The x component of the axis.
 @param y The y component of the axis.
 @param z The z component of the axis.
 */
- (void)rotateByDegrees:(float)angle axisX:(float)x y:(float)y z:(float)z;

/**
 Rotate this node around an axis.
 @param angle the angle in radians.
 @param x The x component of the axis.
 @param y The y component of the axis.
 @param z The z component of the axis.
 */
- (void)rotateByRadians:(float)angle axisX:(float)x y:(float)y z:(float)z;

/**
 Multiply this node's orientation by a quaternion.
 @param rotation The quaternion to rotate this node with.
 */
- (void)rotateByQuaternion:(ARQuaternion *)rotation;

/**
 This node's visibility. If visible is set to NO then no children will be rendered.
 */
@property (nonatomic) BOOL visible;

/**
 Convert a position from this node's space to the nearest world space.
 @param position The position in this node's space.
 @return The position in world space.
 */
- (ARVector3 *)positionToWorld:(ARVector3 *)position;

/**
 Convert a position from this node's space to eye/camera space.
 @param position The position in this node's space.
 @return The position in eye space.
 */
- (ARVector3 *)positionToEye:(ARVector3 *)position;
- (ARQuaternion *)orientationToWorld:(ARQuaternion *)orientation;
- (ARQuaternion *)orientationToEye:(ARQuaternion *)orientation;

/**
 Project a point in this node's coordinate space to its position in the ARViewPort this node is attached to.
 @param position The 3D position in this node's coordinate space to project.
 @return The 2D position in the ARViewPort.
 */
- (CGPoint)viewPortFromNodePosition:(ARVector3 *)position;

/**
 Called when this node is being rendered.
 */
- (void)render;

/**
 Called prior to this node being rendered.
 */
- (void)preRender;

/**
 Called after this node has been rendered.
 */
- (void)postRender;

/**
 Create a node with the specified name.
 @param name The name of this node.
 */
+ (instancetype)nodeWithName:(NSString *)name;

/**
 Add an action that is triggered whenever this node or one of its children is touched.
 @param target The object to receive the event.
 @param action The method to call on the object.
 */
- (void)addTouchTarget:(id)target withAction:(SEL)action;

/**
 Called whenever this node or one of its children is touched.
 */
- (void)didReceiveTouch;

/**
 Unproject a 2D position in the ARViewPort to this nodes coordinate space.
 @param point The 2D position in the viewport.
 @return The 3D position where the point intersects this node.
 */
- (ARVector3 *)nodeFromViewPort:(CGPoint)point;

@end
