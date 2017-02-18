#import <Foundation/Foundation.h>
#import <Kudanar/ARNode.h>

@class ARModelNode;
@class ARMeshNode;

/**
 A protocol for animation related events.
 */
@protocol ARAnimationDelegate <NSObject>

@optional
/**
 Called when the animation finishes.
 @param modelNode This node.
 */
- (void)animationDidFinish:(ARModelNode *)modelNode;

/**
 Called on each frame this animation renders.
 @param modelNode This node.
 @param time the time in seconds relative to the start of the animation.
 */
- (void)animationDidRender:(ARModelNode *)modelNode time:(NSTimeInterval)time;

@end


/**
 This class represents an imported 3D model. It is capable of representing animation and is the channel for controlling animations.
 */
@interface ARModelNode : ARNode

@property (nonatomic) NSArray *nodes;

/**
 The flat list of ARMeshNode objects that were imported.
 */
@property (nonatomic) NSArray *meshNodes;

- (ARMeshNode *)findMeshNode:(NSString *)name;

/**
 Whether this animation should loop automatically once it ends.
 */
@property (nonatomic) BOOL shouldLoop;

@property (nonatomic) NSMutableArray *channels;
@property (nonatomic) NSMutableArray *blendChannels;

/**
 The delegate object to receive ARAnimationDelegate protocol messages.
 */
@property (nonatomic, weak) id delegate;

/**
 Start the animation. Resumes from the current play time.
 */
- (void)start;

/**
 Stop the animation. The current play time remains the same.
 */
- (void)stop;

/**
 Reset the animation.
 */
- (void)reset;

/**
 The current animation time in seconds.
 Setting this value will change the animation position.
 */
@property (nonatomic) NSTimeInterval currentAnimationTime;

/**
 The time in seconds where if this node hasn't been rendered, the animation is reset.
 */
@property (nonatomic) NSTimeInterval resetThreshold;

@end
