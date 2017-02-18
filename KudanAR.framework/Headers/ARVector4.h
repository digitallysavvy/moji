#import <Foundation/Foundation.h>

/**
 A 4D vector.
 */
@interface ARVector4 : NSObject

/**
 Create a vector with zero valued components.
 @return A vector with (0, 0, 0, 0)
 */
+ (ARVector4 *)vectorWithZero;

/**
 Create a vector with specified values.
 @param x The x component.
 @param y The y component.
 @param z The z component.
 @param w The w component.
 @return A vector with the specified components.
 */
+ (ARVector4 *)vectorWithValuesX:(float)x y:(float)y z:(float)z w:(float)w;

/**
 The x value of the vector.
 */
@property (nonatomic) float x;

/**
 The y value of the vector.
 */
@property (nonatomic) float y;

/**
 The z value of the vector.
 */
@property (nonatomic) float z;

/**
 The w value of the vector.
 */
@property (nonatomic) float w;

/**
 Add this vector to another vector and return the result.
 @param vector The vector to add to this vector.
 @return The sum of the vectors.
 */
- (ARVector4 *)addVector:(ARVector4 *)vector;

/**
 Add this vector to another vector and store the result in this vector.
 @param vector The vector to add to this vector.
 @return This vector, now the sum of the two vectors.
 */
- (ARVector4 *)localAddVector:(ARVector4 *)vector;
- (ARVector4 *)subtractVector:(ARVector4 *)vector;
- (ARVector4 *)localSubtractVector:(ARVector4 *)vector;
- (ARVector4 *)multiplyByVector:(ARVector4 *)vector;
- (ARVector4 *)localMultiplyByVector:(ARVector4 *)vector;
- (ARVector4 *)divideByVector:(ARVector4 *)vector;
- (ARVector4 *)localDivideByVector:(ARVector4 *)vector;
- (float)dotProductWithVector:(ARVector4 *)vector;

- (void)setX:(float)x y:(float)y z:(float)z w:(float)w;

- (void)setModifyObserverWithDelegate:(id)delegate selector:(SEL)selector;

@end
