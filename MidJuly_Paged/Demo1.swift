//
//  Demo1.swift
//  MidJuly_Paged
//
//  Created by для интернета on 18.09.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class Demo1 {
    
    static func faceGrid(object: SceneObject, widthDiff: Float, heightDiff: Float, rows: Int, cols: Int) -> SceneObject {
        let objectA = object.cloneAndTranslateTo(xTranslate: 0, yTranslate: 0, zTranslate: 0)
        
        for i in 0..<rows {
            for j in 0..<cols {
                if (i == 0 && j > 0) || i > 0 {
                    let objectB = object.cloneAndTranslateTo(xTranslate: Float(j) * widthDiff, yTranslate: Float(i) * heightDiff, zTranslate: 0)
                    objectA.attachObject(object: objectB)
                }
            }
        }
        
        return objectA
    }
    
    static func demo() {
        let scene = Scene(name: "iphone_app_export_test_3")
        
        let wallCellA = Face(x: -0.3, y: -0.25, z: 0.25, width: 0.1, height: 0.1, rgb: (254, 254, 252))
        wallCellA.attachObject(object: Face(x: -0.3 + 0.1, y: -0.25, z: 0.25, width: 0.1, height: 0.1, rgb: (254, 254, 252)))
        wallCellA.attachObject(object: Face(x: -0.3 + 0.2, y: -0.25, z: 0.25, width: 0.1, height: 0.1, rgb: (254, 254, 252)))
        
        wallCellA.attachObject(object: Face(x: -0.3, y: -0.25 + 0.1, z: 0.25, width: 0.1, height: 0.1, rgb: (254, 254, 252)))
        //wallCellA.attachObject(object: Face(x: -0.3 + 0.1, y: -0.25 + 0.1, z: 0.25, width: 0.1, height: 0.1, rgb: (156, 174, 184)))
        wallCellA.attachObject(object: Face(x: -0.3 + 0.2, y: -0.25 + 0.1, z: 0.25, width: 0.1, height: 0.1, rgb: (254, 254, 252)))
        
        wallCellA.attachObject(object: Face(x: -0.3, y: -0.25 + 0.2, z: 0.25, width: 0.1, height: 0.1, rgb: (254, 254, 252)))
        wallCellA.attachObject(object: Face(x: -0.3 + 0.1, y: -0.25 + 0.2, z: 0.25, width: 0.1, height: 0.1, rgb: (254, 254, 252)))
        wallCellA.attachObject(object: Face(x: -0.3 + 0.2, y: -0.25 + 0.2, z: 0.25, width: 0.1, height: 0.1, rgb: (254, 254, 252)))
        
        let wallCellB = Face(x: -0.3, y: -0.25, z: 0.25, width: 0.3, height: 0.3, rgb: (254, 254, 252))
        
        let wallLeft = faceGrid(object: wallCellA, widthDiff: 0.3, heightDiff: 0.3, rows: 4, cols: 4)
        
        let wall3x2 = faceGrid(object: wallCellA, widthDiff: 0.3, heightDiff: 0.3, rows: 3, cols: 2)
        wall3x2.rotateX(xAngle: -90)
        wall3x2.translateTo(xTranslate: -0.3 * 2 + 0.3, yTranslate: 0.3, zTranslate: -0.3)
        wallLeft.attachObject(object: wall3x2)
        
        let wall4x5 = faceGrid(object: wallCellA, widthDiff: 0.3, heightDiff: 0.3, rows: 5, cols: 4)
        wall4x5.translateTo(xTranslate: 0.3 * 4, yTranslate: 0, zTranslate: 0)
        wallLeft.attachObject(object: wall4x5)
        
        var roof1 = CompoundRoof(x: -0.3 - 0.05, y: 0.3 * 3, z: 0.25, width: 0.05, lowerSegments: 1, rgb: (28, 44, 80))
        wallLeft.attachObject(object: roof1)
        var roof1a = CompoundRoof(x: -0.3, y: 0.3 * 3, z: 0.25, width: 1.2, lowerSegments: 4, rgb: (28, 44, 80))
        wallLeft.attachObject(object: roof1a)
        var roof2 = CompoundRoof(x: -0.3 + 0.3 * 4 - 0.05, y: 0.3 * 4, z: 0.25, width: 0.05, lowerSegments: 1, rgb: (28, 44, 80))
        wallLeft.attachObject(object: roof2)
        var roof2a = CompoundRoof(x: -0.3 + 0.3 * 4, y: 0.3 * 4, z: 0.25, width: 1.2, lowerSegments: 4, rgb: (28, 44, 80))
        wallLeft.attachObject(object: roof2a)
        
        var wallLeft2: SceneObject
        
        
        
        wallLeft2 = wallCellB.cloneAndTranslateTo(xTranslate: -0.3 * 2, yTranslate: 0.3 * 4, zTranslate: 0)
        wallLeft2 = faceGrid(object: wallLeft2, widthDiff: 0.3, heightDiff: 0.3, rows: 1, cols: 1)
        wallLeft2.rotateX(xAngle: -90)
        wallLeft2.translateTo(xTranslate: 0.15 + 0.3 * 5, yTranslate: 0, zTranslate: -0.15)
        wallLeft.attachObject(object: wallLeft2)
        
        wallLeft2 = wallCellB.cloneAndTranslateTo(xTranslate: 0.3 * 4, yTranslate: 0.3 * 5, zTranslate: -0.3)
        wallLeft2 = faceGrid(object: wallLeft2, widthDiff: 0.3, heightDiff: 0.3, rows: 1, cols: 4)
        wallLeft.attachObject(object: wallLeft2)
        
        wallLeft2 = wallCellB.cloneAndTranslateTo(xTranslate: -0.3 * 2, yTranslate: 0.3 * 5, zTranslate: 0)
        wallLeft2 = faceGrid(object: wallLeft2, widthDiff: 0.3, heightDiff: 0.3, rows: 1, cols: 1)
        wallLeft2.rotateX(xAngle: -90)
        wallLeft2.translateTo(xTranslate: 0.15 + 0.3 * 5, yTranslate: 0, zTranslate: -0.45)
        
        wallLeft2.translateVertexTo(nth: 4, xTranslate: 0, yTranslate: -0.1, zTranslate: 0.1)
        
        wallLeft.attachObject(object: wallLeft2)
        
        wallLeft2 = wallCellB.cloneAndTranslateTo(xTranslate: 0.3 * 4, yTranslate: 0.3 * 5, zTranslate: 0)
        wallLeft2 = faceGrid(object: wallLeft2, widthDiff: 0.3, heightDiff: 0.3, rows: 1, cols: 4)
        wallLeft2.rotateZ(zAngle: 90)
        wallLeft2.translateTo(xTranslate: 0, yTranslate: -0.15, zTranslate: -0.15)
        wallLeft.attachObject(object: wallLeft2)
        
        wallLeft2 = Face(x: -0.3 - 0.3 * 2, y: -0.25 - 0.1, z: 0.25, width: 0.3, height: 0.1, rgb: (61, 38, 32))
        wallLeft2 = faceGrid(object: wallLeft2, widthDiff: 0.3, heightDiff: 0.1, rows: 1, cols: 2)
        wallLeft2.rotateX(xAngle: -90)
        wallLeft2.translateTo(xTranslate: 0.3, yTranslate: 0, zTranslate: -0.3)
        wallLeft.attachObject(object: wallLeft2)
        
        wallLeft2 = Face(x: -0.3, y: -0.25 - 0.1, z: 0.25, width: 0.3, height: 0.1, rgb: (61, 38, 32))
        wallLeft2 = faceGrid(object: wallLeft2, widthDiff: 0.3, heightDiff: 0.1, rows: 1, cols: 8)
        wallLeft.attachObject(object: wallLeft2)
        
        let wallRight = wallLeft.cloneAndTranslateTo(xTranslate: 0.3 * 12 + 0.05, yTranslate: 0, zTranslate: 0)
        wallRight.mirrorX()
        
        wallLeft2 = Face(x: 0.3 * 7, y: -0.25 - 0.1, z: 0.25, width: 0.3, height: 0.1, rgb: (61, 38, 32))
        //wallLeft2 = faceGrid(object: wallLeft2, widthDiff: 0.3, heightDiff: 0.1, rows: 1, cols: 1)
        wallLeft.attachObject(object: wallLeft2)
        
        wallLeft2 = wallCellA.cloneAndTranslateTo(xTranslate: -0.3 * 2, yTranslate: 0, zTranslate: 0)
        wallLeft2 = faceGrid(object: wallLeft2, widthDiff: 0.3, heightDiff: 0.3, rows: 1, cols: 2)
        wallLeft2.rotateX(xAngle: -90)
        wallLeft2.translateTo(xTranslate: 0.3, yTranslate: 0, zTranslate: -0.3)
        wallLeft.attachObject(object: wallLeft2)
        
        wallLeft2 = wallCellB.cloneAndTranslateTo(xTranslate: -0.3 * 2, yTranslate: 0.3 * 4, zTranslate: 0)
        wallLeft2 = faceGrid(object: wallLeft2, widthDiff: 0.3, heightDiff: 0.3, rows: 1, cols: 2)
        wallLeft2.rotateX(xAngle: -90)
        wallLeft2.translateTo(xTranslate: 0.3, yTranslate: 0, zTranslate: -0.3)
        
        wallLeft2.translateVertexTo(nth: 4, xTranslate: 0, yTranslate: -0.1, zTranslate: 0.1)
        wallLeft2.translateVertexTo(nth: 2 + 6, xTranslate: 0, yTranslate: -0.1, zTranslate: -0.1)
        wallLeft2.translateVertexTo(nth: 3 + 6, xTranslate: 0, yTranslate: -0.1, zTranslate: -0.1)
        
        wallLeft.attachObject(object: wallLeft2)

        
        // central house
        
        wallLeft2 = wallCellB.cloneAndTranslateTo(xTranslate: 0.3 * 8, yTranslate: 0.3 * 8, zTranslate: 0)
        wallLeft2.setColor(rgb: (254, 254, 252))
        wallLeft.attachObject(object: wallLeft2)
        
        let wallB9x2 = faceGrid(object: wallCellB, widthDiff: 0.3, heightDiff: 0.3, rows: 9, cols: 2)
        wallB9x2.setColor(rgb: (254, 254, 252))
        wallB9x2.translateTo(xTranslate: 0.3 * 8 - 0.3, yTranslate: 0, zTranslate: -0.3)
        wallB9x2.rotateX(xAngle: -90)
        
        let wallObjBa = wallCellB.cloneAndTranslateTo(xTranslate: 0.3 * 8, yTranslate: 0, zTranslate: 0)
        wallObjBa.setColor(rgb: (254, 254, 252))
        
        var wallObjBb = wallCellA.cloneAndTranslateTo(xTranslate: 0.3 * 8, yTranslate: 0.3, zTranslate: 0)
        wallObjBb = faceGrid(object: wallObjBb, widthDiff: 0.3, heightDiff: 0.3, rows: 7, cols: 1)
        wallObjBb.setColor(rgb: (254, 254, 252))
        wallObjBa.attachObject(object: wallObjBb)
        
        let wallA8x2 = faceGrid(object: wallCellA, widthDiff: 0.3, heightDiff: 0.3, rows: 8, cols: 3)
        wallA8x2.setColor(rgb: (254, 254, 252))
        wallA8x2.translateTo(xTranslate: 0.3 * 9, yTranslate: 0, zTranslate: 0)
        
        let wallB9x2b = wallB9x2.cloneAndTranslateTo(xTranslate: 0.3 * 4, yTranslate: 0, zTranslate: 0)
        wallLeft.attachObject(object: wallB9x2)
        
        wallLeft.attachObject(object: wallObjBa)
        
        
        
        
        wallLeft.rotateX(xAngle: 30)
        
        // right house
        
        var wallRightTemp = wallCellB.cloneAndTranslateTo(xTranslate: 0.3 * 20, yTranslate: 0.3 * 4, zTranslate: 0)
        wallRightTemp = faceGrid(object: wallRightTemp, widthDiff: 0.3, heightDiff: 0.3, rows: 1, cols: 2)
        wallRightTemp.rotateX(xAngle: 90)
        wallRightTemp.translateTo(xTranslate: -0.3, yTranslate: 0, zTranslate: -0.3)
        
        wallRightTemp.translateVertexTo(nth: 4, xTranslate: 0, yTranslate: -0.1, zTranslate: -0.1)
        wallRightTemp.translateVertexTo(nth: 2 + 6, xTranslate: 0, yTranslate: -0.1, zTranslate: 0.1)
        wallRightTemp.translateVertexTo(nth: 3 + 6, xTranslate: 0, yTranslate: -0.1, zTranslate: 0.1)
        
        wallRight.attachObject(object: wallRightTemp)
        
        wallRightTemp = Face(x: 0.3 * 8, y: -0.25 - 0.1, z: 0.25, width: 0.3, height: 0.1, rgb: (61, 38, 32))
        wallRightTemp = faceGrid(object: wallRightTemp, widthDiff: 0.3, heightDiff: 0.1, rows: 1, cols: 3)
        wallRight.attachObject(object: wallRightTemp)
        
        wallRightTemp = wallCellB.cloneAndTranslateTo(xTranslate: 0.3 * 20, yTranslate: 0, zTranslate: 0)
        wallRightTemp.attachObject(object: wallCellA.cloneAndTranslateTo(xTranslate: 0.3 * 21, yTranslate: 0, zTranslate: 0))
        wallRightTemp.rotateX(xAngle: 90)
        wallRightTemp.translateTo(xTranslate: -0.3, yTranslate: 0, zTranslate: -0.3)
        wallRight.attachObject(object: wallRightTemp)
        
        wallRightTemp = wallCellB.cloneAndTranslateTo(xTranslate: 0.3 * 16, yTranslate: 0.3 * 5, zTranslate: 0)
        wallRightTemp.rotateX(xAngle: 90)
        wallRightTemp.translateTo(xTranslate: -0.15, yTranslate: 0, zTranslate: -0.15)
        
        wallRightTemp.translateVertexTo(nth: 4, xTranslate: 0, yTranslate: -0.1, zTranslate: -0.1)
        
        wallRight.attachObject(object: wallRightTemp)
        
        wallRightTemp = wallCellB.cloneAndTranslateTo(xTranslate: 0.3 * 9, yTranslate: 0.3 * 8, zTranslate: 0)
        wallRightTemp = faceGrid(object: wallRightTemp, widthDiff: 0.3, heightDiff: 0.3, rows: 1, cols: 3)
        wallRightTemp.setColor(rgb: (254, 254, 252))
        wallRight.attachObject(object: wallRightTemp)
        
        wallRight.attachObject(object: wallB9x2b)
        wallRight.attachObject(object: wallA8x2)
        wallRight.rotateX(xAngle: -30)
        
        wallRight.translateTo(xTranslate: -0.109, yTranslate: 0, zTranslate: 0.15)
        
        let bottom = Cube(x: -2, y: -0.26, z: 5, width: 10, height: 0.01, depth: 10, rgb: (1, 63, 0))
        
        wallLeft.translateTo(xTranslate: 0, yTranslate: 0.1, zTranslate: 0)
        wallRight.translateTo(xTranslate: 0, yTranslate: 0.1, zTranslate: 0)
        
        
        scene.appendObject(object: wallLeft)
        scene.appendObject(object: wallRight)
        scene.appendObject(object: bottom)
        
        scene.prepareForRender()
        
        RootViewController.scenes.append(scene)
    }
}
