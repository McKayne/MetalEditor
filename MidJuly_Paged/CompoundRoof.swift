//
//  CompoundRoof.swift
//  MidJuly_Paged
//
//  Created by для интернета on 20.09.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class CompoundRoof: SceneObject {
    
    private var x: Float, y: Float, z: Float
    private var width: Float, lowerSegments: Int
    private var rgb: (r: Int, g: Int, b: Int)
    
    private func appendCompoundRoof() {
        
        var lowerHeight = 0.3, depth = 0.05, roofDepth = 0.6
        
        var segmentWidth = width / Float(lowerSegments)
        
        // front lower
        var radius = sqrt(pow(lowerHeight / 2, 2) + pow(depth / 2, 2))
        
        var tg = (lowerHeight / 2) / (-depth / 2)
        var angle = atan(tg) / (M_PI / 180) + 180
        
        var lowerY = sin((angle + 30) * M_PI / 180.0) * radius
        
        var lowerCube: SceneObject = Cube(x: x, y: y, z: z, width: segmentWidth, height: Float(lowerHeight), depth: Float(depth), rgb: rgb)
        lowerCube = Demo1.faceGrid(object: lowerCube, widthDiff: segmentWidth, heightDiff: Float(lowerHeight), rows: 1, cols: lowerSegments)
        lowerCube.rotateZ(zAngle: 30)
        lowerCube.translateTo(xTranslate: 0, yTranslate: Float(lowerY - lowerHeight / 2), zTranslate: 0)
        
        // back lower
        //int backLowerStart = self.totalIndices;
        
        var lowerCube2: SceneObject = Cube(x: x, y: y, z: z - Float(roofDepth + depth), width: segmentWidth, height: Float(lowerHeight), depth: Float(depth), rgb: rgb)
        lowerCube2 = Demo1.faceGrid(object: lowerCube2, widthDiff: segmentWidth, heightDiff: Float(lowerHeight), rows: 1, cols: lowerSegments)
        lowerCube2.rotateZ(zAngle: -30)
        lowerCube2.translateTo(xTranslate: 0, yTranslate: Float(lowerY - lowerHeight / 2), zTranslate: 0.1)
        
        // upper
        var upperHeight = 0.255993843
        
        tg = (lowerHeight / 2) / (depth / 2)
        angle = atan(tg) / (M_PI / 180)
        var upperY = sin((angle + 30) * M_PI / 180.0) * radius
        var upperZ = cos((angle + 30) * M_PI / 180.0) * radius
        
        // upper front
        
        radius = sqrt(pow(upperHeight / 2, 2) + pow(depth / 2, 2))
        tg = (upperHeight / 2) / (-depth / 2)
        angle = atan(tg) / (M_PI / 180) + 180
        
        var upperYlower = sin((angle + 60) * M_PI / 180.0) * radius
        var upperZlower = cos((angle + 60) * M_PI / 180.0) * radius
        
        tg = (upperHeight / 2) / (depth / 2)
        angle = atan(tg) / (M_PI / 180)
        
        upperHeight = sqrt(pow((depth / 2 - roofDepth / 2 - (upperZ + upperZlower)) / cos((angle + 60) * M_PI / 180.0), 2) - pow(depth / 2, 2)) * 2
        
        let yArg: Float = y + Float(lowerHeight) - (Float(lowerHeight) / 2.0 - Float(upperY)) + Float(lowerY) - Float(lowerHeight) / 2.0
        var upperCube: SceneObject = Cube(x: x, y: yArg, z: z, width: width, height: Float(upperHeight), depth: Float(depth), rgb: rgb)
        upperCube.rotateZ(zAngle: 60)
        
        var topZ = cos((angle + 60) * M_PI / 180.0) * radius + (upperZ + upperZlower)
        var topDiff = topZ - depth / 2
        var centerDiff = roofDepth / 2 + topDiff
        
        upperCube.translateTo(xTranslate: 0, yTranslate: Float(upperYlower - upperHeight / 2), zTranslate: Float(upperZ) - Float(depth / 2) + Float(upperZlower + depth / 2))
        
        // upper back
        var upperCube2: SceneObject = Cube(x: x, y: yArg, z: z - Float(roofDepth + depth), width: width, height: Float(upperHeight), depth: Float(depth), rgb: rgb)
        upperCube2.rotateZ(zAngle: -60)
        
        var zArg: Float = -(Float(upperZ) - Float(depth / 2) + Float(upperZlower + depth / 2))
        upperCube2.translateTo(xTranslate: 0, yTranslate: Float(upperYlower - upperHeight / 2), zTranslate: zArg + 0.1)
        
        /*
         
         
         
         
         //topDiff = -roofDepth / 2;
         //topZ - depth / 2 = -roofDepth / 2;
         //topZ = depth / 2 - roofDepth / 2;
         //cos((angle + 60) * M_PI / 180.0) * radius + (upperZ + upperZlower) = depth / 2 - roofDepth / 2;
         //cos((angle + 60) * M_PI / 180.0) * radius = depth / 2 - roofDepth / 2 - (upperZ + upperZlower);
         //radius = (depth / 2 - roofDepth / 2 - (upperZ + upperZlower)) / cos((angle + 60) * M_PI / 180.0);
         //sqrt(pow(upperHeight / 2, 2) + pow(depth / 2, 2)) = (depth / 2 - roofDepth / 2 - (upperZ + upperZlower)) / cos((angle + 60) * M_PI / 180.0);
         //pow(upperHeight / 2, 2) + pow(depth / 2, 2) = pow((depth / 2 - roofDepth / 2 - (upperZ + upperZlower)) / cos((angle + 60) * M_PI / 180.0), 2);
         //pow(upperHeight / 2, 2) = pow((depth / 2 - roofDepth / 2 - (upperZ + upperZlower)) / cos((angle + 60) * M_PI / 180.0), 2) - pow(depth / 2, 2);
         //upperHeight / 2 = sqrt(pow((depth / 2 - roofDepth / 2 - (upperZ + upperZlower)) / cos((angle + 60) * M_PI / 180.0), 2) - pow(depth / 2, 2));
         upperHeight = sqrt(pow((depth / 2 - roofDepth / 2 - (upperZ + upperZlower)) / cos((angle + 60) * M_PI / 180.0), 2) - pow(depth / 2, 2)) * 2;
         
         return lastIndices;
 */
        
        
        for i in 0..<lowerCube.vertices.count {
            vertices.append(lowerCube.vertices[i])
            lineVertices.append(lowerCube.lineVertices[i])
        }
        for i in 0..<lowerCube2.vertices.count {
            vertices.append(lowerCube2.vertices[i])
            lineVertices.append(lowerCube2.lineVertices[i])
        }
        for i in 0..<upperCube.vertices.count {
            vertices.append(upperCube.vertices[i])
            lineVertices.append(upperCube.lineVertices[i])
        }
        for i in 0..<upperCube2.vertices.count {
            vertices.append(upperCube2.vertices[i])
            lineVertices.append(upperCube2.lineVertices[i])
        }
    }
    
    init(x: Float, y: Float, z: Float, width: Float, lowerSegments: Int, rgb: (r: Int, g: Int, b: Int)) {
        self.x = x; self.y = y; self.z = z
        self.width = width; self.lowerSegments = lowerSegments
        self.rgb = rgb
        
        super.init()
        appendCompoundRoof()
    }
}
