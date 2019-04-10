//
//  HeightMap.swift
//  MidJuly_Paged
//
//  Created by для интернета on 31.10.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

//On the top of your swift
extension UIImage {
    func getPixelColor(pos: CGPoint) -> UIColor {
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4
        
        let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

class HeightMap: SceneObject {
    
    private var x: Float, y: Float, z: Float
    private var width: Float, depth: Float
    private var rgb: (r: Int, g: Int, b: Int)
    
    func makeFace(position: inout [customFloat4], xStart: Float, yStart: Float, xEnd: Float, yEnd: Float) {
        position.append(customFloat4(x: xEnd, y: y, z: yStart, w: 1.0))
        position.append(customFloat4(x: xEnd, y: y, z: yEnd, w: 1.0))
        position.append(customFloat4(x: xStart, y: y, z: yEnd, w: 1.0))
        
        position.append(customFloat4(x: xStart, y: y, z: yStart, w: 1.0))
        position.append(customFloat4(x: xEnd, y: y, z: yStart, w: 1.0))
        position.append(customFloat4(x: xStart, y: y, z: yEnd, w: 1.0))
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    private func appendHeightMap() {
        
        var heightMapTexture = UIImage(named: "apple.jpg")
        //var heightMapTexture = UIImage(named: "sample screen.png")
        
        var resized = resizeImage(image: heightMapTexture!, targetSize: CGSize(width: 101.0, height: 101.0))
        
        var position: [customFloat4] = []
        
        let xDensity = 100, yDensity = 100
        
        var offsets: [[Float]] = []
        
        let xResizeOffset: Float = 626 / 101.0
        let yResizeOffset: Float = 626 / 101.0
        
        for i in 0...yDensity {
            var off: [Float] = []
            for j in 0...xDensity {
                
                let color: UIColor = heightMapTexture!.getPixelColor(pos: CGPoint(x: Int(Float(j) * xResizeOffset), y: Int(Float(i) * yResizeOffset)))
                let rgb = color.cgColor.components
                let gray: Float = (Float((rgb?[0])!) + Float((rgb?[1])!) + Float((rgb?[2])!)) / 3.0
                print("hm = \(gray)")
                
                //off.append(((Float(arc4random()) / Float(UINT32_MAX)) - 0.5) * 0.1)
                off.append(gray)
            }
            offsets.append(off)
        }
        
        // top face
        
        var widthDiff: Float = width / Float(xDensity)
        var depthDiff: Float = depth / Float(yDensity)
        
        for j in 0..<yDensity {
            for i in 0..<xDensity {
                position.append(customFloat4(x: x + Float(i + 1) * widthDiff, y: y + offsets[j][i + 1], z: z - Float(j) * depthDiff, w: 1.0))
                position.append(customFloat4(x: x + Float(i + 1) * widthDiff, y: y + offsets[j + 1][i + 1], z: z - Float(j + 1) * depthDiff, w: 1.0))
                position.append(customFloat4(x: x + Float(i) * widthDiff, y: y + offsets[j + 1][i], z: z - Float(j + 1) * depthDiff, w: 1.0))
                
                position.append(customFloat4(x: x + Float(i) * widthDiff, y: y + offsets[j][i], z: z - Float(j) * depthDiff, w: 1.0))
                position.append(customFloat4(x: x + Float(i + 1) * widthDiff, y: y + offsets[j][i + 1], z: z - Float(j) * depthDiff, w: 1.0))
                position.append(customFloat4(x: x + Float(i) * widthDiff, y: y + offsets[j + 1][i], z: z - Float(j + 1) * depthDiff, w: 1.0))
                
                //makeFace(position: &position, xStart: x + Float(i) * widthDiff, yStart: z, xEnd: x + Float(i + 1) * widthDiff, yEnd: z - depth)
            }
        }
        //    makeFace(position: &position, xStart: x + width / 2, yStart: z, xEnd: x + width, yEnd: z - depth)
        
        for i in 0..<position.count {
            //indices.append(i)
            
            var vertex: Vertex = Vertex()
            vertex.position = position[i]
            vertex.customColor = customFloat4(x: Float(rgb.r) / 255.0, y: Float(rgb.g) / 255.0, z: Float(rgb.b) / 255.0, w: 1.0)
            
            var lineVertex: Vertex = Vertex()
            lineVertex.position = position[i]
            lineVertex.customColor = customFloat4(x: 0.0, y: 0.0, z: 0.0, w: 1.0)
            
            vertices.append(vertex)
            lineVertices.append(lineVertex)
        }
    }
    
    init(x: Float, y: Float, z: Float, width: Float, depth: Float, rgb: (r: Int, g: Int, b: Int)) {
        self.x = x; self.y = y; self.z = z
        self.width = width; self.depth = depth
        self.rgb = rgb
        
        super.init()
        appendHeightMap()
    }
}
