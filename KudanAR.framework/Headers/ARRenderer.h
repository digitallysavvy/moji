#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreVideo/CoreVideo.h>

@class ARMatrix4;
@class ARTexture;
@class ARVector3;
@class ARRenderTarget;
@class ARRenderer;

/**
 Rendering related events.
 */
@protocol ARRendererDelegate <NSObject>

@required
@optional
/**
 Called prior to rendering each frame.
 */
- (void)rendererPreRender;

/**
 Called after rendering each frame.
 */
- (void)rendererPostRender;

/**
 Called when the renderer has been paused. This can be used to shut down other subsystems.
 */
- (void)rendererDidPause;

/**
 Called when the renderer resumes after being paused.
 */
- (void)rendererDidResume;

@end

/**
 Face culling modes.
 */
typedef enum {
    /**
     Don't cull faces.
     */
    ARFaceCullModeDisabled,
    
    /**
     Cull backfacing polygons.
     */
    ARFaceCullModeBack,
    
    /**
     Cull frontfacing polygons.
     */
    ARFaceCullModeFront,
    
    /**
     Cull all polygons.
     */
    ARFaceCullModeFrontAndBack,
} ARFaceCullMode;

/**
 Blending modes for transparency.
 */
typedef NS_ENUM(NSInteger, ARBlendMode) {
    /**
     Disable blending, no transparency.
     */
    ARBlendModeDisabled,
    
    /**
     Additive blending.
     */
    ARBlendModeAdditive,
    
    /**
     Alpha additive blending.
     */
    ARBlendModeAlphaAdditive,
    
    /**
     Premultiplied alpha blending.
     */
    ARBlendModePreMultiplyAlpha,
};

/**
 Renderer state.
 */
typedef NS_ENUM(NSInteger, ARRendererState) {
    /**
     Renderer is uninitialised.
     */
    ARRendererStateUninitialised,
    
    /**
     Renderer is paused.
     */
    ARRendererStatePaused,
    
    /**
     Renderer is active.
     */
    ARRendererStateRunning,
};

@interface ARRenderer : NSObject

/**
 Get the renderer singleton.
 @return The singleton instance.
 */
+ (ARRenderer *)getInstance;

/**
 The current renderer state.
 */
@property (nonatomic) ARRendererState rendererState;

/**
 The time in seconds of the current frame.
 */
@property (nonatomic, readonly) NSTimeInterval currentFrameTime;

/**
 Use this renderer's OpenGL context. This should be called if you intend to modify content (textures, meshes, materials) from a new thread.
 */
- (void)useContext;

/**
 Add a delegate for rendering event notifications.
 @param delegate The delegate to add.
 */
- (void)addDelegate:(id <ARRendererDelegate>)delegate;

/**
 Remove a delegate for rendering event notifications.
 @param delegate The delegate to remove.
 */
- (void)removeDelegate:(id <ARRendererDelegate>)delegate;

/**
 Add a render target to the renderer. This is required if render targets are to be automatically drawn each frame.
 @param renderTarget The render target to add.
 */
- (void)addRenderTarget:(ARRenderTarget *)renderTarget;

/**
 Remove a render target from the renderer.
 @param renderTarget The render target to remove.
 */
- (void)removeRenderTarget:(ARRenderTarget *)renderTarget;

/**
 The list of ARRenderTarget objects registered with the renderer.
 */
@property (nonatomic, readonly) NSArray *renderTargets;

/**
 Initialise the renderer. This is usually called automatically.
 */
- (void)initialise;

/**
 Deinitialise the renderer. This is usually called automatically.
 */
- (void)deinitialise;

/**
 Pause all renderering operations.
 */
- (void)pause;

/**
 Resume rendering operations.
 */
- (void)resume;

@end
