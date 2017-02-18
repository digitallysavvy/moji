#import <Foundation/Foundation.h>
#import <KudanAR/ARNode.h>

@class ARMatrix4;

/**
 A node representing a bone.
 */
@interface ARBoneNode : ARNode

/**
 The offset matrix of this bone.
 */
@property (nonatomic) ARMatrix4 *offsetMatrix;

@end
