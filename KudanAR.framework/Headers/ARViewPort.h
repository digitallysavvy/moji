#import <Foundation/Foundation.h>

@class ARCamera;
@class ARRenderTarget;

/**
 ARViewPort represents a viewport into the scene. It can be used for cropping the rendered image or for zoom.
 */
@interface ARViewPort : NSObject

/**
 The offset of the viewport in the X direction. This can be negative to crop horizontally.
 */
@property (nonatomic) float offsetX;

/**
 The offset of the viewport in the Y direction. This can be negative to crop vertically.
 */
@property (nonatomic) float offsetY;

/**
 The width of the viewport in pixels, including any that extend beyond edge of the screen.
 */
@property (nonatomic) float width;

/**
 The width of the viewport in pixels, including any that extend beyond edge of the screen.
 */
@property (nonatomic) float height;

- (instancetype)initWithOffsetX:(float)x y:(float)y height:(float)height width:(float)width;

@property (nonatomic) ARCamera *camera;

/**
 The ARRenderTarget that this viewport belongs to.
 */
@property (nonatomic, weak) ARRenderTarget *renderTarget;

/**
 When there are multiple viewports added to a render target, this value determines the order. Lower values get rendered first. Negative integers are OK.
 */
@property (nonatomic) int zOrder;

@end
