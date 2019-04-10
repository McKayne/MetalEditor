
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

@property (nonatomic, strong) Renderer *renderer, *axisRenderer;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) CAMetalLayer *metal, *axisMetal;

@property (assign) int tapX, tapY;
@property (assign) int currentScene;

- (void)translateCamera:(float)x y:(float)y z:(float)z;

- (void)toggleSelectionMode;
- (void)setTapPoint:(int)x y:(int)y;
- (void)setAngle:(float)x y:(float)y;

- (void)setVertexArrays:(Vertex *)bigVertices bigLineVertices:(Vertex *)bigLineVertices selectedVertices:(Vertex *)selectedVertices gridLineVertices:(Vertex *)gridLineVertices axisLineVertices:(Vertex *)axisLineVertices bigIndices:(uint16_t *)bigIndices bigLineIndices:(uint16_t *)bigLineIndices gridLineIndices:(uint16_t *)gridLineIndices;

- (void)customMetalLayer:(CALayer *)layer bounds:(CGRect)bounds indicesCount:(int)indicesCount x:(float)x y:(float)y z:(float)z xAngle:(float)xAngle yAngle:(float)yAngle;
- (void)appendAction:(float)x y:(float)y z:(float)z;
- (void)removeAction:(int)type;
- (void)takeScreenshot;
- (void)completeSavedImage:(UIImage *)_image didFinishSavingWithError:(NSError *)_error contextInfo:(void *)_contextInfo;

- (int)appendPolygon:(float)x y:(float)y z:(float)z
             width:(float)width height:(float)height
               red:(int)red green:(int)green blue:(int)blue alpha:(float)alpha;

- (void)importOBJ:(int)red green:(int)green blue:(int)blue;

- (void)setView:(UIViewController *)view;

- (void)removeFace:(int)offset nth:(int)nth;

- (void)translateVertex:(int)offset length:(int)length x:(float)x y:(float)y z:(float)z xTranslate:(float)xTranslate yTranslate:(float)yTranslate zTranslate:(float)zTranslate debug:(BOOL)debug;

- (void)setFaceTexture:(int)offset nth:(int)nth texNth:(int)texNth;

- (int)getTotalIndices;

- (void)redraw;
- (void)loadModel:(int)indicesCount;

@end

