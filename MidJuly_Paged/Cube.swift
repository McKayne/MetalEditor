//
//  Cube.swift
//  EarlyJuneNM_SV
//
//  Created by для интернета on 06.07.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation
import Metal

class Cube: SceneObject {
    
    private var x: Float, y: Float, z: Float
    private var width: Float, height: Float, depth: Float
    private var rgb: (r: Int, g: Int, b: Int)
    
    private func appendCube() {
        
        var position: [customFloat4] = []
        
        // front face
        
        position.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x + width, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z, w: 1.0))
        
        position.append(customFloat4(x: x + width, y: y + height, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y + height, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        
        // right face
        
        position.append(customFloat4(x: x + width, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x + width, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z, w: 1.0))
        
        position.append(customFloat4(x: x + width, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z, w: 1.0))
        
        // back face
        
        position.append(customFloat4(x: x + width, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z - depth, w: 1.0))
        
        position.append(customFloat4(x: x, y: y + height, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z - depth, w: 1.0))
        
        // left face
        
        position.append(customFloat4(x: x, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y + height, z: z - depth, w: 1.0))
        
        position.append(customFloat4(x: x, y: y + height, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y + height, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z, w: 1.0))
        
        // top face
        
        position.append(customFloat4(x: x + width, y: y + height, z: z, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x, y: y + height, z: z - depth, w: 1.0))
        
        position.append(customFloat4(x: x, y: y + height, z: z, w: 1.0))
        position.append(customFloat4(x: x + width, y: y + height, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y + height, z: z - depth, w: 1.0))
        
        // bottom face
        
        position.append(customFloat4(x: x + width, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y, z: z - depth, w: 1.0))
        
        position.append(customFloat4(x: x, y: y, z: z - depth, w: 1.0))
        position.append(customFloat4(x: x + width, y: y, z: z, w: 1.0))
        position.append(customFloat4(x: x, y: y, z: z, w: 1.0))

        for i in 0..<36 {
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
    
    private func appendNormals() {
        /*
         simd::float3 customNormal[12];
         
         simd::float3 edge1, edge2, cross;
         float len;
         
         
         for (int i = 0, nth = 0; nth < 12; i += 3, nth++) {
         edge1 = {position[i + 1].x - position[i].x, position[i + 1].y - position[i].y, position[i + 1].z - position[i].z};
         edge2 = {position[i + 2].x - position[i].x, position[i + 2].y - position[i].y, position[i + 2].z - position[i].z};
         
         cross = {edge1.y * edge2.z - edge1.z * edge2.y, edge1.z * edge2.x - edge1.x * edge2.z, edge1.x * edge2.y - edge1.y * edge2.x};
         
         len = sqrt(cross.x * cross.x + cross.y * cross.y + cross.z * cross.z);
         
         customNormal[nth] = {cross.x / len, cross.y / len, cross.z / len};
         }
         
         
         
         simd::float3 customVertexNormal;
         
         // front
         
         customVertexNormal = {customNormal[0].x + customNormal[1].x + customNormal[2].x + customNormal[3].x + customNormal[8].x + customNormal[9].x,
         customNormal[0].y + customNormal[1].y + customNormal[2].y + customNormal[3].y + customNormal[8].y + customNormal[9].y,
         customNormal[0].z + customNormal[1].z + customNormal[2].z + customNormal[3].z + customNormal[8].z + customNormal[9].z};
         self.bigVertices[2 + self.totalIndices].normal = normalize(customVertexNormal);
         self.bigVertices[3 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[0].x + customNormal[1].x + customNormal[6].x + customNormal[7].x + customNormal[11].x,
         customNormal[0].y + customNormal[1].y + customNormal[6].y + customNormal[7].y + customNormal[11].y,
         customNormal[0].z + customNormal[1].z + customNormal[6].z + customNormal[7].z + customNormal[11].z};
         self.bigVertices[0 + self.totalIndices].normal = normalize(customVertexNormal);
         self.bigVertices[5 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[0].x + customNormal[2].x + customNormal[10].x + customNormal[11].x,
         customNormal[0].y + customNormal[2].y + customNormal[10].y + customNormal[11].y,
         customNormal[0].z + customNormal[2].z + customNormal[10].z + customNormal[11].z};
         self.bigVertices[1 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[1].x + customNormal[7].x + customNormal[9].x,
         customNormal[1].y + customNormal[7].y + customNormal[9].y,
         customNormal[1].z + customNormal[7].z + customNormal[9].z};
         self.bigVertices[4 + self.totalIndices].normal = normalize(customVertexNormal);
         
         // right
         
         customVertexNormal = {customNormal[2].x + customNormal[3].x + customNormal[4].x + customNormal[10].x,
         customNormal[2].y + customNormal[3].y + customNormal[4].y + customNormal[10].y,
         customNormal[2].z + customNormal[3].z + customNormal[4].z + customNormal[10].z};
         self.bigVertices[7 + self.totalIndices].normal = normalize(customVertexNormal);
         self.bigVertices[9 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[0].x + customNormal[1].x + customNormal[2].x + customNormal[3].x + customNormal[8].x + customNormal[9].x,
         customNormal[0].y + customNormal[1].y + customNormal[2].y + customNormal[3].y + customNormal[8].y + customNormal[9].y,
         customNormal[0].z + customNormal[1].z + customNormal[2].z + customNormal[3].z + customNormal[8].z + customNormal[9].z};
         self.bigVertices[8 + self.totalIndices].normal = normalize(customVertexNormal);
         self.bigVertices[11 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[0].x + customNormal[2].x + customNormal[10].x + customNormal[11].x,
         customNormal[0].y + customNormal[2].y + customNormal[10].y + customNormal[11].y,
         customNormal[0].z + customNormal[2].z + customNormal[10].z + customNormal[11].z};
         self.bigVertices[6 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[3].x + customNormal[4].x + customNormal[5].x + customNormal[8].x,
         customNormal[3].y + customNormal[4].y + customNormal[5].y + customNormal[8].y,
         customNormal[3].z + customNormal[4].z + customNormal[5].z + customNormal[8].z};
         self.bigVertices[10 + self.totalIndices].normal = normalize(customVertexNormal);
         
         // back
         
         customVertexNormal = {customNormal[4].x + customNormal[5].x + customNormal[6].x + customNormal[10].x + customNormal[11].x,
         customNormal[4].y + customNormal[5].y + customNormal[6].y + customNormal[10].y + customNormal[11].y,
         customNormal[4].z + customNormal[5].z + customNormal[6].z + customNormal[10].z + customNormal[11].z};
         self.bigVertices[13 + self.totalIndices].normal = normalize(customVertexNormal);
         self.bigVertices[17 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[3].x + customNormal[4].x + customNormal[5].x + customNormal[8].x,
         customNormal[3].y + customNormal[4].y + customNormal[5].y + customNormal[8].y,
         customNormal[3].z + customNormal[4].z + customNormal[5].z + customNormal[8].z};
         self.bigVertices[14 + self.totalIndices].normal = normalize(customVertexNormal);
         self.bigVertices[16 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[2].x + customNormal[3].x + customNormal[4].x + customNormal[10].x,
         customNormal[2].y + customNormal[3].y + customNormal[4].y + customNormal[10].y,
         customNormal[2].z + customNormal[3].z + customNormal[4].z + customNormal[10].z};
         self.bigVertices[12 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[5].x + customNormal[6].x + customNormal[7].x + customNormal[8].x + customNormal[9].x,
         customNormal[5].y + customNormal[6].y + customNormal[7].y + customNormal[8].y + customNormal[9].y,
         customNormal[5].z + customNormal[6].z + customNormal[7].z + customNormal[8].z + customNormal[9].z};
         self.bigVertices[15 + self.totalIndices].normal = normalize(customVertexNormal);
         
         // left
         
         customVertexNormal = {customNormal[0].x + customNormal[1].x + customNormal[6].x + customNormal[7].x + customNormal[11].x,
         customNormal[0].y + customNormal[1].y + customNormal[6].y + customNormal[7].y + customNormal[11].y,
         customNormal[0].z + customNormal[1].z + customNormal[6].z + customNormal[7].z + customNormal[11].z};
         self.bigVertices[19 + self.totalIndices].normal = normalize(customVertexNormal);
         self.bigVertices[23 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[5].x + customNormal[6].x + customNormal[7].x + customNormal[8].x + customNormal[9].x,
         customNormal[5].y + customNormal[6].y + customNormal[7].y + customNormal[8].y + customNormal[9].y,
         customNormal[5].z + customNormal[6].z + customNormal[7].z + customNormal[8].z + customNormal[9].z};
         self.bigVertices[20 + self.totalIndices].normal = normalize(customVertexNormal);
         self.bigVertices[22 + self.totalIndices].normal = normalize(customVertexNormal);
         
         
         customVertexNormal = {customNormal[4].x + customNormal[5].x + customNormal[6].x + customNormal[10].x + customNormal[11].x,
         customNormal[4].y + customNormal[5].y + customNormal[6].y + customNormal[10].y + customNormal[11].y,
         customNormal[4].z + customNormal[5].z + customNormal[6].z + customNormal[10].z + customNormal[11].z};
         self.bigVertices[18 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[1].x + customNormal[7].x + customNormal[9].x,
         customNormal[1].y + customNormal[7].y + customNormal[9].y,
         customNormal[1].z + customNormal[7].z + customNormal[9].z};
         self.bigVertices[21 + self.totalIndices].normal = normalize(customVertexNormal);
         
         // top
         
         customVertexNormal = {customNormal[5].x + customNormal[6].x + customNormal[7].x + customNormal[8].x + customNormal[9].x,
         customNormal[5].y + customNormal[6].y + customNormal[7].y + customNormal[8].y + customNormal[9].y,
         customNormal[5].z + customNormal[6].z + customNormal[7].z + customNormal[8].z + customNormal[9].z};
         self.bigVertices[26 + self.totalIndices].normal = normalize(customVertexNormal);
         self.bigVertices[29 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[0].x + customNormal[1].x + customNormal[2].x + customNormal[3].x + customNormal[8].x + customNormal[9].x,
         customNormal[0].y + customNormal[1].y + customNormal[2].y + customNormal[3].y + customNormal[8].y + customNormal[9].y,
         customNormal[0].z + customNormal[1].z + customNormal[2].z + customNormal[3].z + customNormal[8].z + customNormal[9].z};
         self.bigVertices[24 + self.totalIndices].normal = normalize(customVertexNormal);
         self.bigVertices[28 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[3].x + customNormal[4].x + customNormal[5].x + customNormal[8].x,
         customNormal[3].y + customNormal[4].y + customNormal[5].y + customNormal[8].y,
         customNormal[3].z + customNormal[4].z + customNormal[5].z + customNormal[8].z};
         self.bigVertices[25 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[1].x + customNormal[7].x + customNormal[9].x,
         customNormal[1].y + customNormal[7].y + customNormal[9].y,
         customNormal[1].z + customNormal[7].z + customNormal[9].z};
         self.bigVertices[27 + self.totalIndices].normal = normalize(customVertexNormal);
         
         // bottom
         
         customVertexNormal = {customNormal[0].x + customNormal[2].x + customNormal[10].x + customNormal[11].x,
         customNormal[0].y + customNormal[2].y + customNormal[10].y + customNormal[11].y,
         customNormal[0].z + customNormal[2].z + customNormal[10].z + customNormal[11].z};
         self.bigVertices[30 + self.totalIndices].normal = normalize(customVertexNormal);
         self.bigVertices[34 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[4].x + customNormal[5].x + customNormal[6].x + customNormal[10].x + customNormal[11].x,
         customNormal[4].y + customNormal[5].y + customNormal[6].y + customNormal[10].y + customNormal[11].y,
         customNormal[4].z + customNormal[5].z + customNormal[6].z + customNormal[10].z + customNormal[11].z};
         self.bigVertices[31 + self.totalIndices].normal = normalize(customVertexNormal);
         self.bigVertices[33 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[2].x + customNormal[3].x + customNormal[4].x + customNormal[10].x,
         customNormal[2].y + customNormal[3].y + customNormal[4].y + customNormal[10].y,
         customNormal[2].z + customNormal[3].z + customNormal[4].z + customNormal[10].z};
         self.bigVertices[32 + self.totalIndices].normal = normalize(customVertexNormal);
         
         customVertexNormal = {customNormal[0].x + customNormal[1].x + customNormal[6].x + customNormal[7].x + customNormal[11].x,
         customNormal[0].y + customNormal[1].y + customNormal[6].y + customNormal[7].y + customNormal[11].y,
         customNormal[0].z + customNormal[1].z + customNormal[6].z + customNormal[7].z + customNormal[11].z};
         self.bigVertices[35 + self.totalIndices].normal = normalize(customVertexNormal);
         
         */
    }
    
    init(x: Float, y: Float, z: Float, width: Float, height: Float, depth: Float, rgb: (r: Int, g: Int, b: Int)) {
        self.x = x; self.y = y; self.z = z
        self.width = width; self.height = height; self.depth = depth
        self.rgb = rgb
        
        super.init()
        appendCube()
    }
}
