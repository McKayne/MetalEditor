
#import <UIKit/UIKit.h>
#import <QuartzCore/CAMetalLayer.h>
#import <Metal/Metal.h>

@interface Renderer : NSObject

@property (nonatomic, copy) NSString *vertexFunctionName;
@property (nonatomic, copy) NSString *fragmentFunctionName;

- (instancetype)initWithLayer:(CAMetalLayer *)metalLayer;

- (id<MTLBuffer>)newBufferWithBytes:(const void *)bytes length:(NSUInteger)length;

- (void)startFrame;
- (void)endFrame;

- (void)drawTrianglesWithInterleavedBuffer:(id<MTLBuffer>)positionBuffer lineVertexBuffer:(id<MTLBuffer>)lineVertexBuffer
                               indexBuffer:(id<MTLBuffer>)indexBuffer lineIndexBuffer:(id<MTLBuffer>)lineIndexBuffer
                             uniformBuffer:(id<MTLBuffer>)uniformBuffer
                                indexCount:(size_t)indexCount numberOfObjects:(int)numberOfObjects;


- (void)updateDrawable:(id<CAMetalDrawable>)lastDrawable;

- (id<MTLTexture>)getDrawable;

- (void)completeSavedImage:(UIImage *)_image didFinishSavingWithError:(NSError *)_error contextInfo:(void *)_contextInfo;

- (void)handleAsset;
- (void)setView:(UIViewController *)view;
- (void)test:(UIView *)view;

@end
