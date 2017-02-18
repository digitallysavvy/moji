#import <Foundation/Foundation.h>
#import <KudanAR/ARNode.h>

@class ARVector3;

/**
 The base light class from which all light objects build from.
 */
@interface ARLight : ARNode

/**
 The colour component of this light. 0..1.
 */
@property (nonatomic) ARVector3 *colour;

/**
 The minimum illumination added to all objects in the scene regardless of incident light.
 */
@property (nonatomic) float ambientCoefficient;

- (id)initWithColour:(ARVector3 *)colour;

@end
