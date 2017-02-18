#import <Foundation/Foundation.h>
#import <KudanAR/ARMeshNode.h>

@class ARVideoTexture;
@class VuforiaTrackableImage;
@class ARVideoTextureMaterial;

/**
 A node for video content.
 */
@interface ARVideoNode : ARMeshNode

/**
 The video texture associated with the node.
 */
@property (nonatomic) ARVideoTexture *videoTexture;

/**
 Convenient access to this node's material without need for a cast.
 */
@property (nonatomic) ARVideoTextureMaterial *videoTextureMaterial;

/**
 Initialise with a video texture.
 @param videoTexture The video texture to initialise with.
 */
- (instancetype)initWithVideoTexture:(ARVideoTexture *)videoTexture;

/**
 Initialise with a file in the app bundle.
 @param file The file in the app bundle to initialise with.
 */
- (instancetype)initWithBundledFile:(NSString *)file;

/**
 Start/resume playback. Default playback state is paused.
 */
- (void)play;

/**
 Pause playback.
 */
- (void)pause;

/**
 Reset the video's position to 0 and its state to paused.
 */
- (void)reset;

@end
