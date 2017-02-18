#import <Foundation/Foundation.h>
#import <KudanAR/ARMaterial.h>

@class ARMatrix4;
@class ARTexture;

@interface ARCameraBackgroundMaterial : ARMaterial

@property (nonatomic) ARMatrix4 *markerModelViewProjection;
@property (nonatomic) ARTexture *cameraTexture;
@property (nonatomic) ARTexture *cameraTextureUV;

- (instancetype)initWithTexture:(ARTexture *)texture textureUV:(ARTexture *)textureUV;

@end
