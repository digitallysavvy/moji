#import <Foundation/Foundation.h>
#import <KudanAR/ARMaterial.h>

@class ARTextureCube;
@class ARMaterialProperty;
@class ARMaterialPropertyReflection;

/**
 A material for shading using dynamic lighting. This is most commonly used with 3D models.
 */
@interface ARLightMaterial : ARMaterial

/**
 The base colour of the material.
 */
@property (nonatomic) ARMaterialProperty *colour;

/**
 The texture to blend with the colour texture based on the blend parameter.
 
 Only used when colour.texture is set.
 */
@property (nonatomic) ARTexture *blendTexture;

/**
 The diffuse component of lighting applied to the material. Represents the general reflection of light at many angles from an incident light source.
 
 Can be set as a constant value or as a texture.
 */
@property (nonatomic) ARMaterialProperty *diffuse;

/**
 The ambient component of lighting applied to the material. Represents a solid colour unaffected by other lighting in the scene.
 
  Can be set as a constant value or as a texture.
 */
@property (nonatomic) ARMaterialProperty *ambient;

/**
 The specular component of lighting applied to the material. Represents the reflection of light at the reflection angle from an incident light source.
 
  Can be set as a constant value or as a texture.
 */
@property (nonatomic) ARMaterialProperty *specular;

/**
 The environment map and reflectivity factor used for image-based reflections and refractions.
 
 Reflectivity is set in the range of 0..1.
 
 Environment map must be assigned a cube map for reflection to occur.
*/
@property (nonatomic) ARMaterialPropertyReflection *reflection;

/**
 Contains the normal map for high-quality lighting.
 
 Can be set as a texture only.
 */
@property (nonatomic) ARMaterialProperty *normal;

/**
 Factor affecting the amount of specular light emitted by the material.
 */
@property (nonatomic) float shininess;

/**
 Transparency of the material. 1.0 for fully opaque objects. 0.0 for fully transparent objects.
 
 Default is 1.0.
 */
@property (nonatomic) float alpha;

/**
 The blend parameter. Mixes blendTexture with colour.texture based on value. Range 0..1.
 
 Default is 0.0.
 */
@property (nonatomic) float blendParameter;

/**
 Ratio between the refractive indices of the mediums the light enters and exits during refraction. 
 
 Default is 1.0.
 
 For example:   Air has a refractive index of 1.0003
                Glass has a refractive index of 1.517
 
                The correct ratio of light that is entering a glass material from air is:
 
                    refractivityRatio = r(Air) / r(Glass) = 1.0003 / 1.517 = 0.66
 */
@property (nonatomic) float refractivityRatio;

/**
 Maximum number of dynamic lights the material can be lit by in the scene. More lights will cause more intensive calculations and produce lower framerates.
 
 Default is 1.
 */
@property (nonatomic) int maxLights;

/**
 Whether the lighting calculations should occure on a per-vertex or a per-pixel basis. Per-pixel lighting calculations produce better visual results at the expense of performance. Some lighting functions, such as normal maps and accurate dynamic lighting, are unavailable in the per-vertex case.
 */
@property (nonatomic) BOOL perPixelShader;

@end
