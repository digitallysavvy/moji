#import <Foundation/Foundation.h>

@class ARTexture;
@class ARVector3;

@interface ARMaterialProperty : NSObject

@property (nonatomic) ARVector3 *value;
@property (nonatomic) ARTexture *texture;

@property (nonatomic) float factor;

@end
