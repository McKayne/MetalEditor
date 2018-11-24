//
//  Tridiag.swift
//  MidJuly_Paged
//
//  Created by для интернета on 14.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class Tridiag {
    
    private var a: [[Float]], b: [Float], n: Int
    
    private func tridiagP(a: [[Float]], i: Int) -> Float {
        if i == 0 {
            return -a[0][1] / a[0][0]
        } else {
            return -a[i][i + 1] / (a[i][i] + a[i][i - 1] * tridiagP(a: a, i: i - 1))
        }
    }
    
    private func tridiagQ(a: [[Float]], b: [Float], i: Int) -> Float {
        if i == 0 {
            return b[0] / a[0][0]
        } else {
            return (b[i] - a[i][i - 1] * tridiagQ(a: a, b: b, i: i - 1)) / (a[i][i] + a[i][i - 1] * tridiagP(a: a, i: i - 1))
        }
    }
    
    func findSolution() -> [Float] {
        var x: [Float] = []
        x.append(tridiagQ(a: a, b: b, i: n - 1))
        for i in (0...(n - 2)).reversed() {
            x.append(tridiagP(a: a, i: i) * x[n - i - 2] + tridiagQ(a: a, b: b, i: i))
        }
        return x.reversed()
    }
    
    init(a: [[Float]], b: [Float]) {
        self.a = a
        self.b = b
        n = a.count
    }
}
