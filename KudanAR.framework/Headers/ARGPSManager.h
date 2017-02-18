#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ARGyroManager.h"

@class ARWorld;

/**
 A manager class singleton for placing nodes at real world locations. The GPSManager world is aligned to true north.
 */
@interface ARGPSManager : NSObject <CLLocationManagerDelegate, ARRendererDelegate>

/**
 The location manager responsible for updating the location of the manager world.
 */
@property (nonatomic, strong) CLLocationManager *locationManager;


/**
 Maths method for calculating the bearing between two locations.
 @param source The start location.
 @param dest The end location.
 */
+ (double)bearingFrom:(CLLocation *)source to:(CLLocation *)dest;

/**
 Returns the manager singleton.
 */
+ (ARGPSManager *)getInstance;

/**
 Returns the most recent update of the device location.
 */
- (CLLocation *)getCurrentLocation;

- (void)initialise;
- (void)deinitialise;
- (void)start;
- (void)stop;

@property (nonatomic) ARWorld *world;

@end
