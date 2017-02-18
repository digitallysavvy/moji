#import <KudanAR/ARTextureMaterial.h>

@class ARVideoTexture;

/**
 A material for use with a video texture.
 */
@interface ARVideoTextureMaterial : ARMaterial

@property (nonatomic) ARVideoTexture *texture;

- (instancetype)initWithTexture:(ARVideoTexture *)texture;
+ (instancetype)materialwithTexture:(ARVideoTexture *)texture;

/**
 The transparency of the video. 0..1 with 1 being fully opaque.
 */
@property (nonatomic) float alpha;

/**
 The time in seconds in which to fade the video in. This takes control of the alpha property. Default: 0 seconds.
 */
@property (nonatomic) float fadeInTime;

@end
