#import <Foundation/Foundation.h>
#import <KudanAR/ARMeshNode.h>

@class ARTexture;
@class UIImage;

@interface ARImageNode : ARMeshNode

@property (nonatomic) ARTexture *texture;

- (instancetype)initWithImage:(UIImage *)image NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithImagePath:(NSString *)path;
- (instancetype)initWithBundledFile:(NSString *)file;

@end
