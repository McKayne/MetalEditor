import Foundation
import Metal

class Line: Node2D {
    
    var verticesArray: [LineVertex] = []
    
    func appendLine(xStart: Float, yStart: Float, xEnd: Float, yEnd: Float, rgb: (r: Float, g: Float, b: Float)) {
        let vStart = LineVertex(x: xStart, y: yStart, z:   0.0, r: rgb.r, g: rgb.g, b: rgb.b, a:  1.0)
        let vEnd = LineVertex(x: xEnd, y: yEnd, z:   0.0, r: rgb.r, g: rgb.g, b: rgb.b, a:  1.0)
        
        verticesArray.append(vStart)
        verticesArray.append(vEnd)
    }
    
    func toLocalCoords(x: Float, y: Float) -> (x: Float, y: Float) {
        return (x / 960 - 1, (y / 640 - 1) * -1)
    }
    
    func appendOuterBorder() {
        // x = 53 54
        var currentStart: (x: Float, y: Float), currentEnd: (x: Float, y: Float)
        
        // vertical left
        
        currentStart = toLocalCoords(x: 53, y: 54)
        currentEnd = toLocalCoords(x: 53, y: 1280 - 53)
        appendLine(xStart: currentStart.x, yStart: currentEnd.y, xEnd: currentStart.x, yEnd: currentStart.y, rgb: (22.0 / 255.0, 121.0 / 255.0, 225.0 / 255.0))
        
        currentStart = toLocalCoords(x: 54, y: 53) // 54?
        currentEnd = toLocalCoords(x: 54, y: 1280 - 54)
        appendLine(xStart: currentStart.x, yStart: currentEnd.y, xEnd: currentStart.x, yEnd: currentStart.y, rgb: (189.0 / 255.0, 217.0 / 255.0, 247.0 / 255.0))
        
        // horizontal top
        
        currentStart = toLocalCoords(x: 54, y: 53)
        currentEnd = toLocalCoords(x: 1920 - 54, y: 0)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentStart.y, rgb: (22.0 / 255.0, 121.0 / 255.0, 225.0 / 255.0))
        
        currentStart = toLocalCoords(x: 53, y: 54)
        currentEnd = toLocalCoords(x: 1920 - 53, y: 0)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentStart.y, rgb: (189.0 / 255.0, 217.0 / 255.0, 247.0 / 255.0))
        
        // horizontal bottom
        
        currentStart = toLocalCoords(x: 54, y: 1280 - 53)
        currentEnd = toLocalCoords(x: 1920 - 54, y: 0)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentStart.y, rgb: (22.0 / 255.0, 121.0 / 255.0, 225.0 / 255.0))
        
        currentStart = toLocalCoords(x: 53, y: 1280 - 54)
        currentEnd = toLocalCoords(x: 1920 - 53, y: 0)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentStart.y, rgb: (189.0 / 255.0, 217.0 / 255.0, 247.0 / 255.0))
        
        // vertical right
        
        currentStart = toLocalCoords(x: 1920 - 53, y: 54)
        currentEnd = toLocalCoords(x: 53, y: 1280 - 53)
        appendLine(xStart: currentStart.x, yStart: currentEnd.y, xEnd: currentStart.x, yEnd: currentStart.y, rgb: (22.0 / 255.0, 121.0 / 255.0, 225.0 / 255.0))
        
        currentStart = toLocalCoords(x: 1920 - 53, y: 53) // 54?
        currentEnd = toLocalCoords(x: 54, y: 1280 - 54)
        appendLine(xStart: currentStart.x, yStart: currentEnd.y, xEnd: currentStart.x, yEnd: currentStart.y, rgb: (189.0 / 255.0, 217.0 / 255.0, 247.0 / 255.0))
        
    }
    
    func appendInnerBorder() {
        var currentStart: (x: Float, y: Float), currentEnd: (x: Float, y: Float)
        
        // vertical left
        
        currentStart = toLocalCoords(x: 79, y: 92)
        currentEnd = toLocalCoords(x: 79, y: 1280 - 92)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0.0 / 255.0, 101.0 / 255.0, 220.0 / 255.0))
        currentStart = toLocalCoords(x: 80, y: 92)
        currentEnd = toLocalCoords(x: 80, y: 1280 - 92)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (114.0 / 255.0, 174.0 / 255.0, 237.0 / 255.0))
        currentStart = toLocalCoords(x: 81, y: 92)
        currentEnd = toLocalCoords(x: 81, y: 1280 - 92)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (159.0 / 255.0, 200.0 / 255.0, 243.0 / 255.0))
        currentStart = toLocalCoords(x: 82, y: 92)
        currentEnd = toLocalCoords(x: 82, y: 1280 - 92)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0.0 / 255.0, 101.0 / 255.0, 220.0 / 255.0))
        
        // vertical right
        
        currentStart = toLocalCoords(x: 1920 - 79, y: 92)
        currentEnd = toLocalCoords(x: 1920 - 79, y: 1280 - 92)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0.0 / 255.0, 101.0 / 255.0, 220.0 / 255.0))
        currentStart = toLocalCoords(x: 1920 - 80, y: 92)
        currentEnd = toLocalCoords(x: 1920 - 80, y: 1280 - 92)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (114.0 / 255.0, 174.0 / 255.0, 237.0 / 255.0))
        currentStart = toLocalCoords(x: 1920 - 81, y: 92)
        currentEnd = toLocalCoords(x: 1920 - 81, y: 1280 - 92)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (159.0 / 255.0, 200.0 / 255.0, 243.0 / 255.0))
        currentStart = toLocalCoords(x: 1920 - 82, y: 92)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1280 - 92)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0.0 / 255.0, 101.0 / 255.0, 220.0 / 255.0))
        
        // horizontal upper
        
        currentStart = toLocalCoords(x: 92, y: 79)
        currentEnd = toLocalCoords(x: 1920 - 92, y: 79)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0.0 / 255.0, 101.0 / 255.0, 220.0 / 255.0))
        currentStart = toLocalCoords(x: 92, y: 80)
        currentEnd = toLocalCoords(x: 1920 - 92, y: 80)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (114.0 / 255.0, 174.0 / 255.0, 237.0 / 255.0))
        currentStart = toLocalCoords(x: 92, y: 81)
        currentEnd = toLocalCoords(x: 1920 - 92, y: 81)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (159.0 / 255.0, 200.0 / 255.0, 243.0 / 255.0))
        currentStart = toLocalCoords(x: 92, y: 82)
        currentEnd = toLocalCoords(x: 1920 - 92, y: 82)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0.0 / 255.0, 101.0 / 255.0, 220.0 / 255.0))
        
        currentStart = toLocalCoords(x: 92, y: 1280 - 79)
        currentEnd = toLocalCoords(x: 1920 - 92, y: 1280 - 79)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0.0 / 255.0, 101.0 / 255.0, 220.0 / 255.0))
        currentStart = toLocalCoords(x: 92, y: 1280 - 80)
        currentEnd = toLocalCoords(x: 1920 - 92, y: 1280 - 80)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (114.0 / 255.0, 174.0 / 255.0, 237.0 / 255.0))
        currentStart = toLocalCoords(x: 92, y: 1280 - 81)
        currentEnd = toLocalCoords(x: 1920 - 92, y: 1280 - 81)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (159.0 / 255.0, 200.0 / 255.0, 243.0 / 255.0))
        currentStart = toLocalCoords(x: 92, y: 1280 - 82)
        currentEnd = toLocalCoords(x: 1920 - 92, y: 1280 - 82)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0.0 / 255.0, 101.0 / 255.0, 220.0 / 255.0))
    }
    
    func appendDivisors() {
        var currentStart: (x: Float, y: Float), currentEnd: (x: Float, y: Float)
        
        // vertical 1 of 3
        
        currentStart = toLocalCoords(x: 507, y: 54)
        currentEnd = toLocalCoords(x: 507, y: 80)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (189.0 / 255.0, 217.0 / 255.0, 247.0 / 255.0))
        currentStart = toLocalCoords(x: 508, y: 55)
        currentEnd = toLocalCoords(x: 508, y: 79)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (77.0 / 255.0, 153.0 / 255.0, 232.0 / 255.0))
        
        // vertical 2 of 3
        
        currentStart = toLocalCoords(x: 959, y: 54)
        currentEnd = toLocalCoords(x: 959, y: 79)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        currentStart = toLocalCoords(x: 960, y: 54)
        currentEnd = toLocalCoords(x: 960, y: 80)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (114 / 255.0, 174 / 255.0, 237 / 255.0))
        currentStart = toLocalCoords(x: 961, y: 54)
        currentEnd = toLocalCoords(x: 961, y: 80)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (159 / 255.0, 200 / 255.0, 243 / 255.0))
        currentStart = toLocalCoords(x: 962, y: 54)
        currentEnd = toLocalCoords(x: 962, y: 79)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        
        // vertical 3 of 3
        
        currentStart = toLocalCoords(x: 1412, y: 54)
        currentEnd = toLocalCoords(x: 1412, y: 79)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        currentStart = toLocalCoords(x: 1413, y: 54)
        currentEnd = toLocalCoords(x: 1413, y: 79)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (36 / 255.0, 129 / 255.0, 227 / 255.0))
        currentStart = toLocalCoords(x: 1414, y: 54)
        currentEnd = toLocalCoords(x: 1414, y: 80)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (209 / 255.0, 229 / 255.0, 249 / 255.0))
        currentStart = toLocalCoords(x: 1415, y: 54)
        currentEnd = toLocalCoords(x: 1415, y: 79)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (12 / 255.0, 116 / 255.0, 224 / 255.0))
        
        // horizontal 1 of 3
        
        currentStart = toLocalCoords(x: 507, y: 1280 - 54)
        currentEnd = toLocalCoords(x: 507, y: 1280 - 80)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (189.0 / 255.0, 217.0 / 255.0, 247.0 / 255.0))
        currentStart = toLocalCoords(x: 508, y: 1280 - 55)
        currentEnd = toLocalCoords(x: 508, y: 1280 - 79)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (77.0 / 255.0, 153.0 / 255.0, 232.0 / 255.0))
        
        // horizontal 2 of 3
        
        currentStart = toLocalCoords(x: 959, y: 1280 - 55)
        currentEnd = toLocalCoords(x: 959, y: 1280 - 79)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        currentStart = toLocalCoords(x: 960, y: 1280 - 54)
        currentEnd = toLocalCoords(x: 960, y: 1280 - 80)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (114 / 255.0, 174 / 255.0, 237 / 255.0))
        currentStart = toLocalCoords(x: 961, y: 1280 - 54)
        currentEnd = toLocalCoords(x: 961, y: 1280 - 80)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (159 / 255.0, 200 / 255.0, 243 / 255.0))
        currentStart = toLocalCoords(x: 962, y: 1280 - 55)
        currentEnd = toLocalCoords(x: 962, y: 1280 - 79)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        
        // horizontal 3 of 3
        
        currentStart = toLocalCoords(x: 1412, y: 1280 - 55)
        currentEnd = toLocalCoords(x: 1412, y: 1280 - 79)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        currentStart = toLocalCoords(x: 1413, y: 1280 - 55)
        currentEnd = toLocalCoords(x: 1413, y: 1280 - 79)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (36 / 255.0, 129 / 255.0, 227 / 255.0))
        currentStart = toLocalCoords(x: 1414, y: 1280 - 54)
        currentEnd = toLocalCoords(x: 1414, y: 1280 - 80)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (209 / 255.0, 229 / 255.0, 249 / 255.0))
        currentStart = toLocalCoords(x: 1415, y: 1280 - 55)
        currentEnd = toLocalCoords(x: 1415, y: 1280 - 79)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (12 / 255.0, 116 / 255.0, 224 / 255.0))
        
        // left 1 of 3
        
        currentStart = toLocalCoords(x: 54, y: 346)
        currentEnd = toLocalCoords(x: 79, y: 346)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        currentStart = toLocalCoords(x: 54, y: 347)
        currentEnd = toLocalCoords(x: 79, y: 347)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (189 / 255.0, 217 / 255.0, 247 / 255.0))
        currentStart = toLocalCoords(x: 54, y: 348)
        currentEnd = toLocalCoords(x: 79, y: 348)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (77 / 255.0, 153 / 255.0, 232 / 255.0))
        currentStart = toLocalCoords(x: 54, y: 349)
        currentEnd = toLocalCoords(x: 79, y: 349)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        
        // left 2 of 3
        
        currentStart = toLocalCoords(x: 54, y: 639)
        currentEnd = toLocalCoords(x: 79, y: 639)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        currentStart = toLocalCoords(x: 54, y: 640)
        currentEnd = toLocalCoords(x: 79, y: 640)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (114 / 255.0, 174 / 255.0, 237 / 255.0))
        currentStart = toLocalCoords(x: 54, y: 641)
        currentEnd = toLocalCoords(x: 79, y: 641)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (159 / 255.0, 200 / 255.0, 243 / 255.0))
        currentStart = toLocalCoords(x: 54, y: 642)
        currentEnd = toLocalCoords(x: 79, y: 642)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        
        // left 3 of 3
        
        currentStart = toLocalCoords(x: 54, y: 932)
        currentEnd = toLocalCoords(x: 79, y: 932)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        currentStart = toLocalCoords(x: 54, y: 933)
        currentEnd = toLocalCoords(x: 79, y: 933)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (35 / 255.0, 129 / 255.0, 227 / 255.0))
        currentStart = toLocalCoords(x: 54, y: 934)
        currentEnd = toLocalCoords(x: 79, y: 934)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (209 / 255.0, 229 / 255.0, 249 / 255.0))
        currentStart = toLocalCoords(x: 54, y: 935)
        currentEnd = toLocalCoords(x: 79, y: 935)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (12 / 255.0, 116 / 255.0, 224 / 255.0))
        
        // right 1 of 3
        
        currentStart = toLocalCoords(x: 1920 - 54, y: 346)
        currentEnd = toLocalCoords(x: 1920 - 80, y: 346)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        currentStart = toLocalCoords(x: 1920 - 54, y: 347)
        currentEnd = toLocalCoords(x: 1920 - 80, y: 347)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (189 / 255.0, 217 / 255.0, 247 / 255.0))
        currentStart = toLocalCoords(x: 1920 - 54, y: 348)
        currentEnd = toLocalCoords(x: 1920 - 80, y: 348)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (77 / 255.0, 153 / 255.0, 232 / 255.0))
        currentStart = toLocalCoords(x: 1920 - 54, y: 349)
        currentEnd = toLocalCoords(x: 1920 - 80, y: 349)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        
        // right 2 of 3
        
        currentStart = toLocalCoords(x: 1920 - 54, y: 639)
        currentEnd = toLocalCoords(x: 1920 - 80, y: 639)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        currentStart = toLocalCoords(x: 1920 - 54, y: 640)
        currentEnd = toLocalCoords(x: 1920 - 80, y: 640)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (114 / 255.0, 174 / 255.0, 237 / 255.0))
        currentStart = toLocalCoords(x: 1920 - 54, y: 641)
        currentEnd = toLocalCoords(x: 1920 - 80, y: 641)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (159 / 255.0, 200 / 255.0, 243 / 255.0))
        currentStart = toLocalCoords(x: 1920 - 54, y: 642)
        currentEnd = toLocalCoords(x: 1920 - 80, y: 642)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        
        // right 3 of 3
        
        currentStart = toLocalCoords(x: 1920 - 54, y: 932)
        currentEnd = toLocalCoords(x: 1920 - 80, y: 932)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        currentStart = toLocalCoords(x: 1920 - 54, y: 933)
        currentEnd = toLocalCoords(x: 1920 - 80, y: 933)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (35 / 255.0, 129 / 255.0, 227 / 255.0))
        currentStart = toLocalCoords(x: 1920 - 54, y: 934)
        currentEnd = toLocalCoords(x: 1920 - 80, y: 934)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (209 / 255.0, 229 / 255.0, 249 / 255.0))
        currentStart = toLocalCoords(x: 1920 - 54, y: 935)
        currentEnd = toLocalCoords(x: 1920 - 80, y: 935)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (12 / 255.0, 116 / 255.0, 224 / 255.0))
    }
    
    func appendCopyright() {
        var currentStart: (x: Float, y: Float), currentEnd: (x: Float, y: Float)
        
        // copyright outer vertical
        
        currentStart = toLocalCoords(x: 1488, y: 999)
        currentEnd = toLocalCoords(x: 1488, y: 1280 - 82)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        currentStart = toLocalCoords(x: 1489, y: 999)
        currentEnd = toLocalCoords(x: 1489, y: 1280 - 82)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (32 / 255.0, 126 / 255.0, 226 / 255.0))
        currentStart = toLocalCoords(x: 1490, y: 999)
        currentEnd = toLocalCoords(x: 1490, y: 1280 - 80)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (209 / 255.0, 229 / 255.0, 249 / 255.0))
        currentStart = toLocalCoords(x: 1491, y: 999)
        currentEnd = toLocalCoords(x: 1491, y: 1280 - 82)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (12 / 255.0, 116 / 255.0, 224 / 255.0))
        
        // copyright outer horizontal
        
        currentStart = toLocalCoords(x: 1502, y: 985)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 985)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        currentStart = toLocalCoords(x: 1502, y: 986)
        currentEnd = toLocalCoords(x: 1920 - 81, y: 986)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (143 / 255.0, 191 / 255.0, 241 / 255.0))
        currentStart = toLocalCoords(x: 1502, y: 987)
        currentEnd = toLocalCoords(x: 1920 - 81, y: 987)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (130 / 255.0, 183 / 255.0, 239 / 255.0))
        currentStart = toLocalCoords(x: 1502, y: 988)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 988)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        
        // copyright inner long vertical
        
        currentStart = toLocalCoords(x: 1640, y: 987)
        currentEnd = toLocalCoords(x: 1640, y: 1280 - 82)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (8 / 255.0, 113 / 255.0, 223 / 255.0))
        currentStart = toLocalCoords(x: 1641, y: 985)
        currentEnd = toLocalCoords(x: 1641, y: 1280 - 82)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (203 / 255.0, 225 / 255.0, 248 / 255.0))
        currentStart = toLocalCoords(x: 1642, y: 987)
        currentEnd = toLocalCoords(x: 1642, y: 1280 - 82)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (42 / 255.0, 133 / 255.0, 228 / 255.0))
        currentStart = toLocalCoords(x: 1643, y: 987)
        currentEnd = toLocalCoords(x: 1643, y: 1280 - 82)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        
        // copyright inner long horizontal 1 of 2
        
        currentStart = toLocalCoords(x: 1490, y: 1008)
        currentEnd = toLocalCoords(x: 1640, y: 1008)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        currentStart = toLocalCoords(x: 1490, y: 1009)
        currentEnd = toLocalCoords(x: 1640, y: 1009)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (121 / 255.0, 178 / 255.0, 238 / 255.0))
        currentStart = toLocalCoords(x: 1490, y: 1010)
        currentEnd = toLocalCoords(x: 1640, y: 1010)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (155 / 255.0, 198 / 255.0, 242 / 255.0))
        currentStart = toLocalCoords(x: 1490, y: 1011)
        currentEnd = toLocalCoords(x: 1640, y: 1011)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        
        currentStart = toLocalCoords(x: 1641, y: 1008)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1008)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        currentStart = toLocalCoords(x: 1641, y: 1009)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1009)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (121 / 255.0, 178 / 255.0, 238 / 255.0))
        currentStart = toLocalCoords(x: 1641, y: 1010)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1010)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (155 / 255.0, 198 / 255.0, 242 / 255.0))
        currentStart = toLocalCoords(x: 1641, y: 1011)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1011)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        
        // copyright inner long horizontal 2 of 2
        
        currentStart = toLocalCoords(x: 1490, y: 1170)
        currentEnd = toLocalCoords(x: 1640, y: 1170)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 108 / 255.0, 222 / 255.0))
        currentStart = toLocalCoords(x: 1490, y: 1171)
        currentEnd = toLocalCoords(x: 1640, y: 1171)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (196 / 255.0, 221 / 255.0, 248 / 255.0))
        currentStart = toLocalCoords(x: 1490, y: 1172)
        currentEnd = toLocalCoords(x: 1640, y: 1172)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (61 / 255.0, 144 / 255.0, 230 / 255.0))
        currentStart = toLocalCoords(x: 1490, y: 1173)
        currentEnd = toLocalCoords(x: 1640, y: 1173)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        
        currentStart = toLocalCoords(x: 1641, y: 1170)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1170)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 108 / 255.0, 222 / 255.0))
        currentStart = toLocalCoords(x: 1641, y: 1171)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1171)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (196 / 255.0, 221 / 255.0, 248 / 255.0))
        currentStart = toLocalCoords(x: 1641, y: 1172)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1172)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (61 / 255.0, 144 / 255.0, 230 / 255.0))
        currentStart = toLocalCoords(x: 1641, y: 1173)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1173)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        
        // copyright inter short horizontal left 1 of 2
        
        currentStart = toLocalCoords(x: 1490, y: 1032)
        currentEnd = toLocalCoords(x: 1640, y: 1032)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        currentStart = toLocalCoords(x: 1490, y: 1033)
        currentEnd = toLocalCoords(x: 1640, y: 1033)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (83 / 255.0, 156 / 255.0, 233 / 255.0))
        currentStart = toLocalCoords(x: 1490, y: 1034)
        currentEnd = toLocalCoords(x: 1640, y: 1034)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (183 / 255.0, 214 / 255.0, 246 / 255.0))
        currentStart = toLocalCoords(x: 1490, y: 1035)
        currentEnd = toLocalCoords(x: 1640, y: 1035)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        
        // copyright inter short horizontal left 2 of 2
        
        currentStart = toLocalCoords(x: 1490, y: 1056)
        currentEnd = toLocalCoords(x: 1640, y: 1056)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        currentStart = toLocalCoords(x: 1490, y: 1057)
        currentEnd = toLocalCoords(x: 1640, y: 1057)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (46 / 255.0, 135 / 255.0, 228 / 255.0))
        currentStart = toLocalCoords(x: 1490, y: 1058)
        currentEnd = toLocalCoords(x: 1640, y: 1058)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (203 / 255.0, 225 / 255.0, 248 / 255.0))
        currentStart = toLocalCoords(x: 1490, y: 1059)
        currentEnd = toLocalCoords(x: 1640, y: 1059)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        
        // copyright inter short horizontal right 1 of 2
        
        currentStart = toLocalCoords(x: 1641, y: 1065)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1065)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        currentStart = toLocalCoords(x: 1641, y: 1066)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1066)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (196 / 255.0, 221 / 255.0, 248 / 255.0))
        currentStart = toLocalCoords(x: 1641, y: 1067)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1067)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (66 / 255.0, 147 / 255.0, 231 / 255.0))
        currentStart = toLocalCoords(x: 1641, y: 1068)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1068)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        
        // copyright inter short horizontal right 2 of 2
        
        currentStart = toLocalCoords(x: 1641, y: 1140)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1140)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        currentStart = toLocalCoords(x: 1641, y: 1141)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1141)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (196 / 255.0, 221 / 255.0, 248 / 255.0))
        currentStart = toLocalCoords(x: 1641, y: 1142)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1142)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (66 / 255.0, 147 / 255.0, 231 / 255.0))
        currentStart = toLocalCoords(x: 1641, y: 1143)
        currentEnd = toLocalCoords(x: 1920 - 82, y: 1143)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 101 / 255.0, 220 / 255.0))
        
        // copyright inner short vertical left 1 of 2
        
        currentStart = toLocalCoords(x: 1589, y: 1010)
        currentEnd = toLocalCoords(x: 1589, y: 1032)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (8 / 255.0, 113 / 255.0, 223 / 255.0))
        currentStart = toLocalCoords(x: 1590, y: 1010)
        currentEnd = toLocalCoords(x: 1590, y: 1033)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (203 / 255.0, 225 / 255.0, 248 / 255.0))
        currentStart = toLocalCoords(x: 1591, y: 1010)
        currentEnd = toLocalCoords(x: 1591, y: 1032)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (42 / 255.0, 133 / 255.0, 228 / 255.0))
        currentStart = toLocalCoords(x: 1592, y: 1010)
        currentEnd = toLocalCoords(x: 1592, y: 1032)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        
        
        
        currentStart = toLocalCoords(x: 1589, y: 1034)
        currentEnd = toLocalCoords(x: 1589, y: 1057)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (8 / 255.0, 113 / 255.0, 223 / 255.0))
        currentStart = toLocalCoords(x: 1590, y: 1034)
        currentEnd = toLocalCoords(x: 1590, y: 1057)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (203 / 255.0, 225 / 255.0, 248 / 255.0))
        currentStart = toLocalCoords(x: 1591, y: 1034)
        currentEnd = toLocalCoords(x: 1591, y: 1057)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (42 / 255.0, 133 / 255.0, 228 / 255.0))
        currentStart = toLocalCoords(x: 1592, y: 1034)
        currentEnd = toLocalCoords(x: 1592, y: 1057)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        
        // copyright inner short vertical left 2 of 2
        
        currentStart = toLocalCoords(x: 1612, y: 1172)
        currentEnd = toLocalCoords(x: 1612, y: 1198)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        currentStart = toLocalCoords(x: 1613, y: 1171)
        currentEnd = toLocalCoords(x: 1613, y: 1198)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (32 / 255.0, 126 / 255.0, 226 / 255.0))
        currentStart = toLocalCoords(x: 1614, y: 1171)
        currentEnd = toLocalCoords(x: 1614, y: 1198)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (209 / 255.0, 229 / 255.0, 249 / 255.0))
        currentStart = toLocalCoords(x: 1615, y: 1172)
        currentEnd = toLocalCoords(x: 1615, y: 1198)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (12 / 255.0, 116 / 255.0, 224 / 255.0))
        
        // copyright inner short vertical right 1 of 2
        
        currentStart = toLocalCoords(x: 1801, y: 1141)
        currentEnd = toLocalCoords(x: 1801, y: 1170)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        currentStart = toLocalCoords(x: 1802, y: 1141)
        currentEnd = toLocalCoords(x: 1802, y: 1170)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (66 / 255.0, 147 / 255.0, 231 / 255.0))
        currentStart = toLocalCoords(x: 1803, y: 1141)
        currentEnd = toLocalCoords(x: 1803, y: 1170)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (196 / 255.0, 221 / 255.0, 248 / 255.0))
        currentStart = toLocalCoords(x: 1804, y: 1141)
        currentEnd = toLocalCoords(x: 1804, y: 1170)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        
        // copyright inner short vertical right 2 of 2
        
        currentStart = toLocalCoords(x: 1748, y: 1171)
        currentEnd = toLocalCoords(x: 1748, y: 1198)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (196 / 255.0, 221 / 255.0, 248 / 255.0))
        currentStart = toLocalCoords(x: 1749, y: 1172)
        currentEnd = toLocalCoords(x: 1749, y: 1198)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (61 / 255.0, 144 / 255.0, 230 / 255.0))
        currentStart = toLocalCoords(x: 1750, y: 1172)
        currentEnd = toLocalCoords(x: 1750, y: 1198)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        
    }
    
    func makeArc(center: (x: Int, y: Int), radius: Double, angleType: Int) {
        
        //let center = (x: Float(93.0), y: Float(93.0))
        //let radius = 12.5
        
        //print(center)
        
        //var testPoint = toLocalCoords(x: Float(Double(center.x) + cos(Double(0) * 3.14 / 180) * Double(radius)), y: Float(Double(center.y) + sin(Double(0) * 3.14 / 180) * Double(radius)))
        //print(testPoint)
        
        var lastPoint: (x: Float, y: Float), lastPointA: (x: Float, y: Float)
        switch angleType {
        case 0:
            lastPoint = toLocalCoords(x: Float(Double(center.x) + cos(Double(0) * 3.14 / 180) * Double(radius)), y: Float(Double(center.y) - sin(Double(0) * 3.14 / 180) * Double(radius)))
            lastPointA = toLocalCoords(x: Float(Double(center.x) + cos(Double(0) * 3.14 / 180) * Double(radius + 0.5)), y: Float(Double(center.y) - sin(Double(0) * 3.14 / 180) * Double(radius + 0.5)))
        case 1:
            lastPoint = toLocalCoords(x: Float(Double(center.x) + cos(Double(0) * 3.14 / 180) * Double(radius)), y: Float(Double(center.y) + sin(Double(0) * 3.14 / 180) * Double(radius)))
            lastPointA = toLocalCoords(x: Float(Double(center.x) + cos(Double(0) * 3.14 / 180) * Double(radius + 0.5)), y: Float(Double(center.y) + sin(Double(0) * 3.14 / 180) * Double(radius + 0.5)))
        case 2:
            lastPoint = toLocalCoords(x: Float(Double(center.x) - cos(Double(0) * 3.14 / 180) * Double(radius)), y: Float(Double(center.y) + sin(Double(0) * 3.14 / 180) * Double(radius)))
            lastPointA = toLocalCoords(x: Float(Double(center.x) - cos(Double(0) * 3.14 / 180) * Double(radius + 0.5)), y: Float(Double(center.y) + sin(Double(0) * 3.14 / 180) * Double(radius + 0.5)))
        case 3:
            lastPoint = toLocalCoords(x: Float(Double(center.x) - cos(Double(0) * 3.14 / 180) * Double(radius)), y: Float(Double(center.y) - sin(Double(0) * 3.14 / 180) * Double(radius)))
            lastPointA = toLocalCoords(x: Float(Double(center.x) - cos(Double(0) * 3.14 / 180) * Double(radius + 0.5)), y: Float(Double(center.y) - sin(Double(0) * 3.14 / 180) * Double(radius + 0.5)))
        default:
            lastPoint = toLocalCoords(x: Float(Double(center.x) - cos(Double(0) * 3.14 / 180) * Double(radius)), y: Float(Double(center.y) - sin(Double(0) * 3.14 / 180) * Double(radius)))
            lastPointA = toLocalCoords(x: Float(Double(center.x) - cos(Double(0) * 3.14 / 180) * Double(radius + 0.5)), y: Float(Double(center.y) - sin(Double(0) * 3.14 / 180) * Double(radius + 0.5)))
        }
        
        
        
        for angle in 1...90 {
            
            
            //var
            
            //var
            
            var nextPoint: (x: Float, y: Float), nextPointA: (x: Float, y: Float)
            
            switch angleType {
            case 0:
                nextPoint = toLocalCoords(x: Float(Double(center.x) + cos(Double(angle) * 3.14 / 180) * Double(radius)), y: Float(Double(center.y) - sin(Double(angle) * 3.14 / 180) * Double(radius))) // 12 - 3 hours
                nextPointA = toLocalCoords(x: Float(Double(center.x) + cos(Double(angle) * 3.14 / 180) * Double(radius + 0.5)), y: Float(Double(center.y) - sin(Double(angle) * 3.14 / 180) * Double(radius - 0.5))) // 12 - 3 hours
            case 1:
                nextPoint = toLocalCoords(x: Float(Double(center.x) + cos(Double(angle) * 3.14 / 180) * Double(radius)), y: Float(Double(center.y) + sin(Double(angle) * 3.14 / 180) * Double(radius))) // 3 - 6 hours
                nextPointA = toLocalCoords(x: Float(Double(center.x) + cos(Double(angle) * 3.14 / 180) * Double(radius + 0.5)), y: Float(Double(center.y) + sin(Double(angle) * 3.14 / 180) * Double(radius + 0.5))) // 3 - 6 hours
            case 2:
                nextPoint = toLocalCoords(x: Float(Double(center.x) - cos(Double(angle) * 3.14 / 180) * Double(radius)), y: Float(Double(center.y) + sin(Double(angle) * 3.14 / 180) * Double(radius))) // 6 - 9 hours
                nextPointA = toLocalCoords(x: Float(Double(center.x) - cos(Double(angle) * 3.14 / 180) * Double(radius + 0.5)), y: Float(Double(center.y) + sin(Double(angle) * 3.14 / 180) * Double(radius + 0.5))) // 6 - 9 hours
            case 3:
                nextPoint = toLocalCoords(x: Float(Double(center.x) - cos(Double(angle) * 3.14 / 180) * Double(radius)), y: Float(Double(center.y) - sin(Double(angle) * 3.14 / 180) * Double(radius))) // 9 - 12 hours
                nextPointA = toLocalCoords(x: Float(Double(center.x) - cos(Double(angle) * 3.14 / 180) * Double(radius + 0.5)), y: Float(Double(center.y) - sin(Double(angle) * 3.14 / 180) * Double(radius + 0.5))) // 9 - 12 hours
            default:
                nextPoint = toLocalCoords(x: Float(Double(center.x) - cos(Double(angle) * 3.14 / 180) * Double(radius)), y: Float(Double(center.y) - sin(Double(angle) * 3.14 / 180) * Double(radius))) // 9 - 12 hours
                nextPointA = toLocalCoords(x: Float(Double(center.x) - cos(Double(angle) * 3.14 / 180) * Double(radius + 0.5)), y: Float(Double(center.y) - sin(Double(angle) * 3.14 / 180) * Double(radius + 0.5))) // 9 - 12 hours
            }
            
            
            //print(nextPoint)
            
            appendLine(xStart: lastPoint.x, yStart: lastPoint.y, xEnd: nextPoint.x, yEnd: nextPoint.y, rgb: (159.0 / 255.0, 200.0 / 255.0, 243.0 / 255.0))
            appendLine(xStart: lastPointA.x, yStart: lastPointA.y, xEnd: nextPointA.x, yEnd: nextPointA.y, rgb: (114.0 / 255.0, 174.0 / 255.0, 237.0 / 255.0))
            
            lastPoint = nextPoint
            lastPointA = nextPointA
        }
        
        var currentStart: (x: Float, y: Float), currentEnd: (x: Float, y: Float)
        
        // copyright outer vertical
        
        currentStart = toLocalCoords(x: 100, y: 999)
        currentEnd = toLocalCoords(x: 1488, y: 1280 - 82)
        appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))

    }
    
    init(device: MTLDevice, bigVertices: UnsafeMutablePointer<Vertex>) {
        
        
        
        
        super.init(name: "Triangle", device: device)
        
        //appendLine(xStart: -1.0, yStart: -1.0, xEnd: 0.0, yEnd: 1.0)
        //appendLine(xStart: -0.1, yStart: 1.0, xEnd: 0.9, yEnd: -1.0)
        //appendLine(xStart: 0.0, yStart: 1.0, xEnd: 1.0, yEnd: -1.0)
        
        /*for i in 0...5 {
            appendLine(xStart: -1.0 + Float(i) * 0.4, yStart: -1.0, xEnd: -1.0 + Float(i) * 0.4, yEnd: 1.0, rgb: (189.0 / 255.0, 217.0 / 255.0, 247.0 / 255.0))
        }*/
        
        /*for i in 0...5 {
            appendLine(xStart: -1.0, yStart: -1.0 + Float(i) * 0.4, xEnd: 1.0, yEnd: -1.0 + Float(i) * 0.4, rgb: (189.0 / 255.0, 217.0 / 255.0, 247.0 / 255.0))
        }*/
        
        appendOuterBorder()
        
        appendInnerBorder()
        
        appendDivisors()
        
        appendCopyright()
        
        makeArc(center: (93, 93), radius: 12.5, angleType: 3)
        makeArc(center: (1920 - 94, 92), radius: 12.5, angleType: 0)
        makeArc(center: (1920 - 94, 1280 - 93), radius: 12.5, angleType: 1)
        makeArc(center: (93, 1280 - 93), radius: 12.5, angleType: 2)
        
        //currentStart = toLocalCoords(x: 1488, y: 999)
        makeArc(center: (1502, 999), radius: 12.5, angleType: 3)
        
        for i in 0..<12 {
            /*self.bigLineIndices[i * 6 + 0 + self.totalIndices * 2] = i * 3 + self.totalIndices;
            self.bigLineIndices[i * 6 + 1 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
            
            self.bigLineIndices[i * 6 + 2 + self.totalIndices * 2] = i * 3 + 1 + self.totalIndices;
            self.bigLineIndices[i * 6 + 3 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
            
            self.bigLineIndices[i * 6 + 4 + self.totalIndices * 2] = i * 3 + 2 + self.totalIndices;
            self.bigLineIndices[i * 6 + 5 + self.totalIndices * 2] = i * 3 + self.totalIndices;*/
            
            //var current: customFloat4 = bigVertices[i * 3].position
            appendLine(xStart: bigVertices[i * 3].position.x, yStart: bigVertices[i * 3].position.y, xEnd: bigVertices[i * 3 + 1].position.x, yEnd: bigVertices[i * 3 + 1].position.y, rgb: (255 / 255.0, 255 / 255.0, 255 / 255.0))
            appendLine(xStart: bigVertices[i * 3 + 1].position.x, yStart: bigVertices[i * 3 + 1].position.y, xEnd: bigVertices[i * 3 + 2].position.x, yEnd: bigVertices[i * 3 + 2].position.y, rgb: (255 / 255.0, 255 / 255.0, 255 / 255.0))
            appendLine(xStart: bigVertices[i * 3 + 2].position.x, yStart: bigVertices[i * 3 + 2].position.y, xEnd: bigVertices[i * 3].position.x, yEnd: bigVertices[i * 3].position.y, rgb: (255 / 255.0, 255 / 255.0, 255 / 255.0))
        }
        
        //appendLine(xStart: currentStart.x, yStart: currentStart.y, xEnd: currentEnd.x, yEnd: currentEnd.y, rgb: (0 / 255.0, 105 / 255.0, 221 / 255.0))
        
        super.finalize(vertices: verticesArray)
    }
    
}
