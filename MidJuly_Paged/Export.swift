//
//  Export.swift
//  MidJuly_Paged
//
//  Created by для интернета on 15.09.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

@objc open class Export: NSObject {
    
    // OBJ format export
    
    static func exportOBJ(scene: Scene) -> URL {
        
        print("\(scene.name ?? "").obj")
        
        let url = URL(fileURLWithPath: NSTemporaryDirectory() + "\(scene.name ?? "").obj")
        
        var contents = "# Modeled on iPhone\n\nmtllib ./\(scene.name ?? "").mtl\n"
        
        contents += "\n# List of geometric vertices\n"
        
        // vertices
        
        let includeColor = true
        if includeColor {
            for i in 0..<scene.indicesCount {
                contents += "\nv \(scene.bigVertices[i].position.x) \(scene.bigVertices[i].position.y) \(scene.bigVertices[i].position.z) \(scene.bigVertices[i].customColor.x) \(scene.bigVertices[i].customColor.y) \(scene.bigVertices[i].customColor.z)"
            }
        } else {
            for i in 0..<scene.indicesCount {
                contents += "\nv \(scene.bigVertices[i].position.x) \(scene.bigVertices[i].position.y) \(scene.bigVertices[i].position.z)"
            }
        }
        
        // texture coords
        
        contents += "\n\n# List of texture coordinates\n"
        
        for i in 0..<scene.indicesCount {
            contents += "\nvt \(scene.bigVertices[i].texCoord.y) \(scene.bigVertices[i].texCoord.z)"
        }
        
        // normals
        
        contents += "\n\n# List of lighting normals\n"
        
        for i in 0..<scene.indicesCount {
            contents += "\nvn \(scene.bigVertices[i].normal.x) \(scene.bigVertices[i].normal.y) \(scene.bigVertices[i].normal.z)"
        }
        
        // faces
        
        contents += "\n\n# List of face indices\n"
        
        var nth = 1
        var lastMaterial = -1
        for _ in 0..<(scene.indicesCount / 3) {
            if scene.bigVertices[nth].texCoord.w == 1 {
                if Int(scene.bigVertices[nth].texCoord.x) != lastMaterial {
                    lastMaterial = Int(scene.bigVertices[nth].texCoord.x)
                    contents += "\n\nusemtl material\(lastMaterial)"
                }
            }
            
            contents += "\nf \(nth)"; nth += 1
            contents += " \(nth)"; nth += 1
            contents += " \(nth)"; nth += 1
        }
        
        let data = contents.data(using: .utf8)
        try! data?.write(to: url)
        
        return url
    }
    
    static func exportOBJfile(scene: Scene) -> String {
        let docPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath: String = docPath + "/" + (scene.name + ".obj")

        var contents = "# Modeled on iPhone\n\n# List of geometric vertices\n"
        
        contents += "\nmtllib ./\(scene.name + ".mtl")\n"
        
        // vertices
        
        let includeColor = true
        if includeColor {
            for i in 0..<scene.indicesCount {
                contents += "\nv \(scene.bigVertices[i].position.x) \(scene.bigVertices[i].position.y) \(scene.bigVertices[i].position.z) \(scene.bigVertices[i].customColor.x) \(scene.bigVertices[i].customColor.y) \(scene.bigVertices[i].customColor.z)"
            }
        } else {
            for i in 0..<scene.indicesCount {
                contents += "\nv \(scene.bigVertices[i].position.x) \(scene.bigVertices[i].position.y) \(scene.bigVertices[i].position.z)"
            }
        }
        
        // texture coords
        
        contents += "\n\n# List of texture coordinates\n"
        
        for i in 0..<scene.indicesCount {
            contents += "\nvt \(scene.bigVertices[i].texCoord.y) \(scene.bigVertices[i].texCoord.z)"
        }
        
        // normals
        
        contents += "\n\n# List of lighting normals\n"
        
        for i in 0..<scene.indicesCount {
            contents += "\nvn \(scene.bigVertices[i].normal.x) \(scene.bigVertices[i].normal.y) \(scene.bigVertices[i].normal.z)"
        }
        
        // faces
        
        contents += "\n\n# List of face indices\n"
        
        var nth = 1
        var lastMaterial = -1
        for _ in 0..<(scene.indicesCount / 3) {
            if scene.bigVertices[nth].texCoord.w == 1 {
                if Int(scene.bigVertices[nth].texCoord.x) != lastMaterial {
                    lastMaterial = Int(scene.bigVertices[nth].texCoord.x)
                    contents += "\n\nusemtl material\(lastMaterial)"
                }
            }
            
            contents += "\nf \(nth)"; nth += 1
            contents += " \(nth)"; nth += 1
            contents += " \(nth)"; nth += 1
        }
        
        print(contents)
        
        FileManager.default.createFile(atPath: filePath, contents: contents.data(using: .utf8), attributes: nil)
        
        return filePath
    }
    
    static func exportMTL(scene: Scene) -> String {
        let docPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath: String = docPath + "/" + (scene.name + ".mtl")
        
        var contents = "# Modeled on iPhone\n\n# List of materials\n"
        
        for i in 0..<4 {
            contents += "\nnewmtl material\(i)"
            contents += "\n\tNs \(0)"
            contents += "\n\td \(1)"
            contents += "\n\tillum \(2)"
            contents += "\n\tKd \(0.8) \(0.8) \(0.8)"
            contents += "\n\tKs \(0.0) \(0.0) \(0.0)"
            contents += "\n\tKa \(0.2) \(0.2) \(0.2)"
            contents += "\n\tmap_Kd texture\(i + 1).jpg\n"
        }
        
        print(contents)
        
        FileManager.default.createFile(atPath: filePath, contents: contents.data(using: .utf8), attributes: nil)
        
        return filePath
    }
    
    // STL format export
    
    static func exportSTL(scene: Scene) -> String {
        let docPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath: String = docPath + "/" + (scene.name + ".stl")
        
        var contents = "solid \(scene.name)\n"
        
        var nth = 0
        for _ in 0..<(scene.indicesCount / 3) {
            contents += "\nfacet normal \(0.0) \(0.0) \(0.0)"
            contents += "\nouter loop"
            contents += "\nvertex \(scene.bigVertices[nth].position.x) \(scene.bigVertices[nth].position.y) \(scene.bigVertices[nth].position.z)"
            contents += "\nvertex \(scene.bigVertices[nth + 1].position.x) \(scene.bigVertices[nth + 1].position.y) \(scene.bigVertices[nth + 1].position.z)"
            contents += "\nvertex \(scene.bigVertices[nth + 2].position.x) \(scene.bigVertices[nth + 2].position.y) \(scene.bigVertices[nth + 2].position.z)"
            contents += "\nendloop"
            contents += "\nendfacet\n"
            
            nth += 3
        }
        
        contents += "\nendsolid \(scene.name)"
        
        print(contents)
        
        FileManager.default.createFile(atPath: filePath, contents: contents.data(using: .utf8), attributes: nil)
        
        return filePath
    }
    
    // PLY format export
    
    static func exportPLY(scene: Scene) -> String {
        let docPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let filePath: String = docPath + "/" + (scene.name + ".ply")
        
        var contents = "ply\nformat ascii 1.0\ncomment Modeled on iPhone"
        
        contents += "\nelement vertex \(scene.indicesCount)\nproperty float x\nproperty float y\nproperty float z"
        
        contents += "\nelement face \(scene.indicesCount / 3)\nproperty list uchar int vertex_index\nend_header"
        
        for i in 0..<scene.indicesCount {
            contents += "\n\(scene.bigVertices[i].position.x) \(scene.bigVertices[i].position.y) \(scene.bigVertices[i].position.z)"
        }
        var nth = 0
        for _ in 0..<(scene.indicesCount / 3) {
            contents += "\n3 \(nth) \(nth + 1) \(nth + 2)"
            nth += 3
        }
        
        print(contents)
        
        FileManager.default.createFile(atPath: filePath, contents: contents.data(using: .utf8), attributes: nil)
        
        return filePath
    }
}
