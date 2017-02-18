#import <Foundation/Foundation.h>
#import <KudanAR/ARMaterial.h>

@class ARVideoTexture;

/**
 A material for working with alpha videos.
 */
@interface ARAlphaVideoMaterial : ARMaterial

/**
 The video texture used by this material.
 */
@property (nonatomic) ARVideoTexture *texture;

/**
 Initialise with a video texture.
 @param texture The texture to use.
 */
- (instancetype)initWithTexture:(ARVideoTexture *)texture;
+ (instancetype)materialwithTexture:(ARVideoTexture *)texture;
@end
