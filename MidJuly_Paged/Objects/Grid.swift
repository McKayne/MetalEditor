//
//  Grid.swift
//  MidJuly_Paged
//
//  Created by для интернета on 29.10.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class Grid {
    
    static var lineVertices: [Vertex] = []
    
    static var bigLineVertices = UnsafeMutablePointer<Vertex>.allocate(capacity: 100000)
    static var bigLineIndices = UnsafeMutablePointer<UInt16>.allocate(capacity: 100000)
    
    static func appendGrid() {
        for i in 0...16 {
            var lineColor: customFloat4
            
            if i == 8 {
                lineColor = customFloat4(x: 132.0 / 255.0, y: 22.0 / 255.0, z: 22.0 / 255.0, w: 1.0)
            } else {
                lineColor = customFloat4(x: 74.0 / 255.0, y: 74.0 / 255.0, z: 74.0 / 255.0, w: 1.0)
            }
            
            var lineVertexA = Vertex()
            lineVertexA.position = customFloat4(x: -5.0, y: 0.0, z: Float(i) * 0.625 - 5.0, w: 1.0)
            lineVertexA.customColor = lineColor
            var lineVertexB = Vertex()
            lineVertexB.position = customFloat4(x: 5.0, y: 0.0, z: Float(i) * 0.625 - 5.0, w: 1.0)
            lineVertexB.customColor = lineColor
            var lineVertexC = Vertex()
            lineVertexC.position = customFloat4(x: -5.0, y: 0.0, z: Float(i) * 0.625 - 5.0, w: 1.0)
            lineVertexC.customColor = lineColor
            
            Grid.bigLineVertices[i * 3] = lineVertexA
            Grid.bigLineVertices[i * 3 + 1] = lineVertexB
            Grid.bigLineVertices[i * 3 + 2] = lineVertexC
            
            Grid.bigLineIndices[i * 6] = UInt16(i * 3)
            Grid.bigLineIndices[i * 6 + 1] = UInt16(i * 3 + 1)
            
            Grid.bigLineIndices[i * 6 + 2] = UInt16(i * 3 + 1)
            Grid.bigLineIndices[i * 6 + 3] = UInt16(i * 3 + 2)
            
            Grid.bigLineIndices[i * 6 + 4] = UInt16(i * 3 + 2)
            Grid.bigLineIndices[i * 6 + 5] = UInt16(i * 3)
        }
        for i in 0...16 {
            var lineColor: customFloat4
            
            if i == 8 {
                lineColor = customFloat4(x: 22.0 / 255.0, y: 132.0 / 255.0, z: 22.0 / 255.0, w: 1.0)
            } else {
                lineColor = customFloat4(x: 74.0 / 255.0, y: 74.0 / 255.0, z: 74.0 / 255.0, w: 1.0)
            }
            
            var lineVertexA = Vertex()
            lineVertexA.position = customFloat4(x: Float(i) * 0.625 - 5.0, y: 0.0, z: -5.0, w: 1.0)
            lineVertexA.customColor = lineColor
            var lineVertexB = Vertex()
            lineVertexB.position = customFloat4(x: Float(i) * 0.625 - 5.0, y: 0.0, z: 5.0, w: 1.0)
            lineVertexB.customColor = lineColor
            var lineVertexC = Vertex()
            lineVertexC.position = customFloat4(x: Float(i) * 0.625 - 5.0, y: 0.0, z: -5.0, w: 1.0)
            lineVertexC.customColor = lineColor
            
            Grid.bigLineVertices[(i + 17) * 3] = lineVertexA
            Grid.bigLineVertices[(i + 17) * 3 + 1] = lineVertexB
            Grid.bigLineVertices[(i + 17) * 3 + 2] = lineVertexC
            
            Grid.bigLineIndices[(i + 17) * 6] = UInt16((i + 17) * 3)
            Grid.bigLineIndices[(i + 17) * 6 + 1] = UInt16((i + 17) * 3 + 1)
            
            Grid.bigLineIndices[(i + 17) * 6 + 2] = UInt16((i + 17) * 3 + 1)
            Grid.bigLineIndices[(i + 17) * 6 + 3] = UInt16((i + 17) * 3 + 2)
            
            Grid.bigLineIndices[(i + 17) * 6 + 4] = UInt16((i + 17) * 3 + 2)
            Grid.bigLineIndices[(i + 17) * 6 + 5] = UInt16((i + 17) * 3)
        }
    }
}
