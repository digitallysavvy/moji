#import <KudanAR/ARNode.h>

@class ARImageTrackable;

/**
 A node that reparents itself to different trackable worlds. This is useful for sharing nodes across different markers.
 */
@interface ARMultiTrackableNode : ARNode

/**
 Add a trackable to the list of trackables that this node will attach itself to when detected.
 @param trackable The trackable to follow.
 */
- (void)addTrackable:(ARImageTrackable *)trackable;

/**
 Remove a trackable from the list of trackables.
 @param trackable The trackable to remove.
 */
- (void)removeTrackable:(ARImageTrackable *)trackable;

/**
 The list of trackables this node follows.
 */
@property (nonatomic) NSArray *trackables;

@end
