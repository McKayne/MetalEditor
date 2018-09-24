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

@objc class DataViewController: UIViewController, UITableViewDelegate, UIActionSheetDelegate {
    
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
    
    
    
    
    var context: Context = .initial
    
    let actionsTableView = UITableView(frame: CGRect(x: 0, y: 100, width: 320, height: 300))
    var actionsDataSource: ActionsTableViewDataSource?
    
    let propertiesTableView = UITableView(frame: CGRect(x: 0, y: 100, width: 320, height: 300))
    var propertiesDataSource: PropertiesTableViewDataSource?
    
    let item = UINavigationItem(title: "Perspective")
    let actionsButton = UIBarButtonItem(title: "Actions", style: .done, target: self, action: #selector(showActionsList(sender:)))
    
    let button = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(takeScreenshot(sender:)))
    let applyButton = UIBarButtonItem(title: "Apply", style: .done, target: self, action: #selector(applyAction(sender:)))
    
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
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        
        var activityItems:[Any] = []
        
        switch buttonIndex {
        case 0:
            contr.takeScreenshot()
        case 1:
            let objFile = Export.exportOBJ(scene: RootViewController.scenes[0])
            let mtlFile = Export.exportMTL(scene: RootViewController.scenes[0])
            
            let docPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filePath: String = docPath + "/" + (RootViewController.scenes[0].name + ".zip")
            
            SSZipArchive.createZipFile(atPath: filePath, withFilesAtPaths: [objFile, mtlFile])
            activityItems = [URL(fileURLWithPath: filePath)]
        case 2:
            activityItems = [URL(fileURLWithPath: Export.exportSTL(scene: RootViewController.scenes[0]))]
        case 3:
            activityItems = [URL(fileURLWithPath: Export.exportPLY(scene: RootViewController.scenes[0]))]
        default:
            activityItems = [URL(fileURLWithPath: Export.exportSTL(scene: RootViewController.scenes[0]))]
        }
        
        if activityItems.count > 0 {
            let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities:nil)
            activityViewController.excludedActivityTypes = []
            activityViewController.popoverPresentationController?.sourceView = view
            activityViewController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.size.width / 2, y: view.bounds.size.height / 4, width: 0, height: 0)
            present(activityViewController, animated: true, completion:nil)
        }
    }
    
    func showExportDialog() {
        let actionSheet = UIActionSheet(title: "Export as", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Take screenshot", "Wavefront (.obj)", "Stl (.stl)", "Stanford (.ply)")
    
        actionSheet.delegate = self
        actionSheet.show(in: self.view)
    }

    func takeScreenshot(sender: UIButton!) {
        showExportDialog()
    }
    
    func showActionsList(sender: UIButton!) {
        print("List of actions")
        
        if actionsTableView.isHidden {
            actionsTableView.isHidden = false
            actionsButton.title = "Cancel"
        } else {
            if context != .initial {
                propertiesTableView.isHidden = true
                context = .initial
                actionsTableView.reloadData()
                
                
            } else {
                actionsTableView.isHidden = true
                actionsButton.title = "Actions"
            }
            
            
        }
        
        
        //contr.takeScreenshot()
    }
    
    func applyAction(sender: UIButton!) {
        print("Applying")
        
        if context == .scaling {
            let xScale = Float((propertiesDataSource?.xText.text!)!)!
            let yScale = Float((propertiesDataSource?.yText.text!)!)!
            let zScale = Float((propertiesDataSource?.zText.text!)!)!
        
            for object in RootViewController.scenes[0].objects {
                object.scaleBy(widthMultiplier: 2, heightMultiplier: 2, depthMultiplier: 2)
            }
            
            RootViewController.scenes[0].prepareForRender()
            contr.loadModel(Int32(RootViewController.scenes[0].indicesCount))
            //contr.scaleObject(0, length: contr.getTotalIndices(), xScale: xScale, yScale: yScale, zScale: zScale)
            //contr.redraw()
        }
        
        item.rightBarButtonItem = button
        
        context = .initial
        actionsTableView.reloadData()
        
        actionsTableView.isHidden = true
        propertiesTableView.isHidden = true
        
        actionsButton.title = "Actions"
    }
    
    /*func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30.0
    }*/
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        switch indexPath.row {
        case 0:
            switch context {
            case .addition:
                print("Cube")
                
                propertiesTableView.isHidden = false
            default:
                print("dummy")
            }
        case 6:
            if context == .initial {
                context = .scaling
                
                propertiesTableView.reloadData()
                propertiesTableView.isHidden = false
                
                item.rightBarButtonItem = applyButton
            } else {
                context = .initial
            }
        case 3:
            print("Add object")
            context = .addition
            
            propertiesTableView.reloadData()
            
            item.rightBarButtonItem = applyButton
        case 10:
            print("Exporting")
            contr.takeScreenshot()
        default:
            print("dummy")
        }
        
        
        
        tableView.reloadData()
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
        
        //UINavigationBar
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action:nil)
        shareButton.tintColor = .red
        
        self.navigationItem.rightBarButtonItem = shareButton
        
        //    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
        //    target:self
        //    action:@selector(shareAction:)];
        
        if nth != 0 {
            timer = CADisplayLink(target: self, selector: #selector(self.gameloop))
            timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        }
        if nth == 0 {
            
            actionsTableView.tableFooterView = UIView(frame: .zero)
            actionsTableView.isHidden = true
            
            actionsDataSource = ActionsTableViewDataSource(controller: self)
            
            actionsTableView.delegate = self
            actionsTableView.dataSource = actionsDataSource
            self.view.addSubview(actionsTableView)
            
            actionsTableView.translatesAutoresizingMaskIntoConstraints = false;
            actionsTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0).isActive = true
            actionsTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0).isActive = true
            actionsTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
            actionsTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 65.0).isActive = true
            
            propertiesTableView.tableFooterView = UIView(frame: .zero)
            propertiesTableView.isHidden = true
            
            propertiesDataSource = PropertiesTableViewDataSource(controller: self)
            
            propertiesTableView.delegate = self
            propertiesTableView.dataSource = propertiesDataSource
            self.view.addSubview(propertiesTableView)
            
            propertiesTableView.translatesAutoresizingMaskIntoConstraints = false;
            propertiesTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0).isActive = true
            propertiesTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0).isActive = true
            propertiesTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
            propertiesTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 65.0).isActive = true
            
            let bar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 320, height: 65))
            bar.isTranslucent = true
            
            
            
            item.rightBarButtonItem = button
            item.hidesBackButton = true
            bar.pushItem(item, animated: false)
            
            
            item.leftBarButtonItem = actionsButton
            
            self.view.addSubview(bar)
            
            self.view.addSubview(addButton)
            self.view.addSubview(createButton)
            //self.view.addSubview(cancelButton)
            //self.view.addSubview(exportButton)
            
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //DataViewController.mainView = self.view
        
        contr.setVertexArrays(RootViewController.scenes[0].bigVertices, bigLineVertices: RootViewController.scenes[0].bigLineVertices, bigIndices: RootViewController.scenes[0].bigIndices, bigLineIndices: RootViewController.scenes[0].bigLineIndices)
        contr.customMetalLayer(self.view.layer, bounds: self.view.bounds, indicesCount: Int32(RootViewController.scenes[0].indicesCount))
        contr.setView(self)
        
        
        //var objcTest = customVertex(position: customFloat4(x: 1, y: 2, z: 3, w: 4), normal: customFloat4(x: 1, y: 2, z: 3, w: 4), customColor: customFloat4(x: 1, y: 2, z: 3, w: 4))
        
        //contr.testBridge(objcTest)
        
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

