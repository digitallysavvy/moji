#import <Foundation/Foundation.h>
#import "ARGyroManager.h"

@class ARNode;

/**
 Delegate method called when ArbiTrack has been started and has values.
 */
@protocol ARArbiTrackerManagerDelegate <NSObject>

@required
@optional

- (void)arbiTrackStarted;

@end

/**
 Manager singleton for The Arbitrary Tracker.
 */
@interface ARArbiTrackerManager : NSObject <ARGyroManagerDelegate>

/**
 Get the singleton instance.
 @return the singleton instance.
 */
+ (ARArbiTrackerManager *)getInstance;

/**
 Initialise the Arbitrary Tracker.
 */
- (void)initialise;

/**
 Deinitialise the Arbitrary Tracker.
 */
- (void)deinitialise;

/**
 The node whose transformation will be used when the Arbitrary Tracker is started. Position this to determine the initial transformation when Arbitrary Tracking begins, and to define the coordinate space.
 */
@property (nonatomic) ARNode *targetNode;

/**
 When the Arbitrary Tracker is tracking, this node's transformation is updated by the tracker. Add content to this node.
 */
@property (nonatomic) ARNode *world;

/**
 Whether the Arbitrary Tracker is currently tracking.
 */
@property (nonatomic) BOOL isTracking;

/**
 The threshold for which tracking halts if the number of tracked features drops too low. Ordinarily around 100 features are tracked frame to frame. Default is 20.
 */
@property (nonatomic) int minimumFeatureCount;

- (void)process:(NSData *)data width:(int)width height:(int)height padding:(int)padding;

/**
 Start the Arbitrary tracker. The targetNode's transformation at this time is used to determine the initial pose of the tracker.
 */
- (void)start;

/**
 Stop the arbitrary tracker.
 */
- (void)stop;

/**
 Whether the tracker is initialised.
 */
@property (nonatomic) BOOL isInitialised;

/**
 Add a delegate for rendering event notifications.
 @param delegate The delegate to add.
 */
- (void)addDelegate:(id <ARArbiTrackerManagerDelegate >)delegate;

/**
 Remove a delegate for rendering event notifications.
 @param delegate The delegate to remove.
 */
- (void)removeDelegate:(id <ARArbiTrackerManagerDelegate >)delegate;

@end
