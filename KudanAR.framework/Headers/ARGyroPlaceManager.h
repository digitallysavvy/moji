#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <KudanAR/ARRenderer.h>

@class ARWorld;

/**
 Gyro place is a sensor-only tracker that places content on a virtual floor plane where the device is aimed.
 */
@interface ARGyroPlaceManager : NSObject <ARRendererDelegate>

/**
 Get the ARGyroPlaceManager instance.
 @return the instance.
 */
+ (ARGyroPlaceManager *)getInstance;

/**
 Initialise gyro place.
 */
- (void)initialise;

/**
 Deinitialise gyro place.
 */
- (void)deinitialise;

/**
 The distance between the floor and the camera. The units are arbitrary but can have real-world meaning to achieve realistic scale for placed content.
 Eg. if you estimate the device to be 100cm above the floor, set floorDepth to 100. Content rendered using this same space will look approximately the correct scale.
 */
@property (nonatomic) float floorDepth;

/**
 The world node that is controlled by this tracker. The world is placed where the camera normal intersects the floor plane.
 */
@property (nonatomic) ARWorld *world;

/**
 The centre of the screen in viewport coordinates. This is automatically set but can be overridden if you with a different part of the screen to act as the target.
 */
@property (nonatomic) CGPoint screenCentre;

@end
