#import <Foundation/Foundation.h>

@class UIImage;

/**
 Texture filtering modes.
 */
typedef enum {
    /**
     No filtering, nearest neighbour.
     */
    ARTextureFilterNearest,
    /**
     Linear interpolation.
     */
    ARTextureFilterLinear,
} ARTextureFilter;

/**
 Class representing a texture. Textures cannot exceed 2048x2048.
 */
@interface ARTexture : NSObject
{
    NSData *_rawImage;
}

@property (nonatomic) unsigned textureID;

/**
 The width of the texture.
 */
@property (nonatomic) unsigned long width;

/**
 The height of the texture.
 */
@property (nonatomic) unsigned long height;

/**
 Create a texture from a UIImage.
 @param image The UIImage to create the texture from.
 */
- (instancetype)initWithUIImage:(UIImage *)image;

/**
 Create an empty texture that can be loaded with an image later.
 */
- (instancetype)initWithEmpty;


//+ (id)textureWithUIImage:(UIImage *)image;
//+ (id)textureWithUIImage:(UIImage *)image normalMap:(BOOL)normalMap;

- (instancetype)initWithExistingTextureID:(unsigned)textureID;

- (void)generateTexture;
- (void)uploadTexture;
- (void)loadTextureFromUIImage:(UIImage *)image reverseLines:(BOOL)reverseLines;

- (void)uploadBGRATexture:(unsigned char *)data width:(float)width height:(float)height;
- (void)uploadBGRATextureSub:(unsigned char *)data width:(float)width height:(float)height;


/**
 Called prior to this texture being used in rendering.
 @return whether to proceed with rendering.
 */
- (BOOL)preRender;

/**
 Called after this texture has been used in rendering.
 */
- (void)postRender;

@property (nonatomic) BOOL isPowerOfTwo;

/**
 The filtering type used for minification. ARTextureFilterLinear is recommended for less aliasing.
 */
@property (nonatomic) ARTextureFilter minificationFilter;

/**
 The filtering type used for magnification. ARTextureFilterLinear is recommended for less aliasing.
 */
@property (nonatomic) ARTextureFilter magnificationFilter;

@end
