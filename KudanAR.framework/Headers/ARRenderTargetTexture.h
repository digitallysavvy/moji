#import <Foundation/Foundation.h>
#import <KudanAR/ARRenderTarget.h>

@class ARTexture;

/**
 A render target backed by a texture that can be used in further rendering.
 */
@interface ARRenderTargetTexture : ARRenderTarget

/**
 The texture this render target renders to.
 */
@property (nonatomic) ARTexture *texture;

/**
 Initialise this render target with texture dimensions.
 @param width The width of the texture.
 @param height The height of the texture.
 @return The initialised render target.
 */
- (instancetype)initWithWidth:(float)width height:(float)height;

@end
