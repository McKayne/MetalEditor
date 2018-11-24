//
//  Chessboard.swift
//  MidJuly_Paged
//
//  Created by для интернета on 16.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation
import simd

class Chessboard: SceneObject {
    
    private var x: Float, y: Float, z: Float
    private var width: Float, height: Float, depth: Float
    private var rgb: (r: Int, g: Int, b: Int)
    private var topBorder: Float
    
    private func makeFace(position: inout [customFloat4], a: float3, b: float3, c: float3, d: float3, offset: Int) {
        position.append(customFloat4(x: a.x, y: a.y, z: a.z, w: 1.0))
        position.append(customFloat4(x: b.x, y: b.y, z: b.z, w: 1.0))
        position.append(customFloat4(x: c.x, y: c.y, z: c.z, w: 1.0))
    
        position.append(customFloat4(x: d.x, y: d.y, z: d.z, w: 1.0))
        position.append(customFloat4(x: c.x, y: c.y, z: c.z, w: 1.0))
        position.append(customFloat4(x: b.x, y: b.y, z: b.z, w: 1.0))
    }
    
    private func appendDiamond() {
        var position: [customFloat4] = []
        
        // front
        
        position.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x + width, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z, w: 1.0))
        
        position.append(customFloat4(x: x + width, y: y + height, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y + height, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        
        //right
        
        position.append(customFloat4(x: x + width, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x + width, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z, w: 1.0))
        
        position.append(customFloat4(x: x + width, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z, w: 1.0))
        
        // back
        
        position.append(customFloat4(x: x + width, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z - depth, w: 1.0))
        
        position.append(customFloat4(x: x, y: y + height, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z - depth, w: 1.0))
        
        // left
        
        position.append(customFloat4(x: x, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y + height, z: z - depth, w: 1.0))
        
        position.append(customFloat4(x: x, y: y + height, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y + height, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        
        // top front
        
        position.append(customFloat4(x: x + width, y: y + height, z: z, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z - topBorder, w: 1.0))
        position.append(customFloat4(x: x, y: y + height, z: z - topBorder, w: 1.0))
    
        position.append(customFloat4(x: x, y: y + height, z: z, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y + height, z: z - topBorder, w: 1.0))
        
        // top back
        
        position.append(customFloat4(x: x + width, y: y + height, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x, y: y + height, z: z - depth + topBorder, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z - depth + topBorder, w: 1.0))
    
        position.append(customFloat4(x: x, y: y + height, z: z - depth + topBorder, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x, y: y + height, z: z - depth, w: 1.0))
    
        // top left
    
        position.append(customFloat4(x: x + topBorder, y: y + height, z: z - depth + topBorder, w: 1.0))
        position.append(customFloat4(x: x, y: y + height, z: z - depth + topBorder, w: 1.0))
        position.append(customFloat4(x: x + topBorder, y: y + height, z: z - topBorder, w: 1.0))
        
        position.append(customFloat4(x: x, y: y + height, z: z - topBorder, w: 1.0))
        position.append(customFloat4(x: x + topBorder, y: y + height, z: z - topBorder, w: 1.0))
        position.append(customFloat4(x: x, y: y + height, z: z - depth + topBorder, w: 1.0))
        
        /*position[42] = {x + width, y + height, z - depth + topBorder, 1.0};
         position[43] = {x + width - topBorder, y + height, z - depth + topBorder, 1.0};
         position[44] = {x + width, y + height, z - topBorder, 1.0};
         
         position[45] = {x + width - topBorder, y + height, z - topBorder, 1.0};
         position[46] = {x + width, y + height, z - topBorder, 1.0};
         position[47] = {x + width - topBorder, y + height, z - depth + topBorder, 1.0};*/
        
        // bottom
        
        position.append(customFloat4(x: x + width, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y, z: z - depth, w: 1.0))
        
        position.append(customFloat4(x: x, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        
        // top right
        
        makeFace(position: &position, a: float3(x: x + width, y: y + height, z: z - depth + topBorder), b: float3(x: x + width - topBorder, y: y + height, z: z - depth + topBorder), c: float3(x: x + width, y: y + height, z: z - topBorder), d: float3(x: x + width - topBorder, y: y + height, z: z - topBorder), offset: 48)
        
        // tops
        
        let cell: Float = ((x + width - topBorder) - (x + topBorder)) / 8.0
        for j in 0..<8 {
            for i in 0..<8 {
                makeFace(position: &position, a: float3(x: x + topBorder + cell * Float(i + 1), y: y + height, z: z - topBorder - cell * Float(j + 1)), b: float3(x: x + topBorder + cell * Float(i), y: y + height, z: z - topBorder - cell * Float(j + 1)), c: float3(x: x + topBorder + cell * Float(i + 1), y: y + height, z: z - topBorder - cell * Float(j)), d: float3(x: x + topBorder + cell * Float(i), y: y + height, z: z - topBorder - cell * Float(j)), offset: 54 + i * 6 + j * 6 * 8)
            }
        }
        
        
        for i in 0..<54 {
            var vertex: Vertex = Vertex()
            vertex.position = position[i]
            vertex.customColor = customFloat4(x: Float(rgb.r) / 255.0, y: Float(rgb.g) / 255.0, z: Float(rgb.b) / 255.0, w: 1.0)
            
            var lineVertex: Vertex = Vertex()
            lineVertex.position = position[i]
            lineVertex.customColor = customFloat4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
            
            vertices.append(vertex)
            lineVertices.append(lineVertex)
        }
        var isBlack = false
        var vertNth = 0, row = 0;
        for i in 54..<(54 + 6 * 8 * 8) {
            var vertex: Vertex = Vertex()
            vertex.position = position[i]
            
            if !isBlack {
                vertex.customColor = customFloat4(x: 1.0, y: 1.0, z: 0, w: 1)
            } else {
                vertex.customColor = customFloat4(x: 1.0, y: 0, z: 0, w: 1)
            }
            
            var lineVertex: Vertex = Vertex()
            lineVertex.position = position[i]
            lineVertex.customColor = customFloat4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
            
            vertices.append(vertex)
            lineVertices.append(lineVertex)
            
            vertNth += 1
            if vertNth == 6 {
                vertNth = 0
                row += 1
                
                if row == 8 {
                    row = 0
                } else {
                    isBlack = !isBlack
                }
            }
        }
    }
    
    init(x: Float, y: Float, z: Float, width: Float, height: Float, depth: Float, topBorder: Float, rgb: (r: Int, g: Int, b: Int)) {
        self.x = x; self.y = y; self.z = z
        self.width = width; self.height = height; self.depth = depth
        self.topBorder = topBorder
        self.rgb = rgb
        
        super.init()
        appendDiamond()
    }
}
