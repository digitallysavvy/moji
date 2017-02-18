#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ARViewPort;
@class UIImage;

/**
 Render target events.
 */
@protocol ARRenderTargetDelegate <NSObject>

/**
 Called prior to rendering this render target.
 */
- (void)preRender;

/**
 Called after rendering this render target.
 */
- (void)postRender;

@end

/**
 A render target represents a target buffer for rendering.
 */
@interface ARRenderTarget : NSObject

/**
 The list of ARViewPort objects that this render target contains. These are rendered based on viewport z-order.
 */
@property (nonatomic) NSArray *viewPorts;

/**
 The number of viewports contained by this render target.
 */
@property (nonatomic, readonly) NSUInteger numberOfViewPorts;

/**
 Add a viewport to this render target.
 @param viewPort The viewport to add.
 */
- (void)addViewPort:(ARViewPort *)viewPort;

/**
 Add a viewport to this render target and set its z-order.
 @param viewPort The viewport to add.
 @param zOrder The render priority of this viewport. Any value is fine, lower values are rendered first.
 */
- (void)addViewPort:(ARViewPort *)viewPort zOrder:(NSInteger)zOrder;

/**
 Remove a viewport from this render target.
 @param viewPort The viewport to remove.
 */
- (void)removeViewPort:(ARViewPort *)viewPort;

/**
 Remove all viewports from this render target.
 */
- (void)clearViewPorts;

/**
 The width of this render target.
 */
@property (nonatomic) float width;

/**
 The height of this render target.
 */
@property (nonatomic) float height;

/**
 Initialise with width and height.
 @param width The width of the render target.
 @param height The height of the render target.
 */
- (instancetype)initWithWidth:(float)width height:(float)height;

/**
 Creates a default viewport with dimensions matching the resolution of this render target and no offset.
 @return The new viewport.
 */
- (ARViewPort *)createDefaultViewPort;

/**
 Add a delegate to receive rendering events for this render target.
 */
- (void)addDelegate:(id <ARRenderTargetDelegate>)delegate;

/**
 The list of delegates.
 */
@property (nonatomic, readonly) NSArray *delegates;

/**
 The priority of this render target relative to other render targets. Any value is fine. Lower is rendered first.
 */
@property (nonatomic) NSInteger priority;

/**
 Take a screenshot of this render target. Resolution of the image is the same as the resolution of the render target.
 @return The screenshot.
 */
- (UIImage *)screenshot;

/**
 Whether this render target has a depth buffer.
 */
@property (nonatomic) BOOL hasDepth;

/**
 Whether this render target has a stencil buffer.
 */
@property (nonatomic) BOOL hasStencil;

/**
 Whether this render target is drawn automatically each frame, or whether it has to be drawn explicitly. Default NO - drawn automatically.
 */
@property (nonatomic) BOOL manualDraw;

// Internal
- (BOOL)checkFBO;
- (void)bindBuffer;;
- (void)bindCaptureBuffer;
- (void)draw;
- (void)drawForCapture;

@property (nonatomic) NSDictionary *captureColourToNode;
@property (nonatomic) BOOL touchEventReceived;
@property (nonatomic) CGPoint touchPoint;



@end
