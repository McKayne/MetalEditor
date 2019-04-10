//
//  SurfaceOfRevolution.swift
//  MidJuly_Paged
//
//  Created by для интернета on 01.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class SurfaceOfRevolution: SceneObject {
    
    private var x: Float, y: Float, z: Float
    private var width: Float, depth: Float
    private var rgb: (r: Int, g: Int, b: Int)
    
    func makeFace(position: inout [customFloat4], xStart: Float, yStart: Float, xEnd: Float, yEnd: Float) {
        position.append(customFloat4(x: xEnd, y: y, z: yStart, w: 1.0))
        position.append(customFloat4(x: xEnd, y: y, z: yEnd, w: 1.0))
        position.append(customFloat4(x: xStart, y: y, z: yEnd, w: 1.0))
        
        position.append(customFloat4(x: xStart, y: y, z: yStart, w: 1.0))
        position.append(customFloat4(x: xEnd, y: y, z: yStart, w: 1.0))
        position.append(customFloat4(x: xStart, y: y, z: yEnd, w: 1.0))
    }
    
    private func f(x: Float) -> Float {
        return 1 / (1 + x * x)
    }
    
    private func appendSurfaceOfRevolution() {
        
        var position: [customFloat4] = []
        
        var offsets: [[Float]] = []
        let diffX: Float = width / 11.0
        let diffY: Float = depth / 11.0
        for i in 0..<11 {
            var off: [Float] = []
            for j in 0..<11 {
                let xCurrent = Float(j) * diffX
                let yCurrent = Float(i) * diffY
                let angle: Float = sqrt(xCurrent * xCurrent + yCurrent * yCurrent)
                
                //off.append(((Float(arc4random()) / Float(UINT32_MAX)) - 0.5) * 1.0)
                off.append(f(x: angle))
            }
            offsets.append(off)
        }
        
        // top face
        
        var widthDiff: Float = width / 10.0
        var depthDiff: Float = depth / 10.0
        
        for j in 0..<10 {
            for i in 0..<10 {
                position.append(customFloat4(x: x + Float(i + 1) * widthDiff, y: y + offsets[j][i + 1], z: z - Float(j) * depthDiff, w: 1.0))
                position.append(customFloat4(x: x + Float(i + 1) * widthDiff, y: y + offsets[j + 1][i + 1], z: z - Float(j + 1) * depthDiff, w: 1.0))
                position.append(customFloat4(x: x + Float(i) * widthDiff, y: y + offsets[j + 1][i], z: z - Float(j + 1) * depthDiff, w: 1.0))
                
                position.append(customFloat4(x: x + Float(i) * widthDiff, y: y + offsets[j][i], z: z - Float(j) * depthDiff, w: 1.0))
                position.append(customFloat4(x: x + Float(i + 1) * widthDiff, y: y + offsets[j][i + 1], z: z - Float(j) * depthDiff, w: 1.0))
                position.append(customFloat4(x: x + Float(i) * widthDiff, y: y + offsets[j + 1][i], z: z - Float(j + 1) * depthDiff, w: 1.0))
                
                //makeFace(position: &position, xStart: x + Float(i) * widthDiff, yStart: z, xEnd: x + Float(i + 1) * widthDiff, yEnd: z - depth)
            }
        }
        //    makeFace(position: &position, xStart: x + width / 2, yStart: z, xEnd: x + width, yEnd: z - depth)
        
        for i in 0..<position.count {
            //indices.append(i)
            
            var vertex: Vertex = Vertex()
            vertex.position = position[i]
            vertex.customColor = customFloat4(x: Float(rgb.r) / 255.0, y: Float(rgb.g) / 255.0, z: Float(rgb.b) / 255.0, w: 1.0)
            
            var lineVertex: Vertex = Vertex()
            lineVertex.position = position[i]
            lineVertex.customColor = customFloat4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
            
            vertices.append(vertex)
            lineVertices.append(lineVertex)
        }
    }
    
    init(x: Float, y: Float, z: Float, width: Float, depth: Float, rgb: (r: Int, g: Int, b: Int)) {
        self.x = x; self.y = y; self.z = z
        self.width = width; self.depth = depth
        self.rgb = rgb
        
        super.init()
        appendSurfaceOfRevolution()
    }
}
