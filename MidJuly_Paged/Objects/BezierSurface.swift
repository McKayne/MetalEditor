//
//  BezierSurface.swift
//  MidJuly_Paged
//
//  Created by для интернета on 13.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class BezierSurface: SceneObject {
    
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
    
    private func appendBezierSurface() {
        
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
            
            let bezierY: Float = Float(i) * ht
            
            var off: [Float] = []
            for j in 0..<11 {
                
                let bezierX: Float = Float(j) * hx
                
                //off.append(((Float(arc4random()) / Float(UINT32_MAX)) - 0.5) * 1.0)
                off.append(p(u: bezierX, v: bezierY))
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
    
    private func fact(n: Int) -> Int {
        if n == 0 {
            return 1
        } else {
            return n * fact(n: n - 1)
        }
    }
    
    private func binomial(n: Int, i: Int) -> Int {
        return fact(n: n) / (fact(n: i) * fact(n: n - i))
    }
    
    func p(u: Float, v: Float) -> Float {
        
        let points: [[Float]] = [[1, 2.75, 3, 1],
                                 [2.75, 3.5, 4, 2.75],
                                 [3, 4.25, 5, 3],
                                 [1, 2.75, 3, 1]]
        
        var puv: Float = 0
        
        for i in 0..<4 {
            
            var sum: Float = 0
            for j in 0..<4 {
                sum += Float(binomial(n: 3, i: i)) * Float(pow(Double(1.0 - u), Double(3 - i))) * Float(pow(Double(u), Double(i))) * Float(binomial(n: 3, i: j)) * Float(pow(Double(1.0 - v), Double(3 - j))) * Float(pow(Double(v), Double(j))) * points[i][j]
            }
            
            puv += sum
        }
        
        return puv
    }
    
    init(x: Float, y: Float, z: Float, width: Float, depth: Float, rgb: (r: Int, g: Int, b: Int)) {
        self.x = x; self.y = y; self.z = z
        self.width = width; self.depth = depth
        self.rgb = rgb
        
        super.init()
        appendBezierSurface()
    }
}
