#import <Foundation/Foundation.h>
#import <KudanAR/ARMaterial.h>

@class ARTexture;

/**
 A material for shading a texture.
 */
@interface ARTextureMaterial : ARMaterial

/**
 The main texture displayed on the material.
 */
@property (nonatomic) ARTexture *texture;

/**
 The texture to blend with the main texture based on the blend parameter.
 */
@property (nonatomic) ARTexture *blendTexture;

/**
 Initialise with an existing texture.
 @param texture The texture to initialise with.
 @return The initialised material.
 */
- (instancetype)initWithTexture:(ARTexture *)texture;
+ (instancetype)materialwithTexture:(ARTexture *)texture;

/**
 The alpha factor. Combined with the texture sample to alter transparency. Range 0..1. Default value is 1.
 */
@property (nonatomic) float alpha;

/**
 The blend parameter. Mixes blendTexture with texture based on value. Range 0..1. Default value is 0.
 */
@property (nonatomic) float blendParameter;

@end
