#import <Foundation/Foundation.h>
#import <KudanAR/ARNode.h>

@class ARVector3;

/**
 An ARNode that maintains a certain direction relative to the camera. This billboarding can be used to ensure 2D objects always face the camera.
 */
@interface ARBillboardNode : ARNode

/**
 The vector which should be aimed at the camera. (0, -1, 0) would caused the negative y-axis to point towards the camera.
 */
@property (nonatomic) ARVector3 *forward;

@property (nonatomic) BOOL lockX;
@property (nonatomic) BOOL lockY;
@property (nonatomic) BOOL lockZ;

@end
