//
//  Scene.swift
//  MidJuly_Paged
//
//  Created by для интернета on 18.09.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class Scene {
    
    var objects: [SceneObject] = []
    
    var bigVertices = UnsafeMutablePointer<Vertex>.allocate(capacity: 100000)
    var bigLineVertices = UnsafeMutablePointer<Vertex>.allocate(capacity: 100000)
    
    var bigIndices = UnsafeMutablePointer<UInt16>.allocate(capacity: 100000)
    var bigLineIndices = UnsafeMutablePointer<UInt16>.allocate(capacity: 100000)
    
    var indicesCount: Int = 0
    
    func prepareForRender() {
        indicesCount = 0
        var lineIndicesCount = 0
        
        for object in objects {
            
            for i in 0..<object.vertices.count {
                bigVertices[indicesCount] = object.vertices[i]
                bigLineVertices[indicesCount] = object.lineVertices[i]
                bigIndices[indicesCount] = UInt16(indicesCount)
                
                indicesCount += 1
            }
            
        }
        
        for i in 0..<(indicesCount / 3) {
            bigLineIndices[i * 6] = UInt16(i * 3)
            bigLineIndices[i * 6 + 1] = UInt16(i * 3 + 1)
            
            bigLineIndices[i * 6 + 2] = UInt16(i * 3 + 1)
            bigLineIndices[i * 6 + 3] = UInt16(i * 3 + 2)
            
            bigLineIndices[i * 6 + 4] = UInt16(i * 3 + 2)
            bigLineIndices[i * 6 + 5] = UInt16(i * 3)
        }
    }
    
    func appendObject(object: SceneObject) {
        objects.append(object)
    }
}
