
#import <UIKit/UIKit.h>
#import "Renderer.h"

//#import <simd/simd.h>



//typedef float4 customFloat;

typedef struct {
    float x, y, z, w;
} customFloat4;

typedef struct {
    customFloat4 position;
    customFloat4 normal;
    customFloat4 customColor;
} customVertex;

/*typedef struct {
    customFloat p;
    float pos;
} tVertex;*/

@interface ViewController : UIViewController

@property (nonatomic, strong) Renderer *renderer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) CAMetalLayer *metal;

- (void)testBridge:(customVertex)v;

- (void)customMetalLayer:(CALayer *)layer bounds:(CGRect)bounds;
- (void)appendAction:(float)x y:(float)y z:(float)z;
- (void)removeAction:(int)type;
- (void)takeScreenshot;
- (void)completeSavedImage:(UIImage *)_image didFinishSavingWithError:(NSError *)_error contextInfo:(void *)_contextInfo;

- (int)appendCube:(float)x y:(float)y z:(float)z
             width:(float)width height:(float)height depth:(float)depth
               red:(int)red green:(int)green blue:(int)blue;

- (void)appendStairs:(float)x y:(float)y z:(float)z
               width:(float)width stepWidth:(float)stepWidth stepHeight:(float)stepHeight depth:(float)depth
                 red:(int)red green:(int)green blue:(int)blue;

- (void)appendPyramid;

- (void)appendCone:(float)x y:(float)y z:(float)z
            radius:(float)radius height:(float)height
               red:(int)red green:(int)green blue:(int)blue;

- (void)appendCylinder:(float)x y:(float)y z:(float)z
                radius:(float)radius height:(float)height
                   red:(int)red green:(int)green blue:(int)blue;

- (void)appendSphere:(float)x y:(float)y z:(float)z
              radius:(float)radius
                 red:(int)red green:(int)green blue:(int)blue;

- (void)appendTorus;

- (void)appendRoof:(float)x y:(float)y z:(float)z
             width:(float)width height:(float)height depth:(float)depth
               red:(int)red green:(int)green blue:(int)blue;

- (void)appendGear:(float)x y:(float)y z:(float)z radius:(float)radius height:(float)height red:(int)red green:(int)green blue:(int)blue;

- (void)appendChessboard:(float)x y:(float)y z:(float)z
                   width:(float)width height:(float)height depth:(float)depth
                     red:(int)red green:(int)green blue:(int)blue
               topBorder:(float)topBorder;

- (void)appendLadder:(float)x y:(float)y z:(float)z
             width:(float)width height:(float)height depth:(float)depth
               red:(int)red green:(int)green blue:(int)blue;

- (void)importOBJ:(int)red green:(int)green blue:(int)blue;

- (void)setView:(UIViewController *)view;

@end

