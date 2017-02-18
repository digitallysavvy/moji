
#import <Foundation/Foundation.h>
#import <KudanAR/ARRenderTargetTexture.h>
#import <KudanAR/ARRenderer.h>

@class ARNode;

/**
 A class for handling textures extracted from the camera stream. This can be used during rendering to deform the camera texture.
 */
@interface ARExtractedCameraTexture : ARRenderTargetTexture <ARRendererDelegate>

/**
 The node which defines the region of the camera image the texture should be extracted from. Move this node around (eg. adding it to a trackable) to the area of interest. Can be reparented to your own nodes.
 */
@property (nonatomic) ARNode *srcNode;

/**
 The width in the coordinate space of srcNode that determines the horizontal boundaries of the texture.
 */
@property (nonatomic) float srcWidth;;

/**
 The height in the coordinate space of srcNode that determines the vertical boundaries of the texture.
 */
@property (nonatomic) float srcHeight;

/**
 Initialises the texture with the texture's dimensions. Overall resolution doesn't have to match the aspect ratio of srcWidth:srcHeight.
 @param width The width of the extracted texture. Maximum width 2048. Recommended width 512 for balance between performance and quality.
 @param height The height of the extracted texture. Maximum width 2048. Recommended height 512 for balance between performance and quality.
 */
- (instancetype)initWithWidth:(float)width height:(float)height;

@end
