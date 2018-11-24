//
//  Gear.swift
//  MidJuly_Paged
//
//  Created by для интернета on 16.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class Gear: SceneObject {
    
    private var x: Float, y: Float, z: Float
    private var radius: Float, height: Float, segments: Int
    private var rgb: (r: Int, g: Int, b: Int)
    
    private func appendCone() {
        var position: [customFloat4] = []
        
        let segmentAngle: Float = 360.0 / Float(segments)
        
        for angle in stride(from: 0.0, to: segmentAngle * Float(segments), by: segmentAngle) {
            
            position.append(customFloat4(x: x - (cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y: y, z: z + (sin((angle + segmentAngle) * 3.14 / 180.0) * radius), w: 1.0))
            position.append(customFloat4(x: x - (cos(angle * 3.14 / 180.0) * radius), y: y, z: z + (sin(angle * 3.14 / 180.0) * radius), w: 1.0))
            position.append(customFloat4(x: x - (cos(angle * 3.14 / 180.0) * radius), y: y + height, z: z + (sin(angle * 3.14 / 180.0) * radius), w: 1.0))
            
            position.append(customFloat4(x: x - (cos(angle * 3.14 / 180.0) * radius), y: y + height, z: z + (sin(angle * 3.14 / 180.0) * radius), w: 1.0))
            position.append(customFloat4(x: x - (cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y: y + height, z: z + (sin((angle + segmentAngle) * 3.14 / 180.0) * radius), w: 1.0))
            position.append(customFloat4(x: x - (cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y: y, z: z + (sin((angle + segmentAngle) * 3.14 / 180.0) * radius), w: 1.0))
            
        }
        for angle in stride(from: 0.0, to: segmentAngle * Float(segments), by: segmentAngle) {
            var bigRadius: Float = 0.25
            let parts = 5
            let partAngle: Float = 40
            
            let nonpartAngle: Float = (360 - Float(parts) * partAngle) / Float(parts)
            
            var currentAngle: Float = nonpartAngle / 2
            if angle >= currentAngle && angle <= currentAngle + partAngle {
                bigRadius = 0.35
            }
            currentAngle += partAngle
            
            for i in 0..<(parts - 1) {
                if angle >= currentAngle + nonpartAngle && angle <= currentAngle + nonpartAngle + partAngle {
                    bigRadius = 0.35
                }
                currentAngle += (nonpartAngle + partAngle)
            }
            
            
            var bigRadiusB: Float = 0.25
            var currentAngleB: Float = nonpartAngle / 2
            if angle + segmentAngle >= currentAngleB && angle + segmentAngle <= currentAngleB + partAngle {
                bigRadiusB = 0.35
            }
            currentAngleB += partAngle
            
            for i in 0..<(parts - 1) {
                if angle + segmentAngle >= currentAngleB + nonpartAngle && angle + segmentAngle <= currentAngleB + nonpartAngle + partAngle {
                    bigRadiusB = 0.35
                }
                currentAngleB += (nonpartAngle + partAngle)
            }
            
            position.append(customFloat4(x: x + (cos((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), y: y, z: z + (sin((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), w: 1.0))
            position.append(customFloat4(x: x + (cos(angle * 3.14 / 180.0) * bigRadius), y: y, z: z + (sin(angle * 3.14 / 180.0) * bigRadius), w: 1.0))
            position.append(customFloat4(x: x + (cos(angle * 3.14 / 180.0) * bigRadius), y: y + height, z: z + (sin(angle * 3.14 / 180.0) * bigRadius), w: 1.0))
            
            position.append(customFloat4(x: x + (cos(angle * 3.14 / 180.0) * bigRadius), y: y + height, z: z + (sin(angle * 3.14 / 180.0) * bigRadius), w: 1.0))
            position.append(customFloat4(x: x + (cos((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), y: y + height, z: z + (sin((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), w: 1.0))
            position.append(customFloat4(x: x + (cos((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), y: y, z: z + (sin((angle + segmentAngle) * 3.14 / 180.0) * bigRadiusB), w: 1.0))
        }
        var last = segments * 3 * 2 * 2
        var angle: Float = 0.0
        
        print(last)
        print(position.count)
        
        for i in stride(from: last, to: segments * 3 * 2 * 2 * 2, by: 6) {
            
            print(i)
            
            //position[i + 2] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
            let positionA = customFloat4(x: x + (cos(angle * 3.14 / 180.0) * radius), y: y + height, z: z + (sin(angle * 3.14 / 180.0) * radius), w: 1.0)
            
            //position[i + 1] = position[i + segments * 3 * 2 - last + 2];
            let positionB = position[i + segments * 3 * 2 - last + 2]
            
            //position[i] = position[i + segments * 3 * 2 - last + 4];
            let positionC = position[i + segments * 3 * 2 - last + 4]
            position.append(positionC)
            
            //position[i + 3] = {x + static_cast<float>(cos(angle * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin(angle * 3.14 / 180.0) * radius), 1.0};
            let positionD = customFloat4(x: x + (cos(angle * 3.14 / 180.0) * radius), y: y + height, z: z + (sin(angle * 3.14 / 180.0) * radius), w: 1.0)
            
            //position[i + 4] = {x + static_cast<float>(cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y + height, z + static_cast<float>(sin((angle + segmentAngle) * 3.14 / 180.0) * radius), 1.0};
            let positionE = customFloat4(x: x + (cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y: y + height, z: z + (sin((angle + segmentAngle) * 3.14 / 180.0) * radius), w: 1.0)
            
            //position[i + 5] = position[i];
            let positionF = position[i]
            
            
            position.append(positionB)
            position.append(positionA)
            
            position.append(positionD)
            position.append(positionE)
            position.append(positionF)
            
            angle += segmentAngle
            
            
        }
        
        angle = 0.0
        last = segments * 3 * 2 * 2 * 2
        for i in stride(from: last, to: segments * 3 * 2 * 2 * 2 * 2, by: 6) {
            position.append(customFloat4(x: x + (cos(angle * 3.14 / 180.0) * radius), y: y, z: z + (sin(angle * 3.14 / 180.0) * radius), w: 1.0))
            position.append(position[i + segments * 3 * 2 - last + 1])
            position.append(position[i + segments * 3 * 2 - last + 5])
            
            position.append(position[i + 2])
            position.append(customFloat4(x: x + (cos((angle + segmentAngle) * 3.14 / 180.0) * radius), y: y, z: z + (sin((angle + segmentAngle) * 3.14 / 180.0) * radius), w: 1.0))
            position.append(customFloat4(x: x + (cos(angle * 3.14 / 180.0) * radius), y: y, z: z + (sin(angle * 3.14 / 180.0) * radius), w: 1.0))
            
            angle += segmentAngle
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
        appendCone()
    }
}
