#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import "ARRenderer.h"

@class ARWorld;
@class ARQuaternion;
/**
 Delegate called when gyro has started and contains values.
 */
@protocol ARGyroManagerDelegate  <NSObject>

@required
@optional

- (void)gyroStarted;

@end


@interface ARGyroManager : NSObject <ARRendererDelegate>

+ (ARGyroManager *)getInstance;

typedef enum {
    ARGyroManagerStateInitialised,
    ARGyroManagerStateStopped,
    ARGyroManagerStateStarted,
} ARGyroManagerState;

@property (nonatomic) ARGyroManagerState gyroState;

typedef enum {
    ARGyroManagerStateInternalInitialised,
    ARGyroManagerStateInternalStopped,
    ARGyroManagerStateInternalStarted,
} ARGyroManagerStateInternal;

@property (nonatomic) ARGyroManagerStateInternal internalGyroState;

- (void)initialise;
- (void)deinitialise;

- (void)start;
- (void)stop;
- (void)actualStart;
- (void)actualStop;

- (void)updateNode;

@property (nonatomic, readonly) CMMotionManager *motionManager;

@property (nonatomic) CMAttitudeReferenceFrame gyroReferenceFrame;

@property (nonatomic) ARWorld *world;

/**
 Add a delegate for rendering event notifications.
 @param delegate The delegate to add.
 */
- (void)addDelegate:(id < ARGyroManagerDelegate>)delegate;

/**
 Remove a delegate for rendering event notifications.
 @param delegate The delegate to remove.
 */
- (void)removeDelegate:(id < ARGyroManagerDelegate>)delegate;

@end
