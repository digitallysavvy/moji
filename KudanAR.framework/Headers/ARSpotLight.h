#import <KudanAR/ARPointLight.h>

/**
 ARSpotLight represents a light in the scene that shines from a specific position along a specific direction with a cone-shaped area of effect.
 */
@interface ARSpotLight : ARPointLight

/**
 The angle between the centre of the light direction vector and side of the light cone at which the light intensity begins to decay, expressed in radians.
 
 Should be no more than M_PI / 2.
 */
@property (nonatomic) float innerSpotAngle;

/**
 The angle between the centre of the light direction vector and the side of the light cone at which the light intesity becomes 0, expressed in radians.
 
 Should be no more than M_PI / 2.
 */
@property (nonatomic) float outerSpotAngle;

/**
 The direction vector of the spot light cone from it's position.
 */
@property (nonatomic) ARVector3 *spotDirection;

@end
