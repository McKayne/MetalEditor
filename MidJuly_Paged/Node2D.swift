import Foundation
import Metal
import QuartzCore

class Node2D {
    
    let device: MTLDevice
    let name: String
    var vertexCount: Int = 0
    var vertexBuffer: MTLBuffer?
    
    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, clearColor: MTLClearColor?){
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        
        renderPassDescriptor.colorAttachments[0].clearColor =
            MTLClearColor(red: 0.0 / 255.0, green: 109.0 / 255.0, blue: 222.0 / 255.0, alpha: 1.0)
        
        //renderPassDescriptor.colorAttachments[0].clearColor =
            //MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        
        renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: vertexCount,
                                     instanceCount: vertexCount / 2)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    func finalize(vertices: Array<LineVertex>) {
        // 1
        var vertexData = Array<Float>()
        for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }
        
        // 2
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
    
        vertexCount = vertices.count
    }
    
    init(name: String, device: MTLDevice){
        
        
        
        
        // 3
        self.name = name
        self.device = device
        
    }
    
    init(name: String, vertices: Array<Vertex>, device: MTLDevice){
        // 1
        var vertexData = Array<Float>()
        /*for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }*/
        
        // 2
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        // 3
        self.name = name
        self.device = device
        vertexCount = vertices.count
    }
    
}
