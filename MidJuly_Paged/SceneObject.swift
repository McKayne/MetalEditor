//
//  SceneObject.swift
//  MidJuly_Paged
//
//  Created by для интернета on 18.09.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class SceneObject {
    var vertices: [Vertex] = []
    var lineVertices: [Vertex] = []
    
    var indices: [Int] = []
    var lineIndices: [Int] = []
    
    func translateTo(xTranslate: Float, yTranslate: Float, zTranslate: Float) {
        for i in 0..<vertices.count {
            vertices[i].position.x += xTranslate
            vertices[i].position.y += yTranslate
            vertices[i].position.z += zTranslate
            
            lineVertices[i].position = vertices[i].position
        }
    }
    
    func placeAt(x: Float, y: Float, z: Float) {
        
    }
    
    func rotate(xAngle: Float, yAngle: Float, zAngle: Float) {
        rotateX(xAngle: xAngle)
        rotateZ(zAngle: zAngle)
    }
    
    func rotateX(xAngle: Float) {
        var xMin = vertices[0].position.x, xMax = vertices[0].position.x
        var zMin = vertices[0].position.z, zMax = vertices[0].position.z

        for i in 0..<vertices.count {
            if vertices[i].position.x < xMin {
                xMin = vertices[i].position.x
            }
            if vertices[i].position.x > xMax {
                xMax = vertices[i].position.x
            }
            if vertices[i].position.z < zMin {
                zMin = vertices[i].position.z
            }
            if vertices[i].position.z > zMax {
                zMax = vertices[i].position.z
            }
        }
        
        let xCenter = (xMax + xMin) / 2.0
        let zCenter = (zMax + zMin) / 2.0
        
        for i in 0..<vertices.count {
            let x = vertices[i].position.x - xCenter
            let z = -(vertices[i].position.z - zCenter)
            
            let radius = sqrt(x * x + z * z)
            if radius == 0.0 {
                continue
            }
            
            let tg = z / x
            if x >= 0.0 && z >= 0.0 {
                let angle = atan(tg) / Float(M_PI / 180) + xAngle
                
                vertices[i].position.x = cos(angle * Float(M_PI / 180)) * radius + xCenter
                vertices[i].position.z = -(sin(angle * Float(M_PI / 180)) * radius - zCenter)
            } else if x < 0.0 && z >= 0.0 {
                let angle = atan(tg) / Float(M_PI / 180) + 180 + xAngle
                
                vertices[i].position.x = cos(angle * Float(M_PI / 180)) * radius + xCenter
                vertices[i].position.z = -(sin(angle * Float(M_PI / 180)) * radius - zCenter)
            } else if x < 0.0 && z < 0.0 {
                let angle = atan(tg) / Float(M_PI / 180) + 180 + xAngle
                
                vertices[i].position.x = cos(angle * Float(M_PI / 180)) * radius + xCenter
                vertices[i].position.z = -(sin(angle * Float(M_PI / 180)) * radius - zCenter)
            } else {
                let angle = atan(tg) / Float(M_PI / 180) + xAngle
                
                vertices[i].position.x = cos(angle * Float(M_PI / 180)) * radius + xCenter
                vertices[i].position.z = -(sin(angle * Float(M_PI / 180)) * radius - zCenter)
            }
            
            lineVertices[i].position = vertices[i].position;
        }
    }
    
    func rotateY(yAngle: Float) {
        
    }
    
    func rotateZ(zAngle: Float) {
        var yMin = vertices[0].position.y, yMax = vertices[0].position.y
        var zMin = vertices[0].position.z, zMax = vertices[0].position.z
        
        for i in 0..<vertices.count {
            if vertices[i].position.y < yMin {
                yMin = vertices[i].position.y
            }
            if vertices[i].position.y > yMax {
                yMax = vertices[i].position.y
            }
            if vertices[i].position.z < zMin {
                zMin = vertices[i].position.z
            }
            if vertices[i].position.z > zMax {
                zMax = vertices[i].position.z
            }
        }
        
        let yCenter = (yMax + yMin) / 2.0
        let zCenter = (zMax + zMin) / 2.0
        
        for i in 0..<vertices.count {
            
            let y = vertices[i].position.y - yCenter
            let z = -(vertices[i].position.z - zCenter)
            
            let radius = sqrt(y * y + z * z)
            if radius == 0.0 {
                continue
            }
            
            let tg = z / y
            if y >= 0.0 && z >= 0.0 {
                let angle = atan(tg) / Float(M_PI / 180) + zAngle
                
                vertices[i].position.y = cos(angle * Float(M_PI / 180)) * radius + yCenter
                vertices[i].position.z = -(sin(angle * Float(M_PI / 180)) * radius - zCenter)
            } else if y < 0.0 && z >= 0.0 {
                let angle = atan(tg) / Float(M_PI / 180) + 180 + zAngle
                
                vertices[i].position.y = cos(angle * Float(M_PI / 180)) * radius + yCenter
                vertices[i].position.z = -(sin(angle * Float(M_PI / 180)) * radius - zCenter)
            } else if y < 0.0 && z < 0.0 {
                let angle = atan(tg) / Float(M_PI / 180) + 180 + zAngle
                
                vertices[i].position.y = cos(angle * Float(M_PI / 180)) * radius + yCenter
                vertices[i].position.z = -(sin(angle * Float(M_PI / 180)) * radius - zCenter)
            } else {
                let angle = atan(tg) / Float(M_PI / 180) + zAngle
                
                vertices[i].position.y = cos(angle * Float(M_PI / 180)) * radius + yCenter
                vertices[i].position.z = -(sin(angle * Float(M_PI / 180)) * radius - zCenter)
            }
            
            lineVertices[i].position = vertices[i].position
        }
    }
    
    func mirrorX() {
        var xMin = vertices[0].position.x, xMax = vertices[0].position.x
        var zMin = vertices[0].position.z, zMax = vertices[0].position.z
        
        for i in 0..<vertices.count {
            if vertices[i].position.x < xMin {
                xMin = vertices[i].position.x
            }
            if vertices[i].position.x > xMax {
                xMax = vertices[i].position.x
            }
            if vertices[i].position.z < zMin {
                zMin = vertices[i].position.z
            }
            if vertices[i].position.z > zMax {
                zMax = vertices[i].position.z
            }
        }
        
        let xCenter = (xMax + xMin) / 2.0
        let zCenter = (zMax + zMin) / 2.0
        
        for i in 0..<vertices.count {
            let x = vertices[i].position.x - xCenter
            let z = -(vertices[i].position.z - zCenter)
            
            let radius = sqrt(x * x + z * z)
            if radius == 0.0 {
                continue
            }
            
            let tg = z / x
            if x >= 0.0 && z >= 0.0 {
                let angle = atan(tg) / Float(M_PI / 180) + 180
                
                vertices[i].position.x = cos(angle * Float(M_PI / 180)) * radius + xCenter
                //vertices[i].position.z = -(sin(angle * Float(M_PI / 180)) * radius - zCenter)
            } else if x < 0.0 && z >= 0.0 {
                let angle = atan(tg) / Float(M_PI / 180) + 180 + 180
                
                vertices[i].position.x = cos(angle * Float(M_PI / 180)) * radius + xCenter
                //vertices[i].position.z = -(sin(angle * Float(M_PI / 180)) * radius - zCenter)
            } else if x < 0.0 && z < 0.0 {
                let angle = atan(tg) / Float(M_PI / 180) + 180 + 180
                
                vertices[i].position.x = cos(angle * Float(M_PI / 180)) * radius + xCenter
                //vertices[i].position.z = -(sin(angle * Float(M_PI / 180)) * radius - zCenter)
            } else {
                let angle = atan(tg) / Float(M_PI / 180) + 180
                
                vertices[i].position.x = cos(angle * Float(M_PI / 180)) * radius + xCenter
                //vertices[i].position.z = -(sin(angle * Float(M_PI / 180)) * radius - zCenter)
            }
            
            lineVertices[i].position = vertices[i].position;
        }
    }
    
    func scaleBy(widthMultiplier: Float, heightMultiplier: Float, depthMultiplier: Float) {
        for i in 0..<vertices.count {
            vertices[i].position.x *= widthMultiplier
            vertices[i].position.y *= heightMultiplier
            vertices[i].position.z *= depthMultiplier
            
            lineVertices[i].position = vertices[i].position
        }
    }
    
    func attachObject(object: SceneObject) {
        for vertex in object.vertices {
            vertices.append(vertex)
        }
        for lineVertex in object.lineVertices {
            lineVertices.append(lineVertex)
        }
    }
    
    func cloneAndTranslateTo(xTranslate: Float, yTranslate: Float, zTranslate: Float) -> SceneObject {
        let object = SceneObject()
        for vertex in vertices {
            var newVertex = Vertex()
            newVertex.position = customFloat4(x: vertex.position.x + xTranslate, y: vertex.position.y + yTranslate, z: vertex.position.z + zTranslate, w: 1.0)
            newVertex.customColor = vertex.customColor
            
            object.vertices.append(newVertex)
        }
        for lineVertex in lineVertices {
            var newLineVertex = Vertex()
            newLineVertex.position = customFloat4(x: lineVertex.position.x + xTranslate, y: lineVertex.position.y + yTranslate, z: lineVertex.position.z + zTranslate, w: 1.0)
            newLineVertex.customColor = lineVertex.customColor
            
            object.lineVertices.append(newLineVertex)
        }
        return object
    }
    
    func setColor(rgb: (r: Float, g: Float, b: Float)) {
        for i in 0..<vertices.count {
            vertices[i].customColor.x = rgb.r
            vertices[i].customColor.y = rgb.g
            vertices[i].customColor.z = rgb.b
        }
    }
    
    func translateVertexTo(nth: Int, xTranslate: Float, yTranslate: Float, zTranslate: Float) {
        vertices[nth].position.x += xTranslate
        vertices[nth].position.y += yTranslate
        vertices[nth].position.z += zTranslate
        
        lineVertices[nth].position = vertices[nth].position
    }
}
