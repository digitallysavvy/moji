#import <KudanAR/ARLight.h>

/**
 ARPointLight represents a light in the scene that shines in all directions equally from a specific position.
 */
@interface ARPointLight : ARLight

/**
 The decay of the light intensity over distance.
 
 Smaller values represent less decay.
 */
@property (nonatomic) float attenuation;

@end
