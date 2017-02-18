#import <Foundation/Foundation.h>
#import <KudanAR/ARRenderer.h>

@class ARNode;

/**
 A material represents how an object is shaded. This serves as a base class and shouldn't be created directly.
 */
@interface ARMaterial : NSObject

/**
 Called after this material has been used to render an object. This is useful for playable textures if you wish to check their updated state.
 */
- (void)postRender;

@property (nonatomic) NSString *name;

/**
 Whether this material involves transparency. Defaults to NO.
 */
@property (nonatomic) BOOL isTranslucent;

/**
 If this material has transparency, the blending mode to use.
 */
@property (nonatomic) ARBlendMode blendMode;

/**
 Whether pixels rendered with this material should be depth tested against existing pixels in the framebuffer. Default: YES
 */
@property (nonatomic) BOOL depthTest;

/**
 Whether pixels rendered with this material should generate depth information in the framebuffer. Default: YES
 */
@property (nonatomic) BOOL depthWrite;

/**
 Whether to write to the colour buffer. If set to NO then only depth information will be written. Default: YES
 */
@property (nonatomic) BOOL colourWrite;

/**
 The face culling mode. Default is no culling.
 */
@property (nonatomic) ARFaceCullMode cullMode;


@end
