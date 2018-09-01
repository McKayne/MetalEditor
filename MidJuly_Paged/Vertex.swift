//
//  Vertex.swift
//  EarlyJuneNM_SV
//
//  Created by для интернета on 06.07.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation
import simd

struct LineVertex {
    
    var x,y,z: Float     // position data
    var r,g,b,a: Float   // color data
    
    func floatBuffer() -> [Float] {
        return [x,y,z,r,g,b,a]
    }
    
}

struct Vertex {
    var position, normal, customColor: float4
}
