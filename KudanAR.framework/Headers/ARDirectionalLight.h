#import "ARLight.h"

/**
 ARDirectionalLight represents a light source of constant intensity emitted from a specific direction. This light behaves as if all rays created are parallel and emitted from a distance infinitely far away.
 
 Affects objects that use ARLightMaterial.
 
 Direction of light source is set by changing the light's orientation variable.
 */
@interface ARDirectionalLight : ARLight

@end
