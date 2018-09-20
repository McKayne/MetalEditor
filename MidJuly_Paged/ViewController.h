
#import <UIKit/UIKit.h>
#import "Renderer.h"

//#import <simd/simd.h>
//#import "MidJuly_Paged-Swift.h"


//typedef float4 customFloat;

typedef struct {
    float x, y, z, w;
} customFloat4;

/*typedef struct {
    customFloat4 position;
    customFloat4 normal;
    customFloat4 customColor;
} customVertex;*/

typedef struct {
    customFloat4 position;
    customFloat4 normal;
    customFloat4 customColor;
    customFloat4 texCoord;
} Vertex;

/*typedef struct {
    customFloat p;
    float pos;
} tVertex;*/

@class Export;

@interface ViewController : UIViewController

@property (nonatomic, strong) Renderer *renderer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) CAMetalLayer *metal;

- (void)setVertexArrays:(Vertex *)bigVertices bigLineVertices:(Vertex *)bigLineVertices bigIndices:(uint16_t *)bigIndices bigLineIndices:(uint16_t *)bigLineIndices;

- (void)customMetalLayer:(CALayer *)layer bounds:(CGRect)bounds indicesCount:(int)indicesCount;
- (void)appendAction:(float)x y:(float)y z:(float)z;
- (void)removeAction:(int)type;
- (void)takeScreenshot;
- (void)completeSavedImage:(UIImage *)_image didFinishSavingWithError:(NSError *)_error contextInfo:(void *)_contextInfo;

- (NSString *)exportOBJ:(NSString *)filename;
- (NSString *)exportMTL:(NSString *)filename;
- (NSString *)exportZIP:(NSString *)filename items:(NSArray *)items;

- (void)showExportDialog;

- (void)appendStairs:(float)x y:(float)y z:(float)z
               width:(float)width stepWidth:(float)stepWidth stepHeight:(float)stepHeight depth:(float)depth
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

- (int)appendPolygon:(float)x y:(float)y z:(float)z
             width:(float)width height:(float)height
               red:(int)red green:(int)green blue:(int)blue alpha:(float)alpha;

- (void)importOBJ:(int)red green:(int)green blue:(int)blue;

- (void)setView:(UIViewController *)view;

- (void)rotateObjectX:(int)offset length:(int)length xAngle:(float)xAngle;
- (void)rotateObjectZ:(int)offset length:(int)length zAngle:(float)zAngle;

- (void)removeFace:(int)offset nth:(int)nth;
- (void)cloneObject:(int)offset length:(int)length xTranslate:(float)xTranslate yTranslate:(float)yTranslate zTranslate:(float)zTranslate;
- (void)translateObject:(int)offset length:(int)length xTranslate:(float)xTranslate yTranslate:(float)yTranslate zTranslate:(float)zTranslate;

- (void)translateVertex:(int)offset length:(int)length x:(float)x y:(float)y z:(float)z xTranslate:(float)xTranslate yTranslate:(float)yTranslate zTranslate:(float)zTranslate debug:(BOOL)debug;

- (void)setFaceTexture:(int)offset nth:(int)nth texNth:(int)texNth;

- (int)getTotalIndices;

- (void)redraw;
- (void)loadModel:(int)indicesCount;

@end

