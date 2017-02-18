#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class ARRenderTargetMain;

/**
 An ARView encapsulates AR activities.
 */
@interface ARView : UIView

/**
 Take a screenshot of the current render target.
 @return A UIImage containing the current framebuffer of the main render target. Resolution will match that of the renderTarget.
 */
- (UIImage *)screenshot;

// The ARRenderTarget associated with this view.
@property (nonatomic) ARRenderTargetMain *renderTarget;

- (void)didRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;

/**
 Initialise a view.
 @param frame The frame for the view.
 @param interfaceOrientation The orientation at the time of creation. ARView needs to keep track of this to function properly.
 */
- (instancetype)initWithFrame:(CGRect)frame interfaceOrientation:(UIInterfaceOrientation)orientation;

@end
