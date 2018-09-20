//
//  Cone.swift
//  MidJuly_Paged
//
//  Created by для интернета on 18.09.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class Cone: SceneObject {
    
    private var x: Float, y: Float, z: Float
    private var radius: Float, height: Float, segments: Int
    private var rgb: (r: Int, g: Int, b: Int)
    
    private func appendCone() {
        let segmentAngle: Float = 360.0 / Float(segments)
        
        var position: [customFloat4] = []
        
        for angle in stride(from: 0.0, to: segmentAngle * Float(segments), by: segmentAngle) {
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius, y: y, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * radius, y: y, z: z + sin(angle * 3.14 / 180.0) * radius, w: 1.0))
            position.append(customFloat4(x: x, y: y + height, z: z, w: 1.0))
            
            position.append(customFloat4(x: x + cos(angle * 3.14 / 180.0) * radius, y: y, z: z + sin(angle * 3.14 / 180.0) * radius, w: 1.0))
            position.append(customFloat4(x: x + cos((angle + segmentAngle) * 3.14 / 180.0) * radius, y: y, z: z + sin((angle + segmentAngle) * 3.14 / 180.0) * radius, w: 1.0))
            position.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        }
        
        for i in 0..<segments * 3 * 2 {
            indices.append(i)
            
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
        appendCone()
    }
}
