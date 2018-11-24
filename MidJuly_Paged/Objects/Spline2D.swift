//
//  Spline2D.swift
//  MidJuly_Paged
//
//  Created by для интернета on 14.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class Spline2D: SceneObject {
    
    private var x: Float, y: Float, z: Float
    private var width: Float, depth: Float
    private var rgb: (r: Int, g: Int, b: Int)
    
    private var a: [[Float]] = []
    
    func makeFace(position: inout [customFloat4], xStart: Float, yStart: Float, xEnd: Float, yEnd: Float) {
        position.append(customFloat4(x: xEnd, y: y, z: yStart, w: 1.0))
        position.append(customFloat4(x: xEnd, y: y, z: yEnd, w: 1.0))
        position.append(customFloat4(x: xStart, y: y, z: yEnd, w: 1.0))
        
        position.append(customFloat4(x: xStart, y: y, z: yStart, w: 1.0))
        position.append(customFloat4(x: xEnd, y: y, z: yStart, w: 1.0))
        position.append(customFloat4(x: xStart, y: y, z: yEnd, w: 1.0))
    }
    
    private func appendSpline() {
        
        var position: [customFloat4] = []
        
        let bezierN = 10
        let bezierK = 10
        let hx = 1.0 / Float(bezierN)
        let ht = 1.0 / Float(bezierK)
        
        var offsets: [[Float]] = []
        let diffX: Float = width / 11.0
        let diffY: Float = depth / 11.0
        for i in 0..<11 {
            var off: [Float] = []
            for j in 0..<11 {
                //off.append(((Float(arc4random()) / Float(UINT32_MAX)) - 0.5) * 1.0)
                
                let bezierY: Float = Float(i) * ht
                let bezierX: Float = Float(j) * hx
                
                off.append(p(x: bezierX, y: bezierY))
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
    
    private func f(x: Float, y: Float) -> Float {
        return sin(x) * sin(y)
    }
    
    private func dx(x: Float, y: Float) -> Float {
        let h: Float = pow(10, -4)
        return (f(x: x + h, y: y) - f(x: x, y: y)) / h
    }
    
    private func dy(x: Float, y: Float) -> Float {
        let h: Float = pow(10, -4)
        return (f(x: x, y: y + h) - f(x: x, y: y)) / h
    }
    
    private func matrixVectorMultiply(a: [[Float]], b: [Float]) -> [Float] {
        var c: [Float] = []
        
        for i in 0..<a.count {
            var sum: Float = 0
            for r in 0..<a.count {
                sum += a[i][r] * b[r]
            }
            c.append(sum)
        }
        
        return c
    }
    
    private func makeSpline() {
        let matA: [[Float]] = [[1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [-3, 3, 0, 0, -2, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [2, -2, 0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, -3, 3, 0, 0, -2, -1, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 2, -2, 0, 0, 1, 1, 0, 0],
            [-3, 0, 3, 0, 0, 0, 0, 0, -2, 0, -1, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, -3, 0, 3, 0, 0, 0, 0, 0, -2, 0, -1, 0],
            [9, -9, -9, 9, 6, 3, -6, -3, 6, -6, 3, -3, 4, 2, 2, 1],
            [-6, 6, 6, -6, -3, -3, 3, 3, -4, 4, -2, 2, -2, -2, -1, -1],
            [2, 0, -2, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 2, 0, -2, 0, 0, 0, 0, 0, 1, 0, 1, 0],
            [-6, 6, 6, -6, -4, -2, 4, 2, -3, 3, -3, 3, -2, -1, -2, -1],
            [4, -4, -4, 4, 2, 2, -2, -2, 2, -2, 2, -2, 1, 1, 1, 1]]
        let matB: [Float] = [f(x: 0, y: 0), f(x: 1, y: 0), f(x: 0, y: 1), f(x: 1, y: 1), dx(x: 0, y: 0), dx(x: 1, y: 0), dx(x: 0, y: 1), dx(x: 1, y: 1), dy(x: 0, y: 0), dy(x: 1, y: 0), dy(x: 0, y: 1), dy(x: 1, y: 1), 0.05, 0.03, -0.1, 0.1]
        let vectA = matrixVectorMultiply(a: matA, b: matB)
        a = []
        for i in 0..<4 {
            var aRow: [Float] = []
            for j in 0..<4 {
                aRow.append(vectA[j + i * 4])
            }
            a.append(aRow)
        }
    }
    
    private func p(x: Float, y: Float) -> Float {
        var p: Float = 0
        for i in 0..<4 {
            var sum1: Float = 0
            for j in 0..<4 {
                sum1 += a[i][j] * pow(x, Float(i)) * pow(y, Float(j))
            }
    
            p += sum1
        }
        return p
    }
    
    init(x: Float, y: Float, z: Float, width: Float, depth: Float, rgb: (r: Int, g: Int, b: Int)) {
        self.x = x; self.y = y; self.z = z
        self.width = width; self.depth = depth
        self.rgb = rgb
        
        super.init()
        makeSpline()
        appendSpline()
    }
}
