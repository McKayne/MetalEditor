//
//  Spline.swift
//  MidJuly_Paged
//
//  Created by для интернета on 14.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class Spline: SceneObject {
    
    private let points: [Float], f: [Float]
    private var a: [Float] = []
    private var b: [Float] = []
    private var c: [Float] = []
    private var d: [Float] = []
    
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
        var startFrom: Float = 0, endAt: Float = 4
        var segments = 20
        var step: Float = (endAt - startFrom) / Float(segments)
        
        for i in 0..<segments {
            let xStart: Float = Float(i) * step + startFrom
            let xEnd: Float = Float(i + 1) * step + startFrom
            appendLine(xStart: xStart, yStart: s(x: xStart), zStart: 0, xEnd: xEnd, yEnd: s(x: xEnd), zEnd: 0)
        }
        
    }
    
    private func s(x: Float) -> Float {
        let i = indexOf(x: x)
        return a[i] + b[i] * (x - points[i]) + c[i] * pow(x - points[i], 2) + d[i] * pow(x - points[i], 3)
    }
    
    private func indexOf(x: Float) -> Int {
        var index = 0
        while x > points[index + 1] {
            index += 1
        }
        return index
    }
    
    private func makeSpline() {
        let n = f.count - 1
        print(n)
        
        a = []
        for i in 0..<n {
            a.append(f[i])
        }
        print(a)
        
        var h: [Float] = []
        for i in 0..<n {
            h.append(points[i + 1] - points[i])
        }
        print(h)
        
        var matA: [[Float]] = []
        var matB: [Float] = []
        for i in 0..<(n - 1) {
            var matArow: [Float] = []
            for _ in 0..<(n - 1) {
                matArow.append(0)
            }
            
            if i > 0 {
                matArow[i - 1] = h[i - 1]
            }
        
            matArow[i] = 2 * (h[i] + h[i + 1])
        
            if i < n - 2 {
                matArow[i + 1] = h[i + 1]
            }
        
            matA.append(matArow)
            matB.append(3 * ((f[i + 2] - f[i + 1]) / h[i + 1] - (f[i + 1] - f[i]) / h[i]))
        }
        print(matA)
        print(matB)
        
        var matC = Tridiag(a: matA, b: matB).findSolution()
        c = [0]
        for i in 0..<(n - 1) {
            c.append(matC[i])
        }
        print(c)
        
        b = []
        for i in 0..<(n - 1) {
            b.append((f[i + 1] - f[i]) / h[i] - h[i] * (c[i + 1] + 2 * c[i]) / 3)
        }
        b.append((f[n] - f[n - 1]) / h[n - 1] - 2 * h[n - 1] * c[n - 1] / 3)
        print(b)
        
        d = []
        for i in 0..<(n - 1) {
            d.append((c[i + 1] - c[i]) / (3 * h[i]))
        }
        d.append(-c[n - 1] / (3 * h[n - 1]))
        print(d)
    }
    
    init(points: [Float], f: [Float]) {
        self.points = points
        self.f = f
        
        super.init()
        
        makeSpline()
        
        appendNURBSCurve()
    }
}
