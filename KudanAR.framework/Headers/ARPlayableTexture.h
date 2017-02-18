#import <Foundation/Foundation.h>
#import <KudanAR/ARTexture.h>

@class ARPlayableTexture;


/**
 A protocol for playable texture events.
 */
@protocol ARPlayableTextureDelegate <NSObject>

@required
@optional
/**
 The playable texture finished playing.
 @param texture The playable texture that finished.
 */
- (void)playableTextureDidFinish:(ARPlayableTexture *)texture;

@end

/**
 This class represents textures that are capable of changing, such as videos or 2D animations.
 */
@interface ARPlayableTexture : ARTexture

/**
 The framerate of the playable texture. This is set automatically but can be set to change playback speed.
 */
@property (nonatomic) float frameRate;

/**
 Reset the playable texture back to its initial state.
 */
- (void)reset;

/**
 Start playing of the playable texture. 
 */
- (void)play;

/**
 Pause playing of the playable texture. The current time will remain the same when play is called.
 */
- (void)pause;

typedef NS_ENUM(NSInteger, ARPlayableTextureState) {
    ARPlayableTextureStateUninitialised,
    ARPlayableTextureStatePaused,
    ARPlayableTextureStatePlaying,
    ARPlayableTextureStateFinished,
};

@property (nonatomic) ARPlayableTextureState playState;

/**
 The time in seconds where audio will continue to play even if no frames are being rendered. This is useful if there is momentary loss of tracking. Recommended value is around 0.5 seconds.
 */
@property (nonatomic) NSTimeInterval pauseTolerance;

/**
 The time in seconds where if this texture hasn't been rendered, it will reset to its initial state.
 */
@property (nonatomic) NSTimeInterval resetThreshold;

/**
 Whether to continually render the last frame after the playable texture has finished playing. Defaults to NO.
 */
@property (nonatomic) BOOL lastFramePersist;

/**
 Delegate to receive playable texture events.
 */
@property (nonatomic, weak) id<ARPlayableTextureDelegate> delegate;

@end
