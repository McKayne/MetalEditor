
#import "Renderer.h"

@interface Renderer ()

@property (nonatomic, getter=pipelineIsDirty) BOOL pipelineDirty;

// Long-lived objects
@property (nonatomic, strong) CAMetalLayer *metalLayer;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLLibrary> library;

// Lazily recreated objects
@property (nonatomic, strong) id<MTLRenderPipelineState> pipeline;
@property (nonatomic, strong) id<MTLDepthStencilState> depthStencilState;

// Per-frame transient objects
@property (nonatomic, strong) id<MTLRenderCommandEncoder> commandEncoder;
@property (nonatomic, strong) id<MTLCommandBuffer> commandBuffer;
@property (nonatomic, strong) id<CAMetalDrawable> drawable;
@property (nonatomic, strong) id<CAMetalDrawable> lastDrawable;

@property (nonatomic, strong) id<MTLTexture> framebufferTexture;
@end

@implementation Renderer

@synthesize vertexFunctionName=_vertexFunctionName;
@synthesize fragmentFunctionName=_fragmentFunctionName;

- (instancetype)initWithLayer:(CAMetalLayer *)metalLayer
{
    if ((self = [super init]))
    {
        _metalLayer = metalLayer;
        _device = MTLCreateSystemDefaultDevice();
        if (!_device)
        {
            NSLog(@"Unable to create default device!");
        }
        _metalLayer.device = _device;
        _metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
        
        _library = [_device newDefaultLibrary];
        
        _pipelineDirty = YES;
    }
    
    return self;
}

- (void)updateDrawable:(id<CAMetalDrawable>)lastDrawable {
    self.lastDrawable = lastDrawable;
}

- (id<MTLTexture>)getDrawable {
    return [self.drawable texture];
}

- (NSString *)vertexFunctionName
{
    return _vertexFunctionName;
}

- (void)setVertexFunctionName:(NSString *)vertexFunctionName
{
    self.pipelineDirty = YES;
    
    _vertexFunctionName = [vertexFunctionName copy];
}

- (NSString *)fragmentFunctionName
{
    return _fragmentFunctionName;
}

- (void)setFragmentFunctionName:(NSString *)fragmentFunctionName
{
    self.pipelineDirty = YES;
    
    _fragmentFunctionName = [fragmentFunctionName copy];
}

- (void)buildPipeline
{
    MTLVertexDescriptor *vertexDescriptor = [MTLVertexDescriptor vertexDescriptor];
    vertexDescriptor.attributes[0].format = MTLVertexFormatFloat4;
    vertexDescriptor.attributes[0].bufferIndex = 0;
    vertexDescriptor.attributes[0].offset = 0;
    
    vertexDescriptor.attributes[1].format = MTLVertexFormatFloat4;
    vertexDescriptor.attributes[1].bufferIndex = 0;
    vertexDescriptor.attributes[1].offset = sizeof(float) * 4;
    
    vertexDescriptor.attributes[2].format = MTLVertexFormatFloat4;
    vertexDescriptor.attributes[2].bufferIndex = 0;
    vertexDescriptor.attributes[2].offset = sizeof(float) * 8;
    
    vertexDescriptor.layouts[0].stride = sizeof(float) * 12;
    vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    
    
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    
    pipelineDescriptor.vertexFunction = [self.library newFunctionWithName:self.vertexFunctionName];
    pipelineDescriptor.fragmentFunction = [self.library newFunctionWithName:self.fragmentFunctionName];
    pipelineDescriptor.vertexDescriptor = vertexDescriptor;
    
    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    depthStencilDescriptor.depthWriteEnabled = YES;
    self.depthStencilState = [self.device newDepthStencilStateWithDescriptor:depthStencilDescriptor];
    
    NSError *error = nil;
    self.pipeline = [self.device newRenderPipelineStateWithDescriptor:pipelineDescriptor
                                                                error:&error];
    
    if (!self.pipeline)
    {
        NSLog(@"Error occurred when creating render pipeline state: %@", error);
    }
    
    self.commandQueue = [self.device newCommandQueue];
}

- (id<MTLBuffer>)newBufferWithBytes:(const void *)bytes length:(NSUInteger)length
{
    return [self.device newBufferWithBytes:bytes
                                    length:length
                                   options:MTLResourceOptionCPUCacheModeDefault];
}

- (void)startFrame
{
    self.drawable = [self.metalLayer nextDrawable];
    //id<MTLTexture> framebufferTexture = self.drawable.texture;
    self.framebufferTexture = self.drawable.texture;
    
    if (!self.framebufferTexture)
    {
        NSLog(@"Unable to retrieve texture; drawable may be nil");
        return;
    }
    
    if (self.pipelineIsDirty)
    {
        [self buildPipeline];
        self.pipelineDirty = NO;
    }
    
    MTLRenderPassDescriptor *renderPass = [MTLRenderPassDescriptor renderPassDescriptor];
    renderPass.colorAttachments[0].texture = self.framebufferTexture;
    renderPass.colorAttachments[0].clearColor = MTLClearColorMake(0.9, 0.9, 0.9, 1);
    renderPass.colorAttachments[0].storeAction = MTLStoreActionStore;
    renderPass.colorAttachments[0].loadAction = MTLLoadActionClear;
    
    MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float width:1000 height:1000 mipmapped:NO];
    id<MTLTexture> texture = [_device newTextureWithDescriptor:desc];
    
    MTLRenderPassDepthAttachmentDescriptor *att = [MTLRenderPassDepthAttachmentDescriptor new];
    
    
    renderPass.depthAttachment.texture = texture;
    
    self.commandBuffer = [self.commandQueue commandBuffer];
    /*[self.commandBuffer addCompletedHandler:^(id<MTLCommandBuffer> buffer){
        self.lastDrawable = self.drawable;
    }];*/
    
    self.commandEncoder = [self.commandBuffer renderCommandEncoderWithDescriptor:renderPass];
    [self.commandEncoder setRenderPipelineState:self.pipeline];
    
    [self.commandEncoder setDepthStencilState:self.depthStencilState];
    
    [self.commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
    
    [self.commandEncoder setCullMode:MTLCullModeBack];
}

- (void)drawTrianglesWithInterleavedBuffer:(id<MTLBuffer>)positionBuffer lineVertexBuffer:(id<MTLBuffer>)lineVertexBuffer
                               indexBuffer:(id<MTLBuffer>)indexBuffer lineIndexBuffer:(id<MTLBuffer>)lineIndexBuffer
                             uniformBuffer:(id<MTLBuffer>)uniformBuffer
                                indexCount:(size_t)indexCount numberOfObjects:(int)numberOfObjects {
    if (!positionBuffer || !indexBuffer || !uniformBuffer)
    {
        return;
    }
    
    [self.commandEncoder setVertexBuffer:positionBuffer offset:0 atIndex:0];
    [self.commandEncoder setVertexBuffer:uniformBuffer offset:0 atIndex:1];
    [self.commandEncoder setFragmentBuffer:uniformBuffer offset:0 atIndex:0];
    
    [self.commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                                    indexCount:numberOfObjects
                                     indexType:MTLIndexTypeUInt16
                                   indexBuffer:indexBuffer
                             indexBufferOffset:0];
    
    
    
    /*[self.commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeLine
     indexCount:36
     indexType:MTLIndexTypeUInt16
     indexBuffer:indexBuffer
     indexBufferOffset:36];*/
    
    /*[self.commandEncoder setVertexBuffer:lineVertexBuffer offset:0 atIndex:0];
    [self.commandEncoder setVertexBuffer:uniformBuffer offset:0 atIndex:1];
    [self.commandEncoder setFragmentBuffer:uniformBuffer offset:0 atIndex:0];
    
    [self.commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeLine
                                    indexCount:(numberOfObjects * 2)
                                     indexType:MTLIndexTypeUInt16
                                   indexBuffer:lineIndexBuffer
                             indexBufferOffset:0];*/
}

- (void)completeSavedImage:(UIImage *)_image didFinishSavingWithError:(NSError *)_error contextInfo:(void *)_contextInfo {
    if (!_error) {
        NSLog(@"Saved");
    }
}

- (void)endFrame
{
    NSLog(@"END FRAME");
    
    /*int width = (int)[self.framebufferTexture width];
    int height = (int)[self.framebufferTexture height];
    int rowBytes = width * 4;
    int selfturesize = width * height * 4;
    NSLog(@">> %d %d", width, height);
    
    void *p = malloc(selfturesize);
    
    
    [self.framebufferTexture getBytes:p bytesPerRow:rowBytes fromRegion:MTLRegionMake2D(0, 0, width, height) mipmapLevel:0];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(nil, p, selfturesize, nil);
    CGImageRef cgImageRef = CGImageCreate(width, height, 8, 32, rowBytes, colorSpace, bitmapInfo, provider, nil, true, (CGColorRenderingIntent)kCGRenderingIntentDefault);
    
    UIImage *getImage = [UIImage imageWithCGImage:cgImageRef];
    CFRelease(cgImageRef);
    free(p);
    
    NSData *pngData = UIImagePNGRepresentation(getImage);
    //NSData *pngData = UIImageJPEGRepresentation(getImage, 0.0);
    UIImage *pngImage = [UIImage imageWithData:pngData];
    
    UIImageWriteToSavedPhotosAlbum(pngImage, self, @selector(completeSavedImage:didFinishSavingWithError:contextInfo:), nil);*/
    
    
    [self.commandEncoder endEncoding];
    
    if (self.drawable)
    {
        [self.commandBuffer presentDrawable:self.drawable];
        [self.commandBuffer commit];
        
        [self.commandBuffer waitUntilCompleted];
        
        int width = (int)[self.framebufferTexture width];
        int height = (int)[self.framebufferTexture height];
        int rowBytes = width * 4;
        int selfturesize = width * height * 4;
        NSLog(@">> %d %d", width, height);
        
        char* rgb = malloc(selfturesize);
        [self.framebufferTexture getBytes:rgb bytesPerRow:rowBytes fromRegion:MTLRegionMake2D(0, 0, width, height) mipmapLevel:0];
        for (int i = 0; i < 100; i++) {
            NSLog(@"RGB %d %d %d %d", (int) rgb[i * 4] + 256, (int) rgb[i * 4 + 1] + 256, (int) rgb[i * 4 + 2] + 256, (int) rgb[i * 4 + 3] + 256);
        }
        
        
        void *p = malloc(selfturesize);
        
        
        [self.framebufferTexture getBytes:p bytesPerRow:rowBytes fromRegion:MTLRegionMake2D(0, 0, width, height) mipmapLevel:0];
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
        
        CGDataProviderRef provider = CGDataProviderCreateWithData(nil, rgb, selfturesize, nil);
        CGImageRef cgImageRef = CGImageCreate(width, height, 8, 32, rowBytes, colorSpace, bitmapInfo, provider, nil, true, (CGColorRenderingIntent)kCGRenderingIntentDefault);
        
        UIImage *getImage = [UIImage imageWithCGImage:cgImageRef];
        CFRelease(cgImageRef);
        free(p);
        
        if (getImage == nil) {
            NSLog(@"Nil Image");
        }
        
        NSData *jpgData = UIImageJPEGRepresentation(getImage, 1.0f);
        UIImage *jpgImage = [UIImage imageWithData:jpgData];
        
        UIImageWriteToSavedPhotosAlbum(jpgImage, self, @selector(completeSavedImage:didFinishSavingWithError:contextInfo:), nil);
        
        
        
    }
}


@end
