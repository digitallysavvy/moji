#import <Foundation/Foundation.h>
#import <KudanAR/ARPlayableTexture.h>
#import <KudanAR/ARRenderer.h>

/**
 An animated texture consisting of a series of frames. Useful for simple 2D animations.
 */
@interface ARAnimatedTexture : ARPlayableTexture <ARRendererDelegate>

/**
 The number of frames in this animation.
 */
@property (nonatomic, readonly) NSUInteger numberOfFrames;

/**
 Add a new frame to the end of this animation.
 @param image The UIImage containing the texture. It should have the same resolution as any previously added images.
 */
- (void)addFrameFromImage:(UIImage *)image;

@end
