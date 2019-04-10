//
//  Node.swift
//  EarlyJuneNM_SV
//
//  Created by для интернета on 06.07.18.
//  Copyright © 2018 для интернета. All rights reserved.
//


import Foundation
import Metal
import QuartzCore

class Node {
    
    let device: MTLDevice
    let name: String
    var vertexCount: Int = 0
    var vertexBuffer: MTLBuffer? = nil, lineVertexBuffer: MTLBuffer? = nil
    
    var positionX: Float = 0.0
    var positionY: Float = 0.0
    var positionZ: Float = 0.0
    
    var rotationX: Float = 0.0
    var rotationY: Float = 0.0
    var rotationZ: Float = 0.0
    var scale: Float     = 1.0
    
    func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, parentModelViewMatrix: Matrix4, projectionMatrix: Matrix4, clearColor: MTLClearColor?) {
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor =
            MTLClearColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0)
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        var commandBuffer = commandQueue.makeCommandBuffer()
        
        var renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        //renderEncoder.setCullMode(MTLCullMode.front)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        
        // 1
        var nodeModelMatrix = self.modelMatrix()
        nodeModelMatrix.multiply(left: parentModelViewMatrix)
        // 2
        var uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * 16 * 2, options: [])
        // 3
        var bufferPointer = uniformBuffer.contents()
        // 4
        memcpy(bufferPointer, nodeModelMatrix.raw, MemoryLayout<Float>.size * 16)
        memcpy(bufferPointer + MemoryLayout<Float>.size * 16, projectionMatrix.raw, MemoryLayout<Float>.size * 16)
        // 5
        renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 1)
        
        /*[encoder drawIndexedPrimitives:MTLPrimitiveTypeLine
            indexCount:
            indexType:
            indexBuffer:
            indexBufferOffset:];*/
        
        //if true {
            
          //  renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: vertexCount,
         //                                instanceCount: vertexCount/3)
        //} else {
        renderEncoder.setCullMode(MTLCullMode.front)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount,
                                     instanceCount: vertexCount/3, baseInstance: 0)
        //renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: vertexCount,
        //                             instanceCount: vertexCount/3, baseInstance: 1)
        //}
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        
        /*
        //renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        //renderEncoder.setCullMode(MTLCullMode.front)
        //renderEncoder.setRenderPipelineState(pipelineState)
        //renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        
        // 1
        nodeModelMatrix = self.modelMatrix()
        nodeModelMatrix.multiply(left: parentModelViewMatrix)
        // 2
        uniformBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * 16 * 2, options: [])
        // 3
        bufferPointer = uniformBuffer.contents()
        // 4
        memcpy(bufferPointer, nodeModelMatrix.raw, MemoryLayout<Float>.size * 16)
        memcpy(bufferPointer + MemoryLayout<Float>.size * 16, projectionMatrix.raw, MemoryLayout<Float>.size * 16)
        // 5
        //renderEncoder.setVertexBuffer(uniformBuffer, offset: 0, at: 1)
        
        /*[encoder drawIndexedPrimitives:MTLPrimitiveTypeLine
         indexCount:
         indexType:
         indexBuffer:
         indexBufferOffset:];*/
        
        //if true {
        
        //  renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: vertexCount,
        //                                instanceCount: vertexCount/3)
        //} else {
        renderEncoder.setCullMode(MTLCullMode.front)
        //renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertexCount,
        //                             instanceCount: vertexCount/3)
        renderEncoder.drawPrimitives(type: .line, vertexStart: 0, vertexCount: vertexCount,
                                     instanceCount: vertexCount/3)
        //}
        renderEncoder.endEncoding()
        */
        
        //commandBuffer.present(drawable)
        //commandBuffer.commit()
        
        
    }
    
    func finalize(vertices: [Vertex]) {
        // 1
        var vertexData = Array<Float>()
        /*for vertex in vertices{
            vertexData += vertex.floatBuffer()
        }*/
        
        // 2
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: [])
        
        
        vertexCount = vertices.count
    }
    
    init(name: String, device: MTLDevice){
        
        // 3
        self.name = name
        self.device = device
        vertexCount = 0
        //vertexBuffer
        
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
    
    func modelMatrix() -> Matrix4 {
        let matrix = Matrix4()
        matrix.translate(x: positionX, y: positionY, z: positionZ)
        matrix.rotateAround(x: rotationX, y: rotationY, z: rotationZ)
        matrix.scale(x: scale, y: scale, z: scale)
        return matrix
    }
}
