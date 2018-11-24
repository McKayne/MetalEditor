//
//  BezierCurve.swift
//  MidJuly_Paged
//
//  Created by для интернета on 09.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class BezierCurve: SceneObject {
    
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
    
    private func appendBezierCurve() {
        var startFrom: Float = 0, endAt: Float = 1
        var segments = 10
        var step: Float = (endAt - startFrom) / Float(segments)
        
        for i in 0..<segments {
            let xStart: Float = Float(i) * step + startFrom
            let xEnd: Float = Float(i + 1) * step + startFrom
            appendLine(xStart: xStart, yStart: bezier(x: xStart), zStart: 0, xEnd: xEnd, yEnd: bezier(x: xEnd), zEnd: 0)
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
    
    private func bezier(x: Float) -> Float {
        var p: [Float] = [1.0, 2.75, 3.0, 1.0]
        var n = p.count - 1
        
        var b: Float = 0
        for i in 0...n {
            b += Float(binomial(n: n, i: i)) * Float(pow(Double(1.0 - x), Double(n - i))) * Float(pow(Double(x), Double(i))) * p[i]
        }
        
        return b
    }
    
    override init() {
        super.init()
        
        appendBezierCurve()
    }
}
