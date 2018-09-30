#import "SSZipArchive/ZipArchive.h"
#import "ViewController.h"
#import "OBJModel.h"
#import "Shared.h"
#import "Transforms.h"

#import <QuartzCore/CAMetalLayer.h>
#import <Metal/Metal.h>

#import <time.h>

#import "MidJuly_Paged-Swift.h"

int lastObject;

static const float kDamping = 0.05;

static float DegToRad(float deg) {
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

@property (assign) float x, y, z, xAngle, yAngle;

@end

@implementation ViewController

- (void)setVertexArrays:(Vertex *)bigVertices bigLineVertices:(Vertex *)bigLineVertices bigIndices:(uint16_t *)bigIndices bigLineIndices:(uint16_t *)bigLineIndices {
    self.bigVertices = bigVertices;
    self.bigLineVertices = bigLineVertices;
    
    self.bigIndices = bigIndices;
    self.bigLineIndices = bigLineIndices;
}

- (void)customMetalLayer:(CALayer *)layer bounds:(CGRect)bounds indicesCount:(int)indicesCount x:(float)x y:(float)y z:(float)z xAngle:(float)xAngle yAngle:(float)yAngle {
    
    self.bounds = bounds;
    
    self.x = x;
    self.y = y;
    self.z = z;
    
    self.xAngle = xAngle;
    self.yAngle = yAngle;
    
    self.metal = [CAMetalLayer new];
    self.metal.frame = bounds;// CGRectMake(10.0, 100.0, 300.0, 300.0);
    self.metal.framebufferOnly = false;
    
    self.metal.opaque = false;
    
    self.renderer = [[Renderer alloc] initWithLayer:self.metal];
    self.renderer.vertexFunctionName = @"vertex_main";
    self.renderer.fragmentFunctionName = @"fragment_main";
    
    self.lastFrameTime = CFAbsoluteTimeGetCurrent();
    
    [self loadModel:indicesCount];
    
    [layer addSublayer:self.metal];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    //[self redraw];
    
}

- (void)displayLinkDidFire:(CADisplayLink *)displayLink
{
    [self redraw];
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
    
    /*[self appendCube:x y:y z:z width:stickDepth height:height depth:stickDepth red:red green:green blue:blue];
    [self appendCube:x + width - stickDepth y:y z:z width:stickDepth height:height depth:stickDepth red:red green:green blue:blue];
    
    int steps = 4;
    float heightOffset = height / (steps + 1);
    for (int i = 0; i < steps; i++) {
        [self appendCube:x + stickDepth y:y + heightOffset * (i + 1) z:z width:width - stickDepth * 2 height:stickDepth depth:stickDepth red:red green:green blue:blue];
    }*/
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


- (void)completeSavedImage:(UIImage *)_image didFinishSavingWithError:(NSError *)_error contextInfo:(void *)_contextInfo {
    if (!_error) {
        NSLog(@"Saved");
    }
}

- (int)getTotalIndices {
    return self.totalIndices;
}

- (void)takeScreenshot {
    [self.renderer takeScreenshot];
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

- (void)loadModel:(int)indicesCount {
    
    self.totalIndices = indicesCount;
    
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

- (void)setAngle:(float)x y:(float)y {
    self.xAngle = x;
    self.yAngle = y;
}

- (void)updateUniforms {
    static const simd::float3 X_AXIS = { 1, 0, 0 };
    static const simd::float3 Y_AXIS = { 0, 1, 0 };
    simd::float4x4 modelMatrix = Identity();
    
    
    //modelMatrix = Rotation(Y_AXIS, -self.angle.x) * modelMatrix;
    
    //self.angle.x = 10 * 3.14 / 180;
    self.angle = CGPointMake(self.xAngle * M_PI / 180, self.yAngle * M_PI / 180);//demo
    //self.angle = CGPointMake(-180 * 3.14 / 180, 30 * 3.14 / 180);
    NSLog(@"ANGLE %f %f", self.xAngle, self.yAngle);
    modelMatrix = Rotation(Y_AXIS, -self.angle.x) * modelMatrix;
    modelMatrix = Rotation(X_AXIS, -self.angle.y) * modelMatrix;
    
    simd::float4x4 viewMatrix = Identity();
    viewMatrix.columns[3].z = -1; // translate camera back along Z axis
    
    /*viewMatrix.columns[3].x = -2.5; // translate camera back along Z axis
    viewMatrix.columns[3].y = 0; // translate camera back along Z axis
    viewMatrix.columns[3].z = -8; // translate camera back along Z axis
     */
    
    /*viewMatrix.columns[3].x = -2.6;
    viewMatrix.columns[3].y = -1; // translate camera back along Z axis
    viewMatrix.columns[3].z = -7;*/
    
    viewMatrix.columns[3].x = -2.6;
    viewMatrix.columns[3].y = -1; // translate camera back along Z axis
    viewMatrix.columns[3].z = -4;
    
    viewMatrix.columns[3].x = self.x;
    viewMatrix.columns[3].y = self.y; // translate camera back along Z axis
    viewMatrix.columns[3].z = self.z;
    
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
