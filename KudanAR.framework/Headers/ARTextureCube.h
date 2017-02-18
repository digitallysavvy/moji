#import <KudanAR/ARTexture.h>

/**
 A texture representing a cube for use in environment mapping.
 */
@interface ARTextureCube : ARTexture

/**
 Initialise with an array of UIImage images.
 @param images an array of UIImage objects. The order is: back, front, up, down, right, left.
 */
- (instancetype)initWithUIImages:(NSArray *)images;

/**
 Initialise with an array of image files relative to the main bundle.
 @param images an array of image file names relative to the main bundle. The order is: back, front, up, down, right, left.
 */
- (instancetype)initWithBundledFiles:(NSArray *)bundledFiles;

@end
