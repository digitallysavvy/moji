#import <Foundation/Foundation.h>

@class ARMaterialProperty;
@class ARTextureCube;

@interface ARMaterialPropertyReflection : NSObject

//@property (nonatomic) ARMaterialProperty *reflectivity;


@property (nonatomic) float reflectivity;

@property (nonatomic) ARTextureCube *environment;

@end
