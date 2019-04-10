//
//  NURBSCurve.swift
//  MidJuly_Paged
//
//  Created by для интернета on 09.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class NURBSCurve: SceneObject {
    
    private func appendLine(xStart: Float, yStart: Float, zStart: Float, xEnd: Float, yEnd: Float, zEnd: Float) {
        var v1 = Vertex()
        v1.position = customFloat4(x: xStart, y: yStart, z: zStart, w: 1)
        v1.normal = customFloat4(x: 0, y: 0, z: 0, w: 0)
        v1.customColor = customFloat4(x: 1, y: 0, z: 1, w: 1)
        v1.texCoord = customFloat4(x: 0, y: 0, z: 0, w: 0)
        
        var v2 = Vertex()
        v2.position = customFloat4(x: xEnd, y: yEnd, z: zEnd, w: 1)
        v2.normal = customFloat4(x: 0, y: 0, z: 0, w: 0)
        v2.customColor = customFloat4(x: 1, y: 0, z: 1, w: 1)
        v2.texCoord = customFloat4(x: 0, y: 0, z: 0, w: 0)
        
        vertices.append(v1)
        vertices.append(v2)
        vertices.append(v1)
        
        lineVertices.append(v1)
        lineVertices.append(v2)
        lineVertices.append(v1)
    }
    
    private func appendNURBSCurve() {
        var startFrom: Float = 0, endAt: Float = 6.1
        var segments = 20
        var step: Float = (endAt - startFrom) / Float(segments)
        
        for i in 0..<segments {
            let xStart: Float = Float(i) * step + startFrom
            let xEnd: Float = Float(i + 1) * step + startFrom
            appendLine(xStart: xStart, yStart: nurbs(x: xStart), zStart: 0, xEnd: xEnd, yEnd: nurbs(x: xEnd), zEnd: 0)
        }
        
    }
    
    private func fact(n: Int) -> Int {
        if n == 0 {
            return 1
        } else {
            return n * fact(n: n - 1)
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
    
    private func nurbs(x: Float) -> Float {
        var points: [Float] = [15, 57, 8, 17]
        var w: Float = 1
        
        var sum1: Float = 0
        for i in 1...4 {
            sum1 += w * points[i - 1] * nn(n: 3, i: i, x: x)
        }
        
        var sum2: Float = 0
        for i in 1...4 {
            sum2 += w * nn(n: 3, i: i, x: x)
        }
        
        return sum1 / sum2
    }
    
    override init() {
        super.init()
        
        appendNURBSCurve()
    }
}
