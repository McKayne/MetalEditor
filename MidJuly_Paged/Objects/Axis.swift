//
//  Axis.swift
//  MidJuly_Paged
//
//  Created by для интернета on 29.10.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class Axis {
    
    static var lineVertices: [Vertex] = []
    
    static var bigLineVertices = UnsafeMutablePointer<Vertex>.allocate(capacity: 100000)
    static var bigLineIndices = UnsafeMutablePointer<UInt16>.allocate(capacity: 100000)
    
    static func appendAxis() {
        var lineVertexA = Vertex()
            lineVertexA.position = customFloat4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
            lineVertexA.customColor = customFloat4(x: 255.0 / 255.0, y: 0.0 / 255.0, z: 0.0 / 255.0, w: 1.0)
            var lineVertexB = Vertex()
            lineVertexB.position = customFloat4(x: 1.0, y: 0.0, z: 0.0, w: 1.0)
            lineVertexB.customColor = customFloat4(x: 255.0 / 255.0, y: 0.0 / 255.0, z: 0.0 / 255.0, w: 1.0)
            var lineVertexC = Vertex()
            lineVertexC.position = customFloat4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
            lineVertexC.customColor = customFloat4(x: 255.0 / 255.0, y: 0.0 / 255.0, z: 0.0 / 255.0, w: 1.0)
            
            Axis.bigLineVertices[0 * 3] = lineVertexA
            Axis.bigLineVertices[0 * 3 + 1] = lineVertexB
            Axis.bigLineVertices[0 * 3 + 2] = lineVertexC
            
            Axis.bigLineIndices[0 * 6] = UInt16(0 * 3)
            Axis.bigLineIndices[0 * 6 + 1] = UInt16(0 * 3 + 1)
            
            Axis.bigLineIndices[0 * 6 + 2] = UInt16(0 * 3 + 1)
            Axis.bigLineIndices[0 * 6 + 3] = UInt16(0 * 3 + 2)
            
            Axis.bigLineIndices[0 * 6 + 4] = UInt16(0 * 3 + 2)
            Axis.bigLineIndices[0 * 6 + 5] = UInt16(0 * 3)
        
        
        
        lineVertexA = Vertex()
        lineVertexA.position = customFloat4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
        lineVertexA.customColor = customFloat4(x: 0.0 / 255.0, y: 255.0 / 255.0, z: 0.0 / 255.0, w: 1.0)
        lineVertexB = Vertex()
        lineVertexB.position = customFloat4(x: 0.0, y: 1.0, z: 0.0, w: 1.0)
        lineVertexB.customColor = customFloat4(x: 0.0 / 255.0, y: 255.0 / 255.0, z: 0.0 / 255.0, w: 1.0)
        lineVertexC = Vertex()
        lineVertexC.position = customFloat4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
        lineVertexC.customColor = customFloat4(x: 0.0 / 255.0, y: 255.0 / 255.0, z: 0.0 / 255.0, w: 1.0)
        
        Axis.bigLineVertices[1 * 3] = lineVertexA
        Axis.bigLineVertices[1 * 3 + 1] = lineVertexB
        Axis.bigLineVertices[1 * 3 + 2] = lineVertexC
        
        Axis.bigLineIndices[1 * 6] = UInt16(1 * 3)
        Axis.bigLineIndices[1 * 6 + 1] = UInt16(1 * 3 + 1)
        
        Axis.bigLineIndices[1 * 6 + 2] = UInt16(1 * 3 + 1)
        Axis.bigLineIndices[1 * 6 + 3] = UInt16(1 * 3 + 2)
        
        Axis.bigLineIndices[1 * 6 + 4] = UInt16(1 * 3 + 2)
        Axis.bigLineIndices[1 * 6 + 5] = UInt16(1 * 3)
        
        lineVertexA = Vertex()
        lineVertexA.position = customFloat4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
        lineVertexA.customColor = customFloat4(x: 0.0 / 255.0, y: 0.0 / 255.0, z: 255.0 / 255.0, w: 1.0)
        lineVertexB = Vertex()
        lineVertexB.position = customFloat4(x: 0.0, y: 0.0, z: 1.0, w: 1.0)
        lineVertexB.customColor = customFloat4(x: 0.0 / 255.0, y: 0.0 / 255.0, z: 255.0 / 255.0, w: 1.0)
        lineVertexC = Vertex()
        lineVertexC.position = customFloat4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
        lineVertexC.customColor = customFloat4(x: 0.0 / 255.0, y: 0.0 / 255.0, z: 255.0 / 255.0, w: 1.0)
        
        Axis.bigLineVertices[2 * 3] = lineVertexA
        Axis.bigLineVertices[2 * 3 + 1] = lineVertexB
        Axis.bigLineVertices[2 * 3 + 2] = lineVertexC
        
        Axis.bigLineIndices[2 * 6] = UInt16(2 * 3)
        Axis.bigLineIndices[2 * 6 + 1] = UInt16(2 * 3 + 1)
        
        Axis.bigLineIndices[2 * 6 + 2] = UInt16(2 * 3 + 1)
        Axis.bigLineIndices[2 * 6 + 3] = UInt16(2 * 3 + 2)
        
        Axis.bigLineIndices[2 * 6 + 4] = UInt16(2 * 3 + 2)
        Axis.bigLineIndices[2 * 6 + 5] = UInt16(2 * 3)
    }
}
