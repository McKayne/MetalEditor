//
//  Hemisphere.swift
//  MidJuly_Paged
//
//  Created by для интернета on 16.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class Hemisphere: SceneObject {
    
    private var x: Float, y: Float, z: Float
    private var radius: Float, height: Float, segments: Int
    private var rgb: (r: Int, g: Int, b: Int)
    
    private func sphereX(radius: Float, horizAngle: Float, vertAngle: Float) -> Float {
        let currentRadius: Float = cos(vertAngle * Float(M_PI) / 180.0) * radius
        
        return cos(horizAngle * Float(M_PI) / 180.0) * currentRadius
    }
    
    private func sphereY(radius: Float, horizAngle: Float, vertAngle: Float) -> Float {
        //__unused float currentRadius = cos(vertAngle * 3.14 / 180.0) * radius;
        
        return sin(vertAngle * Float(M_PI) / 180.0) * radius
    }
    
    private func sphereZ(radius: Float, horizAngle: Float, vertAngle: Float) -> Float {
        let currentRadius: Float = cos(vertAngle * Float(M_PI) / 180.0) * radius
        
        return sin(horizAngle * Float(M_PI) / 180.0) * currentRadius
    }
    
    private func appendDiamond() {
        let segmentAngle: Float = 360.0 / Float(segments)
        
        var position: [customFloat4] = []
        
        var index = 0
        for vertAngle in stride(from: 0.0, to: segmentAngle * Float(segments / 2), by: segmentAngle) {
            for angle in stride(from: 0.0, to: segmentAngle * Float(segments), by: segmentAngle) {
                position.append(customFloat4(x: x + sphereX(radius: radius, horizAngle: angle + segmentAngle, vertAngle: vertAngle), y: y + sphereY(radius: radius, horizAngle: angle + segmentAngle, vertAngle: vertAngle), z: z + sphereZ(radius: radius, horizAngle: angle + segmentAngle, vertAngle: vertAngle), w: 1.0))
                position.append(customFloat4(x: x + sphereX(radius: radius, horizAngle: angle, vertAngle: vertAngle), y: y + sphereY(radius: radius, horizAngle: angle, vertAngle: vertAngle), z: z + sphereZ(radius: radius, horizAngle: angle, vertAngle: vertAngle), w: 1.0))
                position.append(customFloat4(x: x + sphereX(radius: radius, horizAngle: angle + segmentAngle, vertAngle: vertAngle + segmentAngle), y: y + sphereY(radius: radius, horizAngle: angle + segmentAngle, vertAngle: vertAngle + segmentAngle), z: z + sphereZ(radius: radius, horizAngle: angle + segmentAngle, vertAngle: vertAngle + segmentAngle), w: 1.0))
                
                position.append(customFloat4(x: x + sphereX(radius: radius, horizAngle: angle, vertAngle: vertAngle + segmentAngle), y: y + sphereY(radius: radius, horizAngle: angle, vertAngle: vertAngle + segmentAngle), z: z + sphereZ(radius: radius, horizAngle: angle, vertAngle: vertAngle + segmentAngle), w: 1.0))
                position.append(customFloat4(x: x + sphereX(radius: radius, horizAngle: angle + segmentAngle, vertAngle: vertAngle + segmentAngle), y: y + sphereY(radius: radius, horizAngle: angle + segmentAngle, vertAngle: vertAngle + segmentAngle), z: z + sphereZ(radius: radius, horizAngle: angle + segmentAngle, vertAngle: vertAngle + segmentAngle), w: 1.0))
                position.append(customFloat4(x: x + sphereX(radius: radius, horizAngle: angle, vertAngle: vertAngle), y: y + sphereY(radius: radius, horizAngle: angle, vertAngle: vertAngle), z: z + sphereZ(radius: radius, horizAngle: angle, vertAngle: vertAngle), w: 1.0))
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
        appendDiamond()
    }
}
