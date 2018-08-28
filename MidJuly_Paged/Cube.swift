//
//  Cube.swift
//  EarlyJuneNM_SV
//
//  Created by для интернета on 06.07.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation
import Metal

class Cube: Node {
    
    var verticesArray: [Vertex] = []
    
    func appendBorderCube(xStart: Float, yStart: Float, zStart: Float, width: Float, height: Float, depth: Float) {
        /*let A = Vertex(x: xStart, y: yStart + height, z: zStart + depth, r:  0.0, g:  0.0, b:  0.0, a:  1.0)
        let B = Vertex(x: xStart, y: yStart, z: zStart + depth, r:  0.0, g:  0.0, b:  0.0, a:  1.0)
        let C = Vertex(x: xStart + width, y: yStart, z: zStart + depth, r:  0.0, g:  0.0, b:  0.0, a:  1.0)
        let D = Vertex(x: xStart + width, y: yStart + height, z: zStart + depth, r:  0.0, g:  0.0, b:  0.0, a:  1.0)
        
        let Q = Vertex(x: xStart, y: yStart + height, z: zStart, r:  0.0, g:  0.0, b:  0.0, a:  1.0)
        let R = Vertex(x: xStart + width, y: yStart + height, z: zStart, r:  0.0, g:  0.0, b:  0.0, a:  1.0)
        let S = Vertex(x: xStart, y: yStart, z: zStart, r:  0.0, g:  0.0, b:  0.0, a:  1.0)
        let T = Vertex(x: xStart + width, y: yStart, z: zStart, r:  0.0, g:  0.0, b:  0.0, a:  1.0)
        
        verticesArray.append(A)
        verticesArray.append(B)
        verticesArray.append(C)
        
        verticesArray.append(A)
        verticesArray.append(C)
        verticesArray.append(D)   //Front
        
        
        verticesArray.append(R)
        verticesArray.append(T)
        verticesArray.append(S)
        
        verticesArray.append(Q)
        verticesArray.append(R)
        verticesArray.append(S)   //Back
        
        verticesArray.append(Q)
        verticesArray.append(S)
        verticesArray.append(B)
        
        verticesArray.append(Q)
        verticesArray.append(B)
        verticesArray.append(A)   //Left
        
        verticesArray.append(D)
        verticesArray.append(C)
        verticesArray.append(T)
        
        verticesArray.append(D)
        verticesArray.append(T)
        verticesArray.append(R)   //Right
        
        verticesArray.append(Q)
        verticesArray.append(A)
        verticesArray.append(D)
        
        verticesArray.append(Q)
        verticesArray.append(D)
        verticesArray.append(R)   //Top
        
        verticesArray.append(B)
        verticesArray.append(S)
        verticesArray.append(T)
        
        verticesArray.append(B)
        verticesArray.append(T)
        verticesArray.append(C)    //Bot
        */
    }
    
    func appendCube(xStart: Float, yStart: Float, zStart: Float, width: Float, height: Float, depth: Float) {
        /*let A = Vertex(x: xStart, y: yStart + height, z: zStart + depth, r:  1.0, g:  1.0, b:  0.0, a:  1.0)
        let B = Vertex(x: xStart, y: yStart, z: zStart + depth, r:  0.0, g:  1.0, b:  1.0, a:  1.0)
        let C = Vertex(x: xStart + width, y: yStart, z: zStart + depth, r:  1.0, g:  1.0, b:  0.0, a:  1.0)
        let D = Vertex(x: xStart + width, y: yStart + height, z: zStart + depth, r:  0.1, g:  0.6, b:  0.4, a:  1.0)
        
        let Q = Vertex(x: xStart, y: yStart + height, z: zStart, r:  1.0, g:  0.0, b:  0.0, a:  1.0)
        let R = Vertex(x: xStart + width, y: yStart + height, z: zStart, r:  0.0, g:  1.0, b:  0.0, a:  1.0)
        let S = Vertex(x: xStart, y: yStart, z: zStart, r:  0.0, g:  0.0, b:  1.0, a:  1.0)
        let T = Vertex(x: xStart + width, y: yStart, z: zStart, r:  0.1, g:  0.6, b:  0.4, a:  1.0)
        
        verticesArray.append(A)
        verticesArray.append(B)
        verticesArray.append(C)
        
        verticesArray.append(A)
        verticesArray.append(C)
        verticesArray.append(D)   //Front
        
        
        verticesArray.append(R)
        verticesArray.append(T)
        verticesArray.append(S)
        
        verticesArray.append(Q)
        verticesArray.append(R)
        verticesArray.append(S)   //Back
            
        verticesArray.append(Q)
        verticesArray.append(S)
        verticesArray.append(B)
        
        verticesArray.append(Q)
        verticesArray.append(B)
        verticesArray.append(A)   //Left
        
        verticesArray.append(D)
        verticesArray.append(C)
        verticesArray.append(T)
        
        verticesArray.append(D)
        verticesArray.append(T)
        verticesArray.append(R)   //Right
            
        verticesArray.append(Q)
        verticesArray.append(A)
        verticesArray.append(D)
        
        verticesArray.append(Q)
        verticesArray.append(D)
        verticesArray.append(R)   //Top
        
        verticesArray.append(B)
        verticesArray.append(S)
        verticesArray.append(T)
        
        verticesArray.append(B)
        verticesArray.append(T)
        verticesArray.append(C)    //Bot
        */
    }
    
    init(device: MTLDevice){
        
        
        
        super.init(name: "Cube", device: device)
        
        //appendBorderCube(xStart: -3.0, yStart: -1.2, zStart: 2.5, width: 6.0, height: 0.2, depth: 0.5)
        
        appendCube(xStart: -1.0, yStart: 0.5, zStart: -1.0, width: 2.0, height: 1.0, depth: 2.0)
        appendCube(xStart: -3.0, yStart: -1.0, zStart: -3.0, width: 6.0, height: 0.5, depth: 6.0)//base
        
        
        //appendBorderCube(xStart: -3.0, yStart: -0.5, zStart: 2.5, width: 6.0, height: 0.2, depth: 0.5)
        
        
        super.finalize(vertices: verticesArray)
    }
}
