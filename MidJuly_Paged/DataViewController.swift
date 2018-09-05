//
//  DataViewController.swift
//  MidJuly_Paged
//
//  Created by для интернета on 12.07.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import UIKit
import simd

struct Uniforms {
    var modelViewProjectionMatrix: float4x4
    var modelViewMatrix: float4x4
    var normalMatrix: float3x3
}

@objc class DataViewController: UIViewController {
    
    //@property (nonatomic, assign) Vertex *bigVertices, *bigLineVertices;
    var bigVertices = UnsafeMutablePointer<Vertex>.allocate(capacity: 100000)
    var bigLineVertices = UnsafeMutablePointer<Vertex>.allocate(capacity: 100000)
    
    static var mainView: UIView!
    
    var contr: ViewController = ViewController()
    
    var metalLayer: CAMetalLayer!
    var device: MTLDevice!
    var library: MTLLibrary?
    var vertexFunctionName: String = "", fragmentFunctionName: String = ""
    var lastFrameTime: CFAbsoluteTime?
    var vertexBuffer: MTLBuffer?
    var indexBuffer: MTLBuffer?
    var uniformBuffer: MTLBuffer!
    var displayLink: CADisplayLink!
    var angle: CGPoint!
    
    
    

    @IBOutlet weak var dataLabel: UILabel!
    var dataObject: String = ""
    let textFieldX = UITextField(frame: CGRect(x: 50, y: 100, width: 200, height: 50)), textFieldY = UITextField(frame: CGRect(x: 50, y: 150, width: 200, height: 50)), textFieldZ = UITextField(frame: CGRect(x: 50, y: 200, width: 200, height: 50))
    
    let addButton = UIButton(frame: CGRect(x: 150, y: 50, width: 200, height: 50))
    let createButton = UIButton(frame: CGRect(x: 150, y: 50, width: 200, height: 50))
    let cancelButton = UIButton(frame: CGRect(x: 30, y: 50, width: 200, height: 50))
    let exportButton = UIButton(frame: CGRect(x: 150, y: 50, width: 200, height: 50))
    
    var nthPage: Int = 0
    
    var pageData: [String] = []
    var controllerA: DataViewController? = nil
    
    
    
    
    
    
    //var objectToDraw: Cube!, objectToDrawB: Line!
    var lineToDraw: Line!
    
    var pipelineState: MTLRenderPipelineState!
    
    var commandQueue: MTLCommandQueue!
    
    var timer: CADisplayLink!
    
    var projectionMatrix: Matrix4!
    
    
    /*let vertexData:[Float] = [
        0.0, 1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0]
    var vertexBuffer: MTLBuffer!*/
    
    
    /*func render() {
        var drawable = metalLayer?.nextDrawable()!
        let worldModelMatrix = Matrix4()
        worldModelMatrix.translate(x: 0.0, y: 0.0, z: -7.0)
        worldModelMatrix.rotateAround(x: 0.0, y: 0.0, z: 0.0)
        //if nthPage == 0 {
        worldModelMatrix.rotateAround(x: Float(25.0 * 3.14 / 180.0), y: 0.0, z: 0.0)
        //} else {
        //        worldModelMatrix.rotateAround(x: 0.0, y: 0.0, z: 0.0)
        //}
    
        //if nthPage == 0 {
        objectToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable!, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix ,clearColor: nil)
        //} else {
        //    lineToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable!, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix ,clearColor: nil)
        //}
            
        /*drawable = metalLayer?.nextDrawable()!
         objectToDrawB.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable!, clearColor: nil)*/
    }*/
    
    func lineRender() {
        guard let drawable = metalLayer?.nextDrawable() else { return }
        lineToDraw.render(commandQueue: commandQueue, pipelineState: pipelineState, drawable: drawable, clearColor: nil)
    }
    
    func gameloop() {
        autoreleasepool {
            //self.lineRender()
            //if nthPage == 0 {
              //  self.render()
            //} else {
                self.lineRender()
            //}
        }
    }
    
    func IdentityCustom() -> float4x4 {
        let X = float4(x: 1, y: 0, z: 0, w: 0)
        let Y = float4(x: 0, y: 1, z: 0, w: 0)
        let Z = float4(x: 0, y: 0, z: 1, w: -1)
        let W = float4(x: 0, y: 0, z: 0, w: 1)
        
        
        
        let mat = float4x4(rows: [X, Y, Z, W])
        return mat
    }
    
    func Identity() -> float4x4 {
        let X = float4(x: 1, y: 0, z: 0, w: 0)
        let Y = float4(x: 0, y: 1, z: 0, w: 0)
        let Z = float4(x: 0, y: 0, z: 1, w: 0)
        let W = float4(x: 0, y: 0, z: 0, w: 1)
        
        
        
        let mat = float4x4(rows: [X, Y, Z, W])
        return mat
    }
    
    /*func Rotation(axis: float3, angle: Float) -> float4x4 {
        let c: Float = cos(angle)
        let s: Float = sin(angle)
    
        var X: float4
        X.x = axis.x * axis.x + (1 - axis.x * axis.x) * c;
        X.y = axis.x * axis.y * (1 - c) - axis.z*s;
        X.z = axis.x * axis.z * (1 - c) + axis.y * s;
        X.w = 0.0;
    
        var Y: float4
        Y.x = axis.x * axis.y * (1 - c) + axis.z * s;
        Y.y = axis.y * axis.y + (1 - axis.y * axis.y) * c;
        Y.z = axis.y * axis.z * (1 - c) - axis.x * s;
        Y.w = 0.0;
    
        var Z: float4
        Z.x = axis.x * axis.z * (1 - c) - axis.y * s;
        Z.y = axis.y * axis.z * (1 - c) + axis.x * s;
        Z.z = axis.z * axis.z + (1 - axis.z * axis.z) * c;
        Z.w = 0.0;
    
        var W: float4
        W.x = 0.0;
        W.y = 0.0;
        W.z = 0.0;
        W.w = 1.0;
    
        let mat = float4x4(rows: [X, Y, Z, W])
        return mat;
    }*/
    
    func PerspectiveProjection(aspect: Float, fovy: Float, near: Float, far: Float) -> float4x4 {
        let yScale: Float = 1 / tan(fovy * 0.5);
        let xScale: Float = yScale / aspect;
        let zRange: Float = far - near;
        let zScale: Float = -(far + near) / zRange;
        let wzScale: Float = -far * near / zRange;
    
        let P = float4(x: xScale, y: 0, z: 0, w: 0)
        let Q = float4(x: 0, y: yScale, z: 0, w: 0)
        let R = float4(x: 0, y: 0, z: zScale, w: -1)
        let S = float4(x: 0, y: 0, z: wzScale, w: 0)
    
        let mat = float4x4(rows: [P, Q, R, S])
        return mat;
    }
    
    /*func updateUniforms() {
        let X_AXIS = float3(x: 1, y: 0, z: 0)
        let Y_AXIS = float3(x: 0, y: 1, z: 0)
        var modelMatrix: float4x4 = Identity()
    
    
        //modelMatrix = Rotation(Y_AXIS, -self.angle.x) * modelMatrix;
    
        //self.angle.x = 10 * 3.14 / 180;
        angle = CGPoint(x: -315 * 3.14 / 180, y: 0)
        //NSLog(@"ANGLE %f %f", self.angle.x, self.angle.y);
        modelMatrix = Rotation(axis: Y_AXIS, angle: -(Float)(self.angle.x)) * modelMatrix
        modelMatrix = Rotation(axis: X_AXIS, angle: -(Float)(self.angle.y)) * modelMatrix
    
        var viewMatrix: float4x4 = IdentityCustom()
        //viewMatrix.columns[3].z = -1 // translate camera back along Z axis
        
        let near: Float = 0.1
        let far: Float = 100
        let aspect: Float = 300 / 300
        //DegToRad 75
        var projectionMatrix: float4x4 = PerspectiveProjection(aspect: aspect, fovy: 75.0 * 3.14 / 180.0, near: near, far: far)
    
        var uniforms: Uniforms
    
        var modelView: float4x4 = viewMatrix * modelMatrix
        uniforms.modelViewMatrix = modelView;
    
        var modelViewProj: float4x4 = projectionMatrix * modelView
        uniforms.modelViewProjectionMatrix = modelViewProj;
    
        var normalMatrix = float3x3(rows: [modelView.columns[0].xyz, modelView.columns[1].xyz, modelView.columns[2].xyz])
        uniforms.normalMatrix = transpose(inverse(normalMatrix))
    
        uniformBuffer = device.makeBuffer(bytes: uniforms, length: MemoryLayout.size(ofValue: uniforms), options: [])
    }*/
    
    func redraw() {
        //updateMotion()
        //updateUniforms()
    
        //startFrame()
    
        //drawTrianglesWithInterleavedBuffer:self.vertexBuffer indexBuffer:self.indexBuffer uniformBuffer:self.uniformBuffer
    //indexCount:[self.indexBuffer length] / sizeof(IndexType)];
    
        //endFrame()
    }
    
    func displayLinkDidFire() {
        self.redraw()
    }
    
    func buttonAction(sender: UIButton!) {
        addButton.isHidden = true
        createButton.isHidden = false
        
        textFieldX.isHidden = false
        textFieldY.isHidden = false
        textFieldZ.isHidden = false
        
        //contr.appendAction()
        //contr.customMetalLayer(self.view.layer, bounds: self.view.bounds)
    }
    
    func createAction(sender: UIButton!) {
        addButton.isHidden = false
        createButton.isHidden = true
        
        textFieldX.isHidden = true
        textFieldY.isHidden = true
        textFieldZ.isHidden = true
        
        contr.appendAction(Float(textFieldX.text!)!, y: Float(textFieldY.text!)!, z: Float(textFieldZ.text!)!)
    }
    
    func cancelAction(sender: UIButton!) {
        print("Button tapped")
        
        contr.removeAction(0)
        //contr.customMetalLayer(self.view.layer, bounds: self.view.bounds)
    }
    
    func takeScreenshot(sender: UIButton!) {
        print("Taking screenshot")
        
        contr.takeScreenshot()
    }
    
    func appendUI(nth: Int) {
        textFieldX.borderStyle = .roundedRect
        textFieldY.borderStyle = .roundedRect
        textFieldZ.borderStyle = .roundedRect
        
        textFieldX.isHidden = true
        textFieldY.isHidden = true
        textFieldZ.isHidden = true
        
        textFieldX.text = "0.0"
        textFieldY.text = "0.0"
        textFieldZ.text = "0.0"
        
        addButton.setTitleColor(.blue, for: .normal)
        addButton.setTitle("Add", for: .normal)
        addButton.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        addButton.isHidden = true
        
        createButton.setTitleColor(.blue, for: .normal)
        createButton.setTitle("Create", for: .normal)
        createButton.addTarget(self, action: #selector(createAction), for: .touchUpInside)
        createButton.isHidden = true
        
        cancelButton.setTitleColor(.blue, for: .normal)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        exportButton.setTitleColor(.blue, for: .normal)
        exportButton.setTitle("Export", for: .normal)
        exportButton.addTarget(self, action: #selector(takeScreenshot(sender:)), for: .touchUpInside)
        
        if nth != 0 {
            timer = CADisplayLink(target: self, selector: #selector(self.gameloop))
            timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        }
        if nth == 0 {
            self.view.addSubview(addButton)
            self.view.addSubview(createButton)
            self.view.addSubview(cancelButton)
            self.view.addSubview(exportButton)
            
            self.view.addSubview(textFieldX)
            self.view.addSubview(textFieldY)
            self.view.addSubview(textFieldZ)
        }
        /*switch nth {
        case 0, 1:
            //timer = CADisplayLink(target: self, selector: #selector(self.gameloop))
            //timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
            
            displayLink = CADisplayLink(target: self, selector: #selector(self.displayLinkDidFire))
            displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        case 2:
            self.view.addSubview(textFieldA)
        case 3:
            self.view.addSubview(textFieldB)
        default:
            //timer = CADisplayLink(target: self, selector: #selector(self.gameloop))
            //timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
            
            displayLink = CADisplayLink(target: self, selector: #selector(self.displayLinkDidFire))
            displayLink.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        }*/
    }
    
    func loadModel() {
        var indices: [__uint16_t] = [] //[36];
        for i in 0..<36 {
            indices.append(__uint16_t(i))
        }
        
        var normal: [customFloat4] = []
        normal.append(customFloat4(x: 0.285806, y: 0.957545, z: 0.037708, w: 0.000000))
        normal.append(customFloat4(x: 0.379109, y: 0.925352, z: -0.000000, w: 0.000000))
        normal.append(customFloat4(x: 0.000000, y: 1.000000, z: 0.000000, w: 0.000000))
        normal.append(customFloat4(x: 0.194152, y: 0.980637, z: 0.025618, w: 0.000000))
        normal.append(customFloat4(x: 0.533366, y: 0.842427, z: 0.076408, w: 0.000000))
        normal.append(customFloat4(x: 0.578218, y: 0.815882, z: -0.000000, w: 0.000000))
        normal.append(customFloat4(x: 0.681751, y: 0.725877, z: 0.091197, w: 0.000000))
        normal.append(customFloat4(x: 0.706222, y: 0.707990, z: -0.000000, w: 0.000000))
        normal.append(customFloat4(x: 0.775360, y: 0.623030, z: 0.103201, w: 0.000000))
        normal.append(customFloat4(x: 0.795363, y: 0.606133, z: 0.000000, w: 0.000000))
        normal.append(customFloat4(x: 0.843645, y: 0.525092, z: 0.111991, w: 0.000000))
        normal.append(customFloat4(x: 0.860854, y: 0.508852, z: 0.000000, w: 0.000000))
        normal.append(customFloat4(x: 0.883783, y: 0.453058, z: 0.116900, w: 0.000000))
        normal.append(customFloat4(x: 0.895511, y: 0.445040, z: 0.000000, w: 0.000000))
        normal.append(customFloat4(x: 0.190036, y: 0.980666, z: 0.046704, w: 0.000000))
        normal.append(customFloat4(x: 0.323050, y: 0.942658, z: 0.083871, w: 0.000000))
        normal.append(customFloat4(x: 0.528220, y: 0.834889, z: 0.154737, w: 0.000000))
        normal.append(customFloat4(x: 0.663562, y: 0.726167, z: 0.179908, w: 0.000000))
        normal.append(customFloat4(x: 0.754776, y: 0.623418, z: 0.204117, w: 0.000000))
        normal.append(customFloat4(x: 0.821388, y: 0.525466, z: 0.221827, w: 0.000000))
        normal.append(customFloat4(x: 0.860580, y: 0.453416, z: 0.231983, w: 0.000000))
        normal.append(customFloat4(x: 0.182056, y: 0.980710, z: 0.071154, w: 0.000000))
        normal.append(customFloat4(x: 0.308975, y: 0.942767, z: 0.125400, w: 0.000000))
        normal.append(customFloat4(x: 0.503013, y: 0.835158, z: 0.222461, w: 0.000000))
        normal.append(customFloat4(x: 0.633884, y: 0.726537, z: 0.265209, w: 0.000000))
        normal.append(customFloat4(x: 0.721239, y: 0.623771, z: 0.301205, w: 0.000000))
        normal.append(customFloat4(x: 0.784988, y: 0.525861, z: 0.327513, w: 0.000000))
        normal.append(customFloat4(x: 0.822565, y: 0.453784, z: 0.342735, w: 0.000000))
        normal.append(customFloat4(x: 0.171057, y: 0.980744, z: 0.094243, w: 0.000000))
        normal.append(customFloat4(x: 0.304037, y: 0.935812, z: 0.178373, w: 0.000000))
        normal.append(customFloat4(x: 0.485684, y: 0.824244, z: 0.291090, w: 0.000000))
        normal.append(customFloat4(x: 0.593620, y: 0.726799, z: 0.345512, w: 0.000000))
        normal.append(customFloat4(x: 0.675513, y: 0.624142, z: 0.392592, w: 0.000000))
        normal.append(customFloat4(x: 0.735370, y: 0.526186, z: 0.427035, w: 0.000000))
        normal.append(customFloat4(x: 0.770661, y: 0.454121, z: 0.447052, w: 0.000000))
        normal.append(customFloat4(x: 0.157290, y: 0.980761, z: 0.115620, w: 0.000000))
        
        var position: [customFloat4] = []
        for _ in 0..<36 {
            position.append(customFloat4(x: 0, y: 0, z: 0, w: 0))
        }
        // front
        
        position[0] = customFloat4(x: -0.25, y: -0.25, z: 0.25, w: 1.0)
        position[1] = customFloat4(x: 0.25, y: -0.25, z: 0.25, w: 1.0)
        position[2] = customFloat4(x: 0.25, y: 0.25, z: 0.25, w: 1.0)
        
        position[3] = customFloat4(x: 0.25, y: 0.25, z: 0.25, w: 1.0)
        position[4] = customFloat4(x: -0.25, y: 0.25, z: 0.25, w: 1.0)
        position[5] = customFloat4(x: -0.25, y: -0.25, z: 0.25, w: 1.0)
        
        //right
        
        position[6] = customFloat4(x: 0.25, y: -0.25, z: 0.25, w: 1.0)
        position[7] = customFloat4(x: 0.25, y: -0.25, z: -0.25, w: 1.0)
        position[8] = customFloat4(x: 0.25, y: 0.25, z: 0.25, w: 1.0)
        
        position[9] = customFloat4(x: 0.25, y: -0.25, z: -0.25, w: 1.0)
        position[10] = customFloat4(x: 0.25, y: 0.25, z: -0.25, w: 1.0)
        position[11] = customFloat4(x: 0.25, y: 0.25, z: 0.25, w: 1.0)
        
        // back
        
        position[12] = customFloat4(x: 0.25, y: -0.25, z: -0.25, w: 1.0)
        position[13] = customFloat4(x: -0.25, y: -0.25, z: -0.25, w: 1.0)
        position[14] = customFloat4(x: 0.25, y: 0.25, z: -0.25, w: 1.0)
        
        position[15] = customFloat4(x: -0.25, y: 0.25, z: -0.25, w: 1.0)
        position[16] = customFloat4(x: 0.25, y: 0.25, z: -0.25, w: 1.0)
        position[17] = customFloat4(x: -0.25, y: -0.25, z: -0.25, w: 1.0)
        
        // left
        
        position[18] = customFloat4(x: -0.25, y: -0.25, z: -0.25, w: 1.0)
        position[19] = customFloat4(x: -0.25, y: -0.25, z: 0.25, w: 1.0)
        position[20] = customFloat4(x: -0.25, y: 0.25, z: -0.25, w: 1.0)
        
        position[21] = customFloat4(x: -0.25, y: 0.25, z: 0.25, w: 1.0)
        position[22] = customFloat4(x: -0.25, y: 0.25, z: -0.25, w: 1.0)
        position[23] = customFloat4(x: -0.25, y: -0.25, z: 0.25, w: 1.0)
        
        var vertices: [Vertex] = []
        for i in 0..<36 {
            vertices.append(Vertex(position: position[i], normal: normal[i], customColor: position[i], texCoord: position[i]))
        }
        
        

        vertexBuffer = device.makeBuffer(bytes: vertices, length: MemoryLayout.size(ofValue: vertices[0]) * 36, options: [])
        indexBuffer = device.makeBuffer(bytes: indices, length: MemoryLayout.size(ofValue: indices[0]) * 36, options: [])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        //DataViewController.mainView = self.view
        
        contr.setVertexArrays(bigVertices, bigLineVertices: bigLineVertices)
        contr.customMetalLayer(self.view.layer, bounds: self.view.bounds)
        contr.setView(self)
        
        
        var objcTest = customVertex(position: customFloat4(x: 1, y: 2, z: 3, w: 4), normal: customFloat4(x: 1, y: 2, z: 3, w: 4), customColor: customFloat4(x: 1, y: 2, z: 3, w: 4))
        
        contr.testBridge(objcTest)
        
        //self.renderer = Renderer(self.view.layer);
        //metalLayer = self.view.layer
        metalLayer = CAMetalLayer()
        
        device = MTLCreateSystemDefaultDevice()
        if device == nil {
            print("Unable to create default device!")
        }
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        
        //metalLayer.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        //currentStart = toLocalCoords(x: 1488, y: 999)
        metalLayer.frame = CGRect(x: -1920 / 2, y: -200, width: 1920, height: 1280)
        
        library = device.newDefaultLibrary()
        
        view.layer.addSublayer(metalLayer)
        
        
        lineToDraw = Line(device: device, bigVertices: bigLineVertices)
        
        // 1
        let defaultLibrary = device.newDefaultLibrary()!
        
        var fragmentProgram: MTLFunction?
        var vertexProgram: MTLFunction?
        
        fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment_2d")
            vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex_2d")
        
        
        // 2
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // 3
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()
        
        
        
        /*
        //_pipelineDirty = YES;
        
        vertexFunctionName = "vertex_main"
        fragmentFunctionName = "fragment_main"
        
        //self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
        //    action:@selector(gestureRecognizerDidRecognize:)];
        //[self.view addGestureRecognizer:self.panGestureRecognizer];
        
        
        lastFrameTime = CFAbsoluteTimeGetCurrent()
        
        loadModel()
        */
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //if nthPage == 0 {
        
        //} else {
            //projectionMatrix = Matrix4.makePerspectiveView(angle: 90.0 * 3.14 / 180.0, aspectRatio: Float(view.bounds.size.width / view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
        //}
        
        
        /*projectionMatrix = Matrix4.makePerspectiveView(angle: 85.0 * 3.14 / 180.0, aspectRatio: Float(metalLayer.frame.width / metalLayer.frame.height), nearZ: 0.01, farZ: 100.0)
        
        print(nthPage)
        
           // 6
        
        objectToDraw = Cube(device: device)
        lineToDraw = Line(device: device)
        
        
        
        
        
        let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0]) // 1
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: []) // 2
        
        
        
        
        objectToDrawB = Line(device: device)
        
        // 1
        let defaultLibrary = device.newDefaultLibrary()!
        
        var fragmentProgram: MTLFunction?
        var vertexProgram: MTLFunction?
        if nthPage == 0 {
            fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
            vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        } else {
            fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment_2d")
            vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex_2d")
        }
            
        // 2
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        // 3
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        commandQueue = device.makeCommandQueue()*/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.dataLabel!.text = dataObject
    }


}

