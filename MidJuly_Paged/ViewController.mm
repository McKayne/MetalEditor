
#import "ViewController.h"
#import "OBJModel.h"
#import "Shared.h"
#import "Transforms.h"

#import <QuartzCore/CAMetalLayer.h>
//#import <QuartzCore/CAMetalDrawable.h>
#import <Metal/Metal.h>

#import <time.h>

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
    
    simd::float4 position[36];
    
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
    
    simd::float4 position[segments * 3 * 2];
    
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
    
    simd::float4 position[segments * 3 * 4];
    
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
    
    simd::float4 position[segments * 3 * 4];
    
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
    
    simd::float4 position[segments * 3 * 2 * segments];
    
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

simd::float4 normalize(simd::float3 customVertexNormal) {
    return simd::float4{customVertexNormal.x / getLength(customVertexNormal), customVertexNormal.y / getLength(customVertexNormal), customVertexNormal.z / getLength(customVertexNormal), 0};
}

- (int)appendCube:(float)x y:(float)y z:(float)z
             width:(float)width height:(float)height depth:(float)depth
               red:(int)red green:(int)green blue:(int)blue {
    
    simd::float4 position[36];
    
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
        
        self.bigVertices[i + self.totalIndices].customColor = {static_cast<float>((float) red / 255.0), static_cast<float>((float) green / 255.0), static_cast<float>((float) blue / 255.0)};
        self.bigVertices[i + self.totalIndices].position = position[i];
        
        self.bigLineVertices[i + self.totalIndices].normal = {0, 0, 0};
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
    
    
    
    simd::float4 position[36 * numberOfSteps];
    
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

void makeFace(simd::float4* position, simd::float3 a, simd::float3 b, simd::float3 c, simd::float3 d, int offset) {
    position[offset++] = {a.x, a.y, a.z, 1.0};
    position[offset++] = {b.x, b.y, b.z, 1.0};
    position[offset++] = {c.x, c.y, c.z, 1.0};
    
    position[offset++] = {d.x, d.y, d.z, 1.0};
    position[offset++] = {c.x, c.y, c.z, 1.0};
    position[offset++] = {b.x, b.y, b.z, 1.0};
}

- (void)appendChessboard:(float)x y:(float)y z:(float)z width:(float)width height:(float)height depth:(float)depth red:(int)red green:(int)green blue:(int)blue topBorder:(float)topBorder {
    
    simd::float4 position[54 + 6 * 8 * 8];
    
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
    
    simd::float4 position[24];
    
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
    
    simd::float4 position[segments * 3 * 2 * 2 * 2 * 2];
    
    
    
    
    
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

- (void)takeScreenshot {
    NSLog(@"Now switching to another controller");
    
    //self.metalLayer nextDrawable
    
    /*id<CAMetalDrawable> lastDrawable = [self.renderer getDrawable];
    if (lastDrawable == nil) {
        NSLog(@"Last drawable Nil");
    }*/
    
    id<MTLTexture> metalTexture = [self.renderer getDrawable];//[lastDrawable texture];
    
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
    UIImage *pngImage = [UIImage imageWithData:pngData];
    
    //UIImageWriteToSavedPhotosAlbum(pngImage, self, @selector(completeSavedImage:didFinishSavingWithError:contextInfo:), nil);
    
    //UIImage *image = [UIImage imageWithData:[chart getImage]];
    
    
    
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *filePath = [docPath stringByAppendingPathComponent:@"iphone_app_export_test.txt"];
    
    //NSString *contents = [NSString stringWithCapacity:9];
    
    NSString *contents = @"It works";
    //fill contents with data in csv format
    // ...
    
    NSError *error;
    
    [contents writeToFile:filePath
               atomically:YES
                 encoding:NSUTF8StringEncoding
                    error:&error];
    
    // check for the error
    
    NSURL *sampleUrl =  [NSURL fileURLWithPath:filePath];
    
    if (sampleUrl == nil) {
        NSLog(@"URL nul");
    }
    
    char* sampleText = (char*) malloc(sizeof(char) * 8);
    sampleText[0] = 'I';
    sampleText[1] = 't';
    sampleText[2] = ' ';
    sampleText[3] = 'w';
    sampleText[4] = 'o';
    sampleText[5] = 'r';
    sampleText[6] = 'k';
    sampleText[7] = 's';
    
    //NSString *str = [[NSBundle mainBundle] pathForResource:@"AppDistributionGuide" ofType:@"pdf"];
    //NSString *str
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"iphone_app_export_test.txt", sampleUrl] applicationActivities:nil];
    //NSData *pdfData = [NSData dataWithBytes:sampleText length:sizeof(char) * 8];
    //UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"iphone_app_export_test.txt", pdfData] applicationActivities:nil];
    //NSString *str = [[NSBundle mainBundle] pathForResource:@"AppDistributionGuide" ofType:@"pdf"];
    //UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"Test", [NSURL fileURLWithPath:str]] applicationActivities:nil];
    
    //NSArray *activityItems = @[pngImage];
    //UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    activityViewController.popoverPresentationController.sourceView = self.mainView.view;
    activityViewController.popoverPresentationController.sourceRect = CGRectMake(self.mainView.view.bounds.size.width/2, self.mainView.view.bounds.size.height/4, 0, 0);
    }
    [self.mainView presentViewController:activityViewController animated:true completion:nil];
    
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

- (void)loadModel {
    
    self.totalIndices = 0;
    
    __unused int numberOfObjects = 1;
    self.bigVertices = (Vertex*) malloc(sizeof(Vertex) * 100000);
    self.bigIndices = (uint16_t*) malloc(sizeof(uint16_t) * 100000);
    
    self.bigLineVertices = (Vertex*) malloc(sizeof(Vertex) * 100000);
    self.bigLineIndices = (uint16_t*) malloc(sizeof(uint16_t) * 100000);
    
    //[self.bigVertices initWithCapacity:numberOfObjects];
    
    // Early august demo
    /*[self appendCube:-0.4 y:-0.6 z:0.25 width:0.7 height:0.05 depth:0.8 red:255 green:0 blue:255];
    [self appendCube:-0.25 y:-0.55 z:0.05 width:0.4 height:0.15 depth:0.4 red:255 green:255 blue:0];
    [self appendCylinder:-0.05 y:-0.4 z:-0.15 radius:0.15 height:0.5 red:0 green:191 blue:255];
    [self appendCone:-0.05 y:0.1 z:-0.15 radius:0.15 height:0.3 red:90 green:0 blue:157];
    [self appendSphere:-0.05 y:0.5 z:-0.15 radius:0.1 red:255 green:0 blue:0];
    [self appendStairs:-0.25 y:-0.55 z:0.25 width:0.4 stepWidth:0.05 stepHeight:0.05 depth:0.2 red:0 green:255 blue:0];*/
    
    //[self appendChessboard:-0.4 y:-0.6 z:0.25 width:0.8 height:0.05 depth:0.8 red:255 green:0 blue:255 topBorder:0.1];
    //[self appendRoof:-0.4 y:-0.6 z:0.25 width:0.6 height:0.4 depth:0.5 red:255 green:0 blue:255];
    //[self appendLadder:-0.3 y:-0.8 z:0.2 width:0.6 height:1.0 depth:0.5 red:255 green:0 blue:255];
    
    // Gears demo
    /*[self appendGear:0.0 y:-0.3 z:-0.15 radius:0.15 height:0.2 red:0 green:191 blue:255];
    [self appendGear:-0.2 y:-0.6 z:-0.05 radius:0.15 height:0.2 red:0 green:0 blue:255];
    [self appendGear:0.1 y:-0.05 z:-0.35 radius:0.15 height:0.2 red:0 green:255 blue:0];*/
    
    [self appendCube:-0.25 y:-0.25 z:0.25 width:0.5 height:0.5 depth:0.5 red:255 green:0 blue:255];
    //[self.renderer handleAsset];
    //[self importOBJ:255 green:0 blue:0];
    
    //NSLog(@"kfkghkgjhlglhkgljklhkjlhkjl");
    //[self.renderer test:nil];
    //[self.renderer setView:nil];
    
    //[self appendTorus];
    
    //[self appendCube:-0.25 y:-0.25 z:0.25 width:0.5 height:0.5 depth:0.5 red:255 green:0 blue:255];
    //[self appendCube:-0.25 y:-0.75 z:0.25 width:0.5 height:0.5 depth:0.5 red:255 green:0 blue:0];
    
    // light cubes demo
    /*srand(time(NULL));
    [self appendCube:-0.4 y:-0.4 z:0.2 width:0.4 height:0.2 depth:0.2 red:rand() % 256 green:rand() % 256 blue:rand() % 256];
    [self appendCube:0.0 y:-0.4 z:0.2 width:0.4 height:0.2 depth:0.2 red:rand() % 256 green:rand() % 256 blue:rand() % 256];
    
    [self appendCube:-0.4 y:-0.2 z:0.2 width:0.2 height:0.2 depth:0.2 red:rand() % 256 green:rand() % 256 blue:rand() % 256];
    [self appendCube:-0.2 y:-0.2 z:0.2 width:0.4 height:0.2 depth:0.2 red:rand() % 256 green:rand() % 256 blue:rand() % 256];
    [self appendCube:0.2 y:-0.2 z:0.2 width:0.2 height:0.2 depth:0.2 red:rand() % 256 green:rand() % 256 blue:rand() % 256];
    
    [self appendCube:-0.4 y:0.0 z:0.2 width:0.4 height:0.2 depth:0.2 red:rand() % 256 green:rand() % 256 blue:rand() % 256];
    [self appendCube:0.0 y:0.0 z:0.2 width:0.4 height:0.2 depth:0.2 red:rand() % 256 green:rand() % 256 blue:rand() % 256];*/
    
    //[self appendPyramid];
    //[self appendCube:-0.25 width:0.2 nth:0];
    //[self appendCube:0.05 width:0.2 nth:1];
    
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
    self.angle = CGPointMake(-180 * 3.14 / 180, -20 * 3.14 / 180);//demo
    //self.angle = CGPointMake(-180 * 3.14 / 180, 30 * 3.14 / 180);
    //NSLog(@"ANGLE %f %f", self.angle.x, self.angle.y);
    modelMatrix = Rotation(Y_AXIS, -self.angle.x) * modelMatrix;
    modelMatrix = Rotation(X_AXIS, -self.angle.y) * modelMatrix;
    
    simd::float4x4 viewMatrix = Identity();
    viewMatrix.columns[3].z = -1; // translate camera back along Z axis
    
    //viewMatrix.columns[3].z = -1.5; // translate camera back along Z axis
    
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
                                           indexCount:[self.indexBuffer length] / sizeof(IndexType) numberOfObjects:self.totalIndices];
    
    [self.renderer endFrame];
}

@end
