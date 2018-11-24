
#import <UIKit/UIKit.h>
#import <QuartzCore/CAMetalLayer.h>
#import <Metal/Metal.h>

@interface Renderer : NSObject

@property (nonatomic, copy) NSString *vertexFunctionName;
@property (nonatomic, copy) NSString *fragmentFunctionName;
@property (assign) BOOL isSelectionMode;

- (instancetype)initWithLayer:(CAMetalLayer *)metalLayer;

- (id<MTLBuffer>)newBufferWithBytes:(const void *)bytes length:(NSUInteger)length;

- (void)takeScreenshot;
- (int*)pixelColor:(int)x y:(int)y;

- (void)startFrame;
- (void)startAxisFrame;
- (void)endFrame;

- (void)drawTrianglesWithInterleavedBuffer:(id<MTLBuffer>)positionBuffer selectionVertexBuffer:(id<MTLBuffer>)selectionVertexBuffer lineVertexBuffer:(id<MTLBuffer>)lineVertexBuffer gridVertexBuffer:(id<MTLBuffer>)gridVertexBuffer
                               indexBuffer:(id<MTLBuffer>)indexBuffer lineIndexBuffer:(id<MTLBuffer>)lineIndexBuffer gridIndexBuffer:(id<MTLBuffer>)gridIndexBuffer
                             uniformBuffer:(id<MTLBuffer>)uniformBuffer
                                indexCount:(size_t)indexCount numberOfObjects:(int)numberOfObjects texture:(id<MTLTexture>) texture;
- (void)drawAxis:(id<MTLBuffer>)positionBuffer selectionVertexBuffer:(id<MTLBuffer>)selectionVertexBuffer lineVertexBuffer:(id<MTLBuffer>)lineVertexBuffer gridVertexBuffer:(id<MTLBuffer>)gridVertexBuffer axisVertexBuffer:(id<MTLBuffer>)axisVertexBuffer indexBuffer:(id<MTLBuffer>)indexBuffer lineIndexBuffer:(id<MTLBuffer>)lineIndexBuffer gridIndexBuffer:(id<MTLBuffer>)gridIndexBuffer
                             uniformBuffer:(id<MTLBuffer>)uniformBuffer
                                indexCount:(size_t)indexCount numberOfObjects:(int)numberOfObjects texture:(id<MTLTexture>) texture;


- (void)updateDrawable:(id<CAMetalDrawable>)lastDrawable;

- (id<MTLTexture>)getDrawable;

- (void)completeSavedImage:(UIImage *)_image didFinishSavingWithError:(NSError *)_error contextInfo:(void *)_contextInfo;

- (void)handleAsset;
- (void)setView:(UIViewController *)view;
- (void)test:(UIView *)view;

@end
