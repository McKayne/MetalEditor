
#import <MetalKit/MetalKit.h>

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
@property (nonatomic, strong) MTLVertexDescriptor *vertexDescriptor;
@property (nonatomic, strong) UIViewController *mainView;



@end

@implementation Renderer

@synthesize vertexFunctionName=_vertexFunctionName;
@synthesize fragmentFunctionName=_fragmentFunctionName;

@synthesize isSelectionMode;

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

- (void)test:(UIViewController *)view {
    NSLog(@"TEST");
    self.mainView = view;
}

- (void)handleAsset {
    NSLog(@"ASSET EXPORT TEST");
    
    MTKMeshBufferAllocator *bufferAllocator = [[MTKMeshBufferAllocator alloc] initWithDevice:self.device];
    
    NSURL *assetURL = [[NSBundle mainBundle] URLForResource:@"teapot" withExtension:@"obj"];
    
    MDLVertexDescriptor *mdlVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(self.vertexDescriptor);
    mdlVertexDescriptor.attributes[0].name = MDLVertexAttributePosition;
    mdlVertexDescriptor.attributes[1].name = MDLVertexAttributeNormal;
    mdlVertexDescriptor.attributes[2].name = MDLVertexAttributeTextureCoordinate;
    
    MDLAsset *asset = [[MDLAsset alloc] initWithURL:assetURL vertexDescriptor:mdlVertexDescriptor bufferAllocator:bufferAllocator];
    
    if (asset == nil) {
        NSLog(@"ASSET NIL");
    }
    
    NSURL *newAssetURL = [[NSBundle mainBundle] URLForResource:@"Data/Assets/realship/realship.obj" withExtension:nil];
    
    
    /*BOOL res = [asset exportAssetToURL:newAssetURL];
    if (!res) {
        NSLog(@"NOT SAVED");
    }*/
    //- (BOOL)exportAssetToURL:(NSURL *)URL error:(NSError * _Nullable *)error;
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
    self.vertexDescriptor = [MTLVertexDescriptor vertexDescriptor];
    self.vertexDescriptor.attributes[0].format = MTLVertexFormatFloat4;
    self.vertexDescriptor.attributes[0].bufferIndex = 0;
    self.vertexDescriptor.attributes[0].offset = 0;
    
    self.vertexDescriptor.attributes[1].format = MTLVertexFormatFloat4;
    self.vertexDescriptor.attributes[1].bufferIndex = 0;
    self.vertexDescriptor.attributes[1].offset = sizeof(float) * 4;
    
    self.vertexDescriptor.attributes[2].format = MTLVertexFormatFloat4;
    self.vertexDescriptor.attributes[2].bufferIndex = 0;
    self.vertexDescriptor.attributes[2].offset = sizeof(float) * 8;
    
    self.vertexDescriptor.attributes[3].format = MTLVertexFormatFloat4;
    self.vertexDescriptor.attributes[3].bufferIndex = 0;
    self.vertexDescriptor.attributes[3].offset = sizeof(float) * 12;
    
    self.vertexDescriptor.layouts[0].stride = sizeof(float) * 16;
    self.vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;
    
    MTLRenderPipelineDescriptor *pipelineDescriptor = [MTLRenderPipelineDescriptor new];
    pipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    
    
    
    pipelineDescriptor.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
    
    
    pipelineDescriptor.vertexFunction = [self.library newFunctionWithName:self.vertexFunctionName];
    pipelineDescriptor.fragmentFunction = [self.library newFunctionWithName:self.fragmentFunctionName];
    pipelineDescriptor.vertexDescriptor = self.vertexDescriptor;
    
    // blending
    if (false) {
    MTLRenderPipelineColorAttachmentDescriptor *renderbufferAttachment = pipelineDescriptor.colorAttachments[0];
    renderbufferAttachment.blendingEnabled = YES;
    
    renderbufferAttachment.rgbBlendOperation = MTLBlendOperationAdd;
    renderbufferAttachment.alphaBlendOperation = MTLBlendOperationAdd;

    renderbufferAttachment.sourceRGBBlendFactor = MTLBlendFactorSourceAlpha;
    renderbufferAttachment.sourceAlphaBlendFactor = MTLBlendFactorSourceAlpha;

    renderbufferAttachment.destinationRGBBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    renderbufferAttachment.destinationAlphaBlendFactor = MTLBlendFactorOneMinusSourceAlpha;
    }
    
    MTLDepthStencilDescriptor *depthStencilDescriptor = [MTLDepthStencilDescriptor new];
    depthStencilDescriptor.depthCompareFunction = MTLCompareFunctionLess;
    if (false) {
    depthStencilDescriptor.depthWriteEnabled = NO;//YES;
    } else {
        depthStencilDescriptor.depthWriteEnabled = YES;
    }
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

- (void)startAxisFrame {
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
    //renderPass.colorAttachments[0].clearColor = MTLClearColorMake(255.0 / 255.0, 0.0 / 255.0, 255.0 / 255.0, 1);
    renderPass.colorAttachments[0].clearColor = MTLClearColorMake(0.0 / 255.0, 0.0 / 255.0, 0.0 / 255.0, 0);
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
    
    
    if (false) {
        [self.commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
        [self.commandEncoder setCullMode:MTLCullModeNone];
    } else {
        if (false) {
            [self.commandEncoder setCullMode:MTLCullModeBack];
        } else {
            [self.commandEncoder setCullMode:MTLCullModeNone];
        }
    }
}

- (void)startFrame {
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
    renderPass.colorAttachments[0].clearColor = MTLClearColorMake(57.0 / 255.0, 57.0 / 255.0, 57.0 / 255.0, 1);
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
    
    
    if (false) {
        [self.commandEncoder setFrontFacingWinding:MTLWindingCounterClockwise];
        [self.commandEncoder setCullMode:MTLCullModeNone];
    } else {
        if (true) {
            [self.commandEncoder setCullMode:MTLCullModeBack];
        } else {
            [self.commandEncoder setCullMode:MTLCullModeNone];
        }
    }
}

- (void)drawTrianglesWithInterleavedBuffer:(id<MTLBuffer>)positionBuffer selectionVertexBuffer:(id<MTLBuffer>)selectionVertexBuffer lineVertexBuffer:(id<MTLBuffer>)lineVertexBuffer gridVertexBuffer:(id<MTLBuffer>)gridVertexBuffer
                               indexBuffer:(id<MTLBuffer>)indexBuffer lineIndexBuffer:(id<MTLBuffer>)lineIndexBuffer gridIndexBuffer:(id<MTLBuffer>)gridIndexBuffer
                             uniformBuffer:(id<MTLBuffer>)uniformBuffer
                                indexCount:(size_t)indexCount numberOfObjects:(int)numberOfObjects texture:(id<MTLTexture>) texture {
    if (!positionBuffer || !indexBuffer || !uniformBuffer)
    {
        return;
    }
    
    if (!isSelectionMode) {
        [self.commandEncoder setVertexBuffer:positionBuffer offset:0 atIndex:0];
    } else {
        [self.commandEncoder setVertexBuffer:selectionVertexBuffer offset:0 atIndex:0];
    }
    
    [self.commandEncoder setVertexBuffer:uniformBuffer offset:0 atIndex:1];
    [self.commandEncoder setFragmentBuffer:uniformBuffer offset:0 atIndex:0];
    
    
    
    MTLSamplerDescriptor* descriptor = [[MTLSamplerDescriptor alloc] init];
    descriptor.minFilter             = MTLSamplerMinMagFilterNearest;
    descriptor.magFilter             = MTLSamplerMinMagFilterNearest;
    descriptor.mipFilter             = MTLSamplerMipFilterNearest;
    descriptor.maxAnisotropy         = 1;
    descriptor.sAddressMode          = MTLSamplerAddressModeClampToEdge;
    descriptor.tAddressMode          = MTLSamplerAddressModeClampToEdge;
    descriptor.rAddressMode          = MTLSamplerAddressModeClampToEdge;
    descriptor.normalizedCoordinates = true;
    descriptor.lodMinClamp           = 0;
    descriptor.lodMaxClamp           = FLT_MAX;
    id<MTLSamplerState> sampler = [self.device newSamplerStateWithDescriptor:descriptor];
    [self.commandEncoder setFragmentSamplerState:sampler atIndex:0];
    
    /*MTLTextureDescriptor *desc = [MTLTextureDescriptor texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float width:322 height:480 mipmapped:NO];
    MTKTextureLoader *loader = [[MTKTextureLoader alloc] initWithDevice:self.device];
    
    id<MTLTexture> customTexture = [self.device newTextureWithDescriptor:desc];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"texture1" ofType:@"jpg"];
    customTexture = [loader newTextureWithContentsOfURL:[NSURL fileURLWithPath:path] options:nil error:nil];
    if (customTexture == nil) {
        NSLog(@"NIL texture");
    }
    [self.commandEncoder setFragmentTexture:customTexture atIndex:0];
    
    id<MTLTexture> textureB = [self.device newTextureWithDescriptor:desc];
    NSString *pathB = [[NSBundle mainBundle] pathForResource:@"texture2" ofType:@"jpg"];
    textureB = [loader newTextureWithContentsOfURL:[NSURL fileURLWithPath:pathB] options:nil error:nil];
    if (textureB == nil) {
        NSLog(@"NIL texture");
    }
    [self.commandEncoder setFragmentTexture:textureB atIndex:1];
    
    id<MTLTexture> textureC = [self.device newTextureWithDescriptor:desc];
    NSString *pathC = [[NSBundle mainBundle] pathForResource:@"texture3" ofType:@"jpg"];
    textureC = [loader newTextureWithContentsOfURL:[NSURL fileURLWithPath:pathC] options:nil error:nil];
    if (textureC == nil) {
        NSLog(@"NIL texture");
    }
    [self.commandEncoder setFragmentTexture:textureC atIndex:2];
    
    id<MTLTexture> textureD = [self.device newTextureWithDescriptor:desc];
    NSString *pathD = [[NSBundle mainBundle] pathForResource:@"texture4" ofType:@"jpg"];
    textureD = [loader newTextureWithContentsOfURL:[NSURL fileURLWithPath:pathD] options:nil error:nil];
    if (textureC == nil) {
        NSLog(@"NIL texture");
    }
    [self.commandEncoder setFragmentTexture:textureD atIndex:3];*/
    
    if (numberOfObjects > 0) {
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
    
        if (!isSelectionMode) {
            [self.commandEncoder setVertexBuffer:lineVertexBuffer offset:0 atIndex:0];
            [self.commandEncoder setVertexBuffer:uniformBuffer offset:0 atIndex:1];
            [self.commandEncoder setFragmentBuffer:uniformBuffer offset:0 atIndex:0];
    
            [self.commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeLine
                                    indexCount:(numberOfObjects * 2)
                                     indexType:MTLIndexTypeUInt16
                                   indexBuffer:lineIndexBuffer
                             indexBufferOffset:0];
        }
        
        
    }
    [self.commandEncoder setVertexBuffer:gridVertexBuffer offset:0 atIndex:0];
    [self.commandEncoder setVertexBuffer:uniformBuffer offset:0 atIndex:1];
    [self.commandEncoder setFragmentBuffer:uniformBuffer offset:0 atIndex:0];
    
    [self.commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeLine
                                    indexCount:6 * 34
                                     indexType:MTLIndexTypeUInt16
                                   indexBuffer:gridIndexBuffer
                             indexBufferOffset:0];
}

- (void)drawAxis:(id<MTLBuffer>)positionBuffer selectionVertexBuffer:(id<MTLBuffer>)selectionVertexBuffer lineVertexBuffer:(id<MTLBuffer>)lineVertexBuffer gridVertexBuffer:(id<MTLBuffer>)gridVertexBuffer axisVertexBuffer:(id<MTLBuffer>)axisVertexBuffer indexBuffer:(id<MTLBuffer>)indexBuffer lineIndexBuffer:(id<MTLBuffer>)lineIndexBuffer gridIndexBuffer:(id<MTLBuffer>)gridIndexBuffer
                             uniformBuffer:(id<MTLBuffer>)uniformBuffer
                                indexCount:(size_t)indexCount numberOfObjects:(int)numberOfObjects texture:(id<MTLTexture>) texture {
    if (!positionBuffer || !indexBuffer || !uniformBuffer)
    {
        return;
    }
    
    if (!isSelectionMode) {
        [self.commandEncoder setVertexBuffer:positionBuffer offset:0 atIndex:0];
    } else {
        [self.commandEncoder setVertexBuffer:selectionVertexBuffer offset:0 atIndex:0];
    }
    
    [self.commandEncoder setVertexBuffer:uniformBuffer offset:0 atIndex:1];
    [self.commandEncoder setFragmentBuffer:uniformBuffer offset:0 atIndex:0];
    
    
    
    MTLSamplerDescriptor* descriptor = [[MTLSamplerDescriptor alloc] init];
    descriptor.minFilter             = MTLSamplerMinMagFilterNearest;
    descriptor.magFilter             = MTLSamplerMinMagFilterNearest;
    descriptor.mipFilter             = MTLSamplerMipFilterNearest;
    descriptor.maxAnisotropy         = 1;
    descriptor.sAddressMode          = MTLSamplerAddressModeClampToEdge;
    descriptor.tAddressMode          = MTLSamplerAddressModeClampToEdge;
    descriptor.rAddressMode          = MTLSamplerAddressModeClampToEdge;
    descriptor.normalizedCoordinates = true;
    descriptor.lodMinClamp           = 0;
    descriptor.lodMaxClamp           = FLT_MAX;
    id<MTLSamplerState> sampler = [self.device newSamplerStateWithDescriptor:descriptor];
    [self.commandEncoder setFragmentSamplerState:sampler atIndex:0];
    
        [self.commandEncoder setVertexBuffer:axisVertexBuffer offset:0 atIndex:0];
        [self.commandEncoder setVertexBuffer:uniformBuffer offset:0 atIndex:1];
        [self.commandEncoder setFragmentBuffer:uniformBuffer offset:0 atIndex:0];
        
        [self.commandEncoder drawIndexedPrimitives:MTLPrimitiveTypeLine
                                        indexCount:6 * 3
                                         indexType:MTLIndexTypeUInt16
                                       indexBuffer:gridIndexBuffer
                                 indexBufferOffset:0];
}

- (void)completeSavedImage:(UIImage *)_image didFinishSavingWithError:(NSError *)_error contextInfo:(void *)_contextInfo {
    if (!_error) {
        NSLog(@"Saved");
    }
}

- (void)setView:(UIViewController *)view {
    self.mainView = view;
}

- (int*)pixelColor:(int)x y:(int)y {
    [self.commandBuffer waitUntilCompleted];
    
    int width = (int)[self.framebufferTexture width];
    int height = (int)[self.framebufferTexture height];
    int rowBytes = width * 4;
    int selfturesize = width * height * 4;
    NSLog(@">> %d %d", width, height);
    
    char* rgb = malloc(selfturesize);
    [self.framebufferTexture getBytes:rgb bytesPerRow:rowBytes fromRegion:MTLRegionMake2D(0, 0, width, height) mipmapLevel:0];
    /*for (int i = 0; i < 10; i++) {
        NSLog(@"%d", rgb[i] + 256);
    }*/
    
    int* color = (int*) malloc(sizeof(int) * 3);
    int red = (int) rgb[4 * x + y * rowBytes];
    int green = (int) rgb[4 * x + y * rowBytes + 1];
    int blue = (int) rgb[4 * x + y * rowBytes + 2];
    
    if (red < 0) {
        red += 256;
    }
    if (green < 0) {
        green += 256;
    }
    if (blue < 0) {
        blue += 256;
    }
    
    color[0] = red;
    color[1] = green;
    color[2] = blue;
    
    
    
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
    
    return color;
}

- (void)takeScreenshot {
    [self.commandBuffer waitUntilCompleted];
    
    int width = (int)[self.framebufferTexture width];
    int height = (int)[self.framebufferTexture height];
    int rowBytes = width * 4;
    int selfturesize = width * height * 4;
    NSLog(@">> %d %d", width, height);
    
    char* rgb = malloc(selfturesize);
    [self.framebufferTexture getBytes:rgb bytesPerRow:rowBytes fromRegion:MTLRegionMake2D(0, 0, width, height) mipmapLevel:0];
    /*for (int i = 0; i < 100; i++) {
     NSLog(@"RGB %d %d %d %d", (int) rgb[i * 4] + 256, (int) rgb[i * 4 + 1] + 256, (int) rgb[i * 4 + 2] + 256, (int) rgb[i * 4 + 3] + 256);
     }*/
    
    
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
    
    //UIImage *image = [UIImage imageWithData:[chart getImage]];
    NSArray *activityItems = @[jpgImage];
    UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    activityViewControntroller.excludedActivityTypes = @[];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    activityViewControntroller.popoverPresentationController.sourceView = self.mainView.view;
    activityViewControntroller.popoverPresentationController.sourceRect = CGRectMake(self.mainView.view.bounds.size.width/2, self.mainView.view.bounds.size.height/4, 0, 0);
    }
    [self.mainView presentViewController:activityViewControntroller animated:true completion:nil];
    
    //UIImageWriteToSavedPhotosAlbum(jpgImage, self, @selector(completeSavedImage:didFinishSavingWithError:contextInfo:), nil);
}

- (void)endFrame {
    //NSLog(@"END FRAME");
    
    
    
    [self.commandEncoder endEncoding];
    
    if (self.drawable) {
        [self.commandBuffer presentDrawable:self.drawable];
        [self.commandBuffer commit];
        
        //[self takeScreenshot];
        
        
        
    }
}


@end
