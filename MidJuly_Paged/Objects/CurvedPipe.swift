//
//  CurvedPipe.swift
//  MidJuly_Paged
//
//  Created by для интернета on 15.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class CurvedPipe: SceneObject {
    
    private var x: Float, y: Float, z: Float
    private var radius: Float, height: Float, segments: Int
    private var rgb: (r: Int, g: Int, b: Int)
    
    //private func angleAt(x: Float, )
    
    private func appendCylinder() {
        let segmentAngle: Float = 360.0 / Float(segments)
        
        var position: [customFloat4] = []
        
        let innerRadius: Float = 0.5
        
        var lastHeight: Float = 0
        var currentHeight: Float = 1
        
        for angle in stride(from: 0.0, to: segmentAngle * Float(segments), by: segmentAngle) {
            // outer
            
            let shift: Float = 0.5
            var rad: Float = 0
            //var nth = 0
            var centerX: Float = 0
            
            var bendAngle: Float = 30
            
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius, y: lastHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * radius, y: lastHeight, z: z + sin(angle * 3.14 / 180.0) * radius, w: 1.0))
            
            // rot 1
            let nthA = position.count
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * radius, y: currentHeight, z: z + sin(angle * 3.14 / 180.0) * radius, w: 1.0))
            
            position[nthA].x += shift
            centerX = x + shift
            rad = abs(position[nthA].x - centerX)
            
            if position[nthA].x - centerX < 0 {
                //print(position[nth].x - centerX)
                //print(position[nth].x)
                position[nthA].x = cos((bendAngle + 180) * Float(M_PI) / 180) * rad + centerX
                position[nthA].y = sin((bendAngle + 180) * Float(M_PI) / 180) * rad + currentHeight
                //print(position[nth].x)
                //print("")
            } else {
                position[nthA].x = cos((bendAngle + 0) * Float(M_PI) / 180) * rad + centerX
                position[nthA].y = sin((bendAngle + 0) * Float(M_PI) / 180) * rad + currentHeight
            }
            
            // rot 2
            let nthB = position.count
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * radius, y: currentHeight, z: z + sin(angle * 3.14 / 180.0) * radius, w: 1.0))
            
            position[nthB].x += shift
            centerX = x + shift
            rad = abs(position[nthB].x - centerX)
            
            if position[nthB].x - centerX < 0 {
                //print(position[nth].x - centerX)
                //print(position[nth].x)
                position[nthB].x = cos((bendAngle + 180) * Float(M_PI) / 180) * rad + centerX
                position[nthB].y = sin((bendAngle + 180) * Float(M_PI) / 180) * rad + currentHeight
                //print(position[nth].x)
                //print("")
            } else {
                position[nthB].x = cos((bendAngle + 0) * Float(M_PI) / 180) * rad + centerX
                position[nthB].y = sin((bendAngle + 0) * Float(M_PI) / 180) * rad + currentHeight
            }
            
            // rot 3
            let nthC = position.count
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius, y: currentHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
            
            position[nthC].x += shift
            centerX = x + shift
            rad = abs(position[nthC].x - centerX)
            
            if position[nthC].x - centerX < 0 {
                //print(position[nth].x - centerX)
                //print(position[nth].x)
                position[nthC].x = cos((bendAngle + 180) * Float(M_PI) / 180) * rad + centerX
                position[nthC].y = sin((bendAngle + 180) * Float(M_PI) / 180) * rad + currentHeight
                //print(position[nth].x)
                //print("")
            } else {
                position[nthC].x = cos((bendAngle + 0) * Float(M_PI) / 180) * rad + centerX
                position[nthC].y = sin((bendAngle + 0) * Float(M_PI) / 180) * rad + currentHeight
            }
            
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius, y: lastHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
            
            // inner
            
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * innerRadius, y: lastHeight, z: z + sin(angle * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, y: lastHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, w: 1.0))
            
            // rot 4
            let nthD = position.count
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * innerRadius, y: currentHeight, z: z + sin(angle * 3.14 / 180.0) * innerRadius, w: 1.0))
            
            position[nthD].x += shift
            centerX = x + shift
            rad = abs(position[nthD].x - centerX)
            
            if position[nthD].x - centerX < 0 {
                //print(position[nth].x - centerX)
                //print(position[nth].x)
                position[nthD].x = cos((bendAngle + 180) * Float(M_PI) / 180) * rad + centerX
                position[nthD].y = sin((bendAngle + 180) * Float(M_PI) / 180) * rad + currentHeight
                //print(position[nth].x)
                //print("")
            } else {
                position[nthD].x = cos((bendAngle + 0) * Float(M_PI) / 180) * rad + centerX
                position[nthD].y = sin((bendAngle + 0) * Float(M_PI) / 180) * rad + currentHeight
            }
            
            // rot 5
            let nthE = position.count
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, y: currentHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, w: 1.0))
            
            position[nthE].x += shift
            centerX = x + shift
            rad = abs(position[nthE].x - centerX)
            
            if position[nthE].x - centerX < 0 {
                //print(position[nth].x - centerX)
                //print(position[nth].x)
                position[nthE].x = cos((bendAngle + 180) * Float(M_PI) / 180) * rad + centerX
                position[nthE].y = sin((bendAngle + 180) * Float(M_PI) / 180) * rad + currentHeight
                //print(position[nth].x)
                //print("")
            } else {
                position[nthE].x = cos((bendAngle + 0) * Float(M_PI) / 180) * rad + centerX
                position[nthE].y = sin((bendAngle + 0) * Float(M_PI) / 180) * rad + currentHeight
            }
            
            // rot 6
            let nthF = position.count
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * innerRadius, y: currentHeight, z: z + sin(angle * 3.14 / 180.0) * innerRadius, w: 1.0))
            
            position[nthF].x += shift
            centerX = x + shift
            rad = abs(position[nthF].x - centerX)
            
            if position[nthF].x - centerX < 0 {
                //print(position[nth].x - centerX)
                //print(position[nth].x)
                position[nthF].x = cos((bendAngle + 180) * Float(M_PI) / 180) * rad + centerX
                position[nthF].y = sin((bendAngle + 180) * Float(M_PI) / 180) * rad + currentHeight
                //print(position[nth].x)
                //print("")
            } else {
                position[nthF].x = cos((bendAngle + 0) * Float(M_PI) / 180) * rad + centerX
                position[nthF].y = sin((bendAngle + 0) * Float(M_PI) / 180) * rad + currentHeight
            }
            
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, y: lastHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, w: 1.0))
            
            // top
            
            //position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * radius + shift, y: currentHeight, z: z + sin(angle * 3.14 / 180.0) * radius, w: 1.0))
            position.append(position[nthA])
            
            //position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * innerRadius + shift, y: currentHeight, z: z + sin(angle * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(position[nthD])
            //position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius + shift, y: currentHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
            position.append(position[nthC])
            
            //position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * innerRadius + shift, y: currentHeight, z: z + sin(angle * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(position[nthD])
            //position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * innerRadius + shift, y: currentHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(position[nthE])
            //position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius + shift, y: currentHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
            position.append(position[nthC])
            
            // bottom
            
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * innerRadius, y: lastHeight, z: z + sin(angle * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * radius, y: lastHeight, z: z + sin(angle * 3.14 / 180.0) * radius, w: 1.0))
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius, y: lastHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
            
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, y: lastHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * innerRadius, y: lastHeight, z: z + sin(angle * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius, y: lastHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
        }
        /*lastHeight = 1
        currentHeight = 2
        
        for angle in stride(from: 0.0, to: segmentAngle * Float(segments), by: segmentAngle) {
            // outer
            
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius, y: lastHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * radius, y: lastHeight, z: z + sin(angle * 3.14 / 180.0) * radius, w: 1.0))
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * radius, y: currentHeight, z: z + sin(angle * 3.14 / 180.0) * radius, w: 1.0))
            
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * radius, y: currentHeight, z: z + sin(angle * 3.14 / 180.0) * radius, w: 1.0))
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius, y: currentHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius, y: lastHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
            
            // inner
            
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * innerRadius, y: lastHeight, z: z + sin(angle * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, y: lastHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * innerRadius, y: currentHeight, z: z + sin(angle * 3.14 / 180.0) * innerRadius, w: 1.0))
            
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, y: currentHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * innerRadius, y: currentHeight, z: z + sin(angle * 3.14 / 180.0) * innerRadius, w: 1.0))
            
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, y: lastHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, w: 1.0))
            
            // top
            
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * radius, y: currentHeight, z: z + sin(angle * 3.14 / 180.0) * radius, w: 1.0))
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * innerRadius, y: currentHeight, z: z + sin(angle * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius, y: currentHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
            
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * innerRadius, y: currentHeight, z: z + sin(angle * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, y: currentHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius, y: currentHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
            
            // bottom
            
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * innerRadius, y: lastHeight, z: z + sin(angle * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * radius, y: lastHeight, z: z + sin(angle * 3.14 / 180.0) * radius, w: 1.0))
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius, y: lastHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
            
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, y: lastHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * innerRadius, y: lastHeight, z: z + sin(angle * 3.14 / 180.0) * innerRadius, w: 1.0))
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius, y: lastHeight, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
        }*/
        
        for i in 0..<segments * 3 * 8 * 1 {
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
    
    init(x: Float, y: Float, z: Float, radius: Float, height: Float, segments: Int, rgb: (r: Int, g: Int, b: Int)) {
        self.x = x; self.y = y; self.z = z
        self.radius = radius; self.height = height; self.segments = segments
        self.rgb = rgb
        
        super.init()
        appendCylinder()
    }
}
