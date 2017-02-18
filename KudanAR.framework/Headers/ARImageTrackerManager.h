#import <Foundation/Foundation.h>

@class ARImageTrackable;
@class ARImageTrackableSet;
@class ARNode;

/**
 Manager singleton for the image tracker. The image tracker is capable of detecting pre-registered 2D images within the camera stream.
 */
@interface ARImageTrackerManager : NSObject

/**
 Get the instance of the singleton.
 @return The singleton instance.
 */
+ (ARImageTrackerManager *)getInstance;

/**
 Initialise the image tracker.
 */
- (void)initialise;

/**
 Deinitialise the image tracker.
 */
- (void)deinitialise;

/**
 Add a trackable to the image tracker so that it may be detected. The trackable's name must be unique compared to the currently added trackables.
 @param trackable The trackable to add.
 @return A boolean, true iff the marker was successfully created and added to the tracker
 */
- (BOOL)addTrackable:(ARImageTrackable *)trackable;

/**
 Remove a trackable from the image tracker. This trackable will no longer be detected.
 @param trackable The trackable to remove.
 */
- (void)removeTrackable:(ARImageTrackable *)trackable;

/**
 Add a set of trackables to the image tracker so they may be detected.
 @param set The set of trackables to add.
 */
- (void)addTrackableSet:(ARImageTrackableSet *)set;

/**
 The list of registered trackables.
 */
@property (readonly) NSArray *trackables;

/**
 The number of trackables detected in the last processed frames.
 */
@property (readonly) int numberOfDetectedTrackables;

/**
 The list of detected ARImageTrackable objects from the last processed frame.
 */
@property (readonly) NSArray *detectedTrackables;

/**
 Find a trackable registered with the tracker by its name.
 @param name The name of the trackable to find.
 @return The matching trackable or nil if not found.
 */
- (ARImageTrackable *)findTrackableByName:(NSString *)name;

- (void)process:(NSData *)data width:(int)width height:(int)height padding:(int)padding;

/**
 This node is the parent of all trackable worlds. It can be used to toggle visibility of all markers or as a touch target to receive touches on any marker.
 */
@property (nonatomic) ARNode *baseNode;

/**
 Whether the tracker is initialised or not.
 */
@property (nonatomic) BOOL isInitialised;

/**
 Start image tracking.
 */
- (void)start;

/**
 Stop image tracking.
 */
- (void)stop;


// ** New computer vision features **


/** 
 Set the maximum number of trackables which can be tracked at the same time.
 The detector will not run if the maximum number are already tracked.
 This does not affect the number of trackables which can be loaded at the same time.
 Set to a value of 0 for an unlimited number of concurrent tracked markers (default)
 @param maxToTrack The maximum numbers of trackables which can be simultaneously tracked
 */
- (void)setMaximumSimultaneousTracking:(int)maxToTrack;


/**
 Set whether recovery mode is enabled, for all trackables. This can be overridden on a per-trackable basis by using the force- and prohibit- functions of KudanImageTrackable
 @param doRecovery Whether recovery mode is used (true) or not (false)
 */
- (void)setRecoveryMode:(BOOL)doRecovery;

/**
 Query whether recovery mode is on, for all trackables in general. This could be overridden for individual trackables 
 @return Whether recovery mode is used (true) or not (false)
 */
- (BOOL)queryRecoveryMode;

/**
 Prohibit recovery mode for all trackables (ignoring the global setting)
 */
- (void)prohibitRecoveryMode;

/**
 For an individual trackable, query whether it is able to use recovery mode (depends on the global setting and the trackable's own setting) 
 @param trackable The trackable for which recovery mode is being queried
 @return Whether recovery mode is used (true) or not (false) for this one trackable
 */
- (BOOL)queryRecoveryMode:(ARImageTrackable *)trackable;


/**
 Set whether marker detection is parallelised (for simultaneous detection of multiple trackables) or not.
 The number of threads is not controllable but set automatically for the device
 @param isParallel Set whether detection can run in paralel (true) or not (false)
 */
-(void) toggleParallelDetection:(bool)isParallel;

/**
 Query whether marker detection is parallelised (for simultaneous detection of multiple trackables) or not.
 @return Boolean indicating whether detection can run in parallel or not
*/
-(BOOL) isDetectorParallel;


@end
