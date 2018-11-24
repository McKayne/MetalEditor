//
//  NURBSSurface.swift
//  MidJuly_Paged
//
//  Created by для интернета on 13.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class NURBSSurface: SceneObject {
    
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
    
    private func appendNURBSSurface() {
        
        var position: [customFloat4] = []
        
        let bezierN = 10
        let bezierK = 10
        let hx = 1.0 / Float(bezierN)
        let ht = 1.0 / Float(bezierK)
        
        var offsets: [[Float]] = []
        let diffX: Float = width / 11.0
        let diffY: Float = depth / 11.0
        
        //let bezierX: Float =
        //
        
        for i in 0..<11 {
            
            var off: [Float] = []
            for j in 0..<11 {
                
                let currentX = Float(j) * diffX
                let currentY = Float(i) * diffY
                
                off.append(g(s: currentX, t: currentY))
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
    
    private func nn(n: Int, i: Int, x: Float) -> Float {
        var k: [Float] = [0, 1, 2, 2.5, 4, 4.5, 5.3, 6.1]
        
        if n > 0 {
            return (x - k[i - 1]) / (k[i + n - 1] - k[i - 1]) * nn(n: n - 1, i: i, x: x) + (k[i + n] - x) / (k[i + n] - k[i]) * nn(n: n - 1, i: i + 1, x: x)
        } else {
            if k[i - 1] <= x && x < k[i] {
                return 1
            } else {
                return 0
            }
        }
    }
    
    private func g(s: Float, t: Float) -> Float {
        
        let knots: [Float] = [0, 1, 2, 2.5, 4, 4.5, 5.3, 6.1]
        let points: [Float] = [15, 57, 8, 17]
        
        let w: Float = 1.0
        
        var sum1: Float = 0
        for i in 1...4 {
            
            var sum1b: Float = 0
            for j in 1...4 {
                sum1b += w * nn(n: 3, i: i, x: s) * nn(n: 3, i: j, x: t) * points[j - 1]
            }
            
            sum1 += sum1b
        }
        
        var sum2: Float = 0
        for i in 1...4 {
            
            var sum2b: Float = 0
            for j in 1...4 {
                sum2b += w * nn(n: 3, i: i, x: s) * nn(n: 3, i: j, x: t)
            }
            
            sum2 += sum2b
        }
        
        return sum1 / sum2
    }
    
    init(x: Float, y: Float, z: Float, width: Float, depth: Float, rgb: (r: Int, g: Int, b: Int)) {
        self.x = x; self.y = y; self.z = z
        self.width = width; self.depth = depth
        self.rgb = rgb
        
        super.init()
        appendNURBSSurface()
    }
}
