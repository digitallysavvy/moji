#import <KudanAR/ARMeshNode.h>

@class ARTexture;

@interface ARPointNode : ARMeshNode

- (instancetype)initWithTexture:(ARTexture *)texture;
- (void)setPoints:(NSData *)points;

@property (nonatomic) NSUInteger pointSize;
@property (nonatomic, readonly) NSUInteger numberOfPoints;

@end
