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

@property (nonatomic, strong) id<MTLBuffer> vertexBuffer, lineVertexBuffer, selectionBuffer, gridVertexBuffer, axisVertexBuffer;
@property (nonatomic, strong) id<MTLBuffer> indexBuffer, lineIndexBuffer, gridIndexBuffer;
@property (nonatomic, strong) id<MTLBuffer> uniformBuffer, axisUniformBuffer;

@property (nonatomic, assign) Vertex *bigVertices, *bigLineVertices, *selectedVertices, *gridLineVertices, *axisLineVertices;
@property (nonatomic, assign) uint16_t *bigIndices, *bigLineIndices, *gridLineIndices;

@property (nonatomic, assign) simd::float4x4 projectionMatrix;

@property (nonatomic, assign) CGRect bounds, axisFrame;

@property (nonatomic, assign) int totalIndices;

@property (nonatomic, strong) UIViewController *mainView;

@property (assign) float x, y, z, xAngle, yAngle;

@end

@implementation ViewController

- (void)translateCamera:(float)x y:(float)y z:(float)z {
    self.x = x;
    self.y = y;
    self.z = z;
}

- (void)setVertexArrays:(Vertex *)bigVertices bigLineVertices:(Vertex *)bigLineVertices selectedVertices:(Vertex *)selectedVertices gridLineVertices:(Vertex *) gridLineVertices axisLineVertices:(Vertex *)axisLineVertices bigIndices:(uint16_t *)bigIndices bigLineIndices:(uint16_t *)bigLineIndices gridLineIndices:(uint16_t *)gridLineIndices {
    self.bigVertices = bigVertices;
    self.bigLineVertices = bigLineVertices;
    self.selectedVertices = selectedVertices;
    self.gridLineVertices = gridLineVertices;
    self.axisLineVertices = axisLineVertices;
    
    self.bigIndices = bigIndices;
    self.bigLineIndices = bigLineIndices;
    self.gridLineIndices = gridLineIndices;
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
    
    self.axisFrame = CGRectMake(0, 400, 100, 100);
    self.axisMetal = [CAMetalLayer new];
    self.axisMetal.frame = self.axisFrame;
    self.axisMetal.framebufferOnly = false;
    
    self.axisMetal.backgroundColor = [[UIColor clearColor] CGColor];
    
    self.metal.opaque = false;
    self.axisMetal.opaque = false;
    //self.axisMetal.opacity = 0;
    
    self.renderer = [[Renderer alloc] initWithLayer:self.metal];
    self.renderer.vertexFunctionName = @"vertex_main";
    self.renderer.fragmentFunctionName = @"fragment_main";
    
    self.axisRenderer = [[Renderer alloc] initWithLayer:self.axisMetal];
    self.axisRenderer.vertexFunctionName = @"vertex_main";
    self.axisRenderer.fragmentFunctionName = @"fragment_main";
    
    self.lastFrameTime = CFAbsoluteTimeGetCurrent();
    
    [self loadModel:indicesCount];
    
    [layer addSublayer:self.metal];
    [layer addSublayer:self.axisMetal];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkDidFire:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    //[self redraw];
    
}

- (void)displayLinkDidFire:(CADisplayLink *)displayLink {
    [self redraw];
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

simd::float4 positionAt(float radius, float angle, float segmentAngle, float offsetX, float offsetY) {
    float x = offsetX + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius);
    float y;
    float z;
    return simd::float4{0, 0, 0, 1.0f};
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

- (void)toggleSelectionMode {
    self.renderer.isSelectionMode = true;
}

- (void)loadModel:(int)indicesCount {
    
    self.totalIndices = indicesCount;
    
    if (indicesCount > 0) {
    self.vertexBuffer = [self.renderer newBufferWithBytes:self.bigVertices length:sizeof(Vertex) * self.totalIndices];
    self.selectionBuffer = [self.renderer newBufferWithBytes:self.selectedVertices length:sizeof(Vertex) * self.totalIndices];
        self.gridVertexBuffer = [self.renderer newBufferWithBytes:self.gridLineVertices length:sizeof(Vertex) * 3 * 34];
        self.axisVertexBuffer = [self.axisRenderer newBufferWithBytes:self.axisLineVertices length:sizeof(Vertex) * 3 * 3];
    
    self.indexBuffer = [self.renderer newBufferWithBytes:self.bigIndices length:sizeof(IndexType) * self.totalIndices];
    
        self.lineVertexBuffer = [self.renderer newBufferWithBytes:self.bigLineVertices length:sizeof(Vertex) * self.totalIndices];
    self.lineIndexBuffer = [self.renderer newBufferWithBytes:self.bigLineIndices length:sizeof(uint16_t) * (self.totalIndices * 2)];
        
        self.gridIndexBuffer = [self.renderer newBufferWithBytes:self.gridLineIndices length:sizeof(uint16_t) * 6 * 34];
    }
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
    //NSLog(@"ANGLE %f %f", self.xAngle, self.yAngle);
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
    
    
    
    
    simd::float4x4 axisViewMatrix = Identity();
    axisViewMatrix.columns[3].x = 0;
    axisViewMatrix.columns[3].y = 0; // translate camera back along Z axis
    axisViewMatrix.columns[3].z = -1.75;
    
    
    const float near = 0.1;
    const float far = 200;
    //const float aspect = self.view.bounds.size.width / self.view.bounds.size.height;
    
    
    
    
    
    const float aspect = self.bounds.size.width / self.bounds.size.height;
    const float axisAspect = self.axisFrame.size.width / self.axisFrame.size.height;
    
    simd::float4x4 projectionMatrix = PerspectiveProjection(aspect, DegToRad(75), near, far);
    simd::float4x4 axisProjectionMatrix = PerspectiveProjection(axisAspect, DegToRad(75), near, far);
    
    Uniforms uniforms, axisUniforms;
    
    simd::float4x4 modelView = viewMatrix * modelMatrix;
    uniforms.modelViewMatrix = modelView;
    
    simd::float4x4 axisModelView = axisViewMatrix * modelMatrix;
    axisUniforms.modelViewMatrix = axisModelView;
    
    simd::float4x4 modelViewProj = projectionMatrix * modelView;
    uniforms.modelViewProjectionMatrix = modelViewProj;
    
    simd::float4x4 axisModelViewProj = axisProjectionMatrix * axisModelView;
    axisUniforms.modelViewProjectionMatrix = axisModelViewProj;
    
    simd::float3x3 normalMatrix = { modelView.columns[0].xyz, modelView.columns[1].xyz, modelView.columns[2].xyz };
    uniforms.normalMatrix = simd::transpose(simd::inverse(normalMatrix));
    
    simd::float3x3 axisNormalMatrix = { axisModelView.columns[0].xyz, axisModelView.columns[1].xyz, axisModelView.columns[2].xyz };
    axisUniforms.normalMatrix = simd::transpose(simd::inverse(axisNormalMatrix));
    
    self.uniformBuffer = [self.renderer newBufferWithBytes:(void *)&uniforms length:sizeof(Uniforms)];
    self.axisUniformBuffer = [self.axisRenderer newBufferWithBytes:(void *)&axisUniforms length:sizeof(Uniforms)];
}

- (void)setTapPoint:(int)x y:(int)y {
    self.tapX = x;
    self.tapY = y;
}

- (void)redraw {
    [self updateMotion];
    [self updateUniforms];
    
    [self.renderer startFrame];
    
    
    
    
    [self.renderer drawTrianglesWithInterleavedBuffer:self.vertexBuffer selectionVertexBuffer:self.selectionBuffer lineVertexBuffer:self.lineVertexBuffer gridVertexBuffer:self.gridVertexBuffer
                                          indexBuffer:self.indexBuffer lineIndexBuffer:self.lineIndexBuffer gridIndexBuffer:self.gridIndexBuffer
                                        uniformBuffer:self.uniformBuffer
                                           indexCount:[self.indexBuffer length] / sizeof(IndexType) numberOfObjects:self.totalIndices texture:nil];
    
    [self.renderer endFrame];
    
    [self.axisRenderer startAxisFrame];
    
    
    
    
    [self.axisRenderer drawAxis:self.vertexBuffer selectionVertexBuffer:self.selectionBuffer lineVertexBuffer:self.lineVertexBuffer gridVertexBuffer:self.gridVertexBuffer axisVertexBuffer:self.axisVertexBuffer indexBuffer:self.indexBuffer lineIndexBuffer:self.lineIndexBuffer gridIndexBuffer:self.gridIndexBuffer
                                        uniformBuffer:self.axisUniformBuffer
                                           indexCount:[self.indexBuffer length] / sizeof(IndexType) numberOfObjects:self.totalIndices texture:nil];
    
    [self.axisRenderer endFrame];
    
    if (self.renderer.isSelectionMode) {
        //sleep(2);
        int* color = [self.renderer pixelColor:self.tapX y:self.tapY];
        self.renderer.isSelectionMode = false;
        
        NSLog(@"Red = %d", color[0]);
        NSLog(@"Green = %d", color[1]);
        NSLog(@"Blue = %d", color[2]);
        
        [RootViewController.scenes[self.currentScene] selectObjectWithColorWithRgb:color];
        [self loadModel:RootViewController.scenes[self.currentScene].indicesCount];
        //RootViewController.scenes
        
    }
}

@end
