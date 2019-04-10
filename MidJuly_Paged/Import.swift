//
//  Import.swift
//  MidJuly_Paged
//
//  Created by для интернета on 25.09.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class Import {
    
    private enum Coord {
        case x
        case y
        case z
    }
    
    // STL format import
    
    static func importSTL(modelURL: URL) -> SceneObject {
        let fileText = try! String(contentsOf: modelURL, encoding: .utf8)
        //print(fileText)
        
        let fileTextArr = fileText.components(separatedBy: [" ", "\n"])
        
        let object = SceneObject()
        
        var modelName: String
        var coord: Coord = .x
        var x: Float = 0, y: Float = 0, z: Float = 0
        var isVertexCoord = false
        for i in 0..<fileTextArr.count {
            if fileTextArr[i] == "solid" {
                modelName = fileTextArr[i + 1]
            } else if fileTextArr[i] == "normal" {
                isVertexCoord = false
            } else if fileTextArr[i] == "vertex" {
                isVertexCoord = true
            } else if let currentValue = Float(fileTextArr[i]) {
                if isVertexCoord {
                    switch coord {
                    case .x:
                        x = currentValue
                        print("X " + String(x))
                        
                        coord = .y
                    case .y:
                        y = currentValue
                        print("Y " + String(y))
                        
                        coord = .z
                    case .z:
                        z = currentValue
                        print("Z " + String(z))
                        
                        coord = .x
                        
                        object.vertices.append(Vertex(position: customFloat4(x: x, y: y, z: z, w: 1.0), normal: customFloat4(x: 0, y: 0, z: 0, w: 0.0), customColor: customFloat4(x: 1, y: 0, z: 1, w: 1), texCoord: customFloat4(x: 0, y: 0, z: 0, w: 0)))
                        object.lineVertices.append(Vertex(position: customFloat4(x: x, y: y, z: z, w: 1.0), normal: customFloat4(x: 0, y: 0, z: 0, w: 0.0), customColor: customFloat4(x: 0, y: 0, z: 0, w: 1), texCoord: customFloat4(x: 0, y: 0, z: 0, w: 0)))
                    }
                }
            }
        }
        
        return object
    }
    
    // PLY format import
    
    static func importPLY(modelURL: URL) -> SceneObject {
        let fileText = try! String(contentsOf: modelURL, encoding: .utf8)
        //print(fileText)
        
        let fileTextArr = fileText.components(separatedBy: [" ", "\n"])
        
        let object = SceneObject()
        
        if fileTextArr[0] == "ply" {
            print("PLY header found")
        }
        if fileTextArr[1] == "format" && fileTextArr[2] == "ascii" && fileTextArr[3] == "1.0" {
            print("PLY format found")
        }
        
        var headerEnd = false
        var vertices: Int = 0, currentVertices: Int = 0
        var coord: Coord = .x
        var x: Float = 0, y: Float = 0, z: Float = 0
        for i in 4..<fileTextArr.count {
            if fileTextArr[i] == "element" {
                if fileTextArr[i + 1] == "vertex" {
                    print(fileTextArr[i + 2] + " vertices")
                    vertices = Int(fileTextArr[i + 2])!
                }
            } else if fileTextArr[i] == "end_header" {
                print("PLY header end")
                headerEnd = true
            } else {
                if let currentValue = Float(fileTextArr[i]) {
                    if headerEnd {
                        if currentVertices < vertices {
                            switch coord {
                            case .x:
                                x = currentValue
                                print("X " + String(x))
                            
                                coord = .y
                            case .y:
                                y = currentValue
                                print("Y " + String(y))
                            
                                coord = .z
                            case .z:
                                z = currentValue
                                print("Z " + String(z))
                            
                                coord = .x
                            
                                object.vertices.append(Vertex(position: customFloat4(x: x, y: y, z: z, w: 1.0), normal: customFloat4(x: 0, y: 0, z: 0, w: 0.0), customColor: customFloat4(x: 1, y: 0, z: 1, w: 1), texCoord: customFloat4(x: 0, y: 0, z: 0, w: 0)))
                                object.lineVertices.append(Vertex(position: customFloat4(x: x, y: y, z: z, w: 1.0), normal: customFloat4(x: 0, y: 0, z: 0, w: 0.0), customColor: customFloat4(x: 0, y: 0, z: 0, w: 1), texCoord: customFloat4(x: 0, y: 0, z: 0, w: 0)))
                                currentVertices += 1
                            }
                        }
                    }
                }
            }
        }
        
        return object
    }
}
