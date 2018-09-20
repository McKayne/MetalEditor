//
//  Face.swift
//  MidJuly_Paged
//
//  Created by для интернета on 18.09.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class Face: SceneObject {
    
    private var x: Float, y: Float, z: Float
    private var width: Float, height: Float
    private var rgb: (r: Int, g: Int, b: Int)
    
    private func appendFace() {
        var position: [customFloat4] = []
        
        position.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x + width, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z, w: 1.0))
        
        position.append(customFloat4(x: x + width, y: y + height, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y + height, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        
        for i in 0..<6 {
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
        
        /*for i in 0..<2 {
            lineIndices.append(i * 3)
            lineIndices.append(i * 3 + 1)
            
            lineIndices.append(i * 3 + 1)
            lineIndices.append(i * 3 + 2)
            
            lineIndices.append(i * 3 + 2)
            lineIndices.append(i * 3)
        }*/
    }
    
    init(x: Float, y: Float, z: Float, width: Float, height: Float, rgb: (r: Int, g: Int, b: Int)) {
        self.x = x; self.y = y; self.z = z
        self.width = width; self.height = height
        self.rgb = rgb
        
        super.init()
        appendFace()
    }
}
