//
//  VertexSet.swift
//  MidJuly_Paged
//
//  Created by для интернета on 07.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class VertexSet: SceneObject {
    
    private var rgb: (r: Float, g: Float, b: Float)
    private var coords: [(x: Float, y: Float, z: Float)] = []
    
    func appendVertexWithCoords(xyz: (Float, Float, Float)) {
        self.coords.append(xyz)
        
        vertices = []
        lineVertices = []
        if coords.count > 2 {
            for i in 0..<coords.count {
                var v1 = Vertex()
                v1.position = customFloat4(x: coords[i].x, y: coords[i].y, z: coords[i].z, w: 1)
                v1.normal = customFloat4(x: 0, y: 0, z: 0, w: 0)
                v1.customColor = customFloat4(x: rgb.r, y: rgb.g, z: rgb.b, w: 1)
                v1.texCoord = customFloat4(x: 0, y: 0, z: 0, w: 0)
                
                for j in 0..<coords.count {
                    if j != i {
                        var v2 = Vertex()
                        v2.position = customFloat4(x: coords[j].x, y: coords[j].y, z: coords[j].z, w: 1)
                        v2.normal = customFloat4(x: 0, y: 0, z: 0, w: 0)
                        v2.customColor = customFloat4(x: rgb.r, y: rgb.g, z: rgb.b, w: 1)
                        v2.texCoord = customFloat4(x: 0, y: 0, z: 0, w: 0)
                        
                        for k in 0..<coords.count {
                            if k != i && k != j {
                                var v3 = Vertex()
                                v3.position = customFloat4(x: coords[k].x, y: coords[k].y, z: coords[k].z, w: 1)
                                v3.normal = customFloat4(x: 0, y: 0, z: 0, w: 0)
                                v3.customColor = customFloat4(x: rgb.r, y: rgb.g, z: rgb.b, w: 1)
                                v3.texCoord = customFloat4(x: 0, y: 0, z: 0, w: 0)
                                
                                vertices.append(v1)
                                vertices.append(v2)
                                vertices.append(v3)
                                
                                var lv1 = Vertex()
                                lv1.position = v1.position
                                lv1.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
                                
                                var lv2 = Vertex()
                                lv2.position = v2.position
                                lv2.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
                                
                                var lv3 = Vertex()
                                lv3.position = v3.position
                                lv3.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
                                
                                lineVertices.append(lv1)
                                lineVertices.append(lv2)
                                lineVertices.append(lv3)
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    init(rgb: (Float, Float, Float)) {
        self.rgb = rgb
    }
}
