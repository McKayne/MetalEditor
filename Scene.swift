//
//  Scene.swift
//  MidJuly_Paged
//
//  Created by для интернета on 18.09.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

@objc class Scene: NSObject {
    
    var multipleSelection = false
    
    var x: Float = 0.0, y: Float = 0.0, z: Float = 0.0
    var xAngle: Float = 0.0, yAngle: Float = 0.0
    
    var name: String!
    var objects: [SceneObject] = []
    
    var bigVertices = UnsafeMutablePointer<Vertex>.allocate(capacity: 100000)
    var bigLineVertices = UnsafeMutablePointer<Vertex>.allocate(capacity: 100000)
    
    var bigIndices = UnsafeMutablePointer<UInt16>.allocate(capacity: 100000)
    var bigLineIndices = UnsafeMutablePointer<UInt16>.allocate(capacity: 100000)
    
    var selectionVertices = UnsafeMutablePointer<Vertex>.allocate(capacity: 100000)
    
    var indicesCount: Int = 0
    
    init(name: String) {
        self.name = name
    }
    
    @objc func selectObjectWithColor(rgb: UnsafeMutablePointer<Int32>) {
        var nth = 0
        
        sel: for i in 0..<objects.count {
            let object = objects[i]
            
            for _ in 0..<object.vertices.count {
                if selectionVertices[nth].customColor.x == Float(rgb[0]) / 255.0 {
                    print("\(i) Selected")
                    
                    if !objects[i].isSelected {
                        objects[i].isSelected = true
                        
                        if !multipleSelection {
                            for j in 0..<objects.count {
                                if j != i {
                                    objects[j].isSelected = false
                                }
                            }
                        }
                    } else {
                        objects[i].isSelected = false
                        
                        if !multipleSelection {
                            for j in 0..<objects.count {
                                if j != i {
                                    objects[j].isSelected = false
                                }
                            }
                        }
                    }
                    
                    prepareForRender()
                    break sel
                }
                
                nth += 1
            }
            
        }
        
    }
    
    func prepareForRender() {
        indicesCount = 0
        
        for i in 0..<objects.count {
            let object = objects[i]
            
            for j in 0..<object.vertices.count {
                bigVertices[indicesCount] = object.vertices[j]
                if object.isSelected {
                    
                    bigVertices[indicesCount].customColor = customFloat4(x: 1.0, y: 0.5, z: 0.0, w: 1.0)
                }
                
                selectionVertices[indicesCount] = object.vertices[j]
                selectionVertices[indicesCount].customColor = customFloat4(x: Float(i) / 255.0, y: Float(i) / 255.0, z: Float(i) / 255.0, w: 1.0)
                
                bigLineVertices[indicesCount] = object.lineVertices[j]
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
    
    func attachObjects(objectsToAttach: [Int]) {
        let object = SceneObject()
        for nth in objectsToAttach {
            for i in 0..<objects[nth].vertices.count {
                object.vertices.append(objects[nth].vertices[i])
                object.lineVertices.append(objects[nth].lineVertices[i])
            }
        }
        
        object.isSelected = true
        objects = [object]
    }
    
    func removeObject(nth: Int) {
        objects.remove(at: nth)
    }
    
    func removeAll(nth: Int) {
        objects.removeAll()
    }
}
