#import "SSZipArchive/ZipArchive.h"
#import "ViewController.h"
#import "OBJModel.h"
#import "Shared.h"
#import "Transforms.h"

#import <QuartzCore/CAMetalLayer.h>
//#import <QuartzCore/CAMetalDrawable.h>
#import <Metal/Metal.h>

#import <time.h>

#import "MidJuly_Paged-Swift.h"

int lastObject;

static const float kVelocityScale = 0.01;
static const float kDamping = 0.05;

static float DegToRad(float deg)
{
    return deg * (M_PI / 180);
}

@interface ViewController ()

@property (nonatomic, strong) UIGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) NSTimeInterval lastFrameTime;
@property (nonatomic, assign) CGPoint angularVelocity;
@property (nonatomic, assign) CGPoint angle;

@property (nonatomic, strong) id<MTLBuffer> vertexBuffer, lineVertexBuffer;
@property (nonatomic, strong) id<MTLBuffer> indexBuffer, lineIndexBuffer;
@property (nonatomic, strong) id<MTLBuffer> uniformBuffer;

@property (nonatomic, assign) Vertex *bigVertices, *bigLineVertices;
@property (nonatomic, assign) uint16_t *bigIndices, *bigLineIndices;

@property (nonatomic, assign) simd::float4x4 projectionMatrix;

@property (nonatomic, assign) CGRect bounds;

@property (nonatomic, assign) int totalIndices;

@property (nonatomic, strong) UIViewController *mainView;

@end

@implementation ViewController

- (void)setVertexArrays:(Vertex *)bigVertices bigLineVertices:(Vertex *)bigLineVertices {
    self.bigVertices = bigVertices;
    self.bigLineVertices = bigLineVertices;
}

- (void)testBridge:(customVertex)v {
    NSLog(@"X = %f", v.position.x);
    NSLog(@"Y = %f", v.position.y);
    NSLog(@"Z = %f", v.position.z);
    NSLog(@"W = %f", v.position.w);
}

- (void)customMetalLayer:(CALayer *)layer bounds:(CGRect)bounds {
    NSLog(@"It works");
    
    self.bounds = bounds;
    
    self.metal = [CAMetalLayer new];
    self.metal.frame = bounds;// CGRectMake(10.0, 100.0, 300.0, 300.0);
    self.metal.framebufferOnly = false;
    
    self.metal.opaque = false;
    
    self.renderer = [[Renderer alloc] initWithLayer:self.metal];
    self.renderer.vertexFunctionName = @"vertex_main";
    self.renderer.fragmentFunctionName = @"fragment_main";
    
    self.lastFrameTime = CFAbsoluteTimeGetCurrent();
    
    [self loadModel];
    
    [layer addSublayer:self.metal];
    
    //self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
    //[self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self redraw];
    
    /*
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(gestureRecognizerDidRecognize:)];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    
    */
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.renderer = [[Renderer alloc] initWithLayer:(CAMetalLayer *)self.view.layer];
    self.renderer.vertexFunctionName = @"vertex_main";
    self.renderer.fragmentFunctionName = @"fragment_main";
    
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(gestureRecognizerDidRecognize:)];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    
    self.lastFrameTime = CFAbsoluteTimeGetCurrent();

    [self loadModel];
}

- (void)viewDidAppear:(BOOL)animated
{
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)displayLinkDidFire:(CADisplayLink *)displayLink
{
    [self redraw];
}

- (void)gestureRecognizerDidRecognize:(UIPanGestureRecognizer *)recognizer
{
    CGPoint velocity = [recognizer velocityInView:self.view];
    self.angularVelocity = CGPointMake(velocity.x * kVelocityScale, velocity.y * kVelocityScale);
}

- (void)appendPyramid {
    for (int i = 0; i < 36; i++) {
        self.bigIndices[i] = i;
    }
    
    customFloat4 position[36];
    
    // front
    
    position[0] = {-0.25, -0.25, 0.25, 1.0};
    position[1] = {0.25, -0.25, 0.25, 1.0};
    position[2] = {0.0, 0.25, 0.0, 1.0};
    
    // right
    
    position[3] = {0.25, -0.25, 0.25, 1.0};
    position[4] = {0.25, -0.25, -0.25, 1.0};
    position[5] = {0.0, 0.25, 0.0, 1.0};
    
    // back
    
    position[6] = {0.25, -0.25, -0.25, 1.0};
    position[7] = {-0.25, -0.25, -0.25, 1.0};
    position[8] = {0.0, 0.25, 0.0, 1.0};
    
    // left
    
    position[9] = {-0.25, -0.25, -0.25, 1.0};
    position[10] = {-0.25, -0.25, 0.25, 1.0};
    position[11] = {0.0, 0.25, 0.0, 1.0};
    
    // bottom
    
    position[12] = {0.25, -0.25, 0.25, 1.0};
    position[13] = {-0.25, -0.25, -0.25, 1.0};
    position[14] = {0.25, -0.25, -0.25, 1.0};
    
    position[15] = {-0.25, -0.25, -0.25, 1.0};
    position[16] = {0.25, -0.25, 0.25, 1.0};
    position[17] = {-0.25, -0.25, 0.25, 1.0};
    
    for (int i = 0; i < 36; i++) {
        self.bigVertices[i].normal = {1, 0, 1};
        self.bigVertices[i].position = position[i];
        
        self.bigLineVertices[i].normal = {0, 0, 0};
        self.bigLineVertices[i].position = position[i];
    }
    
    for (int i = 0; i < 12; i++) {
        self.bigLineIndices[i * 6 + 0] = i * 3;
        self.bigLineIndices[i * 6 + 1] = i * 3 + 1;
        
        self.bigLineIndices[i * 6 + 2] = i * 3 + 1;
        self.bigLineIndices[i * 6 + 3] = i * 3 + 2;
        
        self.bigLineIndices[i * 6 + 4] = i * 3 + 2;
        self.bigLineIndices[i * 6 + 5] = i * 3;
    }
    
    self.totalIndices += 18;
}

- (void)appendCone:(float)x y:(float)y z:(float)z radius:(float)radius height:(float)height red:(int)red green:(int)green blue:(int)blue {
    
    
    int segments = 36;
    
    float segmentAngle = 360.0 / segments;
    
    customFloat4 position[segments * 3 * 2];
    
    int index = 0;
    for (float angle = 0.0; angle < segmentAngle * segments; angle += segmentAngle) {
        position[index++] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x, y + height, z, 1.0};
    
        // bottom
        
        position[index++] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x, y, z, 1.0};
    }
    
    for (int i = 0; i < segments * 3 * 2; i++) {
        self.bigIndices[i + self.totalIndices] = i + self.totalIndices;
        
        self.bigVertices[i + self.totalIndices].normal = {static_cast<float>((float) red / 255.0), static_cast<float>((float) green / 255.0), static_cast<float>((float) blue / 255.0)};
        self.bigVertices[i + self.totalIndices].position = position[i];
        
        self.bigLineVertices[i + self.totalIndices].normal = {0, 0, 0};
        self.bigLineVertices[i + self.totalIndices].position = position[i];
    }
    
    for (int i = 0; i < segments * 2; i++) {
        self.bigLineIndices[i * 6 + 0 + self.totalIndices * 2] = i * 3 + self.totalIndices;
        self.bigLineIndices[i * 6 + 1 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 2 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        self.bigLineIndices[i * 6 + 3 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 4 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        self.bigLineIndices[i * 6 + 5 + self.totalIndices * 2] = i * 3 + self.totalIndices;
    }
    
    self.totalIndices += segments * 3 * 2;
}

- (void)appendCylinder:(float)x y:(float)y z:(float)z radius:(float)radius height:(float)height red:(int)red green:(int)green blue:(int)blue {
    int segments = 36;
    
    float segmentAngle = 360.0 / segments;
    
    customFloat4 position[segments * 3 * 4];
    
    int index = 0;
    for (float angle = 0.0; angle < segmentAngle * segments; angle += segmentAngle) {
        position[index++] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        
        position[index++] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        
        // bottom
        
        position[index++] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x, y, z, 1.0};
        
        // top
        
        position[index++] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x, y + height, z, 1.0};
    }
    
    for (int i = 0; i < segments * 3 * 4; i++) {
        self.bigIndices[i + self.totalIndices] = i + self.totalIndices;
        
        self.bigVertices[i + self.totalIndices].normal = {static_cast<float>((float) red / 255.0), static_cast<float>((float) green / 255.0), static_cast<float>((float) blue / 255.0)};
        self.bigVertices[i + self.totalIndices].position = position[i];
        
        self.bigLineVertices[i + self.totalIndices].normal = {0, 0, 0};
        self.bigLineVertices[i + self.totalIndices].position = position[i];
    }
    
    for (int i = 0; i < segments * 4; i++) {
        self.bigLineIndices[i * 6 + 0 + self.totalIndices * 2] = i * 3 + self.totalIndices;
        self.bigLineIndices[i * 6 + 1 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 2 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        self.bigLineIndices[i * 6 + 3 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 4 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        self.bigLineIndices[i * 6 + 5 + self.totalIndices * 2] = i * 3 + self.totalIndices;
    }
    
    self.totalIndices += segments * 3 * 4;
}

- (void)appendTorus {
    float radius = 0.25;
    int segments = 36;
    
    float segmentAngle = 360.0 / segments;
    
    customFloat4 position[segments * 3 * 4];
    
    int index = 0;
    for (float angle = 0.0; angle < segmentAngle * segments; angle += segmentAngle) {
        position[index++] = {static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), -0.25, static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {static_cast<float>(cos(angle * 3.14 / 180.0) * radius), -0.25, static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {static_cast<float>(cos(angle * 3.14 / 180.0) * radius), 0.25, static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        
        position[index++] = {static_cast<float>(cos(angle * 3.14 / 180.0) * radius), 0.25, static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), 0.25, static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), -0.25, static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        
        // bottom
        
        /*position[index++] = {static_cast<float>(cos(angle * 3.14 / 180.0) * radius), -0.25, static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), -0.25, static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {0.0, -0.25, 0.0, 1.0};
        
        // top
        
        position[index++] = {static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), 0.25, static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {static_cast<float>(cos(angle * 3.14 / 180.0) * radius), 0.25, static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {0.0, 0.25, 0.0, 1.0};*/
    }
    
    for (int i = 0; i < segments * 3 * 4; i++) {
        self.bigIndices[i] = i;
        
        self.bigVertices[i].normal = {1, 0, 1};
        self.bigVertices[i].position = position[i];
        
        self.bigLineVertices[i].normal = {0, 0, 0};
        self.bigLineVertices[i].position = position[i];
    }
    
    for (int i = 0; i < segments * 4; i++) {
        self.bigLineIndices[i * 6 + 0] = i * 3;
        self.bigLineIndices[i * 6 + 1] = i * 3 + 1;
        
        self.bigLineIndices[i * 6 + 2] = i * 3 + 1;
        self.bigLineIndices[i * 6 + 3] = i * 3 + 2;
        
        self.bigLineIndices[i * 6 + 4] = i * 3 + 2;
        self.bigLineIndices[i * 6 + 5] = i * 3;
    }
    
    self.totalIndices += segments * 3 * 2;
}

float sphereX(float radius, float horizAbgle, float vertAngle) {
    float currentRadius = cos(vertAngle * 3.14 / 180.0) * radius;
    
    return cos(horizAbgle * 3.14 / 180.0) * currentRadius;
}

float sphereY(float radius, float horizAbgle, float vertAngle) {
    __unused float currentRadius = cos(vertAngle * 3.14 / 180.0) * radius;
    
    return sin(vertAngle * 3.14 / 180.0) * radius;
}

float sphereZ(float radius, float horizAbgle, float vertAngle) {
    float currentRadius = cos(vertAngle * 3.14 / 180.0) * radius;
    
    return sin(horizAbgle * 3.14 / 180.0) * currentRadius;
}

- (void)appendSphere:(float)x y:(float)y z:(float)z radius:(float)radius red:(int)red green:(int)green blue:(int)blue {
    int segments = 20;
    
    float segmentAngle = 360.0 / segments;
    
    customFloat4 position[segments * 3 * 2 * segments];
    
    int index = 0;
    for (float vertAngle = 0.0; vertAngle < segmentAngle * segments; vertAngle += segmentAngle) {
        for (float angle = 0.0; angle < segmentAngle * segments; angle += segmentAngle) {
            position[index++] = {x + sphereX(radius, angle + segmentAngle, vertAngle), y + sphereY(radius, angle + segmentAngle, vertAngle), z + sphereZ(radius, angle + segmentAngle, vertAngle), 1.0};
            position[index++] = {x + sphereX(radius, angle, vertAngle), y + sphereY(radius, angle, vertAngle), z + sphereZ(radius, angle, vertAngle), 1.0};
            position[index++] = {x + sphereX(radius, angle + segmentAngle, vertAngle + segmentAngle), y + sphereY(radius, angle + segmentAngle, vertAngle + segmentAngle), z + sphereZ(radius, angle + segmentAngle, vertAngle + segmentAngle), 1.0};
            
            position[index++] = {x + sphereX(radius, angle, vertAngle + segmentAngle), y + sphereY(radius, angle, vertAngle + segmentAngle), z + sphereZ(radius, angle, vertAngle + segmentAngle), 1.0};
            position[index++] = {x + sphereX(radius, angle + segmentAngle, vertAngle + segmentAngle), y + sphereY(radius, angle + segmentAngle, vertAngle + segmentAngle), z + sphereZ(radius, angle + segmentAngle, vertAngle + segmentAngle), 1.0};
            position[index++] = {x + sphereX(radius, angle, vertAngle), y + sphereY(radius, angle, vertAngle), z + sphereZ(radius, angle, vertAngle), 1.0};
        }
    }
    
    for (int i = 0; i < segments * 3 * 2 * segments; i++) {
        self.bigIndices[i + self.totalIndices] = i + self.totalIndices;
        
        self.bigVertices[i + self.totalIndices].normal = {static_cast<float>((float) red / 255.0), static_cast<float>((float) green / 255.0), static_cast<float>((float) blue / 255.0)};
        self.bigVertices[i + self.totalIndices].position = position[i];
        
        self.bigLineVertices[i + self.totalIndices].normal = {0, 0, 0};
        self.bigLineVertices[i + self.totalIndices].position = position[i];
    }
    
    for (int i = 0; i < segments * 2 * segments; i++) {
        self.bigLineIndices[i * 6 + 0 + self.totalIndices * 2] = i * 3 + self.totalIndices;
        self.bigLineIndices[i * 6 + 1 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 2 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        self.bigLineIndices[i * 6 + 3 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 4 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        self.bigLineIndices[i * 6 + 5 + self.totalIndices * 2] = i * 3 + self.totalIndices;
    }
    
    self.totalIndices += segments * 3 * 2 * segments;
}

float getLength(simd::float3 customVertexNormal) {
    return sqrt(customVertexNormal.x * customVertexNormal.x + customVertexNormal.y * customVertexNormal.y + customVertexNormal.z * customVertexNormal.z);
}

customFloat4 normalize(simd::float3 customVertexNormal) {
    return customFloat4{customVertexNormal.x / getLength(customVertexNormal), customVertexNormal.y / getLength(customVertexNormal), customVertexNormal.z / getLength(customVertexNormal), 0};
}

- (int)appendPolygon:(float)x y:(float)y z:(float)z width:(float)width height:(float)height red:(int)red green:(int)green blue:(int)blue alpha:(float)alpha {
    customFloat4 position[3];
    
    // front
    // 0
    
    position[0] = {x, y, z, 1.0};
    position[1] = {x + width, y, z, 1.0};
    position[2] = {x + width / 2, y + height, z, 1.0};
    
    simd::float3 customNormal[1];
    for (int i = 0, nth = 0; nth < 1; i += 3, nth++) {
        simd::float3 edge1 = {position[i + 1].x - position[i].x, position[i + 1].y - position[i].y, position[i + 1].z - position[i].z};
        simd::float3 edge2 = {position[i + 2].x - position[i].x, position[i + 2].y - position[i].y, position[i + 2].z - position[i].z};
        
        simd::float3 cross = {edge1.y * edge2.z - edge1.z * edge2.y, edge1.z * edge2.x - edge1.x * edge2.z, edge1.x * edge2.y - edge1.y * edge2.x};
        
        float len = sqrt(cross.x * cross.x + cross.y * cross.y + cross.z * cross.z);
        
        customNormal[nth] = {cross.x / len, cross.y / len, cross.z / len};
    }
    
    for (int i = 0; i < 3; i++) {
        self.bigIndices[i + self.totalIndices] = i + self.totalIndices;
        
        self.bigVertices[i + self.totalIndices].customColor = {static_cast<float>((float) red / 255.0), static_cast<float>((float) green / 255.0), static_cast<float>((float) blue / 255.0), alpha};
        self.bigVertices[i + self.totalIndices].position = position[i];
        
        self.bigLineVertices[i + self.totalIndices].normal = {0, 0, 0};
        self.bigLineVertices[i + self.totalIndices].position = position[i];
        self.bigLineVertices[i + self.totalIndices].customColor = {0, 0, 0, 1};
        self.bigLineVertices[i + self.totalIndices].texCoord = {0, 0, 0, 0};
    }
    // front
    
    simd::float3 customVertexNormal = {customNormal[0].x, customNormal[0].y, customNormal[0].z};
    self.bigVertices[0 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[1 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[2 + self.totalIndices].normal = normalize(customVertexNormal);
    
    self.bigVertices[self.totalIndices].texCoord = {1, 0.25, 0.5, 0};
    self.bigVertices[self.totalIndices + 1].texCoord = {1, 0.5, 0.5, 0};
    self.bigVertices[self.totalIndices + 2].texCoord = {1, 0.5, 0.25, 0};
    
    for (int i = 0; i < 1; i++) {
        self.bigLineIndices[i * 6 + 0 + self.totalIndices * 2] = i * 3 + self.totalIndices;
        self.bigLineIndices[i * 6 + 1 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 2 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        self.bigLineIndices[i * 6 + 3 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 4 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        self.bigLineIndices[i * 6 + 5 + self.totalIndices * 2] = i * 3 + self.totalIndices;
    }
    
    int lastIndices = self.totalIndices;
    self.totalIndices += 3;
    
    return lastIndices;
}

- (int)appendPlate:(float)x y:(float)y z:(float)z width:(float)width height:(float)height red:(int)red green:(int)green blue:(int)blue alpha:(float)alpha {
    customFloat4 position[6];
    
    // front
    // 0
    
    position[0] = {x, y, z, 1.0};
    position[1] = {x + width, y, z, 1.0};
    position[2] = {x + width, y + height, z, 1.0};
    
    // 1
    
    position[3] = {x + width, y + height, z, 1.0};
    position[4] = {x, y + height, z, 1.0};
    position[5] = {x, y, z, 1.0};
    
    simd::float3 customNormal[2];
    for (int i = 0, nth = 0; nth < 2; i += 3, nth++) {
        simd::float3 edge1 = {position[i + 1].x - position[i].x, position[i + 1].y - position[i].y, position[i + 1].z - position[i].z};
        simd::float3 edge2 = {position[i + 2].x - position[i].x, position[i + 2].y - position[i].y, position[i + 2].z - position[i].z};
        
        simd::float3 cross = {edge1.y * edge2.z - edge1.z * edge2.y, edge1.z * edge2.x - edge1.x * edge2.z, edge1.x * edge2.y - edge1.y * edge2.x};
        
        float len = sqrt(cross.x * cross.x + cross.y * cross.y + cross.z * cross.z);
        
        customNormal[nth] = {cross.x / len, cross.y / len, cross.z / len};
    }
    
    for (int i = 0; i < 6; i++) {
        self.bigIndices[i + self.totalIndices] = i + self.totalIndices;
        
        self.bigVertices[i + self.totalIndices].customColor = {static_cast<float>((float) red / 255.0), static_cast<float>((float) green / 255.0), static_cast<float>((float) blue / 255.0), alpha};
        self.bigVertices[i + self.totalIndices].position = position[i];
        
        self.bigLineVertices[i + self.totalIndices].normal = {0, 0, 0};
        self.bigLineVertices[i + self.totalIndices].position = position[i];
        self.bigLineVertices[i + self.totalIndices].customColor = {0, 0, 0, 1};
        self.bigLineVertices[i + self.totalIndices].texCoord = {0, 0, 0, 0};
    }
    // front
    
    simd::float3 customVertexNormal = {customNormal[0].x + customNormal[1].x,
        customNormal[0].y + customNormal[1].y,
        customNormal[0].z + customNormal[1].z};
    self.bigVertices[2 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[3 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[0].x + customNormal[1].x,
        customNormal[0].y + customNormal[1].y,
        customNormal[0].z + customNormal[1].z};
    self.bigVertices[0 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[5 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[0].x,
        customNormal[0].y,
        customNormal[0].z};
    self.bigVertices[1 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[1].x,
        customNormal[1].y,
        customNormal[1].z};
    self.bigVertices[4 + self.totalIndices].normal = normalize(customVertexNormal);
    
    self.bigVertices[self.totalIndices].texCoord = {1, 0.25, 0.5, 0};
    self.bigVertices[self.totalIndices + 1].texCoord = {1, 0.5, 0.5, 0};
    self.bigVertices[self.totalIndices + 2].texCoord = {1, 0.5, 0.25, 0};
    
    self.bigVertices[self.totalIndices + 3].texCoord = {1, 0.5, 0.25, 0};
    self.bigVertices[self.totalIndices + 4].texCoord = {1, 0.25, 0.25, 0};
    self.bigVertices[self.totalIndices + 5].texCoord = {1, 0.25, 0.5, 0};
    
    for (int i = 0; i < 2; i++) {
        self.bigLineIndices[i * 6 + 0 + self.totalIndices * 2] = i * 3 + self.totalIndices;
        self.bigLineIndices[i * 6 + 1 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 2 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        self.bigLineIndices[i * 6 + 3 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 4 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        self.bigLineIndices[i * 6 + 5 + self.totalIndices * 2] = i * 3 + self.totalIndices;
    }
    
    int lastIndices = self.totalIndices;
    self.totalIndices += 6;
    
    return lastIndices;
}

- (int)appendCube:(float)x y:(float)y z:(float)z
             width:(float)width height:(float)height depth:(float)depth
               red:(int)red green:(int)green blue:(int)blue {
    
    customFloat4 position[36];
    
    simd::float3 customNormal[12];
    
    simd::float3 edge1, edge2, cross;
    float len;
    
    // front
    // 0
    
    position[0] = {x, y, z, 1.0};
    position[1] = {x + width, y, z, 1.0};
    position[2] = {x + width, y + height, z, 1.0};
    
    // 1
    
    position[3] = {x + width, y + height, z, 1.0};
    position[4] = {x, y + height, z, 1.0};
    position[5] = {x, y, z, 1.0};
    
    //right
    
    position[6] = {x + width, y, z, 1.0};
    position[7] = {x + width, y, z - depth, 1.0};
    position[8] = {x + width, y + height, z, 1.0};
    
    position[9] = {x + width, y, z - depth, 1.0};
    position[10] = {x + width, y + height, z - depth, 1.0};
    position[11] = {x + width, y + height, z, 1.0};
    
    // back
    
    position[12] = {x + width, y, z - depth, 1.0};
    position[13] = {x, y, z - depth, 1.0};
    position[14] = {x + width, y + height, z - depth, 1.0};
    
    position[15] = {x, y + height, z - depth, 1.0};
    position[16] = {x + width, y + height, z - depth, 1.0};
    position[17] = {x, y, z - depth, 1.0};
    
    // left
    
    position[18] = {x, y, z - depth, 1.0};
    position[19] = {x, y, z, 1.0};
    position[20] = {x, y + height, z - depth, 1.0};
    
    position[21] = {x, y + height, z, 1.0};
    position[22] = {x, y + height, z - depth, 1.0};
    position[23] = {x, y, z, 1.0};
    
    // top
    // 8
    
    position[24] = {x + width, y + height, z, 1.0};
    position[26] = {x, y + height, z - depth, 1.0};
    position[25] = {x + width, y + height, z - depth, 1.0};
    
    // 9
    
    position[27] = {x, y + height, z, 1.0};
    position[28] = {x + width, y + height, z, 1.0};
    position[29] = {x, y + height, z - depth, 1.0};
    
    // bottom
    // 10
    
    position[30] = {x + width, y, z, 1.0};
    position[31] = {x, y, z - depth, 1.0};
    position[32] = {x + width, y, z - depth, 1.0};
    
    // 11
    
    position[33] = {x, y, z - depth, 1.0};
    position[34] = {x + width, y, z, 1.0};
    position[35] = {x, y, z, 1.0};
    
    for (int i = 0, nth = 0; nth < 12; i += 3, nth++) {
        edge1 = {position[i + 1].x - position[i].x, position[i + 1].y - position[i].y, position[i + 1].z - position[i].z};
        edge2 = {position[i + 2].x - position[i].x, position[i + 2].y - position[i].y, position[i + 2].z - position[i].z};
        
        cross = {edge1.y * edge2.z - edge1.z * edge2.y, edge1.z * edge2.x - edge1.x * edge2.z, edge1.x * edge2.y - edge1.y * edge2.x};
        
        len = sqrt(cross.x * cross.x + cross.y * cross.y + cross.z * cross.z);
        
        customNormal[nth] = {cross.x / len, cross.y / len, cross.z / len};
    }
    /*edge1 = {position[13].x - position[12].x, position[13].y - position[12].y, position[13].z - position[12].z};
    //edge1 = {position[12].x - position[13].x, position[12].y - position[13].y, position[12].z - position[13].z};
    
    edge2 = {position[14].x - position[12].x, position[14].y - position[12].y, position[14].z - position[12].z};
    //edge2 = {position[12].x - position[14].x, position[12].y - position[14].y, position[12].z - position[14].z};
    
    cross = {edge1.y * edge2.z - edge1.z * edge2.y, edge1.z * edge2.x - edge1.x * edge2.z, edge1.x * edge2.y - edge1.y * edge2.x};
    //cross = {edge2.y * edge1.z - edge2.z * edge1.y, edge2.z * edge1.x - edge2.x * edge1.z, edge2.x * edge1.y - edge2.y * edge1.x};
    
    len = sqrt(cross.x * cross.x + cross.y * cross.y + cross.z * cross.z);
    
    customNormal[4] = {cross.x / len, cross.y / len, cross.z / len};
    
    edge1 = {position[13].x - position[12].x, position[13].y - position[12].y, position[13].z - position[12].z};
    //edge1 = {position[15].x - position[16].x, position[15].y - position[16].y, position[15].z - position[16].z};
    
    edge2 = {position[14].x - position[12].x, position[14].y - position[12].y, position[14].z - position[12].z};
    //edge2 = {position[15].x - position[17].x, position[15].y - position[17].y, position[15].z - position[17].z};
    
    cross = {edge1.y * edge2.z - edge1.z * edge2.y, edge1.z * edge2.x - edge1.x * edge2.z, edge1.x * edge2.y - edge1.y * edge2.x};
    //cross = {edge2.y * edge1.z - edge2.z * edge1.y, edge2.z * edge1.x - edge2.x * edge1.z, edge2.x * edge1.y - edge2.y * edge1.x};
    
    len = sqrt(cross.x * cross.x + cross.y * cross.y + cross.z * cross.z);
    
    customNormal[5] = {cross.x / len, cross.y / len, cross.z / len};*/
    
    for (int i = 0; i < 36; i++) {
        self.bigIndices[i + self.totalIndices] = i + self.totalIndices;
        
        self.bigVertices[i + self.totalIndices].customColor = {static_cast<float>((float) red / 255.0), static_cast<float>((float) green / 255.0), static_cast<float>((float) blue / 255.0), 1.0f};
        self.bigVertices[i + self.totalIndices].position = position[i];
        
        self.bigLineVertices[i + self.totalIndices].customColor = {0, 0, 0, 1.0f};
        self.bigLineVertices[i + self.totalIndices].position = position[i];
    }
    
    simd::float3 customVertexNormal;
    
    // front
    
    customVertexNormal = {customNormal[0].x + customNormal[1].x + customNormal[2].x + customNormal[3].x + customNormal[8].x + customNormal[9].x,
        customNormal[0].y + customNormal[1].y + customNormal[2].y + customNormal[3].y + customNormal[8].y + customNormal[9].y,
        customNormal[0].z + customNormal[1].z + customNormal[2].z + customNormal[3].z + customNormal[8].z + customNormal[9].z};
    self.bigVertices[2 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[3 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[0].x + customNormal[1].x + customNormal[6].x + customNormal[7].x + customNormal[11].x,
        customNormal[0].y + customNormal[1].y + customNormal[6].y + customNormal[7].y + customNormal[11].y,
        customNormal[0].z + customNormal[1].z + customNormal[6].z + customNormal[7].z + customNormal[11].z};
    self.bigVertices[0 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[5 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[0].x + customNormal[2].x + customNormal[10].x + customNormal[11].x,
        customNormal[0].y + customNormal[2].y + customNormal[10].y + customNormal[11].y,
        customNormal[0].z + customNormal[2].z + customNormal[10].z + customNormal[11].z};
    self.bigVertices[1 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[1].x + customNormal[7].x + customNormal[9].x,
        customNormal[1].y + customNormal[7].y + customNormal[9].y,
        customNormal[1].z + customNormal[7].z + customNormal[9].z};
    self.bigVertices[4 + self.totalIndices].normal = normalize(customVertexNormal);
    
    // right
    
    customVertexNormal = {customNormal[2].x + customNormal[3].x + customNormal[4].x + customNormal[10].x,
        customNormal[2].y + customNormal[3].y + customNormal[4].y + customNormal[10].y,
        customNormal[2].z + customNormal[3].z + customNormal[4].z + customNormal[10].z};
    self.bigVertices[7 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[9 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[0].x + customNormal[1].x + customNormal[2].x + customNormal[3].x + customNormal[8].x + customNormal[9].x,
        customNormal[0].y + customNormal[1].y + customNormal[2].y + customNormal[3].y + customNormal[8].y + customNormal[9].y,
        customNormal[0].z + customNormal[1].z + customNormal[2].z + customNormal[3].z + customNormal[8].z + customNormal[9].z};
    self.bigVertices[8 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[11 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[0].x + customNormal[2].x + customNormal[10].x + customNormal[11].x,
        customNormal[0].y + customNormal[2].y + customNormal[10].y + customNormal[11].y,
        customNormal[0].z + customNormal[2].z + customNormal[10].z + customNormal[11].z};
    self.bigVertices[6 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[3].x + customNormal[4].x + customNormal[5].x + customNormal[8].x,
        customNormal[3].y + customNormal[4].y + customNormal[5].y + customNormal[8].y,
        customNormal[3].z + customNormal[4].z + customNormal[5].z + customNormal[8].z};
    self.bigVertices[10 + self.totalIndices].normal = normalize(customVertexNormal);
    
    // back
    
    customVertexNormal = {customNormal[4].x + customNormal[5].x + customNormal[6].x + customNormal[10].x + customNormal[11].x,
        customNormal[4].y + customNormal[5].y + customNormal[6].y + customNormal[10].y + customNormal[11].y,
        customNormal[4].z + customNormal[5].z + customNormal[6].z + customNormal[10].z + customNormal[11].z};
    self.bigVertices[13 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[17 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[3].x + customNormal[4].x + customNormal[5].x + customNormal[8].x,
        customNormal[3].y + customNormal[4].y + customNormal[5].y + customNormal[8].y,
        customNormal[3].z + customNormal[4].z + customNormal[5].z + customNormal[8].z};
    self.bigVertices[14 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[16 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[2].x + customNormal[3].x + customNormal[4].x + customNormal[10].x,
        customNormal[2].y + customNormal[3].y + customNormal[4].y + customNormal[10].y,
        customNormal[2].z + customNormal[3].z + customNormal[4].z + customNormal[10].z};
    self.bigVertices[12 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[5].x + customNormal[6].x + customNormal[7].x + customNormal[8].x + customNormal[9].x,
        customNormal[5].y + customNormal[6].y + customNormal[7].y + customNormal[8].y + customNormal[9].y,
        customNormal[5].z + customNormal[6].z + customNormal[7].z + customNormal[8].z + customNormal[9].z};
    self.bigVertices[15 + self.totalIndices].normal = normalize(customVertexNormal);
    
    // left
    
    customVertexNormal = {customNormal[0].x + customNormal[1].x + customNormal[6].x + customNormal[7].x + customNormal[11].x,
        customNormal[0].y + customNormal[1].y + customNormal[6].y + customNormal[7].y + customNormal[11].y,
        customNormal[0].z + customNormal[1].z + customNormal[6].z + customNormal[7].z + customNormal[11].z};
    self.bigVertices[19 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[23 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[5].x + customNormal[6].x + customNormal[7].x + customNormal[8].x + customNormal[9].x,
        customNormal[5].y + customNormal[6].y + customNormal[7].y + customNormal[8].y + customNormal[9].y,
        customNormal[5].z + customNormal[6].z + customNormal[7].z + customNormal[8].z + customNormal[9].z};
    self.bigVertices[20 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[22 + self.totalIndices].normal = normalize(customVertexNormal);
    
    
    customVertexNormal = {customNormal[4].x + customNormal[5].x + customNormal[6].x + customNormal[10].x + customNormal[11].x,
        customNormal[4].y + customNormal[5].y + customNormal[6].y + customNormal[10].y + customNormal[11].y,
        customNormal[4].z + customNormal[5].z + customNormal[6].z + customNormal[10].z + customNormal[11].z};
    self.bigVertices[18 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[1].x + customNormal[7].x + customNormal[9].x,
        customNormal[1].y + customNormal[7].y + customNormal[9].y,
        customNormal[1].z + customNormal[7].z + customNormal[9].z};
    self.bigVertices[21 + self.totalIndices].normal = normalize(customVertexNormal);
    
    // top
    
    customVertexNormal = {customNormal[5].x + customNormal[6].x + customNormal[7].x + customNormal[8].x + customNormal[9].x,
        customNormal[5].y + customNormal[6].y + customNormal[7].y + customNormal[8].y + customNormal[9].y,
        customNormal[5].z + customNormal[6].z + customNormal[7].z + customNormal[8].z + customNormal[9].z};
    self.bigVertices[26 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[29 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[0].x + customNormal[1].x + customNormal[2].x + customNormal[3].x + customNormal[8].x + customNormal[9].x,
        customNormal[0].y + customNormal[1].y + customNormal[2].y + customNormal[3].y + customNormal[8].y + customNormal[9].y,
        customNormal[0].z + customNormal[1].z + customNormal[2].z + customNormal[3].z + customNormal[8].z + customNormal[9].z};
    self.bigVertices[24 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[28 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[3].x + customNormal[4].x + customNormal[5].x + customNormal[8].x,
        customNormal[3].y + customNormal[4].y + customNormal[5].y + customNormal[8].y,
        customNormal[3].z + customNormal[4].z + customNormal[5].z + customNormal[8].z};
    self.bigVertices[25 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[1].x + customNormal[7].x + customNormal[9].x,
        customNormal[1].y + customNormal[7].y + customNormal[9].y,
        customNormal[1].z + customNormal[7].z + customNormal[9].z};
    self.bigVertices[27 + self.totalIndices].normal = normalize(customVertexNormal);
    
    // bottom
    
    customVertexNormal = {customNormal[0].x + customNormal[2].x + customNormal[10].x + customNormal[11].x,
        customNormal[0].y + customNormal[2].y + customNormal[10].y + customNormal[11].y,
        customNormal[0].z + customNormal[2].z + customNormal[10].z + customNormal[11].z};
    self.bigVertices[30 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[34 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[4].x + customNormal[5].x + customNormal[6].x + customNormal[10].x + customNormal[11].x,
        customNormal[4].y + customNormal[5].y + customNormal[6].y + customNormal[10].y + customNormal[11].y,
        customNormal[4].z + customNormal[5].z + customNormal[6].z + customNormal[10].z + customNormal[11].z};
    self.bigVertices[31 + self.totalIndices].normal = normalize(customVertexNormal);
    self.bigVertices[33 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[2].x + customNormal[3].x + customNormal[4].x + customNormal[10].x,
        customNormal[2].y + customNormal[3].y + customNormal[4].y + customNormal[10].y,
        customNormal[2].z + customNormal[3].z + customNormal[4].z + customNormal[10].z};
    self.bigVertices[32 + self.totalIndices].normal = normalize(customVertexNormal);
    
    customVertexNormal = {customNormal[0].x + customNormal[1].x + customNormal[6].x + customNormal[7].x + customNormal[11].x,
        customNormal[0].y + customNormal[1].y + customNormal[6].y + customNormal[7].y + customNormal[11].y,
        customNormal[0].z + customNormal[1].z + customNormal[6].z + customNormal[7].z + customNormal[11].z};
    self.bigVertices[35 + self.totalIndices].normal = normalize(customVertexNormal);
    
    for (int i = 0; i < 12; i++) {
        self.bigLineIndices[i * 6 + 0 + self.totalIndices * 2] = i * 3 + self.totalIndices;
        self.bigLineIndices[i * 6 + 1 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 2 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        self.bigLineIndices[i * 6 + 3 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 4 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        self.bigLineIndices[i * 6 + 5 + self.totalIndices * 2] = i * 3 + self.totalIndices;
    }
    
    int lastIndices = self.totalIndices;
    self.totalIndices += 36;
    
    return lastIndices;
}

- (void)appendStairs:(float)x y:(float)y z:(float)z width:(float)width stepWidth:(float)stepWidth stepHeight:(float)stepHeight depth:(float)depth red:(int)red green:(int)green blue:(int)blue {
    const int numberOfSteps = 3;
    
    
    
    customFloat4 position[36 * numberOfSteps];
    
    int index = 0;
    for (int step = 0; step < numberOfSteps; step++) {
        // front
        
        position[index++] = {x, y + step * stepHeight, z - step * stepWidth, 1.0};
        position[index++] = {x + width, y + step * stepHeight, z - step * stepWidth, 1.0};
        position[index++] = {x + width, y + (step + 1) * stepHeight, z - step * stepWidth, 1.0};
        
        position[index++] = {x + width, y + (step + 1) * stepHeight, z - step * stepWidth, 1.0};
        position[index++] = {x, y + (step + 1) * stepHeight, z - step * stepWidth, 1.0};
        position[index++] = {x, y + step * stepHeight, z - step * stepWidth, 1.0};
        
        //right
        
        position[index++] = {x + width, y + step * stepHeight, z - step * stepWidth, 1.0};
        position[index++] = {x + width, y + step * stepHeight, z - depth, 1.0};
        position[index++] = {x + width, y + (step + 1) * stepHeight, z - step * stepWidth, 1.0};
        
        position[index++] = {x + width, y + step * stepHeight, z - depth, 1.0};
        position[index++] = {x + width, y + (step + 1) * stepHeight, z - depth, 1.0};
        position[index++] = {x + width, y + (step + 1) * stepHeight, z - step * stepWidth, 1.0};
        
        // back
        
        position[index++] = {x + width, y + step * stepHeight, z - depth, 1.0};
        position[index++] = {x, y + step * stepHeight, z - depth, 1.0};
        position[index++] = {x + width, y + (step + 1) * stepHeight, z - depth, 1.0};
        
        position[index++] = {x, y + (step + 1) * stepHeight, z - depth, 1.0};
        position[index++] = {x + width, y + (step + 1) * stepHeight, z - depth, 1.0};
        position[index++] = {x, y + step * stepHeight, z - depth, 1.0};
        
        // left
        
        position[index++] = {x, y + step * stepHeight, z - depth, 1.0};
        position[index++] = {x, y + step * stepHeight, z - step * stepWidth, 1.0};
        position[index++] = {x, y + (step + 1) * stepHeight, z - depth, 1.0};
        
        position[index++] = {x, y + (step + 1) * stepHeight, z - step * stepWidth, 1.0};
        position[index++] = {x, y + (step + 1) * stepHeight, z - depth, 1.0};
        position[index++] = {x, y + step * stepHeight, z - step * stepWidth, 1.0};
        
        // top
        
        position[index++] = {x + width, y + (step + 1) * stepHeight, z - step * stepWidth, 1.0};
        position[index++] = {x + width, y + (step + 1) * stepHeight, z - depth, 1.0};
        position[index++] = {x, y + (step + 1) * stepHeight, z - depth, 1.0};
        
        position[index++] = {x, y + (step + 1) * stepHeight, z - step * stepWidth, 1.0};
        position[index++] = {x + width, y + (step + 1) * stepHeight, z - step * stepWidth, 1.0};
        position[index++] = {x, y + (step + 1) * stepHeight, z - depth, 1.0};
        
        // bottom
        
        position[index++] = {x + width, y + step * stepHeight, z - step * stepWidth, 1.0};
        position[index++] = {x, y + step * stepHeight, z - depth, 1.0};
        position[index++] = {x + width, y + step * stepHeight, z - depth, 1.0};
        
        position[index++] = {x, y + step * stepHeight, z - depth, 1.0};
        position[index++] = {x + width, y + step * stepHeight, z - step * stepWidth, 1.0};
        position[index++] = {x, y + step * stepHeight, z - step * stepWidth, 1.0};
    }
    
    
    
    for (int i = 0; i < 36 * numberOfSteps; i++) {
        self.bigIndices[i + self.totalIndices] = i + self.totalIndices;
        
        self.bigVertices[i + self.totalIndices].normal = {static_cast<float>((float) red / 255.0), static_cast<float>((float) green / 255.0), static_cast<float>((float) blue / 255.0)};
        self.bigVertices[i + self.totalIndices].position = position[i];
        
        self.bigLineVertices[i + self.totalIndices].normal = {0, 0, 0};
        self.bigLineVertices[i + self.totalIndices].position = position[i];
    }
    
    for (int i = 0; i < 12 * numberOfSteps; i++) {
        self.bigLineIndices[i * 6 + 0 + self.totalIndices * 2] = i * 3 + self.totalIndices;
        self.bigLineIndices[i * 6 + 1 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 2 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        self.bigLineIndices[i * 6 + 3 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 4 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        self.bigLineIndices[i * 6 + 5 + self.totalIndices * 2] = i * 3 + self.totalIndices;
    }
    
    self.totalIndices += 36 * numberOfSteps;
}

void makeFace(customFloat4* position, simd::float3 a, simd::float3 b, simd::float3 c, simd::float3 d, int offset) {
    position[offset++] = {a.x, a.y, a.z, 1.0};
    position[offset++] = {b.x, b.y, b.z, 1.0};
    position[offset++] = {c.x, c.y, c.z, 1.0};
    
    position[offset++] = {d.x, d.y, d.z, 1.0};
    position[offset++] = {c.x, c.y, c.z, 1.0};
    position[offset++] = {b.x, b.y, b.z, 1.0};
}

- (void)appendChessboard:(float)x y:(float)y z:(float)z width:(float)width height:(float)height depth:(float)depth red:(int)red green:(int)green blue:(int)blue topBorder:(float)topBorder {
    
    customFloat4 position[54 + 6 * 8 * 8];
    
    // front
    
    position[0] = {x, y, z, 1.0};
    position[1] = {x + width, y, z, 1.0};
    position[2] = {x + width, y + height, z, 1.0};
    
    position[3] = {x + width, y + height, z, 1.0};
    position[4] = {x, y + height, z, 1.0};
    position[5] = {x, y, z, 1.0};
    
    //right
    
    position[6] = {x + width, y, z, 1.0};
    position[7] = {x + width, y, z - depth, 1.0};
    position[8] = {x + width, y + height, z, 1.0};
    
    position[9] = {x + width, y, z - depth, 1.0};
    position[10] = {x + width, y + height, z - depth, 1.0};
    position[11] = {x + width, y + height, z, 1.0};
    
    // back
    
    position[12] = {x + width, y, z - depth, 1.0};
    position[13] = {x, y, z - depth, 1.0};
    position[14] = {x + width, y + height, z - depth, 1.0};
    
    position[15] = {x, y + height, z - depth, 1.0};
    position[16] = {x + width, y + height, z - depth, 1.0};
    position[17] = {x, y, z - depth, 1.0};
    
    // left
    
    position[18] = {x, y, z - depth, 1.0};
    position[19] = {x, y, z, 1.0};
    position[20] = {x, y + height, z - depth, 1.0};
    
    position[21] = {x, y + height, z, 1.0};
    position[22] = {x, y + height, z - depth, 1.0};
    position[23] = {x, y, z, 1.0};
    
    // top front
    
    position[24] = {x + width, y + height, z, 1.0};
    position[26] = {x, y + height, z - topBorder, 1.0};
    position[25] = {x + width, y + height, z - topBorder, 1.0};
    
    position[27] = {x, y + height, z, 1.0};
    position[28] = {x + width, y + height, z, 1.0};
    position[29] = {x, y + height, z - topBorder, 1.0};
    
    // top back
    
    position[30] = {x + width, y + height, z - depth, 1.0};
    position[31] = {x, y + height, z - depth + topBorder, 1.0};
    position[32] = {x + width, y + height, z - depth + topBorder, 1.0};
    
    position[35] = {x, y + height, z - depth, 1.0};
    position[34] = {x + width, y + height, z - depth, 1.0};
    position[33] = {x, y + height, z - depth + topBorder, 1.0};
    
    // top left
    
    position[38] = {x + topBorder, y + height, z - topBorder, 1.0};
    position[37] = {x, y + height, z - depth + topBorder, 1.0};
    position[36] = {x + topBorder, y + height, z - depth + topBorder, 1.0};
    
    position[39] = {x, y + height, z - topBorder, 1.0};
    position[40] = {x + topBorder, y + height, z - topBorder, 1.0};
    position[41] = {x, y + height, z - depth + topBorder, 1.0};
    
    
    
    /*position[42] = {x + width, y + height, z - depth + topBorder, 1.0};
    position[43] = {x + width - topBorder, y + height, z - depth + topBorder, 1.0};
    position[44] = {x + width, y + height, z - topBorder, 1.0};
    
    position[45] = {x + width - topBorder, y + height, z - topBorder, 1.0};
    position[46] = {x + width, y + height, z - topBorder, 1.0};
    position[47] = {x + width - topBorder, y + height, z - depth + topBorder, 1.0};*/
    
    // bottom
    
    position[42] = {x + width, y, z, 1.0};
    position[43] = {x, y, z - depth, 1.0};
    position[44] = {x + width, y, z - depth, 1.0};
    
    position[45] = {x, y, z - depth, 1.0};
    position[46] = {x + width, y, z, 1.0};
    position[47] = {x, y, z, 1.0};
    
    // top right
    
    makeFace(position,
             simd::float3{x + width, y + height, z - depth + topBorder},
             simd::float3{x + width - topBorder, y + height, z - depth + topBorder},
             simd::float3{x + width, y + height, z - topBorder},
             simd::float3{x + width - topBorder, y + height, z - topBorder},
             48);
    
    // tops
    
    float cell = ((x + width - topBorder) - (x + topBorder)) / 8.0;
    for (int j = 0; j < 8; j++) {
        for (int i = 0; i < 8; i++) {
            makeFace(position,
                    simd::float3{x + topBorder + cell * (i + 1), y + height, z - topBorder - cell * (j + 1)},
                    simd::float3{x + topBorder + cell * i, y + height, z - topBorder - cell * (j + 1)},
                    simd::float3{x + topBorder + cell * (i + 1), y + height, z - topBorder - cell * j},
                    simd::float3{x + topBorder + cell * i, y + height, z - topBorder - cell * j},
                    54 + i * 6 + j * 6 * 8);
        }
    }
    
    
    for (int i = 0; i < 54; i++) {
        self.bigIndices[i + self.totalIndices] = i + self.totalIndices;
        
        self.bigVertices[i + self.totalIndices].normal = {static_cast<float>((float) red / 255.0), static_cast<float>((float) green / 255.0), static_cast<float>((float) blue / 255.0)};
        self.bigVertices[i + self.totalIndices].position = position[i];
        
        self.bigLineVertices[i + self.totalIndices].normal = {0, 0, 0};
        self.bigLineVertices[i + self.totalIndices].position = position[i];
    }
    bool isBlack = false;
    int vertNth = 0, row = 0;
    for (int i = 54; i < 54 + 6 * 8 * 8; i++) {
        self.bigIndices[i + self.totalIndices] = i + self.totalIndices;
        
        if (!isBlack) {
            self.bigVertices[i + self.totalIndices].normal = {static_cast<float>((float) 255 / 255.0), static_cast<float>((float) 255 / 255.0), static_cast<float>((float) 0 / 255.0)};
        } else {
            self.bigVertices[i + self.totalIndices].normal = {static_cast<float>((float) 255 / 255.0), static_cast<float>((float) 0 / 255.0), static_cast<float>((float) 0 / 255.0)};
        }
        self.bigVertices[i + self.totalIndices].position = position[i];
        
        self.bigLineVertices[i + self.totalIndices].normal = {0, 0, 0};
        self.bigLineVertices[i + self.totalIndices].position = position[i];
        
        vertNth++;
        if (vertNth == 6) {
            vertNth = 0;
            row++;
            
            if (row == 8) {
                row = 0;
            } else {
                isBlack = !isBlack;
            }
        }
    }
    
    for (int i = 0; i < (54 + 6 * 8 * 8) / 3; i++) {
        self.bigLineIndices[i * 6 + 0 + self.totalIndices * 2] = i * 3 + self.totalIndices;
        self.bigLineIndices[i * 6 + 1 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 2 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        self.bigLineIndices[i * 6 + 3 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 4 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        self.bigLineIndices[i * 6 + 5 + self.totalIndices * 2] = i * 3 + self.totalIndices;
    }
    
    self.totalIndices += 54 + 6 * 8 * 8;
}

- (void)appendRoof:(float)x y:(float)y z:(float)z
             width:(float)width height:(float)height depth:(float)depth
               red:(int)red green:(int)green blue:(int)blue {
    
    customFloat4 position[24];
    
    // front
    
    position[0] = {x, y, z, 1.0};
    position[1] = {x + width, y, z, 1.0};
    position[2] = {x + width / 2.0f, y + height, z, 1.0};
    
    //right
    
    position[3] = {x + width, y, z, 1.0};
    position[4] = {x + width, y, z - depth, 1.0};
    position[5] = {x + width / 2.0f, y + height, z, 1.0};
    
    position[6] = {x + width, y, z - depth, 1.0};
    position[7] = {x + width / 2.0f, y + height, z - depth, 1.0};
    position[8] = {x + width / 2.0f, y + height, z, 1.0};
    
    // back
    
    position[9] = {x + width, y, z - depth, 1.0};
    position[10] = {x, y, z - depth, 1.0};
    position[11] = {x + width / 2.0f, y + height, z - depth, 1.0};
    
    // left
    
    position[12] = {x, y, z - depth, 1.0};
    position[13] = {x, y, z, 1.0};
    position[14] = {x + width / 2.0f, y + height, z - depth, 1.0};
    
    position[15] = {x + width / 2.0f, y + height, z, 1.0};
    position[16] = {x + width / 2.0f, y + height, z - depth, 1.0};
    position[17] = {x, y, z, 1.0};
    
    // bottom
    
    position[18] = {x + width, y, z, 1.0};
    position[19] = {x, y, z - depth, 1.0};
    position[20] = {x + width, y, z - depth, 1.0};
    
    position[21] = {x, y, z - depth, 1.0};
    position[22] = {x + width, y, z, 1.0};
    position[23] = {x, y, z, 1.0};
    
    for (int i = 0; i < 24; i++) {
        self.bigIndices[i + self.totalIndices] = i + self.totalIndices;
        
        self.bigVertices[i + self.totalIndices].normal = {static_cast<float>((float) red / 255.0), static_cast<float>((float) green / 255.0), static_cast<float>((float) blue / 255.0)};
        self.bigVertices[i + self.totalIndices].position = position[i];
        
        self.bigLineVertices[i + self.totalIndices].normal = {0, 0, 0};
        self.bigLineVertices[i + self.totalIndices].position = position[i];
    }
    
    for (int i = 0; i < 8; i++) {
        self.bigLineIndices[i * 6 + 0 + self.totalIndices * 2] = i * 3 + self.totalIndices;
        self.bigLineIndices[i * 6 + 1 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 2 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        self.bigLineIndices[i * 6 + 3 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 4 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        self.bigLineIndices[i * 6 + 5 + self.totalIndices * 2] = i * 3 + self.totalIndices;
    }
    
    self.totalIndices += 24;
}

- (void)appendLadder:(float)x y:(float)y z:(float)z width:(float)width height:(float)height depth:(float)depth red:(int)red green:(int)green blue:(int)blue {
    
    float stickDepth = 0.05;
    
    [self appendCube:x y:y z:z width:stickDepth height:height depth:stickDepth red:red green:green blue:blue];
    [self appendCube:x + width - stickDepth y:y z:z width:stickDepth height:height depth:stickDepth red:red green:green blue:blue];
    
    int steps = 4;
    float heightOffset = height / (steps + 1);
    for (int i = 0; i < steps; i++) {
        [self appendCube:x + stickDepth y:y + heightOffset * (i + 1) z:z width:width - stickDepth * 2 height:stickDepth depth:stickDepth red:red green:green blue:blue];
    }
}

simd::float4 positionAt(float radius, float angle, float segmentAngle, float offsetX, float offsetY) {
    float x = offsetX + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius);
    float y;
    float z;
    return simd::float4{0, 0, 0, 1.0f};
}

- (void)appendGear:(float)x y:(float)y z:(float)z radius:(float)radius height:(float)height red:(int)red green:(int)green blue:(int)blue {
    int segments = 36;
    
    float segmentAngle = 360.0 / segments;
    
    customFloat4 position[segments * 3 * 2 * 2 * 2 * 2];
    
    
    
    
    
    int index = 0;
    for (float angle = 0.0; angle < segmentAngle * segments; angle += segmentAngle) {
        
        position[index++] = {x - static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x - static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x - static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        
        position[index++] = {x - static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x - static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x - static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        
        
        
        // bottom
        
        /*position[index++] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x, y, z, 1.0};*/
        
        // top
        
        /*position[index++] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[index++] = {x, y + height, z, 1.0};*/
    }
    for (float angle = 0.0; angle < segmentAngle * segments; angle += segmentAngle) {
        //simd::float4 pos = positionAt(bigRadius, angle, segmentAngle, x, y);
        float bigRadius = 0.25f;
        int parts = 5;
        int partAngle = 40;
        
        int nonpartAngle = (360 - parts * partAngle) / parts;
        
        int currentAngle = nonpartAngle / 2;
        if (angle >= currentAngle && angle <= currentAngle + partAngle) {
            bigRadius = 0.35f;
        }/* else {
            bigRadius = 0.25f;
        }*/
        currentAngle += partAngle;
        
        for (int i = 0; i < parts - 1; i++) {
            if (angle >= currentAngle + nonpartAngle && angle <= currentAngle + nonpartAngle + partAngle) {
                bigRadius = 0.35f;
            }/* else {
                bigRadius = 0.25f;
            }*/
            currentAngle += (nonpartAngle + partAngle);
        }
        
        
        float bigRadiusB = 0.25f;
        int currentAngleB = nonpartAngle / 2;
        if (angle + segmentAngle >= currentAngleB && angle + segmentAngle <= currentAngleB + partAngle) {
            bigRadiusB = 0.35f;
        }
        currentAngleB += partAngle;
        
        for (int i = 0; i < parts - 1; i++) {
            if (angle + segmentAngle >= currentAngleB + nonpartAngle && angle + segmentAngle <= currentAngleB + nonpartAngle + partAngle) {
                bigRadiusB = 0.35f;
            }
            currentAngleB += (nonpartAngle + partAngle);
        }
        
        position[index++] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), y, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), 1.0};
        position[index++] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * bigRadius), y, z + static_cast<float>(sin(angle * 3.14 / 180.0) * bigRadius), 1.0};
        position[index++] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * bigRadius), y + height, z + static_cast<float>(sin(angle * 3.14 / 180.0) * bigRadius), 1.0};
        
        position[index++] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * bigRadius), y + height, z + static_cast<float>(sin(angle * 3.14 / 180.0) * bigRadius), 1.0};
        position[index++] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), y + height, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), 1.0};
        position[index++] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), y, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), 1.0};
    }
    int last = segments * 3 * 2 * 2;
    float angle = 0.0f;
    for (int i = last; i < segments * 3 * 2 * 2 * 2; i += 6, angle += segmentAngle) {
        position[i + 2] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[i + 1] = position[i + segments * 3 * 2 - last + 2];
        position[i] = position[i + segments * 3 * 2 - last + 4];
        
        position[i + 3] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[i + 4] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};//position[i - last + segments * 3 * 2 + 2];
        position[i + 5] = position[i];//position[i - last + segments * 3 * 3 + 1];
        
        /*position[i + 3] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * bigRadius), y + height, z + static_cast<float>(sin(angle * 3.14 / 180.0) * bigRadius), 1.0};
        position[i + 4] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), y + height, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), 1.0};
        position[i + 5] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), y, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), 1.0};*/
    }
    angle = 0.0f;
    last = segments * 3 * 2 * 2 * 2;
    for (int i = last; i < segments * 3 * 2 * 2 * 2 * 2; i += 6, angle += segmentAngle) {
        position[i] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[i + 1] = position[i + segments * 3 * 2 - last + 1];
        position[i + 2] = position[i + segments * 3 * 2 - last + 5];
        
        position[i + 5] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
        position[i + 4] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
        position[i + 3] = position[i + 2];
    }
    
    for (int i = 0; i < segments * 3 * 2 * 2 * 2 * 2; i++) {
        self.bigIndices[i + self.totalIndices] = i + self.totalIndices;
        
        self.bigVertices[i + self.totalIndices].customColor = {static_cast<float>((float) red / 255.0), static_cast<float>((float) green / 255.0), static_cast<float>((float) blue / 255.0)};
        self.bigVertices[i + self.totalIndices].position = position[i];
        
        self.bigLineVertices[i + self.totalIndices].customColor = {0, 0, 0};
        self.bigLineVertices[i + self.totalIndices].position = position[i];
    }
    
    for (int i = 0; i < segments * 2 * 2 * 2 * 2; i++) {
        self.bigLineIndices[i * 6 + 0 + self.totalIndices * 2] = i * 3 + self.totalIndices;
        self.bigLineIndices[i * 6 + 1 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 2 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        self.bigLineIndices[i * 6 + 3 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 4 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        self.bigLineIndices[i * 6 + 5 + self.totalIndices * 2] = i * 3 + self.totalIndices;
    }
    
    self.totalIndices += segments * 3 * 2 * 2 * 2 * 2;
}

- (void)removeAction:(int)type {
    NSLog(@"Remove action");
    
    if (lastObject + 36 < self.totalIndices) {
        for (int i = lastObject; i < self.totalIndices; i++) {
            self.bigVertices[i] = self.bigVertices[i + 36];
            self.bigIndices[i] = self.bigIndices[i + 36];
            self.bigLineVertices[i] = self.bigLineVertices[i + 36];
            //self.bigLineIndices[i] = self.bigLineIndices[i + 36];
        }
        for (int i = lastObject * 2; i < self.totalIndices * 2; i++) {
            self.bigLineIndices[i] = self.bigLineIndices[i + 72];
        }
    }
    self.totalIndices -= 36;
    
    self.vertexBuffer = [self.renderer newBufferWithBytes:self.bigVertices length:sizeof(Vertex) * self.totalIndices];
    self.indexBuffer = [self.renderer newBufferWithBytes:self.bigIndices length:sizeof(IndexType) * self.totalIndices];
    
    self.lineVertexBuffer = [self.renderer newBufferWithBytes:self.bigLineVertices length:sizeof(Vertex) * self.totalIndices];
    self.lineIndexBuffer = [self.renderer newBufferWithBytes:self.bigLineIndices length:sizeof(uint16_t) * (self.totalIndices * 2)];
}

- (void)appendAction:(float)x y:(float)y z:(float)z {
    NSLog(@"Append action");
    
    lastObject = [self appendCube:x y:y z:z width:0.5 height:0.5 depth:0.5 red:0 green:255 blue:0];
    
    self.vertexBuffer = [self.renderer newBufferWithBytes:self.bigVertices length:sizeof(Vertex) * self.totalIndices];
    self.indexBuffer = [self.renderer newBufferWithBytes:self.bigIndices length:sizeof(IndexType) * self.totalIndices];
    
    self.lineVertexBuffer = [self.renderer newBufferWithBytes:self.bigLineVertices length:sizeof(Vertex) * self.totalIndices];
    self.lineIndexBuffer = [self.renderer newBufferWithBytes:self.bigLineIndices length:sizeof(uint16_t) * (self.totalIndices * 2)];
}

- (void)completeSavedImage:(UIImage *)_image didFinishSavingWithError:(NSError *)_error contextInfo:(void *)_contextInfo {
    if (!_error) {
        NSLog(@"Saved");
    }
}

- (NSString *)exportOBJ:(NSString *)filename {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:[filename stringByAppendingString:@".obj"]];
    
    NSMutableString *contents = [NSMutableString string];
    [contents appendString:@"# Modeled on iPhone\n\n# List of geometric vertices\n"];
    
    //NSMutableString *contents = @"# Modeled on iPhone\n\n# List of geometric vertices\n";
    NSError *error;
    
    //contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\nmtllib ./%@\n", [filename stringByAppendingString:@".mtl"]]];
    [contents appendString:[NSString stringWithFormat:@"\nmtllib ./%@\n", [filename stringByAppendingString:@".mtl"]]];
    
    // vertices
    
    BOOL includeColor = true;
    if (includeColor) {
        for (int i = 0; i < self.totalIndices; i++) {
            //contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\nv %f %f %f %f %f %f", self.bigVertices[i].position.x, self.bigVertices[i].position.y, self.bigVertices[i].position.z, self.bigVertices[i].customColor.x, self.bigVertices[i].customColor.y, self.bigVertices[i].customColor.z]];
            [contents appendString:[NSString stringWithFormat:@"\nv %f %f %f %f %f %f", self.bigVertices[i].position.x, self.bigVertices[i].position.y, self.bigVertices[i].position.z, self.bigVertices[i].customColor.x, self.bigVertices[i].customColor.y, self.bigVertices[i].customColor.z]];
        }
    } else {
        for (int i = 0; i < self.totalIndices; i++) {
            contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\nv %f %f %f", self.bigVertices[i].position.x, self.bigVertices[i].position.y, self.bigVertices[i].position.z]];
        }
    }
    NSLog(@"LEN = %lu", [contents length]);
    
    // texture coords
    
    //contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\n\n# List of texture coordinates\n"]];
    [contents appendString:[NSString stringWithFormat:@"\n\n# List of texture coordinates\n"]];
    
    for (int i = 0; i < self.totalIndices; i++) {
        //contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\nvt %f %f", self.bigVertices[i].texCoord.y, self.bigVertices[i].texCoord.z]];
        [contents appendString:[NSString stringWithFormat:@"\nvt %f %f", self.bigVertices[i].texCoord.y, self.bigVertices[i].texCoord.z]];
    }
    
    // normals
    
    //contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\n\n# List of lighting normals\n"]];
    [contents appendString:[NSString stringWithFormat:@"\n\n# List of lighting normals\n"]];
    
    for (int i = 0; i < self.totalIndices; i++) {
        //contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\nvn %f %f %f", self.bigVertices[i].normal.x, self.bigVertices[i].normal.y, self.bigVertices[i].normal.z]];
        [contents appendString:[NSString stringWithFormat:@"\nvn %f %f %f", self.bigVertices[i].normal.x, self.bigVertices[i].normal.y, self.bigVertices[i].normal.z]];
    }
    
    // faces
    
    //contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\n\n# List of face indices\n"]];
    [contents appendString:[NSString stringWithFormat:@"\n\n# List of face indices\n"]];
    
    int nth = 1;
    int lastMaterial = -1;
    for (int i = 0; i < self.totalIndices / 3; i++) {
        if (self.bigVertices[nth].texCoord.w == 1) {
            if (self.bigVertices[nth].texCoord.x != lastMaterial) {
                lastMaterial = self.bigVertices[nth].texCoord.x;
                //NSLog(@"MATERIAL %d %d %f", lastMaterial, nth, self.bigVertices[nth].texCoord.x);
                //contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\n\nusemtl material%d", lastMaterial]];
                [contents appendString:[NSString stringWithFormat:@"\n\nusemtl material%d", lastMaterial]];
            }
        }
        //contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\nf %d %d %d", nth++, nth++, nth++]];
        [contents appendString:[NSString stringWithFormat:@"\nf %d %d %d", nth++, nth++, nth++]];
    }
    
    NSLog(contents);
    
    [contents writeToFile:filePath
               atomically:YES
                 encoding:NSUTF8StringEncoding
                    error:&error];
    
    return filePath;
}

- (NSString *)exportMTL:(NSString *)filename {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:[filename stringByAppendingString:@".mtl"]];
    
    NSString *contents = @"# Modeled on iPhone\n\n# List of materials\n";
    NSError *error;
    
    for (int i = 0; i < 4; i++) {
        contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\nnewmtl material%d", i]];
        contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\n\tNs %d", 0]];
        contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\n\td %d", 1]];
        contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\n\tillum %d", 2]];
        contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\n\tKd %f %f %f", 0.8, 0.8, 0.8]];
        contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\n\tKs %f %f %f", 0.0, 0.0, 0.0]];
        contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\n\tKa %f %f %f", 0.2, 0.2, 0.2]];
        contents = [contents stringByAppendingString:[NSString stringWithFormat:@"\n\tmap_Kd texture%d.jpg\n", i + 1]];
    }
    
    NSLog(contents);
    
    [contents writeToFile:filePath
               atomically:YES
                 encoding:NSUTF8StringEncoding
                    error:&error];
    
    return filePath;
}

- (NSString *)exportZIP:(NSString *)filename items:(NSArray *)items {
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:[filename stringByAppendingString:@".zip"]];
    
    [SSZipArchive createZipFileAtPath:filePath withFilesAtPaths:items];
    
    return filePath;
}

- (int)getTotalIndices {
    return self.totalIndices;
}

- (void)takeScreenshot {
    NSLog(@"Now switching to another controller");
    
    //self.metalLayer nextDrawable
    
    /*id<CAMetalDrawable> lastDrawable = [self.renderer getDrawable];
    if (lastDrawable == nil) {
        NSLog(@"Last drawable Nil");
    }*/
    
    /*id<MTLTexture> metalTexture = [self.renderer getDrawable];//[lastDrawable texture];
    
    int width = (int)[metalTexture width];
    int height = (int)[metalTexture height];
    int rowBytes = width * 4;
    int selfturesize = width * height * 4;
    
    void *p = malloc(selfturesize);
    
    
    [metalTexture getBytes:p bytesPerRow:rowBytes fromRegion:MTLRegionMake2D(0, 0, width, height) mipmapLevel:0];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(nil, p, selfturesize, nil);
    CGImageRef cgImageRef = CGImageCreate(width, height, 8, 32, rowBytes, colorSpace, bitmapInfo, provider, nil, true, (CGColorRenderingIntent)kCGRenderingIntentDefault);
    
    UIImage *getImage = [UIImage imageWithCGImage:cgImageRef];
    CFRelease(cgImageRef);
    free(p);
    
    NSData *pngData = UIImagePNGRepresentation(getImage);
    UIImage *pngImage = [UIImage imageWithData:pngData];*/
    
    //UIImageWriteToSavedPhotosAlbum(pngImage, self, @selector(completeSavedImage:didFinishSavingWithError:contextInfo:), nil);
    
    //UIImage *image = [UIImage imageWithData:[chart getImage]];
    
    [Export exportOBJWithModelName:@"iphone_app_export_obj_3"];
    //[Export exportOBJ:modelName @"fgfg"];
    //[Export exportOBJ:@"hfhf"];
    //Export.exportOBJ:@"iphone_app_export_obj_3";
    NSString *filename = @"iphone_app_export_obj_3";
    NSString *objFilename = [self exportOBJ:filename];
    NSString *mtlFilename = [self exportMTL:filename];
    NSString *zipFilename = [self exportZIP:filename items:@[objFilename, mtlFilename]];
    
    // check for the error
    
    NSURL *zipUrl =  [NSURL fileURLWithPath:zipFilename];
    
    if (zipUrl == nil) {
        NSLog(@"URL nil");
    }
    
    //dispatch_async(dispatch_get_main_queue(), ^{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[zipUrl] applicationActivities:nil];
    
    activityViewController.excludedActivityTypes = @[];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        activityViewController.popoverPresentationController.sourceView = self.mainView.view;
        activityViewController.popoverPresentationController.sourceRect = CGRectMake(self.mainView.view.bounds.size.width/2, self.mainView.view.bounds.size.height/4, 0, 0);
    }
    
    //dispatch_async(dispatch_get_main_queue(), ^{
        [self.mainView presentViewController:activityViewController animated:true completion:nil];
    //});
    //});
    //[self.mainView presentViewController:activityViewController animated:true completion:nil];
    
    //[self.renderer.drawa]
    
    
    /*UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(0, 50, 320, 320)];
    
    CGRect screenRect = self.bounds;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillRect(context, screenRect);
    
    [self.metal renderInContext:context];
    
    UIImage *metalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (metalImage == nil) {
        NSLog(@"Metal image Nil");
    }
    
    UIImage* serverImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString: @"https://upload.wikimedia.org/wikipedia/commons/6/63/Strokkur_geyser_eruption%2C_close-up_view.jpg"]]];
    
    dot.image = serverImage;
    
    if (serverImage == nil) {
        NSLog(@"Nil");
    }*/
    
    
    
    //UIImageWriteToSavedPhotosAlbum(metalImage, self, @selector(completeSavedImage:didFinishSavingWithError:contextInfo:), nil);
    //UIImageWriteToSavedPhotosAlbum(serverImage, self, @selector(completeSavedImage:didFinishSavingWithError:contextInfo:), nil);
    
    //[self.view addSubview:dot];
    //[controller.view addSubview:dot];
    
    /*[self addChildViewController:controller];
    [controller didMoveToParentViewController:self];
    [controller.view setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    [self.view addSubview:controller.view];
    controller.view.backgroundColor = [UIColor whiteColor];
    
    UITextField* textField = [[UITextField alloc]initWithFrame:CGRectMake(100.0, 100.0, 200, 30.0)];
    textField.borderStyle = UITextBorderStyleRoundedRect;*/
    
    //UIImageView *dot =[[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 200, 200)];
    //dot.image=[UIImage imageNamed:@"sampler.jpg"];
    //[controller.view addSubview:dot];
    
    //[controller.view addSubview:textField];
}

- (void)setView:(UIViewController *)view {
    [self.renderer setView:view];
    self.mainView = view;
}

- (void)importOBJ:(int)red green:(int)green blue:(int)blue {
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"teapot" withExtension:@"obj"];
    OBJModel *teapot = [[OBJModel alloc] initWithContentsOfURL:modelURL];
    OBJGroup *group = [teapot groupAtIndex:1];
    
    for (int i = 0; i < group->vertexCount; i++) {
        group->vertices[i].customColor = {static_cast<float>((float) red / 255.0), static_cast<float>((float) green / 255.0), static_cast<float>((float) blue / 255.0)};
        
        self.bigVertices[i + self.totalIndices] = group->vertices[i];
        
        self.bigLineVertices[i + self.totalIndices] = group->vertices[i];
        self.bigLineVertices[i + self.totalIndices].customColor = {0, 0, 0};
    }
    for (int i = 0; i < group->indexCount; i++) {
        self.bigIndices[i + self.totalIndices] = group->indices[i];
    }
    for (int i = 0; i < group->indexCount / 3; i++) {
        self.bigLineIndices[i * 6 + 0 + self.totalIndices * 2] = i * 3 + self.totalIndices;
        self.bigLineIndices[i * 6 + 1 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 2 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        self.bigLineIndices[i * 6 + 3 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 4 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        self.bigLineIndices[i * 6 + 5 + self.totalIndices * 2] = i * 3 + self.totalIndices;
    }
    
    //NSLog(@"VERTICES %zu", group->vertexCount);
    //NSLog(@"INDICES %zu", group->indexCount);
    
    self.totalIndices += (int) group->indexCount;
    //self.bigIndices[i + self.totalIndices] = i + self.totalIndices;
    
    //self.bigVertices[i + self.totalIndices].customColor = {static_cast<float>((float) red / 255.0), static_cast<float>((float) green / 255.0), static_cast<float>((float) blue / 255.0)};
    //self.bigVertices[i + self.totalIndices].position = position[i];
    
    //self.vertexBuffer = [self.renderer newBufferWithBytes:baseGroup->vertices           length:sizeof(Vertex) * baseGroup->vertexCount];
    //self.indexBuffer = [self.renderer newBufferWithBytes:baseGroup->indices          length:sizeof(IndexType) * baseGroup->indexCount];
}

- (void)removeFace:(int)offset nth:(int)nth {
    int nthOffset = nth * 6;
    for (int i = offset + nthOffset; i < self.totalIndices; i++) {
        self.bigVertices[i] = self.bigVertices[i + 6];
        self.bigIndices[i] = self.bigIndices[i + 6] - 6;
        
        self.bigLineVertices[i] = self.bigLineVertices[i + 6];
        self.bigLineIndices[i] = self.bigLineIndices[i + 2] - 2;
    }
    self.totalIndices -= 6;
    
    for (int i = offset + nth * 2; i < self.totalIndices / 3; i++) {
        self.bigLineIndices[i * 6 + 0 + self.totalIndices * 2] = i * 3 + self.totalIndices;
        self.bigLineIndices[i * 6 + 1 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 2 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
        self.bigLineIndices[i * 6 + 3 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        
        self.bigLineIndices[i * 6 + 4 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
        self.bigLineIndices[i * 6 + 5 + self.totalIndices * 2] = i * 3 + self.totalIndices;
    }
}

- (void)cloneObject:(int)offset length:(int)length xTranslate:(float)xTranslate yTranslate:(float)yTranslate zTranslate:(float)zTranslate {
    for (int i = offset; i < offset + length; i++) {
        self.bigVertices[i] = self.bigVertices[i - length];
        self.bigVertices[i].position.x += xTranslate;
        self.bigVertices[i].position.y += yTranslate;
        self.bigVertices[i].position.z += zTranslate;
        
        self.bigIndices[i] = i;
        
        self.bigLineVertices[i] = self.bigLineVertices[i - length];
        self.bigLineVertices[i].position.x += xTranslate;
        self.bigLineVertices[i].position.y += yTranslate;
        self.bigLineVertices[i].position.z += zTranslate;
    }
    
    self.totalIndices += length;
}

- (void)rotateObjectX:(int)offset length:(int)length xAngle:(float)xAngle {
    float xMin = self.bigVertices[offset].position.x, xMax = self.bigVertices[offset].position.x;
    float zMin = self.bigVertices[offset].position.z, zMax = self.bigVertices[offset].position.z;
    
    for (int i = offset; i < offset + length; i++) {
        if (self.bigVertices[i].position.x < xMin) {
            xMin = self.bigVertices[i].position.x;
        }
        if (self.bigVertices[i].position.x > xMax) {
            xMax = self.bigVertices[i].position.x;
        }
        if (self.bigVertices[i].position.z < zMin) {
            zMin = self.bigVertices[i].position.z;
        }
        if (self.bigVertices[i].position.z > zMax) {
            zMax = self.bigVertices[i].position.z;
        }
    }
    NSLog(@"x min = %f", xMin);
    NSLog(@"x max = %f", xMax);
    NSLog(@"z min = %f", zMin);
    NSLog(@"z max = %f", zMax);
    
    float xCenter = (xMax + xMin) / 2.0f;
    float zCenter = (zMax + zMin) / 2.0f;
    
    NSLog(@"x center = %f", xCenter);
    NSLog(@"z center = %f", zCenter);
    
    
    
    
    for (int i = offset; i < offset + length; i++) {
    
        float x = self.bigVertices[i].position.x - xCenter;
        float z = -(self.bigVertices[i].position.z - zCenter);
    
        //NSLog(@"X = %f", x);
        //NSLog(@"Z = %f", z);
    
        float radius = sqrt(x * x + z * z);
        if (radius == 0.0f) {
            continue;
        }
        
        if (x >= 0.0f && z >= 0.0f) {
            float tg = z / x;
            float angle = atan(tg) / (M_PI / 180) + xAngle;
        
            self.bigVertices[i].position.x = cos(angle * M_PI / 180) * radius + xCenter;
            self.bigVertices[i].position.z = -(sin(angle * M_PI / 180) * radius - zCenter);
        
            //NSLog(@"X = %f", self.bigVertices[i].position.x);
            //NSLog(@"Z = %f", self.bigVertices[i].position.z);
        } else if (x < 0.0f && z >= 0.0f) {
            float tg = z / x;
            float angle = atan(tg) / (M_PI / 180) + 180 + xAngle;
        
            self.bigVertices[i].position.x = cos(angle * M_PI / 180) * radius + xCenter;
            self.bigVertices[i].position.z = -(sin(angle * M_PI / 180) * radius - zCenter);
        
            //NSLog(@"X = %f", self.bigVertices[i].position.x);
            //NSLog(@"Z = %f", self.bigVertices[i].position.z);
        } else if (x < 0.0f && z < 0.0f) {
            float tg = z / x;
            float angle = atan(tg) / (M_PI / 180) + 180 + xAngle;
        
            self.bigVertices[i].position.x = cos(angle * M_PI / 180) * radius + xCenter;
            self.bigVertices[i].position.z = -(sin(angle * M_PI / 180) * radius - zCenter);
        
            //NSLog(@"X = %f", self.bigVertices[i].position.x);
            //NSLog(@"Z = %f", self.bigVertices[i].position.z);
        } else {
            float tg = z / x;
            float angle = atan(tg) / (M_PI / 180) + xAngle;
        
            self.bigVertices[i].position.x = cos(angle * M_PI / 180) * radius + xCenter;
            self.bigVertices[i].position.z = -(sin(angle * M_PI / 180) * radius - zCenter);
        
            //NSLog(@"X = %f", self.bigVertices[i].position.x);
            //NSLog(@"Z = %f", self.bigVertices[i].position.z);
        }
    
        self.bigLineVertices[i].position = self.bigVertices[i].position;
    }
}

- (void)rotateObjectZ:(int)offset length:(int)length zAngle:(float)zAngle {
    float yMin = self.bigVertices[offset].position.y, yMax = self.bigVertices[offset].position.y;
    float zMin = self.bigVertices[offset].position.z, zMax = self.bigVertices[offset].position.z;
    
    for (int i = offset; i < offset + length; i++) {
        if (self.bigVertices[i].position.y < yMin) {
            yMin = self.bigVertices[i].position.y;
        }
        if (self.bigVertices[i].position.y > yMax) {
            yMax = self.bigVertices[i].position.y;
        }
        if (self.bigVertices[i].position.z < zMin) {
            zMin = self.bigVertices[i].position.z;
        }
        if (self.bigVertices[i].position.z > zMax) {
            zMax = self.bigVertices[i].position.z;
        }
    }
    NSLog(@"y min = %f", yMin);
    NSLog(@"y max = %f", yMax);
    NSLog(@"z min = %f", zMin);
    NSLog(@"z max = %f", zMax);
    
    float yCenter = (yMax + yMin) / 2.0f;
    float zCenter = (zMax + zMin) / 2.0f;
    
    NSLog(@"y center = %f", yCenter);
    NSLog(@"z center = %f", zCenter);
    
    
    
    
    for (int i = offset; i < offset + length; i++) {
        
        float y = self.bigVertices[i].position.y - yCenter;
        float z = -(self.bigVertices[i].position.z - zCenter);
        
        //NSLog(@"Y = %f", y);
        //NSLog(@"Z = %f", z);
        
        float radius = sqrt(y * y + z * z);
        if (radius == 0.0f) {
            continue;
        }
        
        if (y >= 0.0f && z >= 0.0f) {
            float tg = z / y;
            float angle = atan(tg) / (M_PI / 180) + zAngle;
            
            self.bigVertices[i].position.y = cos(angle * M_PI / 180) * radius + yCenter;
            self.bigVertices[i].position.z = -(sin(angle * M_PI / 180) * radius - zCenter);
            
            //NSLog(@"Y = %f", self.bigVertices[i].position.y);
            //NSLog(@"Z = %f", self.bigVertices[i].position.z);
        } else if (y < 0.0f && z >= 0.0f) {
            float tg = z / y;
            float angle = atan(tg) / (M_PI / 180) + 180 + zAngle;
            
            self.bigVertices[i].position.y = cos(angle * M_PI / 180) * radius + yCenter;
            self.bigVertices[i].position.z = -(sin(angle * M_PI / 180) * radius - zCenter);
            
            //NSLog(@"Y = %f", self.bigVertices[i].position.y);
            //NSLog(@"Z = %f", self.bigVertices[i].position.z);
        } else if (y < 0.0f && z < 0.0f) {
            float tg = z / y;
            float angle = atan(tg) / (M_PI / 180) + 180 + zAngle;
            
            self.bigVertices[i].position.y = cos(angle * M_PI / 180) * radius + yCenter;
            self.bigVertices[i].position.z = -(sin(angle * M_PI / 180) * radius - zCenter);
            
            //NSLog(@"Y = %f", self.bigVertices[i].position.y);
            //NSLog(@"Z = %f", self.bigVertices[i].position.z);
        } else {
            float tg = z / y;
            float angle = atan(tg) / (M_PI / 180) + zAngle;
            
            self.bigVertices[i].position.y = cos(angle * M_PI / 180) * radius + yCenter;
            self.bigVertices[i].position.z = -(sin(angle * M_PI / 180) * radius - zCenter);
            
            //NSLog(@"Y = %f", self.bigVertices[i].position.y);
            //NSLog(@"Z = %f", self.bigVertices[i].position.z);
        }
        
        self.bigLineVertices[i].position = self.bigVertices[i].position;
    }
}

- (void)translateObject:(int)offset length:(int)length xTranslate:(float)xTranslate yTranslate:(float)yTranslate zTranslate:(float)zTranslate {
    for (int i = offset; i < offset + length; i++) {
        self.bigVertices[i].position.x += xTranslate;
        self.bigVertices[i].position.y += yTranslate;
        self.bigVertices[i].position.z += zTranslate;
        
        self.bigLineVertices[i].position = self.bigVertices[i].position;
    }
}

- (void)translateVertex:(int)offset length:(int)length x:(float)x y:(float)y z:(float)z xTranslate:(float)xTranslate yTranslate:(float)yTranslate zTranslate:(float)zTranslate debug:(BOOL)debug {
    for (int i = offset; i < offset + length; i++) {
        float diff = sqrt(pow(self.bigVertices[i].position.x - x, 2) + pow(self.bigVertices[i].position.y - y, 2) + pow(self.bigVertices[i].position.z - z, 2));
        
        if (debug) {
            NSLog(@"DIFF %d %e", i, diff);
            NSLog(@"%d %f %f %f ", i, self.bigVertices[i].position.x, self.bigVertices[i].position.y, self.bigVertices[i].position.z);
            NSLog(@"diff %d %e %e %e ", i, self.bigVertices[i].position.x - x, self.bigVertices[i].position.y - y, self.bigVertices[i].position.z - z);
        }
        //if (self.bigVertices[i].position.x == x && self.bigVertices[i].position.y == y && self.bigVertices[i].position.z == z) {
        if (diff <= pow(10, -6)) {
            NSLog(@"jhbjnnlknlknklnlknknknknknknknknknknknknkn");
            self.bigVertices[i].position.x += xTranslate;
            self.bigVertices[i].position.y += yTranslate;
            self.bigVertices[i].position.z += zTranslate;
            
            self.bigLineVertices[i].position = self.bigVertices[i].position;
        }
    }
}

- (void)scaleObject:(int)offset length:(int)length xScale:(float)xScale yScale:(float)yScale zScale:(float)zScale {
    for (int i = offset; i < offset + length; i++) {
        self.bigVertices[i].position.x *= xScale;
        self.bigVertices[i].position.y *= yScale;
        self.bigVertices[i].position.z *= zScale;
        
        self.bigLineVertices[i].position = self.bigVertices[i].position;
    }
}

- (void)setFaceTexture:(int)offset nth:(int)nth texNth:(int)texNth {
    int nthOffset = nth * 6;
    int i = offset + nthOffset;
        /*// top
         // 8
         
         position[24] = {x + width, y + height, z, 1.0};
         position[26] = {x, y + height, z - depth, 1.0};
         position[25] = {x + width, y + height, z - depth, 1.0};
         
         // 9
         
         position[27] = {x, y + height, z, 1.0};
         position[28] = {x + width, y + height, z, 1.0};
         position[29] = {x, y + height, z - depth, 1.0};*/
    
    switch (nth) {
        case 4:
            self.bigVertices[i].texCoord = {static_cast<float>(texNth), 1.0, 1.0, 1};//
            self.bigVertices[i + 1].texCoord = {static_cast<float>(texNth), 1.0, 0.0, 1};
            self.bigVertices[i + 2].texCoord = {static_cast<float>(texNth), 0.0, 0.0, 1};
            
            self.bigVertices[i + 3].texCoord = {static_cast<float>(texNth), 0.0, 1.0, 1};
            self.bigVertices[i + 4].texCoord = {static_cast<float>(texNth), 1.0, 1.0, 1};
            self.bigVertices[i + 5].texCoord = {static_cast<float>(texNth), 0.0, 0.0, 1};
            break;
        default:
            self.bigVertices[i].texCoord = {static_cast<float>(texNth), 0.0, 1.0, 1};
            self.bigVertices[i + 1].texCoord = {static_cast<float>(texNth), 1.0, 1.0, 1};
            self.bigVertices[i + 2].texCoord = {static_cast<float>(texNth), 1.0, 0.0, 1};
            
            self.bigVertices[i + 3].texCoord = {static_cast<float>(texNth), 1.0, 0.0, 1};
            self.bigVertices[i + 4].texCoord = {static_cast<float>(texNth), 0.0, 0.0, 1};
            self.bigVertices[i + 5].texCoord = {static_cast<float>(texNth), 0.0, 1.0, 1};
    }
        
    
        
    
    
}

- (void)demo1 {
    // Compound object demo
    
    int a = [self appendCube:-0.25 y:-0.25 z:0.15 width:0.5 height:0.2 depth:0.5 red:255 green:255 blue:128];
    [self setFaceTexture:a nth:0 texNth:3];
    [self setFaceTexture:a nth:1 texNth:3];
    [self setFaceTexture:a nth:2 texNth:3];
    [self setFaceTexture:a nth:3 texNth:3];
    [self removeFace:a nth:4];
    [self removeFace:a nth:4];
    
    int b = [self appendCube:-0.3 y:-0.25 z:0.15 width:0.05 height:0.2 depth:0.1 red:255 green:255 blue:128];
    [self setFaceTexture:b nth:0 texNth:3];
    [self setFaceTexture:b nth:1 texNth:3];
    [self setFaceTexture:b nth:2 texNth:3];
    [self setFaceTexture:b nth:3 texNth:3];
    [self removeFace:b nth:4];
    [self removeFace:b nth:4];
    
    int c = [self appendCube:-0.1 y:-0.25 z:0.25 width:0.35 height:0.2 depth:0.1 red:255 green:255 blue:128];
    [self setFaceTexture:c nth:0 texNth:3];
    [self setFaceTexture:c nth:1 texNth:3];
    [self setFaceTexture:c nth:2 texNth:3];
    [self setFaceTexture:c nth:3 texNth:3];
    [self removeFace:c nth:4];
    [self removeFace:c nth:4];
    
    int d = [self appendCube:0.05 y:-0.25 z:0.3 width:0.1 height:0.2 depth:0.05 red:255 green:255 blue:128];
    [self setFaceTexture:d nth:0 texNth:3];
    [self setFaceTexture:d nth:1 texNth:3];
    [self setFaceTexture:d nth:2 texNth:3];
    [self setFaceTexture:d nth:3 texNth:3];
    [self removeFace:d nth:4];
    [self removeFace:d nth:4];
    
    int e = [self appendCube:0.35 y:-0.25 z:0.05 width:0.01 height:0.2 depth:0.01 red:255 green:255 blue:128];
    [self setFaceTexture:e nth:0 texNth:3];
    [self setFaceTexture:e nth:1 texNth:3];
    [self setFaceTexture:e nth:2 texNth:3];
    [self setFaceTexture:e nth:3 texNth:3];
    [self removeFace:e nth:4];
    [self removeFace:e nth:4];
    
    int f = [self appendCube:0.35 y:-0.25 z:-0.05 width:0.01 height:0.2 depth:0.01 red:255 green:255 blue:128];
    [self setFaceTexture:f nth:0 texNth:3];
    [self setFaceTexture:f nth:1 texNth:3];
    [self setFaceTexture:f nth:2 texNth:3];
    [self setFaceTexture:f nth:3 texNth:3];
    [self removeFace:f nth:4];
    [self removeFace:f nth:4];
    
    int g = [self appendCube:-0.26 y:-0.05 z:0.16 width:0.52 height:0.05 depth:0.52 red:255 green:0 blue:255];
    [self translateVertex:g length:36 x:-0.26 y:-0.05 + 0.05 z:0.16 xTranslate:0.02 yTranslate:0.0 zTranslate:-0.02 debug:false];
    [self translateVertex:g length:36 x:-0.26 + 0.52 y:-0.05 + 0.05 z:0.16 xTranslate:-0.02 yTranslate:0.0 zTranslate:-0.02 debug:false];
    [self translateVertex:g length:36 x:-0.26 + 0.52 y:0.0 z:-0.36 xTranslate:-0.02 yTranslate:0.0 zTranslate:0.02 debug:false];
    [self translateVertex:g length:36 x:-0.26 y:0.0 z:-0.36 xTranslate:0.02 yTranslate:0.0 zTranslate:0.02 debug:false];
    [self setFaceTexture:g nth:4 texNth:1];
    [self setFaceTexture:g nth:0 texNth:2];
    [self setFaceTexture:g nth:1 texNth:2];
    [self setFaceTexture:g nth:2 texNth:2];
    [self setFaceTexture:g nth:3 texNth:2];
    [self setFaceTexture:g nth:5 texNth:1];
    
    int h = [self appendCube:-0.31 y:-0.05 z:0.16 width:0.05 height:0.05 depth:0.12 red:255 green:0 blue:255];
    [self translateVertex:h length:36 x:-0.31 y:-0.05 + 0.05 z:0.16 xTranslate:0.02 yTranslate:0.0 zTranslate:-0.02 debug:false];
    [self translateVertex:h length:36 x:-0.31 y:-0.05 + 0.05 z:0.16 - 0.12 xTranslate:0.02 yTranslate:0.0 zTranslate:0.02 debug:false];
    [self translateVertex:h length:36 x:-0.31 + 0.05 y:-0.05 + 0.05 z:0.16 xTranslate:0.02 yTranslate:0.0 zTranslate:-0.02 debug:false];
    [self translateVertex:h length:36 x:-0.31 + 0.05 y:-0.05 + 0.05 z:0.16 - 0.12 xTranslate:0.02 yTranslate:0.0 zTranslate:0.02 debug:false];
    [self setFaceTexture:h nth:4 texNth:1];
    [self setFaceTexture:h nth:0 texNth:2];
    [self setFaceTexture:h nth:1 texNth:2];
    [self setFaceTexture:h nth:2 texNth:2];
    [self setFaceTexture:h nth:3 texNth:2];
    [self setFaceTexture:h nth:5 texNth:1];
    
    int k = [self appendCube:-0.11 y:-0.05 z:0.26 width:0.37 height:0.05 depth:0.1 red:255 green:0 blue:255];
    [self translateVertex:k length:36 x:-0.11 y:-0.05 + 0.05 z:0.26 xTranslate:0.02 yTranslate:0.0 zTranslate:-0.02 debug:false];
    [self translateVertex:k length:36 x:-0.11 y:-0.05 + 0.05 z:0.26 - 0.1 xTranslate:0.02 yTranslate:0.0 zTranslate:-0.02 debug:false];
    [self translateVertex:k length:36 x:-0.11 + 0.37 y:-0.05 + 0.05 z:0.26 xTranslate:-0.02 yTranslate:0.0 zTranslate:-0.02 debug:false];
    [self translateVertex:k length:36 x:-0.11 + 0.37 y:-0.05 + 0.05 z:0.26 - 0.1 xTranslate:-0.02 yTranslate:0.0 zTranslate:-0.02 debug:false];
    [self setFaceTexture:k nth:4 texNth:1];
    [self setFaceTexture:k nth:0 texNth:2];
    [self setFaceTexture:k nth:1 texNth:2];
    [self setFaceTexture:k nth:2 texNth:2];
    [self setFaceTexture:k nth:3 texNth:2];
    [self setFaceTexture:k nth:5 texNth:1];
    
    int l = [self appendCube:0.04 y:-0.05 z:0.31 width:0.12 height:0.05 depth:0.05 red:255 green:0 blue:255];
    [self translateVertex:l length:36 x:0.04 y:-0.05 + 0.05 z:0.31 xTranslate:0.02 yTranslate:0.0 zTranslate:-0.02 debug:false];
    [self translateVertex:l length:36 x:0.04 y:-0.05 + 0.05 z:0.31 - 0.05 xTranslate:0.02 yTranslate:0.0 zTranslate:-0.02 debug:false];
    [self translateVertex:l length:36 x:0.04 + 0.12 y:-0.05 + 0.05 z:0.31 xTranslate:-0.02 yTranslate:0.0 zTranslate:-0.02 debug:false];
    [self translateVertex:l length:36 x:0.04 + 0.12 y:-0.05 + 0.05 z:0.31 - 0.05 xTranslate:-0.02 yTranslate:0.0 zTranslate:-0.02 debug:false];
    [self setFaceTexture:l nth:4 texNth:1];
    [self setFaceTexture:l nth:0 texNth:2];
    [self setFaceTexture:l nth:1 texNth:2];
    [self setFaceTexture:l nth:3 texNth:2];
    [self setFaceTexture:l nth:5 texNth:1];
    
    int m = [self appendCube:0.26 y:-0.05 z:0.06 width:0.12 height:0.05 depth:0.12 red:255 green:0 blue:255];
    [self translateVertex:m length:36 x:0.26 y:-0.05 + 0.05 z:0.06 xTranslate:-0.02 yTranslate:0.0 zTranslate:-0.02 debug:false];
    [self translateVertex:m length:36 x:0.26 y:-0.05 + 0.05 z:0.06 - 0.12 xTranslate:-0.02 yTranslate:0.0 zTranslate:0.02 debug:false];
    [self translateVertex:m length:36 x:0.26 + 0.12 y:-0.05 + 0.05 z:0.06 xTranslate:-0.02 yTranslate:0.0 zTranslate:-0.02 debug:false];
    [self translateVertex:m length:36 x:0.26 + 0.12 y:-0.05 + 0.05 z:0.06 - 0.12 xTranslate:-0.02 yTranslate:0.0 zTranslate:0.02 debug:false];
    [self setFaceTexture:m nth:4 texNth:1];
    [self setFaceTexture:m nth:0 texNth:2];
    [self setFaceTexture:m nth:1 texNth:2];
    [self setFaceTexture:m nth:2 texNth:2];
    [self setFaceTexture:m nth:3 texNth:2];
    [self setFaceTexture:m nth:5 texNth:1];
    
    int compoundSize = self.totalIndices;
    [self translateObject:0 length:compoundSize xTranslate:0 yTranslate:0 zTranslate:-1];
    
    [self cloneObject:compoundSize length:compoundSize xTranslate:-0.6f yTranslate:0.0f zTranslate:0.8f];
    [self cloneObject:compoundSize * 2 length:compoundSize xTranslate:1.2f yTranslate:0.0f zTranslate:0.0f];
    
    
    [self rotateObjectX:compoundSize length:compoundSize xAngle:45];
    [self rotateObjectX:compoundSize * 2 length:compoundSize xAngle:-45];
    
    int n = [self appendCube:-1 y:-0.26 z:0.5 width:2.0 height:0.01 depth:2.0 red:200 green:200 blue:200];
    NSLog(@">>>>>>>>>>>>> %d", n);
    [self setFaceTexture:n nth:4 texNth:0];
    
    for (int i = n; i < self.totalIndices; i++) {
        NSLog(@"%d: %f %f %f %f", i, self.bigVertices[i].texCoord.x, self.bigVertices[i].texCoord.y, self.bigVertices[i].texCoord.z, self.bigVertices[i].texCoord.w);
    }
    
    [self scaleObject:0 length:self.totalIndices xScale:2 yScale:2 zScale:2];
    
    for (int i = 0; i < self.totalIndices / 3; i++) {
        self.bigLineIndices[i * 6 + 0] = i * 3;
        self.bigLineIndices[i * 6 + 1] = i * 3 + 1;
        
        self.bigLineIndices[i * 6 + 2] = i * 3 + 1;
        self.bigLineIndices[i * 6 + 3] = i * 3 + 2;
        
        self.bigLineIndices[i * 6 + 4] = i * 3 + 2;
        self.bigLineIndices[i * 6 + 5] = i * 3;
    }
}

- (int)appendCompoundRoof:(float)x y:(float)y z:(float)z width:(float)width lowerSegments:(int)lowerSegments {
    
    int lastIndices = self.totalIndices;
    
    float lowerHeight = 0.3, depth = 0.05, roofDepth = 0.6;
    
    float segmentWidth = width / lowerSegments;
    
    // front lower
    float centerY = lowerHeight / 2, centerZ = depth / 2;
    float radius = sqrt(pow(lowerHeight / 2, 2) + pow(depth / 2, 2));
    
    float tg = (lowerHeight / 2) / (-depth / 2);
    float angle = atan(tg) / (M_PI / 180) + 180;
    
    float lowerY = sin((angle + 30) * M_PI / 180.0) * radius;
    
    int frontLowerStart = self.totalIndices;
    for (int i = 0; i < lowerSegments; i++) {
        int start = [self appendCube:x + segmentWidth * i y:y z:z width:segmentWidth height:lowerHeight depth:depth red:0 green:128 blue:255];
        [self rotateObjectZ:start length:self.totalIndices - start zAngle:30];
    }
    
    [self translateObject:frontLowerStart length:self.totalIndices - frontLowerStart xTranslate:0 yTranslate:lowerY - lowerHeight / 2 zTranslate:0];//1.342404
    
    for (int i = frontLowerStart; i < self.totalIndices; i++) {
        NSLog(@"VERTEX %f %f %f", self.bigVertices[i].position.x, self.bigVertices[i].position.y, self.bigVertices[i].position.z);
    }//y max = 1.309808
    
    // back lower
    int backLowerStart = self.totalIndices;
    for (int i = 0; i < lowerSegments; i++) {
        int start = [self appendCube:x + segmentWidth * i y:y z:z - roofDepth + depth width:segmentWidth height:lowerHeight depth:depth red:0 green:128 blue:255];
        [self rotateObjectZ:start length:self.totalIndices - start zAngle:-30];
    }
    
    [self translateObject:backLowerStart length:self.totalIndices - backLowerStart xTranslate:0 yTranslate:lowerY - lowerHeight / 2 zTranslate:0];
    
    // upper
    float upperHeight = 0.255993843;
    
    tg = (lowerHeight / 2) / (depth / 2);
    angle = atan(tg) / (M_PI / 180);
    float upperY = sin((angle + 30) * M_PI / 180.0) * radius;
    float upperZ = cos((angle + 30) * M_PI / 180.0) * radius;//0.025 if no angle
    
    // upper front
    
    
    radius = sqrt(pow(upperHeight / 2, 2) + pow(depth / 2, 2));
    tg = (upperHeight / 2) / (-depth / 2);
    angle = atan(tg) / (M_PI / 180) + 180;
    
    float upperYlower = sin((angle + 60) * M_PI / 180.0) * radius;
    float upperZlower = cos((angle + 60) * M_PI / 180.0) * radius;
    
    tg = (upperHeight / 2) / (depth / 2);
    angle = atan(tg) / (M_PI / 180);
    
    upperHeight = sqrt(pow((depth / 2 - roofDepth / 2 - (upperZ + upperZlower)) / cos((angle + 60) * M_PI / 180.0), 2) - pow(depth / 2, 2)) * 2;
    
    int upperFront = [self appendCube:x y:y + lowerHeight - (lowerHeight / 2 - upperY) + lowerY - lowerHeight / 2 z:z width:width height:upperHeight depth:depth red:0 green:128 blue:255];
    for (int i = upperFront; i < self.totalIndices; i++) {
        NSLog(@"VERTEX %f %f %f", self.bigVertices[i].position.x, self.bigVertices[i].position.y, self.bigVertices[i].position.z);
    }
    [self rotateObjectZ:upperFront length:self.totalIndices - upperFront zAngle:60];
    
    
    
    
    
    
    
    float topZ = cos((angle + 60) * M_PI / 180.0) * radius + (upperZ + upperZlower);
    float topDiff = topZ - depth / 2;
    float centerDiff = roofDepth / 2 + topDiff;
    
    
    
    
    [self translateObject:upperFront length:self.totalIndices - upperFront xTranslate:0 yTranslate:upperYlower - upperHeight / 2 zTranslate:upperZ - depth / 2 + upperZlower + depth / 2];
    
    // upper back
    int upperBack = [self appendCube:x y:y + lowerHeight - (lowerHeight / 2 - upperY) + lowerY - lowerHeight / 2 z:z - roofDepth + depth width:width height:upperHeight depth:depth red:0 green:128 blue:255];
    [self rotateObjectZ:upperBack length:self.totalIndices - upperBack zAngle:-60];
    [self translateObject:upperBack length:self.totalIndices - upperBack xTranslate:0 yTranslate:upperYlower - upperHeight / 2 zTranslate:-(upperZ - depth / 2 + upperZlower + depth / 2)];
    
    
    //topDiff = -roofDepth / 2;
    //topZ - depth / 2 = -roofDepth / 2;
    //topZ = depth / 2 - roofDepth / 2;
    //cos((angle + 60) * M_PI / 180.0) * radius + (upperZ + upperZlower) = depth / 2 - roofDepth / 2;
    //cos((angle + 60) * M_PI / 180.0) * radius = depth / 2 - roofDepth / 2 - (upperZ + upperZlower);
    //radius = (depth / 2 - roofDepth / 2 - (upperZ + upperZlower)) / cos((angle + 60) * M_PI / 180.0);
    //sqrt(pow(upperHeight / 2, 2) + pow(depth / 2, 2)) = (depth / 2 - roofDepth / 2 - (upperZ + upperZlower)) / cos((angle + 60) * M_PI / 180.0);
    //pow(upperHeight / 2, 2) + pow(depth / 2, 2) = pow((depth / 2 - roofDepth / 2 - (upperZ + upperZlower)) / cos((angle + 60) * M_PI / 180.0), 2);
    //pow(upperHeight / 2, 2) = pow((depth / 2 - roofDepth / 2 - (upperZ + upperZlower)) / cos((angle + 60) * M_PI / 180.0), 2) - pow(depth / 2, 2);
    //upperHeight / 2 = sqrt(pow((depth / 2 - roofDepth / 2 - (upperZ + upperZlower)) / cos((angle + 60) * M_PI / 180.0), 2) - pow(depth / 2, 2));
    upperHeight = sqrt(pow((depth / 2 - roofDepth / 2 - (upperZ + upperZlower)) / cos((angle + 60) * M_PI / 180.0), 2) - pow(depth / 2, 2)) * 2;
    
    return lastIndices;
}

- (void)loadModel {
    
    self.totalIndices = 0;
    
    __unused int numberOfObjects = 1;
    self.bigIndices = (uint16_t*) malloc(sizeof(uint16_t) * 100000);
    
    self.bigLineIndices = (uint16_t*) malloc(sizeof(uint16_t) * 100000);
    
    //[self demo1];
    
    float widthA = 0.2, widthB = 0.1, currentY = -0.45;
    
    for (int i = 0; i < 5; i++) {
        float current = -1 - 0.6;
        for (int j = 0; j < 2; j++) {
            [self appendPlate:current y:currentY z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.1 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.1 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            current += 0.3;
        }
        NSLog(@"CURRENT = %f", current);
        currentY += 0.3;
    }
    int temp = self.totalIndices;
    float currentQ = -1 - 0.6;
    for (int j = 0; j < 2; j++) {
        [self appendPlate:currentQ y:-0.45 + 1.5 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentQ + 0.1 y:-0.45 + 1.5 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentQ + 0.2 y:-0.45 + 1.5 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        [self appendPlate:currentQ y:-0.45 + 1.5 + 0.1 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentQ + 0.1 y:-0.45 + 1.5 + 0.1 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentQ + 0.2 y:-0.45 + 1.5 + 0.1 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        [self appendPlate:currentQ y:-0.45 + 1.5 + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentQ + 0.1 y:-0.45 + 1.5 + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentQ + 0.2 y:-0.45 + 1.5 + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        currentQ += 0.3;
    }
    int temp2 = self.totalIndices - temp;
    [self translateVertex:temp length:temp2 x:-1 - 0.6 y:-0.45 + 1.5 + 0.2 + 0.1 z:0.25 xTranslate:0.1 yTranslate:0 zTranslate:0 debug:true];
    [self translateVertex:temp length:temp2 x:-1 y:-0.45 + 1.5 + 0.2 + 0.1 z:0.25 xTranslate:-0.1 yTranslate:0 zTranslate:0 debug:true];
    [self translateVertex:temp length:temp2 x:-1 y:-0.45 + 1.5 + 0.2 z:0.25 xTranslate:-0.05 yTranslate:0 zTranslate:0 debug:true];
    
    int objectZ = self.totalIndices;
    [self rotateObjectX:0 length:objectZ xAngle:-90];
    [self translateObject:0 length:objectZ xTranslate:0.3 yTranslate:0 zTranslate:-0.3];
    
    currentY = -0.45;
    for (int i = 0; i < 5; i++) {
        float current = -1;
        for (int j = 0; j < 4; j++) {
            [self appendPlate:current y:currentY z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.1 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.1 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            current += 0.3;
        }
        
        
        
        NSLog(@"CURRENT = %f", current);
        currentY += 0.3;
    }
    currentY = -0.45 + 1.5;
    float currentF = -1 + 0.3;
    for (int j = 0; j < 2; j++) {
        [self appendPlate:currentF y:currentY z:0.25 - 0.05 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.1 y:currentY z:0.25 - 0.05 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.2 y:currentY z:0.25 - 0.05 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        [self appendPlate:currentF y:currentY + 0.1 z:0.25 - 0.05 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.2 y:currentY + 0.1 z:0.25 - 0.05 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        [self appendPlate:currentF y:currentY + 0.2 z:0.25 - 0.05 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.1 y:currentY + 0.2 z:0.25 - 0.05 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.2 y:currentY + 0.2 z:0.25 - 0.05 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        currentF += 0.3;
    }
    
    currentY = -0.45;
    for (int i = 0; i < 6; i++) {
        float current = 0.2;
        for (int j = 0; j < 4; j++) {
            [self appendPlate:current y:currentY z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.1 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.1 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            current += 0.3;
        }
        NSLog(@"CURRENT = %f", current);
        currentY += 0.3;
    }
    
    int objectH = self.totalIndices;
    currentF = 0.2 - 0.3 + 0.15;
    currentY = -0.45 + 1.5;
    for (int j = 0; j < 1; j++) {
        [self appendPlate:currentF y:currentY z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.1 y:currentY z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.2 y:currentY z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        [self appendPlate:currentF y:currentY + 0.1 z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.1 y:currentY + 0.1 z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.2 y:currentY + 0.1 z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        [self appendPlate:currentF y:currentY + 0.2 z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.1 y:currentY + 0.2 z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.2 y:currentY + 0.2 z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        
    }
    [self rotateObjectX:objectH length:self.totalIndices - objectH xAngle:-90];
    
    objectH = self.totalIndices;
    currentF = 0.2 - 0.3 + 0.15;
    currentY = -0.45 + 1.8;
    for (int j = 0; j < 1; j++) {
        [self appendPlate:currentF y:currentY z:0.25 - 0.45 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.1 y:currentY z:0.25 - 0.45 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.2 y:currentY z:0.25 - 0.45 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        [self appendPlate:currentF y:currentY + 0.1 z:0.25 - 0.45 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.1 y:currentY + 0.1 z:0.25 - 0.45 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.2 y:currentY + 0.1 z:0.25 - 0.45 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        [self appendPlate:currentF y:currentY + 0.2 z:0.25 - 0.45 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.1 y:currentY + 0.2 z:0.25 - 0.45 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.2 y:currentY + 0.2 z:0.25 - 0.45 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        
    }
    [self rotateObjectX:objectH length:self.totalIndices - objectH xAngle:-90];
    
    currentF = 0.2;
    currentY = -0.45 + 1.8;
    for (int j = 0; j < 4; j++) {
        [self appendPlate:currentF y:currentY z:0.25 - 0.3 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.1 y:currentY z:0.25 - 0.3 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.2 y:currentY z:0.25 - 0.3 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        [self appendPlate:currentF y:currentY + 0.1 z:0.25 - 0.3 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.1 y:currentY + 0.1 z:0.25 - 0.3 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.2 y:currentY + 0.1 z:0.25 - 0.3 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        [self appendPlate:currentF y:currentY + 0.2 z:0.25 - 0.3 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.1 y:currentY + 0.2 z:0.25 - 0.3 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.2 y:currentY + 0.2 z:0.25 - 0.3 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        currentF += 0.3;
    }
    
    objectH = self.totalIndices;
    currentF = 0.2;
    currentY = -0.45 + 1.8 - 0.15;
    for (int j = 0; j < 4; j++) {
        [self appendPlate:currentF y:currentY z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.1 y:currentY z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.2 y:currentY z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        [self appendPlate:currentF y:currentY + 0.1 z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.1 y:currentY + 0.1 z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.2 y:currentY + 0.1 z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        [self appendPlate:currentF y:currentY + 0.2 z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.1 y:currentY + 0.2 z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        [self appendPlate:currentF + 0.2 y:currentY + 0.2 z:0.25 - 0.15 width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
        
        currentF += 0.3;
    }
    [self rotateObjectZ:objectH length:self.totalIndices - objectH zAngle:90];
    
    int objectB = self.totalIndices;
    
    currentY = -0.45;
    for (int i = 0; i < 9; i++) {
        float current = 1.4;
        for (int j = 0; j < 2; j++) {
            [self appendPlate:current y:currentY z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.1 y:currentY z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.2 y:currentY z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            
            [self appendPlate:current y:currentY + 0.1 z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.1 y:currentY + 0.1 z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.1 z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            
            [self appendPlate:current y:currentY + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.1 y:currentY + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            
            current += 0.3;
        }
        NSLog(@"CURRENT = %f", current);
        currentY += 0.3;
    }
    int objectC = self.totalIndices;
    [self rotateObjectX:objectB length:objectC - objectB xAngle:-90];
    [self translateObject:objectB length:objectC - objectB xTranslate:-0.3 yTranslate:0 zTranslate:-0.3];
    
    currentY = -0.45;
    for (int i = 0; i < 9; i++) {
        float current = 1.4;
        for (int j = 0; j < 1; j++) {
            [self appendPlate:current y:currentY z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.1 y:currentY z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.2 y:currentY z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            
            [self appendPlate:current y:currentY + 0.1 z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            if (i == 0 || i == 8) {
                [self appendPlate:current + 0.1 y:currentY + 0.1 z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            }
            [self appendPlate:current + 0.2 y:currentY + 0.1 z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            
            [self appendPlate:current y:currentY + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.1 y:currentY + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.2 z:0.25 width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            
            current += 0.3;
        }
        NSLog(@"CURRENT = %f", current);
        currentY += 0.3;
    }
    
    int roofStart = self.totalIndices;
    [self appendCompoundRoof:-1.05 y:-0.45 + 1.5 z:0.25 width:0.05 lowerSegments:1];
    int roofa = [self appendCompoundRoof:-1 y:-0.45 + 1.5 z:0.25 width:1.2 lowerSegments:4];
    for (int i = 0; i < 12; i++) {
        [self removeFace:roofa nth:6];
    }
    
    
    int roofb = [self appendCompoundRoof:0.2 y:-0.45 + 1.8 z:0.25 width:1.2 lowerSegments:4];
    for (int i = 0; i < 24; i++) {
        [self removeFace:roofb nth:0];
    }
    for (int i = 0; i < 6; i++) {
        [self removeFace:roofb nth:24];
    }
    
    int roofEnd = self.totalIndices;
    //[self cloneObject:roofEnd length:roofEnd - roofStart xTranslate:5.15 yTranslate:0 zTranslate:-0.675];
    //[self rotateObjectX:roofEnd length:roofEnd - roofStart xAngle:180];
    
    
    
    int objectA = self.totalIndices;
    [self rotateObjectX:0 length:roofEnd xAngle:30];
    
    for (int i = objectA - 1; i >= objectA - 200; i--) {
        NSLog(@"%f %f", self.bigVertices[i].position.x, self.bigVertices[i].position.z);
    }
    //[self translateObject:0 length:objectA xTranslate:0.22 yTranslate:0 zTranslate:0.825];
    
    int objectRight = self.totalIndices;
    
    float z = -0.465192;//5192f;
    
    currentY = -0.45;
    for (int i = 0; i < 9; i++) {
        float current = 1.669134f;
        for (int j = 0; j < 3; j++) {
            [self appendPlate:current y:currentY z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.1 y:currentY z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.2 y:currentY z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            
            [self appendPlate:current y:currentY + 0.1 z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.1 z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            
            [self appendPlate:current y:currentY + 0.2 z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.1 y:currentY + 0.2 z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.2 z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            
            current += 0.3;
        }
        NSLog(@"CURRENT = %f", current);
        currentY += 0.3;
    }
    
    int objectD = self.totalIndices;
    
    currentY = -0.45;
    for (int i = 0; i < 9; i++) {
        float current = 2.569134f;
        for (int j = 0; j < 1; j++) {
            [self appendPlate:current y:currentY z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.1 y:currentY z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.2 y:currentY z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            
            [self appendPlate:current y:currentY + 0.1 z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            if (i < 1 || i > 5) {
                [self appendPlate:current + 0.1 y:currentY + 0.1 z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            }
            [self appendPlate:current + 0.2 y:currentY + 0.1 z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            
            [self appendPlate:current y:currentY + 0.2 z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.1 y:currentY + 0.2 z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.2 z:z width:0.1 height:0.1 red:255 green:255 blue:0 alpha:1];
            
            current += 0.3;
        }
        NSLog(@"CURRENT = %f", current);
        currentY += 0.3;
    }
    
    int objectE = self.totalIndices;
    [self rotateObjectX:objectD length:objectE - objectD xAngle:90];
    [self translateObject:objectD length:objectE - objectD xTranslate:-0.15 yTranslate:0 zTranslate:-0.15];
    
    currentY = -0.45 + 0.3;
    for (int i = 0; i < 5; i++) {
        float current = 2.569134f;
        for (int j = 0; j < 1; j++) {
            [self appendPlate:current y:currentY z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.1 z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.1 z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.2 z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY + 0.2 z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.2 z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            
            current += 0.3;
        }
        NSLog(@"CURRENT = %f", current);
        currentY += 0.3;
    }
    
    int objectF = self.totalIndices;
    
    currentY = -0.45 + 0.3 + 1.5;
    for (int i = 0; i < 1; i++) {
        float current = 2.569134f;
        for (int j = 0; j < 1; j++) {
            [self appendPlate:current y:currentY z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.1 z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY + 0.1 z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.1 z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.2 z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY + 0.2 z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.2 z:z width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            
            current += 0.3;
        }
        NSLog(@"CURRENT = %f", current);
        currentY += 0.3;
    }
    
    int objectG = self.totalIndices;
    [self rotateObjectZ:objectF length:objectG - objectF zAngle:90];
    [self translateObject:objectF length:objectG - objectF xTranslate:0 yTranslate:-0.15 zTranslate:-0.15];
    
    [self cloneObject:self.totalIndices length:objectG - objectF xTranslate:0 yTranslate:-0.3 zTranslate:0];
    [self cloneObject:self.totalIndices length:objectG - objectF xTranslate:0 yTranslate:-0.3 zTranslate:0];
    [self cloneObject:self.totalIndices length:objectG - objectF xTranslate:0 yTranslate:-0.3 zTranslate:0];
    [self cloneObject:self.totalIndices length:objectG - objectF xTranslate:0 yTranslate:-0.3 zTranslate:0];
    [self cloneObject:self.totalIndices length:objectG - objectF xTranslate:0 yTranslate:-0.3 zTranslate:0];
    
    currentY = -0.45 + 0.3;
    for (int i = 0; i < 5; i++) {
        float current = 2.569134f;
        for (int j = 0; j < 1; j++) {
            [self appendPlate:current y:currentY z:z - 0.3 width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY z:z - 0.3 width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY z:z - 0.3 width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.1 z:z - 0.3 width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.1 z:z - 0.3 width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.2 z:z - 0.3 width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY + 0.2 z:z - 0.3 width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.2 z:z - 0.3 width:0.1 height:0.1 red:0 green:191 blue:255 alpha:1];
            
            current += 0.3;
        }
        NSLog(@"CURRENT = %f", current);
        currentY += 0.3;
    }
    
    currentY = -0.45;
    for (int i = 0; i < 6; i++) {
        float current = 2.869134f;
        for (int j = 0; j < 4; j++) {
            [self appendPlate:current y:currentY z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.1 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.1 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.2 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY + 0.2 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.2 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            current += 0.3;
        }
        NSLog(@"CURRENT = %f", current);
        currentY += 0.3;
    }
    
    int roofc = [self appendCompoundRoof:2.869134f y:-0.45 + 1.8 z:z width:1.2 lowerSegments:4];
    for (int i = 0; i < 6; i++) {
        [self removeFace:roofc nth:6];
    }
    for (int i = 0; i < 6; i++) {
        [self removeFace:roofc nth:12];
    }
    
    currentY = -0.45;
    for (int i = 0; i < 5; i++) {
        float current = 4.069134f;
        for (int j = 0; j < 4; j++) {
            [self appendPlate:current y:currentY z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.1 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.1 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.2 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY + 0.2 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.2 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            current += 0.3;
        }
        NSLog(@"CURRENT = %f", current);
        currentY += 0.3;
    }
    
    int roofd = [self appendCompoundRoof:4.069134f y:-0.45 + 1.5 z:z width:1.2 lowerSegments:4];
    for (int i = 0; i < 6; i++) {
        [self removeFace:roofd nth:6];
    }
    for (int i = 0; i < 6; i++) {
        [self removeFace:roofd nth:12];
    }
    
    [self appendCompoundRoof:4.069134f + 1.2 y:-0.45 + 1.5 z:z width:0.05 lowerSegments:4];
    
    int objectY = self.totalIndices;
    
    currentY = -0.45;
    for (int i = 0; i < 5; i++) {
        float current = 5.269135f;
        for (int j = 0; j < 2; j++) {
            [self appendPlate:current y:currentY z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.1 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            if (i == 0 && j == 0) {
                [self appendPlate:current + 0.1 y:currentY + 0.1 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            }
            [self appendPlate:current + 0.2 y:currentY + 0.1 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            [self appendPlate:current y:currentY + 0.2 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.1 y:currentY + 0.2 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            [self appendPlate:current + 0.2 y:currentY + 0.2 z:z width:0.1 height:0.1 red:255 green:0 blue:255 alpha:1];
            
            current += 0.3;
        }
        NSLog(@"CURRENT = %f", current);
        currentY += 0.3;
    }
    
    int objectX = self.totalIndices;
    [self rotateObjectX:objectY length:objectX - objectY xAngle:90];
    [self translateObject:objectY length:objectX - objectY xTranslate:-0.3 yTranslate:0 zTranslate:-0.3];
    
    [self rotateObjectX:objectRight length:self.totalIndices - objectRight xAngle:-30];
    
    [self appendCube:-2 y:-0.46 z:2 width:10 height:0.01 depth:10 red:200 green:200 blue:200];
    
    for (int i = 0; i < self.totalIndices / 3; i++) {
        self.bigLineIndices[i * 6 + 0] = i * 3;
        self.bigLineIndices[i * 6 + 1] = i * 3 + 1;
        
        self.bigLineIndices[i * 6 + 2] = i * 3 + 1;
        self.bigLineIndices[i * 6 + 3] = i * 3 + 2;
        
        self.bigLineIndices[i * 6 + 4] = i * 3 + 2;
        self.bigLineIndices[i * 6 + 5] = i * 3;
    }
    
    self.vertexBuffer = [self.renderer newBufferWithBytes:self.bigVertices length:sizeof(Vertex) * self.totalIndices];
    self.indexBuffer = [self.renderer newBufferWithBytes:self.bigIndices length:sizeof(IndexType) * self.totalIndices];
    
    self.lineVertexBuffer = [self.renderer newBufferWithBytes:self.bigLineVertices length:sizeof(Vertex) * self.totalIndices];
    self.lineIndexBuffer = [self.renderer newBufferWithBytes:self.bigLineIndices length:sizeof(uint16_t) * (self.totalIndices * 2)];
}

- (void)updateMotion
{
    NSTimeInterval frameTime = CFAbsoluteTimeGetCurrent();
    NSTimeInterval frameDuration = frameTime - self.lastFrameTime;
    self.lastFrameTime = frameTime;
    
    if (frameDuration > 0)
    {
        self.angle = CGPointMake(self.angle.x + self.angularVelocity.x * frameDuration,
                                 self.angle.y + self.angularVelocity.y * frameDuration);
        self.angularVelocity = CGPointMake(self.angularVelocity.x * (1 - kDamping),
                                           self.angularVelocity.y * (1 - kDamping));
    }
}

- (void)updateUniforms {
    static const simd::float3 X_AXIS = { 1, 0, 0 };
    static const simd::float3 Y_AXIS = { 0, 1, 0 };
    simd::float4x4 modelMatrix = Identity();
    
    
    //modelMatrix = Rotation(Y_AXIS, -self.angle.x) * modelMatrix;
    
    //self.angle.x = 10 * 3.14 / 180;
    self.angle = CGPointMake(40 * 3.14 / 180, 10 * 3.14 / 180);//demo
    //self.angle = CGPointMake(-180 * 3.14 / 180, 30 * 3.14 / 180);
    //NSLog(@"ANGLE %f %f", self.angle.x, self.angle.y);
    modelMatrix = Rotation(Y_AXIS, -self.angle.x) * modelMatrix;
    modelMatrix = Rotation(X_AXIS, -self.angle.y) * modelMatrix;
    
    simd::float4x4 viewMatrix = Identity();
    viewMatrix.columns[3].z = -1; // translate camera back along Z axis
    
    viewMatrix.columns[3].x = -0; // translate camera back along Z axis
    viewMatrix.columns[3].y = -1.5; // translate camera back along Z axis
    viewMatrix.columns[3].z = -3; // translate camera back along Z axis
    //viewMatrix.columns[3].z = -0.5;
    
    const float near = 0.1;
    const float far = 100;
    //const float aspect = self.view.bounds.size.width / self.view.bounds.size.height;
    const float aspect = self.bounds.size.width / self.bounds.size.height;
    simd::float4x4 projectionMatrix = PerspectiveProjection(aspect, DegToRad(75), near, far);
    
    Uniforms uniforms;
    
    simd::float4x4 modelView = viewMatrix * modelMatrix;
    uniforms.modelViewMatrix = modelView;
    
    simd::float4x4 modelViewProj = projectionMatrix * modelView;
    uniforms.modelViewProjectionMatrix = modelViewProj;
    
    simd::float3x3 normalMatrix = { modelView.columns[0].xyz, modelView.columns[1].xyz, modelView.columns[2].xyz };
    uniforms.normalMatrix = simd::transpose(simd::inverse(normalMatrix));
    
    self.uniformBuffer = [self.renderer newBufferWithBytes:(void *)&uniforms length:sizeof(Uniforms)];
}

- (void)redraw {
    [self updateMotion];
    [self updateUniforms];
    
    [self.renderer startFrame];
    
    
    
    
    [self.renderer drawTrianglesWithInterleavedBuffer:self.vertexBuffer lineVertexBuffer:self.lineVertexBuffer
                                          indexBuffer:self.indexBuffer lineIndexBuffer:self.lineIndexBuffer
                                        uniformBuffer:self.uniformBuffer
                                           indexCount:[self.indexBuffer length] / sizeof(IndexType) numberOfObjects:self.totalIndices texture:nil];
    
    [self.renderer endFrame];
}

@end
