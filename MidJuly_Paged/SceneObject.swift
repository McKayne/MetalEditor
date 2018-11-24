//
//  SceneObject.swift
//  MidJuly_Paged
//
//  Created by для интернета on 18.09.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class SceneObject {
    
    var isSelected = false
    
    var vertices: [Vertex] = []
    var lineVertices: [Vertex] = []
    
    //var indices: [Int] = []
    //var lineIndices: [Int] = []
    
    func translateTo(xTranslate: Float, yTranslate: Float, zTranslate: Float) {
        for i in 0..<vertices.count {
            vertices[i].position.x += xTranslate
            vertices[i].position.y += yTranslate
            vertices[i].position.z += zTranslate
            
            lineVertices[i].position = vertices[i].position
        }
    }
    
    func shiftTo(xShift: Float, yShift: Float, zShift: Float) {
        var shiftVertices = vertices
        var shiftLineVertices = lineVertices
        
        for i in 0..<vertices.count {
            shiftVertices[i].position.x += xShift
            shiftVertices[i].position.y += yShift
            shiftVertices[i].position.z += zShift
            
            shiftLineVertices[i].position = shiftVertices[i].position
        }
        
        var innerVertices: [Vertex] = [], innerLineVertices: [Vertex] = []
        for i in 0..<(vertices.count - 1) {
            var v1 = Vertex()
            v1.position = vertices[i].position
            v1.normal = customFloat4(x: 0, y: 0, z: 0, w: 0)
            v1.customColor = vertices[i].customColor
            v1.texCoord = customFloat4(x: 0, y: 0, z: 0, w: 0)
            
            var v2 = Vertex()
            v2.position = shiftVertices[i].position
            v2.normal = customFloat4(x: 0, y: 0, z: 0, w: 0)
            v2.customColor = shiftVertices[i].customColor
            v2.texCoord = customFloat4(x: 0, y: 0, z: 0, w: 0)
            
            var v3 = Vertex()
            v3.position = shiftVertices[i + 1].position
            v3.normal = customFloat4(x: 0, y: 0, z: 0, w: 0)
            v3.customColor = shiftVertices[i + 1].customColor
            v3.texCoord = customFloat4(x: 0, y: 0, z: 0, w: 0)
            
            var v4 = Vertex()
            v4.position = vertices[i + 1].position
            v4.normal = customFloat4(x: 0, y: 0, z: 0, w: 0)
            v4.customColor = vertices[i + 1].customColor
            v4.texCoord = customFloat4(x: 0, y: 0, z: 0, w: 0)
            
            innerVertices.append(v1)
            innerVertices.append(v2)
            innerVertices.append(v3)
            
            innerVertices.append(v1)
            innerVertices.append(v4)
            innerVertices.append(v3)
            
            var lv1 = v1
            lv1.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
            
            var lv2 = v2
            lv2.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
            
            var lv3 = v3
            lv3.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
            
            var lv4 = v4
            lv4.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
            
            innerLineVertices.append(lv1)
            innerLineVertices.append(lv2)
            innerLineVertices.append(lv3)
            
            innerLineVertices.append(lv1)
            innerLineVertices.append(lv4)
            innerLineVertices.append(lv3)
        }
        
        for i in 0..<vertices.count {
            vertices.append(shiftVertices[i])
            lineVertices.append(shiftLineVertices[i])
        }
        for i in 0..<innerVertices.count {
            vertices.append(innerVertices[i])
            lineVertices.append(innerLineVertices[i])
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
    
    func split() {
        var splitVertices: [Vertex] = []
        var splitLineVertices: [Vertex] = []
        
        for i in stride(from: 0, to: vertices.count, by: 3) {
            
            let centerAB = customFloat4(x: (vertices[i + 1].position.x - vertices[i].position.x) / 2 + vertices[i].position.x, y: (vertices[i + 1].position.y - vertices[i].position.y) / 2 + vertices[i].position.y, z: (vertices[i + 1].position.z - vertices[i].position.z) / 2 + vertices[i].position.z, w: 1)
            
            let centerBC = customFloat4(x: (vertices[i + 2].position.x - vertices[i + 1].position.x) / 2 + vertices[i + 1].position.x, y: (vertices[i + 2].position.y - vertices[i + 1].position.y) / 2 + vertices[i + 1].position.y, z: (vertices[i + 2].position.z - vertices[i + 1].position.z) / 2 + vertices[i + 1].position.z, w: 1)
            
            let centerAC = customFloat4(x: (vertices[i].position.x - vertices[i + 2].position.x) / 2 + vertices[i + 2].position.x, y: (vertices[i].position.y - vertices[i + 2].position.y) / 2 + vertices[i + 2].position.y, z: (vertices[i].position.z - vertices[i + 2].position.z) / 2 + vertices[i + 2].position.z, w: 1)
            
            
            /*let centerBC = customFloat4(x: (vertices[i + 2].position.x - vertices[i + 1].position.x) / 2, y: (vertices[i + 2].position.y - vertices[i + 1].position.y) / 2, w: 1)
            
            let centerAC = customFloat4(x: (vertices[i].position.x - vertices[i + 2].position.x) / 2, y: (vertices[i].position.y - vertices[i + 2].position.y) / 2, w: 1)*/
            
            
            var splitVertexA = Vertex()
            splitVertexA.position = vertices[i].position
            splitVertexA.normal = vertices[i].normal
            splitVertexA.customColor = vertices[i].customColor
            splitVertexA.texCoord = vertices[i].texCoord
            
            var splitVertexAB = Vertex()
            splitVertexAB.position = centerAB
            splitVertexAB.normal = vertices[i + 1].normal
            splitVertexAB.customColor = vertices[i + 1].customColor
            splitVertexAB.texCoord = vertices[i + 1].texCoord
            
            var splitVertexB = Vertex()
            splitVertexB.position = vertices[i + 1].position
            splitVertexB.normal = vertices[i].normal
            splitVertexB.customColor = vertices[i].customColor
            splitVertexB.texCoord = vertices[i].texCoord
            
            var splitVertexBC = Vertex()
            splitVertexBC.position = centerBC
            splitVertexBC.normal = vertices[i + 1].normal
            splitVertexBC.customColor = vertices[i + 1].customColor
            splitVertexBC.texCoord = vertices[i + 1].texCoord
            
            var splitVertexC = Vertex()
            splitVertexC.position = vertices[i + 2].position
            splitVertexC.normal = vertices[i].normal
            splitVertexC.customColor = vertices[i].customColor
            splitVertexC.texCoord = vertices[i].texCoord
            
            var splitVertexAC = Vertex()
            splitVertexAC.position = centerAC
            splitVertexAC.normal = vertices[i + 1].normal
            splitVertexAC.customColor = vertices[i + 1].customColor
            splitVertexAC.texCoord = vertices[i + 1].texCoord
            
            splitVertices.append(splitVertexA)
            splitVertices.append(splitVertexAB)
            splitVertices.append(splitVertexAC)
            
            splitVertices.append(splitVertexAB)
            splitVertices.append(splitVertexB)
            splitVertices.append(splitVertexBC)
            
            splitVertices.append(splitVertexBC)
            splitVertices.append(splitVertexC)
            splitVertices.append(splitVertexAC)
            
            splitVertices.append(splitVertexAB)
            splitVertices.append(splitVertexBC)
            splitVertices.append(splitVertexAC)
            
            var splitLineVertexA = splitVertexA
            splitLineVertexA.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
            
            var splitLineVertexAB = splitVertexAB
            splitLineVertexAB.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
            
            var splitLineVertexB = splitVertexB
            splitLineVertexB.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
            
            var splitLineVertexBC = splitVertexBC
            splitLineVertexBC.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
            
            var splitLineVertexC = splitVertexC
            splitLineVertexC.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
            
            var splitLineVertexAC = splitVertexAC
            splitLineVertexAC.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
            
            splitLineVertices.append(splitLineVertexA)
            splitLineVertices.append(splitLineVertexAB)
            splitLineVertices.append(splitLineVertexAC)
            
            splitLineVertices.append(splitLineVertexAB)
            splitLineVertices.append(splitLineVertexB)
            splitLineVertices.append(splitLineVertexBC)
            
            splitLineVertices.append(splitLineVertexBC)
            splitLineVertices.append(splitLineVertexC)
            splitLineVertices.append(splitLineVertexAC)
            
            splitLineVertices.append(splitLineVertexAB)
            splitLineVertices.append(splitLineVertexBC)
            splitLineVertices.append(splitLineVertexAC)
        }
        
        vertices = splitVertices
        lineVertices = splitLineVertices
        
    }
    
    func bendAround(center: (x: Float, y: Float, z: Float), zAngle: Float) {
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
            var angle: Float = 0
            if y >= 0.0 && z >= 0.0 {
                angle = atan(tg) / Float(M_PI / 180)
                
                
            } else if y < 0.0 && z >= 0.0 {
                angle = atan(tg) / Float(M_PI / 180) + 180
                
                
            } else if y < 0.0 && z < 0.0 {
                angle = atan(tg) / Float(M_PI / 180) + 180
                
            } else {
                angle = atan(tg) / Float(M_PI / 180)
                
                
            }
            
            print(angle)
            // 0 .. 90
            if angle >= 270 {
                
            }
            if (angle >= 0 && angle <= 90) || angle < 0 {
                angle += zAngle
            vertices[i].position.y = cos(angle * Float(M_PI / 180)) * radius + yCenter
            vertices[i].position.z = -(sin(angle * Float(M_PI / 180)) * radius - zCenter)
            }
            
            lineVertices[i].position = vertices[i].position
        }
    }
    
    func subdivide() {
        var facePoints: [customFloat4] = []
        for i in stride(from: 0, to: vertices.count, by: 3) {
            let a = vertices[i].position
            let b = vertices[i + 1].position
            let c = vertices[i + 2].position
            
            let avg = customFloat4(x: (a.x + b.x + c.x) / 3, y: (a.y + b.y + c.y) / 3, z: (a.z + b.z + c.z) / 3, w: 1)
            facePoints.append(avg)
        }
        
        var edgePoints: [customFloat4] = []
        for i in 0..<(vertices.count - 1) {
            let a = vertices[i].position
            let b = vertices[i + 1].position
            
            let avg = customFloat4(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2, z: (a.z + b.z) / 2, w: 1)
            edgePoints.append(avg)
        }
        
        var newVertices = vertices
        for i in 0..<vertices.count {

        //vertices[i].position.y -= 0.5
        var faces: [customFloat4] = []
        for j in stride(from: 0, to: vertices.count, by: 3) {
            let currentA = vertices[j].position, currentB = vertices[j + 1].position, currentC = vertices[j + 2].position
            var isFaceTouched = false
            
            if abs(currentA.x - vertices[i].position.x) <= pow(10, -4) && abs(currentA.y - vertices[i].position.y) <= pow(10, -4) && abs(currentA.z - vertices[i].position.z) <= pow(10, -4) {
                isFaceTouched = true
            } else if abs(currentB.x - vertices[i].position.x) <= pow(10, -4) && abs(currentB.y - vertices[i].position.y) <= pow(10, -4) && abs(currentB.z - vertices[i].position.z) <= pow(10, -4) {
                isFaceTouched = true
            } else if abs(currentC.x - vertices[i].position.x) <= pow(10, -4) && abs(currentC.y - vertices[i].position.y) <= pow(10, -4) && abs(currentC.z - vertices[i].position.z) <= pow(10, -4) {
                isFaceTouched = true
            }
            
            if isFaceTouched {
                let avg = customFloat4(x: (currentA.x + currentB.x + currentC.x) / 3, y: (currentA.y + currentB.y + currentC.y) / 3, z: (currentA.z + currentB.z + currentC.z) / 3, w: 1)
                faces.append(avg)
            }
        }
        
        var faceX: [Float] = [], faceY: [Float] = [], faceZ: [Float] = []
        for face in faces {
            faceX.append(face.x)
            faceY.append(face.y)
            faceZ.append(face.z)
        }
        let f = customFloat4(x: faceX.reduce(0, +) / Float(faces.count), y: faceY.reduce(0, +) / Float(faces.count), z: faceZ.reduce(0, +) / Float(faces.count), w: 1)
        
        let n = faces.count
        print(n)
        print("")
        print(faces)
        print("")
        print(f)
        
        var edges: [customFloat4] = []
        for j in 0..<(vertices.count - 1) {
            let currentA = vertices[j].position, currentB = vertices[j + 1].position
            var isEdgeTouched = false
            
            if abs(currentA.x - vertices[i].position.x) <= pow(10, -4) && abs(currentA.y - vertices[i].position.y) <= pow(10, -4) && abs(currentA.z - vertices[i].position.z) <= pow(10, -4) {
                isEdgeTouched = true
            } else if abs(currentB.x - vertices[i].position.x) <= pow(10, -4) && abs(currentB.y - vertices[i].position.y) <= pow(10, -4) && abs(currentB.z - vertices[i].position.z) <= pow(10, -4) {
                isEdgeTouched = true
            }
            
            if isEdgeTouched {
                
                var isEdgeRepeated = false
                for k in 0..<j {
                    let prevA = vertices[k].position, prevB = vertices[k + 1].position
                    
                    let diffX = abs(prevA.x - vertices[j].position.x)
                    let diffY = abs(prevA.y - vertices[j].position.y)
                    let diffZ = abs(prevA.z - vertices[j].position.z)
                    
                    let diffX2 = abs(prevB.x - vertices[j + 1].position.x)
                    let diffY2 = abs(prevB.y - vertices[j + 1].position.y)
                    let diffZ2 = abs(prevB.z - vertices[j + 1].position.z)
                    
                    let diffXinv = abs(prevA.x - vertices[j + 1].position.x)
                    let diffYinv = abs(prevA.y - vertices[j + 1].position.y)
                    let diffZinv = abs(prevA.z - vertices[j + 1].position.z)
                    
                    let diffX2inv = abs(prevB.x - vertices[j].position.x)
                    let diffY2inv = abs(prevB.y - vertices[j].position.y)
                    let diffZ2inv = abs(prevB.z - vertices[j].position.z)
                    
                    //print("\(diffX) \(diffY) \(diffZ) \(diffX2) \(diffY2) \(diffZ2)")
                    
                    if diffX <= pow(10, -4) && diffY <= pow(10, -4) && diffZ <= pow(10, -4) && diffX2 <= pow(10, -4) && diffY2 <= pow(10, -4) && diffZ2 <= pow(10, -4) {
                        isEdgeRepeated = true
                        //print("REPEAT")
                        break
                    } else if diffXinv <= pow(10, -4) && diffYinv <= pow(10, -4) && diffZinv <= pow(10, -4) && diffX2inv <= pow(10, -4) && diffY2inv <= pow(10, -4) && diffZ2inv <= pow(10, -4) {
                        isEdgeRepeated = true
                        //print("REPEAT")
                        break
                    }
                }
                
                if !isEdgeRepeated {
                    print("TOUCHED")
                    
                    let avg = customFloat4(x: (currentA.x + currentB.x) / 2, y: (currentA.y + currentB.y) / 2, z: (currentA.z + currentB.z) / 2, w: 1)
                    edges.append(avg)
                    
                    //print(currentA)
                    //print(currentB)
                }
                //print(currentA)
                //print(currentB)
                //let avg = customFloat4(x: (currentA.x + currentB.x + currentC.x) / 3, y: (currentA.y + currentB.y + currentC.y) / 3, z: (currentA.z + currentB.z + currentC.z) / 3, w: 1)
                //faces.append(avg)
            }
            
            
        }
        
        print(edges)
        var edgeX: [Float] = [], edgeY: [Float] = [], edgeZ: [Float] = []
        for edge in edges {
            edgeX.append(edge.x)
            edgeY.append(edge.y)
            edgeZ.append(edge.z)
        }
        let r = customFloat4(x: edgeX.reduce(0, +) / Float(edges.count), y: edgeY.reduce(0, +) / Float(edges.count), z: edgeZ.reduce(0, +) / Float(edges.count), w: 1)
        print(r)
        
        newVertices[i].position = customFloat4(x: (f.x + 2 * r.x + Float(n - 3) * vertices[i].position.x) / Float(n), y: (f.y + 2 * r.y + Float(n - 3) * vertices[i].position.y) / Float(n), z: (f.z + 2 * r.z + Float(n - 3) * vertices[i].position.z) / Float(n), w: 1)
        }
        
        
        var subdivided: [Vertex] = []
        var lineSubdivided: [Vertex] = []
        
        var facePointNth = 0
        for i in stride(from: 0, to: vertices.count, by: 3) {
            
            let positionA = newVertices[i].position
            let positionB = newVertices[i + 1].position
            let positionC = newVertices[i + 2].position
            
            var vertexCenter = Vertex()
            vertexCenter.position = facePoints[facePointNth]
            vertexCenter.normal = customFloat4(x: 0, y: 0, z: 0, w: 0)
            vertexCenter.customColor = customFloat4(x: 1, y: 0, z: 1, w: 1)
            vertexCenter.texCoord = customFloat4(x: 0, y: 0, z: 0, w: 0)
            
            var vertexA = Vertex()
            vertexA.position = positionA
            vertexA.normal = customFloat4(x: 0, y: 0, z: 0, w: 0)
            vertexA.customColor = customFloat4(x: 1, y: 0, z: 1, w: 1)
            vertexA.texCoord = customFloat4(x: 0, y: 0, z: 0, w: 0)
            
            var vertexB = Vertex()
            vertexB.position = positionB
            vertexB.normal = customFloat4(x: 0, y: 0, z: 0, w: 0)
            vertexB.customColor = customFloat4(x: 1, y: 0, z: 1, w: 1)
            vertexB.texCoord = customFloat4(x: 0, y: 0, z: 0, w: 0)
            
            var vertexC = Vertex()
            vertexC.position = positionC
            vertexC.normal = customFloat4(x: 0, y: 0, z: 0, w: 0)
            vertexC.customColor = customFloat4(x: 1, y: 0, z: 1, w: 1)
            vertexC.texCoord = customFloat4(x: 0, y: 0, z: 0, w: 0)
            
            subdivided.append(vertexCenter)
            subdivided.append(vertexA)
            subdivided.append(vertexB)
            
            subdivided.append(vertexCenter)
            subdivided.append(vertexB)
            subdivided.append(vertexC)
            
            subdivided.append(vertexCenter)
            subdivided.append(vertexC)
            subdivided.append(vertexA)
            
            var lineVertexCenter = vertexCenter
            lineVertexCenter.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
            
            var lineVertexA = vertexA
            lineVertexA.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
            
            var lineVertexB = vertexB
            lineVertexB.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
            
            var lineVertexC = vertexC
            lineVertexC.customColor = customFloat4(x: 0, y: 0, z: 0, w: 1)
            
            lineSubdivided.append(lineVertexCenter)
            lineSubdivided.append(lineVertexA)
            lineSubdivided.append(lineVertexB)
            
            lineSubdivided.append(lineVertexCenter)
            lineSubdivided.append(lineVertexB)
            lineSubdivided.append(lineVertexC)
            
            lineSubdivided.append(lineVertexCenter)
            lineSubdivided.append(lineVertexC)
            lineSubdivided.append(lineVertexA)
            
            facePointNth += 1
        }
        
        vertices = subdivided
        lineVertices = lineSubdivided
        
        
    }
}
