
#import <UIKit/UIKit.h>
#import <QuartzCore/CAMetalLayer.h>
#import <Metal/Metal.h>

@interface MetalView : UIView

@property(nonatomic, strong) CAMetalLayer *metalLayer;

@end
