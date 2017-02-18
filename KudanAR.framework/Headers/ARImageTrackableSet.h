#import <Foundation/Foundation.h>

/**
 This class represents a set of ARImageTrackable objects, typically imported from a file.
 */
@interface ARImageTrackableSet : NSObject

/**
 Initialise with a trackable set file.
 @param path The full path name to the trackable set file.
 */
- (instancetype)initWithPath:(NSString *)path;

/**
 Initialise with a trackable set file.
 @param file The file relative to the main bundle.
 */
- (instancetype)initWithBundledFile:(NSString *)file;

/**
 The number of trackables in this set.
 */
@property (nonatomic, readonly) NSUInteger numberOfTrackables;

/**
 The list of ARImageTrackable objects in this set.
 */
@property (nonatomic, readonly) NSArray *trackables;



// ** New computer vision features **

/**
 Set this marker set to use flow recovery, if the global setting is switched on (default to global setting)
 */
- (void)allowRecoveryMode;

/**
 Make this marker set use flow recovery irrespective of the global setting
 */
- (void)forceRecoveryMode;

/**
 Prevernt this set marker from using flow recovery, irrespective of the global setting
 */
- (void)prohibitRecoveryMode;



@end
