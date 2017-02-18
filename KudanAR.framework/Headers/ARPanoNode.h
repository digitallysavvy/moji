#import <Foundation/Foundation.h>
#import <KudanAR/ARNode.h>

/**
 This node represents cube panorama that can be added to the gyro controller.
 */
@interface ARPanoNode : ARNode

- (instancetype)initWithImages:(NSArray *)images;

@end
