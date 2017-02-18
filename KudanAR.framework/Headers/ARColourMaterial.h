#import <Foundation/Foundation.h>
#import <KudanAR/ARMaterial.h>

/**
 Material for rendering a solid colour.
 */
@interface ARColourMaterial : ARMaterial

/**
 The red component. 0..1.
 */
@property float red;

/**
 The green component. 0..1.
 */
@property float green;

/**
 The blue component. 0..1.
 */
@property float blue;

/**
 The alpha component. 0..1.
 */
@property float alpha;

/**
 Initialise with red, green and blue components. Range 0..1.
 */
- (instancetype)initWithRed:(float)red green:(float)green blue:(float)blue;
- (instancetype)initWithRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
+ (instancetype)colourMaterialWithRed:(float)red green:(float)green blue:(float)blue;

@property (nonatomic) BOOL depthOnly;

@end
