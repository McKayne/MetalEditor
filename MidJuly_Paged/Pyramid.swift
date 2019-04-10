//
//  Pyramid.swift
//  MidJuly_Paged
//
//  Created by для интернета on 18.09.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class Pyramid: SceneObject {
    
    private var x: Float, y: Float, z: Float
    private var width: Float, height: Float, depth: Float
    private var rgb: (r: Int, g: Int, b: Int)
    
    private func appendPyramid() {
        var position: [customFloat4] = []
        
        // front face
        
        position.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x + width, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x + width / 2.0, y: y + height, z: z - depth / 2.0, w: 1.0))
        
        // right face
        
        position.append(customFloat4(x: x + width, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x + width, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width / 2.0, y: y + height, z: z - depth / 2.0, w: 1.0))
        
        // back face
        
        position.append(customFloat4(x: x + width, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width / 2.0, y: y + height, z: z - depth / 2.0, w: 1.0))
        
        // left face
        
        position.append(customFloat4(x: x, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x + width / 2.0, y: y + height, z: z - depth / 2.0, w: 1.0))
        
        // bottom face
        
        position.append(customFloat4(x: x + width, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y, z: z - depth, w: 1.0))
        
        position.append(customFloat4(x: x, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        
        for i in 0..<18 {
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
    
    init(x: Float, y: Float, z: Float, width: Float, height: Float, depth: Float, rgb: (r: Int, g: Int, b: Int)) {
        self.x = x; self.y = y; self.z = z
        self.width = width; self.height = height; self.depth = depth
        self.rgb = rgb
        
        super.init()
        appendPyramid()
    }
}
