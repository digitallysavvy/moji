#import <Foundation/Foundation.h>
#import <KudanAR/ARPlayableTexture.h>
#import <KudanAR/ARRenderer.h>
#import <AVFoundation/AVFoundation.h>


@interface ARVideoTexture : ARPlayableTexture <ARRendererDelegate, AVAudioPlayerDelegate, NSCopying>

- (instancetype)initWithVideoFile:(NSString *)videoFile audioFile:(NSString *)audioFile;

@property (nonatomic) BOOL isActive;
@property (nonatomic) double currentVideoTime;
@property (nonatomic) double lastRenderTime;

- (void)spill;
- (void)activate;

@end
