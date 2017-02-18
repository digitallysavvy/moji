#import <Foundation/Foundation.h>
#import <KudanAR/ARMeshNode.h>

@class ARVideoTexture;

/**
 A node containing an alpha video.
 */
@interface ARAlphaVideoNode : ARMeshNode

/**
 The video texture associated with this alpha video.
 */
@property (nonatomic) ARVideoTexture *videoTexture;

/**
 Initialise with a video texture.
 @param videoTexture the video texture to use.
 */
- (instancetype)initWithVideoTexture:(ARVideoTexture *)videoTexture NS_DESIGNATED_INITIALIZER;

/**
 Initialise with a video file in the app bundle.
 @param file the video file relative to the app bundle.
 */
- (instancetype)initWithBundledFile:(NSString *)file;

@end
