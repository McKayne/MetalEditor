//
//  Torus.swift
//  MidJuly_Paged
//
//  Created by для интернета on 17.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class Torus: SceneObject {
    
    private var x: Float, y: Float, z: Float
    private var radius: Float, height: Float, segments: Int
    private var rgb: (r: Int, g: Int, b: Int)
    
    private func makeCircleAt(center: (x: Float, z: Float), angle: Float) -> [customFloat4] {
        var circle: [customFloat4] = []
        
        let torusRadius: Float = 0.3
        
        let segmentAngle: Float = 360.0 / Float(segments)
        for currentAngle in stride(from: 0.0, through: segmentAngle * Float(segments), by: segmentAngle) {
            var x: Float = cos(currentAngle * Float(M_PI) / 180) * torusRadius + center.x
            var y: Float = sin(currentAngle * Float(M_PI) / 180) * torusRadius
            var z: Float = center.z
            
            var currentRadius = sqrt(pow(x - center.x, 2) + pow(z - center.z, 2))
            if x - center.x < 0 {
                x = cos((angle + 180) * Float(M_PI) / 180) * currentRadius + center.x
                z = sin((angle + 180) * Float(M_PI) / 180) * currentRadius + center.z
            } else {
                x = cos(angle * Float(M_PI) / 180) * currentRadius + center.x
                z = sin(angle * Float(M_PI) / 180) * currentRadius + center.z
            }
                
            print(x)
            
            circle.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        }
        
        return circle
    }
    
    private func appendCylinder() {
        var position: [customFloat4] = []
        
        let segmentAngle: Float = 360.0 / Float(segments)
        
        var circles: [[customFloat4]] = []
        for angle in stride(from: 0.0, through: segmentAngle * Float(segments), by: segmentAngle) {
            
            let center: (x: Float, z: Float) = (x: cos(angle * Float(M_PI) / 180) * radius, z: sin(angle * Float(M_PI) / 180) * radius)
            print(center)
            circles.append(makeCircleAt(center: center, angle: angle))
            
        }
        for i in 0..<(circles.count - 1) {
            for j in 0..<(circles[i].count - 1) {
                position.append(customFloat4(x: circles[i][j].x, y: circles[i][j].y, z: circles[i][j].z, w: 1))
                position.append(customFloat4(x: circles[i][j + 1].x, y: circles[i][j + 1].y, z: circles[i][j + 1].z, w: 1))
                position.append(customFloat4(x: circles[i + 1][j + 1].x, y: circles[i + 1][j + 1].y, z: circles[i + 1][j + 1].z, w: 1))
                
                position.append(customFloat4(x: circles[i + 1][j + 1].x, y: circles[i + 1][j + 1].y, z: circles[i + 1][j + 1].z, w: 1))
                position.append(customFloat4(x: circles[i + 1][j].x, y: circles[i + 1][j].y, z: circles[i + 1][j].z, w: 1))
                position.append(customFloat4(x: circles[i][j].x, y: circles[i][j].y, z: circles[i][j].z, w: 1))
            }
        }
        
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
    
    init(x: Float, y: Float, z: Float, radius: Float, height: Float, segments: Int, rgb: (r: Int, g: Int, b: Int)) {
        self.x = x; self.y = y; self.z = z
        self.radius = radius; self.height = height; self.segments = segments
        self.rgb = rgb
        
        super.init()
        appendCylinder()
    }
}
