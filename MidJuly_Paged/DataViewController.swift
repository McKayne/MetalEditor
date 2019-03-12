//
//  DataViewController.swift
//  MidJuly_Paged
//
//  Created by для интернета on 12.07.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import CoreMotion
import UIKit
import simd
import Darwin

struct Uniforms {
    var modelViewProjectionMatrix: float4x4
    var modelViewMatrix: float4x4
    var normalMatrix: float3x3
}

@objc class DataViewController: UIViewController, UITableViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate {
    
    //var touchViews = [UITouch:TouchSpotView]()
    
    var activityViewController: UIActivityViewController!
    
    let motionManager = CMMotionManager()
    
    var panGestureRecognizer: UIGestureRecognizer!
    var angularVelocity: CGPoint!

    var currentScene = 0
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
    
    
    
    
    var context: Context = .initial, additionContext: AdditionContext = .face
    
    let actionsTableView = UITableView(frame: CGRect(x: 0, y: 100, width: 320, height: 300))
    var actionsDataSource: ActionsTableViewDataSource?
    
    let additionTableView = UITableView(frame: CGRect(x: 0, y: 100, width: 320, height: 300))
    var additionDataSource: AdditionTableViewDataSource?
    
    let propertiesTableView = UITableView(frame: CGRect(x: 0, y: 100, width: 320, height: 300))
    var propertiesDataSource: PropertiesTableViewDataSource?
    
    let scenesListTableView = UITableView(frame: CGRect(x: 0, y: 100, width: 320, height: 300))
    var scenesDataSource: ScenesListTableViewDataSource?
    
    let item = UINavigationItem(title: RootViewController.scenes[0].name)
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
    
    // UITapGestureRecognizer конфликтует с выделением UITableView, поэтому тапы по UITableView необходимо исключать
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: actionsTableView))! {
            return false
        }
        if (touch.view?.isDescendant(of: additionTableView))! {
            return false
        }
        if (touch.view?.isDescendant(of: propertiesTableView))! {
            return false
        }
        if (touch.view?.isDescendant(of: scenesListTableView))! {
            return false
        }
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
    
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        print(buttonIndex)
        
        let url = Export.exportOBJ(scene: RootViewController.scenes[currentScene])
        
        activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .airDrop] //[]
        activityViewController.popoverPresentationController?.sourceView = view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.size.width / 2, y: view.bounds.size.height / 4, width: 0, height: 0)
        
        activityViewController.completionWithItemsHandler = {(type, completed, items, error) in
            print("COMPLETED")
            try! FileManager.default.removeItem(at: url)
        }
        
        DispatchQueue.main.async {
            self.present(self.activityViewController, animated: true, completion:nil)
        }
        
        /*var activityItems:[Any] = []
        
        switch buttonIndex {
        case 1:
            contr.takeScreenshot()
        case 2:
            let objFile = Export.exportOBJ(scene: RootViewController.scenes[currentScene])
            let mtlFile = Export.exportMTL(scene: RootViewController.scenes[currentScene])
            
            let docPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let filePath: String = docPath + "/" + (RootViewController.scenes[currentScene].name + ".zip")
            
            SSZipArchive.createZipFile(atPath: filePath, withFilesAtPaths: [objFile, mtlFile])
            activityItems = [URL(fileURLWithPath: filePath)]
        case 3:
            activityItems = [URL(fileURLWithPath: Export.exportSTL(scene: RootViewController.scenes[currentScene]))]
        case 4:
            activityItems = [URL(fileURLWithPath: Export.exportPLY(scene: RootViewController.scenes[currentScene]))]
        default:
            activityItems = [URL(fileURLWithPath: Export.exportSTL(scene: RootViewController.scenes[currentScene]))]
        }
        
        if activityItems.count > 0 {
            let url = URL(fileURLWithPath: NSTemporaryDirectory() + "file.txt")
            let data = "Testing".data(using: .utf8)
            try! data?.write(to: url)
            
            //let path = Export.exportSTL(scene: RootViewController.scenes[currentScene])
            //let str = URL
            
            let test = "UIActitityViewController test string: it works"
         
        }*/
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
        
        if !scenesListTableView.isHidden {
            actionsTableView.isHidden = false
            scenesListTableView.isHidden = true
        } else if !propertiesTableView.isHidden {
            propertiesTableView.isHidden = true
        } else if !additionTableView.isHidden {
            actionsTableView.isHidden = false
            additionTableView.isHidden = true
        } else if actionsTableView.isHidden {
            actionsTableView.isHidden = false
            actionsButton.title = "Cancel"
        } else {
            if context != .initial && context != .addition {
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
        view.endEditing(true)
        
        switch context {
        case .initial:
            print("Dummy")
        case .addition:
            
            // Position
            let x = Float((propertiesDataSource?.xText.text!)!)!
            let y = Float((propertiesDataSource?.yText.text!)!)!
            let z = Float((propertiesDataSource?.zText.text!)!)!
            
            // Dimensions
            let width = Float((propertiesDataSource?.widthText.text!)!)!
            let height = Float((propertiesDataSource?.heightText.text!)!)!
            let depth = Float((propertiesDataSource?.depthText.text!)!)!
            
            // Rotation
            let xAngle = Float((propertiesDataSource?.xAngleText.text!)!)!
            let yAngle = Float((propertiesDataSource?.yAngleText.text!)!)!
            let zAngle = Float((propertiesDataSource?.zAngleText.text!)!)!
            
            // Color
            let red = Int((propertiesDataSource?.redText.text!)!)!
            let green = Int((propertiesDataSource?.greenText.text!)!)!
            let blue = Int((propertiesDataSource?.blueText.text!)!)!
            
            switch additionContext {
            case .face:
                let face = Face(x: x, y: y, z: z, width: width, height: height, rgb: (red, green, blue))
                RootViewController.scenes[currentScene].appendObject(object: face)
            case .cube:
                let cube = Cube(x: x, y: y, z: z, width: width, height: height, depth: depth, rgb: (red, green, blue))
                cube.rotate(xAngle: xAngle, yAngle: yAngle, zAngle: zAngle)
                RootViewController.scenes[currentScene].appendObject(object: cube)
            case .cone:
                let cone = Cone(x: x, y: y, z: z, radius: 0.5, height: height, segments: 36, rgb: (red, green, blue))
                RootViewController.scenes[currentScene].appendObject(object: cone)
            case .pyramid:
                let pyramid = Pyramid(x: x, y: y, z: z, width: width, height: height, depth: depth, rgb: (red, green, blue))
                RootViewController.scenes[currentScene].appendObject(object: pyramid)
            case .cylinder:
                let cylinder = Cylinder(x: x, y: y, z: z, radius: 0.5, height: height, segments: 36, rgb: (red, green, blue))
                RootViewController.scenes[currentScene].appendObject(object: cylinder)
            case .stairs:
                let steps = Int(Stairs.numberOfSteps.text!) ?? 5
                
                //print(Stairs.xAngle.text ?? "0.0")
                //print(Stairs.yAngle.text ?? "0.0")
                //print(Stairs.zAngle.text ?? "0.0")
                
                
                let xAngle2 = Float(Stairs.xAngle.text!) ?? 0.0
                let yAngle2 = Float(Stairs.yAngle.text!) ?? 0.0
                let zAngle2 = Float(Stairs.zAngle.text!) ?? 0.0
                
                let stairs = Stairs(x: x, y: y, z: z, width: width, height: height, depth: depth, steps: steps, rgb: (red, green, blue))
                stairs.rotate(xAngle: xAngle2, yAngle: yAngle2, zAngle: zAngle2)
                RootViewController.scenes[currentScene].appendObject(object: stairs)
            case .surface:
                let steps = Int(Stairs.numberOfSteps.text!) ?? 5
                
                //print(Stairs.xAngle.text ?? "0.0")
                //print(Stairs.yAngle.text ?? "0.0")
                //print(Stairs.zAngle.text ?? "0.0")
                
                
                let xAngle2 = Float(Stairs.xAngle.text!) ?? 0.0
                let yAngle2 = Float(Stairs.yAngle.text!) ?? 0.0
                let zAngle2 = Float(Stairs.zAngle.text!) ?? 0.0
                
                let stairs = Stairs(x: x, y: y, z: z, width: width, height: height, depth: depth, steps: steps, rgb: (red, green, blue))
                stairs.rotate(xAngle: xAngle2, yAngle: yAngle2, zAngle: zAngle2)
                RootViewController.scenes[currentScene].appendObject(object: stairs)
            case .height:
                let steps = Int(Stairs.numberOfSteps.text!) ?? 5
                
                //print(Stairs.xAngle.text ?? "0.0")
                //print(Stairs.yAngle.text ?? "0.0")
                //print(Stairs.zAngle.text ?? "0.0")
                
                
                let xAngle2 = Float(Stairs.xAngle.text!) ?? 0.0
                let yAngle2 = Float(Stairs.yAngle.text!) ?? 0.0
                let zAngle2 = Float(Stairs.zAngle.text!) ?? 0.0
                
                let stairs = Stairs(x: x, y: y, z: z, width: width, height: height, depth: depth, steps: steps, rgb: (red, green, blue))
                stairs.rotate(xAngle: xAngle2, yAngle: yAngle2, zAngle: zAngle2)
                RootViewController.scenes[currentScene].appendObject(object: stairs)
            }
            
            RootViewController.scenes[currentScene].prepareForRender()
            contr.loadModel(Int32(RootViewController.scenes[currentScene].indicesCount))
        case .translation:
            let xTranslate = Float((propertiesDataSource?.xTranslationText.text!)!)!
            let yTranslate = Float((propertiesDataSource?.yTranslationText.text!)!)!
            let zTranslate = Float((propertiesDataSource?.zTranslationText.text!)!)!
            
            var isAnyObjectSelected = false
            for object in RootViewController.scenes[currentScene].objects {
                if object.isSelected {
                    isAnyObjectSelected = true
                    object.translateTo(xTranslate: xTranslate, yTranslate: yTranslate, zTranslate: zTranslate)
                }
            }
            
            if !isAnyObjectSelected {
                for object in RootViewController.scenes[currentScene].objects {
                    object.isSelected = true
                    object.translateTo(xTranslate: xTranslate, yTranslate: yTranslate, zTranslate: zTranslate)
                }
            }
            
            RootViewController.scenes[currentScene].updateDatabase()
            RootViewController.scenes[currentScene].prepareForRender()
            contr.loadModel(Int32(RootViewController.scenes[currentScene].indicesCount))
        case .rotation:
            let xAngle = Float((propertiesDataSource?.xAngleText.text!)!)!
            let yAngle = Float((propertiesDataSource?.yAngleText.text!)!)!
            let zAngle = Float((propertiesDataSource?.zAngleText.text!)!)!
            
            var isAnyObjectSelected = false
            for object in RootViewController.scenes[currentScene].objects {
                if object.isSelected {
                    isAnyObjectSelected = true
                    object.rotate(xAngle: xAngle, yAngle: yAngle, zAngle: zAngle)
                }
            }
            
            if !isAnyObjectSelected {
                for object in RootViewController.scenes[currentScene].objects {
                    object.isSelected = true
                    object.rotate(xAngle: xAngle, yAngle: yAngle, zAngle: zAngle)
                }
            }
            
            RootViewController.scenes[currentScene].updateDatabase()
            RootViewController.scenes[currentScene].prepareForRender()
            contr.loadModel(Int32(RootViewController.scenes[currentScene].indicesCount))
        case .scaling:
            let widthScale = Float((propertiesDataSource?.widthText.text!)!)!
            let heightScale = Float((propertiesDataSource?.heightText.text!)!)!
            let depthScale = Float((propertiesDataSource?.depthText.text!)!)!
            
            var isAnyObjectSelected = false
            for object in RootViewController.scenes[0].objects {
                if object.isSelected {
                    isAnyObjectSelected = true
                    object.scaleBy(widthMultiplier: widthScale, heightMultiplier: heightScale, depthMultiplier: depthScale)
                }
            }
            
            if !isAnyObjectSelected {
                for object in RootViewController.scenes[0].objects {
                    object.isSelected = true
                    object.scaleBy(widthMultiplier: widthScale, heightMultiplier: heightScale, depthMultiplier: depthScale)
                }
            }
            
            RootViewController.scenes[0].prepareForRender()
            contr.loadModel(Int32(RootViewController.scenes[0].indicesCount))
        }
        
        propertiesDataSource?.clearTranslationParams()
        propertiesDataSource?.clearRotationParams()
        propertiesDataSource?.clearColorParams()
        hideActions()
    }
    
    private func attachAction() {
        var objectsToAttach: [Int] = []
        for i in 0..<RootViewController.scenes[currentScene].objects.count {
            objectsToAttach.append(i)
        }
        RootViewController.scenes[currentScene].attachObjects(objectsToAttach: objectsToAttach)
        RootViewController.scenes[currentScene].prepareForRender()
        contr.loadModel(Int32(RootViewController.scenes[currentScene].indicesCount))
        
        hideActions()
    }
    
    func removeAction() {
        var isAnyObjectSelected = false
        // TODO fix multiple selection
        for i in 0..<RootViewController.scenes[currentScene].objects.count {
            if RootViewController.scenes[currentScene].objects[i].isSelected {
                isAnyObjectSelected = true
                RootViewController.scenes[currentScene].removeObject(nth: i)
                break
            }
        }
        
        if !isAnyObjectSelected {
            RootViewController.scenes[currentScene].removeAll(nth: 0)
            /*for i in 0..<RootViewController.scenes[0].objects.count {
                object.rotate(xAngle: xAngle, yAngle: yAngle, zAngle: zAngle)
            }*/
        }
        
        RootViewController.scenes[currentScene].prepareForRender()
        contr.loadModel(Int32(RootViewController.scenes[currentScene].indicesCount))
        
        hideActions()
    }
    
    func hideActions() {
        item.rightBarButtonItem = button
        
        context = .initial
        actionsTableView.reloadData()
        
        actionsTableView.isHidden = true
        propertiesTableView.isHidden = true
        
        additionTableView.isHidden = true
        
        actionsButton.title = "Actions"
    }
    
    func copyAction() {
        // create or open db
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("copyDB.sqlite")
        
        var db: OpaquePointer?
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        // create tables
        if sqlite3_exec(db, "CREATE TABLE if not exists copied(nth integer, x real, y real, z real, red real, green real, blue real, alpha real)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        // trunc
        if sqlite3_exec(db, "delete from copied", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        for i in 0..<RootViewController.scenes[currentScene].objects.count {
            
            if RootViewController.scenes[currentScene].objects[i].isSelected {
                for j in 0..<RootViewController.scenes[currentScene].objects[i].vertices.count {
                    
                    //creating a statement
                    var stmt: OpaquePointer?
                    
                    //the insert query
                    let queryString = "insert into copied(nth, x, y, z, red, green, blue, alpha) values(?, ?, ?, ?, ?, ?, ?, ?)"
                    
                    //preparing the query
                    if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("error preparing insert: \(errmsg)")
                        return
                    }
                    
                    //binding the parameters
                    if sqlite3_bind_int(stmt, 1, Int32(i)) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure binding name: \(errmsg)")
                        return
                    }
                    if sqlite3_bind_double(stmt, 2, Double(RootViewController.scenes[currentScene].objects[i].vertices[j].position.x)) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure binding name: \(errmsg)")
                        return
                    }
                    if sqlite3_bind_double(stmt, 3, Double(RootViewController.scenes[currentScene].objects[i].vertices[j].position.y)) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure binding name: \(errmsg)")
                        return
                    }
                    if sqlite3_bind_double(stmt, 4, Double(RootViewController.scenes[currentScene].objects[i].vertices[j].position.z)) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure binding name: \(errmsg)")
                        return
                    }
                    if sqlite3_bind_double(stmt, 5, Double(RootViewController.scenes[currentScene].objects[i].vertices[j].customColor.x)) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure binding name: \(errmsg)")
                        return
                    }
                    if sqlite3_bind_double(stmt, 6, Double(RootViewController.scenes[currentScene].objects[i].vertices[j].customColor.y)) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure binding name: \(errmsg)")
                        return
                    }
                    if sqlite3_bind_double(stmt, 7, Double(RootViewController.scenes[currentScene].objects[i].vertices[j].customColor.z)) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure binding name: \(errmsg)")
                        return
                    }
                    if sqlite3_bind_double(stmt, 8, Double(RootViewController.scenes[currentScene].objects[i].vertices[j].customColor.w)) != SQLITE_OK{
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure binding name: \(errmsg)")
                        return
                    }
                    
                    //executing the query to insert values
                    if sqlite3_step(stmt) != SQLITE_DONE {
                        let errmsg = String(cString: sqlite3_errmsg(db)!)
                        print("failure inserting hero: \(errmsg)")
                        return
                    }
                }
            }
        }
    }
    
    func pasteAction() {
        // create or open db
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("copyDB.sqlite")
        
        var db: OpaquePointer?
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        // update camera params
        //creating a statement
        var stmt: OpaquePointer?
        
        //this is our select query
        var queryString = "SELECT * FROM copied"
        
        //statement pointer
        //stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        var objects: [SceneObject] = []
        var nth: Int = -1
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let current = Int(sqlite3_column_int(stmt, 0))
            
            print(current)
            
            if current != nth {
                nth = current
                
                let obj = SceneObject()
                obj.isSelected = true
                objects.append(obj)
            }
            
            let x = Float(sqlite3_column_double(stmt, 1))
            let y = Float(sqlite3_column_double(stmt, 2))
            let z = Float(sqlite3_column_double(stmt, 3))
            
            let red = Float(sqlite3_column_double(stmt, 4))
            let green = Float(sqlite3_column_double(stmt, 5))
            let blue = Float(sqlite3_column_double(stmt, 6))
            let alpha = Float(sqlite3_column_double(stmt, 7))
            
            print(nth)
            
            print(x)
            print(y)
            print(z)
            
            print(red)
            print(green)
            print(blue)
            print(alpha)
            
            let position = customFloat4(x: x, y: y, z: z, w: 1.0)
            let color = customFloat4(x: red, y: green, z: blue, w: alpha)
            let normal = customFloat4(x: 0, y: 0, z: 0, w: 0)
            let lineColor = customFloat4(x: 0, y: 0, z: 0, w: 1.0)
            
            let vertex = Vertex(position: position, normal: normal, customColor: color, texCoord: normal)
            let lineVertex = Vertex(position: position, normal: normal, customColor: lineColor, texCoord: normal)
            
            objects.last!.vertices.append(vertex)
            objects.last!.lineVertices.append(lineVertex)
        }
        
        for object in RootViewController.scenes[currentScene].objects {
            object.isSelected = false
        }
        for object in objects {
            RootViewController.scenes[currentScene].appendObjectWithoutUpdate(object: object)
        }
        RootViewController.scenes[currentScene].updateDatabase()
        
        RootViewController.scenes[currentScene].prepareForRender()
        contr.loadModel(Int32(RootViewController.scenes[currentScene].indicesCount))
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        switch indexPath.row {
        case 0:
            print("dummy")
        case 1:
            switch context {
            case .initial:
                print("New scene")
                
                
                
                hideActions()
            default:
                print("dummy")
            }
        case 2:
            switch context {
            case .initial:
                print("Switching scenes")
                
                scenesListTableView.isHidden = false
                actionsTableView.isHidden = true
            default:
                print("dummy")
            }
        case 3:
            switch context {
            case .initial:
                print("Duplicate scene")
                
                let sceneNth = arc4random()
                
                UserDefaults.standard.set("Scene \(sceneNth)", forKey: "MetalEditor Scene \(sceneNth)")
                
                let sceneName = "Scene \(sceneNth)"
                let scene = Scene(name: sceneName, fromDatabase: false)

                scene.x = RootViewController.scenes[currentScene].x
                scene.y = RootViewController.scenes[currentScene].y
                scene.z = RootViewController.scenes[currentScene].z
                
                scene.xAngle = RootViewController.scenes[currentScene].xAngle
                scene.yAngle = RootViewController.scenes[currentScene].yAngle
                
                //var nth = 0
                for object in RootViewController.scenes[currentScene].objects {
                    //print(nth)
                    scene.appendObjectWithoutUpdate(object: object)
                    //nth += 1
                    //print(RootViewController.scenes[currentScene].objects.count)
                }
                scene.updateDatabase()
                
                RootViewController.scenes.append(scene)
                scenesListTableView.reloadData()
                
                currentScene = RootViewController.scenes.count - 1
                contr.setVertexArrays(RootViewController.scenes[currentScene].bigVertices, bigLineVertices: RootViewController.scenes[currentScene].bigLineVertices, selectedVertices:RootViewController.scenes[currentScene].selectionVertices, gridLineVertices: Grid.bigLineVertices, axisLineVertices: Axis.bigLineVertices, bigIndices: RootViewController.scenes[currentScene].bigIndices, bigLineIndices: RootViewController.scenes[currentScene].bigLineIndices, gridLineIndices: Grid.bigLineIndices)
                contr.translateCamera(RootViewController.scenes[currentScene].x, y: RootViewController.scenes[currentScene].y, z: RootViewController.scenes[currentScene].z)
                contr.setAngle(RootViewController.scenes[currentScene].xAngle, y: RootViewController.scenes[currentScene].yAngle)
                contr.loadModel(Int32(RootViewController.scenes[currentScene].indicesCount))
                item.title = RootViewController.scenes[currentScene].name
                
                hideActions()
            default:
                print("dummy")
            }
        case 4:
            print("Delete scene")
            
            UserDefaults.standard.removeObject(forKey: "MetalEditor \(RootViewController.scenes[currentScene].name ?? "")")
            RootViewController.scenes[currentScene].deleteDatabase()
            
            RootViewController.scenes.remove(at: currentScene)
            scenesListTableView.reloadData()
            currentScene = RootViewController.scenes.count - 1
            
            contr.setVertexArrays(RootViewController.scenes[currentScene].bigVertices, bigLineVertices: RootViewController.scenes[currentScene].bigLineVertices, selectedVertices:RootViewController.scenes[currentScene].selectionVertices, gridLineVertices: Grid.bigLineVertices, axisLineVertices: Axis.bigLineVertices, bigIndices: RootViewController.scenes[currentScene].bigIndices, bigLineIndices: RootViewController.scenes[currentScene].bigLineIndices, gridLineIndices: Grid.bigLineIndices)
            contr.translateCamera(RootViewController.scenes[currentScene].x, y: RootViewController.scenes[currentScene].y, z: RootViewController.scenes[currentScene].z)
            contr.setAngle(RootViewController.scenes[currentScene].xAngle, y: RootViewController.scenes[currentScene].yAngle)
            contr.loadModel(Int32(RootViewController.scenes[currentScene].indicesCount))
            item.title = RootViewController.scenes[currentScene].name
            
            hideActions()
        case 5:
            print("Add object")
            
            context = .addition
            
            additionTableView.isHidden = false
            
            actionsTableView.isHidden = true
            
        case 6:
            switch context {
            case .initial:
                context = .translation
                
                propertiesTableView.reloadData()
                propertiesTableView.isHidden = false
                
                item.rightBarButtonItem = applyButton
            default:
                print("dummy")
            }
        case 7:
            switch context {
            case .initial:
                context = .rotation
                
                propertiesTableView.reloadData()
                propertiesTableView.isHidden = false
                
                item.rightBarButtonItem = applyButton
            default:
                context = .initial
            }
        case 8:
            if context == .initial {
                context = .scaling
                
                propertiesTableView.reloadData()
                propertiesTableView.isHidden = false
                
                item.rightBarButtonItem = applyButton
            } else {
                context = .initial
            }
        case 10:
            print("Copy")
            copyAction()
        case 11:
            print("Paste")
            pasteAction()
        case 12:
            print("Attach")
            attachAction()
        case 13:
            print("Deletion")
            removeAction()
        case 14:
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
            //timer = CADisplayLink(target: self, selector: #selector(self.gameloop))
            //timer.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
        }
        if nth > -1 {
            
            let tabBar = UITabBar(frame: CGRect(x: 0, y: 300, width: 320, height: 100))
            //tabBar.isTranslucent = false
            tabBar.unselectedItemTintColor = .white
            tabBar.barTintColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1)

            view.addSubview(tabBar)
            tabBar.translatesAutoresizingMaskIntoConstraints = false
            tabBar.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0).isActive = true
            tabBar.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0).isActive = true
            tabBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
            tabBar.topAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -65.0).isActive = true
            
            let tabBarItem = UITabBarItem(title: "Perspective", image: nil, selectedImage: nil)
            let tabBarItem2 = UITabBarItem(title: "Front", image: nil, selectedImage: nil)
            let tabBarItem3 = UITabBarItem(title: "Right", image: nil, selectedImage: nil)
            let tabBarItem4 = UITabBarItem(title: "Back", image: nil, selectedImage: nil)
            let tabBarItem5 = UITabBarItem(title: "Left", image: nil, selectedImage: nil)
            let tabBarItem6 = UITabBarItem(title: "Top", image: nil, selectedImage: nil)
            let tabBarItem7 = UITabBarItem(title: "Bottom", image: nil, selectedImage: nil)
            //tabBarItem.textColor = .white
            tabBar.setItems([tabBarItem, tabBarItem2, tabBarItem3, tabBarItem4, tabBarItem5, tabBarItem6, tabBarItem7], animated: false)
            
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
            
            // addition
            
            additionTableView.tableFooterView = UIView(frame: .zero)
            additionTableView.isHidden = true
            
            additionDataSource = AdditionTableViewDataSource(controller: self)
            
            additionTableView.delegate = additionDataSource
            additionTableView.dataSource = additionDataSource
            self.view.addSubview(additionTableView)
            
            additionTableView.translatesAutoresizingMaskIntoConstraints = false;
            additionTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0).isActive = true
            additionTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0).isActive = true
            additionTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
            additionTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 65.0).isActive = true
            
            // properties
            
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
            
            scenesListTableView.tableFooterView = UIView(frame: .zero)
            scenesListTableView.isHidden = true
            
            scenesDataSource = ScenesListTableViewDataSource(controller: self)
            
            scenesListTableView.delegate = scenesDataSource
            scenesListTableView.dataSource = scenesDataSource
            self.view.addSubview(scenesListTableView)
            
            scenesListTableView.translatesAutoresizingMaskIntoConstraints = false
            scenesListTableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0.0).isActive = true
            scenesListTableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0.0).isActive = true
            scenesListTableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0).isActive = true
            scenesListTableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 65.0).isActive = true
            
            let bar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: 320, height: 65))
            bar.isTranslucent = true
            
            item.title = RootViewController.scenes[currentScene].name
            
            item.rightBarButtonItem = button
            item.hidesBackButton = true
            bar.pushItem(item, animated: false)
            
            
            item.leftBarButtonItem = actionsButton
            
            
            //self.view.addSubview(bar)
            
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
    
    func gestureRecognizerDidRecognize(recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocity(in: self.view)
        let kVelocityScale: CGFloat = 0.01
        
        if recognizer.numberOfTouches > 1 {
            angularVelocity = CGPoint(x: velocity.x * kVelocityScale, y: velocity.y * kVelocityScale)
            RootViewController.scenes[currentScene].x += (Float(angularVelocity.x) * 0.01)
            RootViewController.scenes[currentScene].y -= (Float(angularVelocity.y) * 0.01)
            
            contr.translateCamera(RootViewController.scenes[currentScene].x, y: RootViewController.scenes[currentScene].y, z: RootViewController.scenes[currentScene].z)
            contr.setAngle(RootViewController.scenes[currentScene].xAngle, y: RootViewController.scenes[currentScene].yAngle)
        } else {
            angularVelocity = CGPoint(x: velocity.x * kVelocityScale, y: velocity.y * kVelocityScale)
            RootViewController.scenes[currentScene].xAngle += (Float(angularVelocity.x))
            RootViewController.scenes[currentScene].yAngle += (Float(angularVelocity.y))
            contr.setAngle(RootViewController.scenes[currentScene].xAngle, y: RootViewController.scenes[currentScene].yAngle)
        }
            
        print(recognizer.numberOfTouches)
        
        
        //print(RootViewController.scenes[0].xAngle)
        //RootViewController.scenes[nth].xAngle +=
        //self.angle = CGPointMake(self.angle.x + self.angularVelocity.x * frameDuration,
        //                         self.angle.y + self.angularVelocity.y * frameDuration);
        //self.angularVelocity = CGPointMake(self.angularVelocity.x * (1 - kDamping),
        //                                   self.angularVelocity.y * (1 - kDamping));
        
    }
    
    func tap(recognizer: UITapGestureRecognizer) {
        
        let point = recognizer.location(in: recognizer.view)
        print(point.x)
        print(point.y)
        
        contr.setTapPoint(Int32(point.x), y: Int32(point.y))
        contr.currentScene = Int32(currentScene)
        contr.toggleSelectionMode()
        //contr.loadModel(Int32(RootViewController.scenes[nth].indicesCount))
    }
    
    func pinchAction(recognizer: UIPinchGestureRecognizer) {
        //RootViewController.scenes[nth].z *= CGFloat(recognizer.scale)
        
        let scale: Float = (Float(recognizer.scale) - 1.0) * 0.1
        print(recognizer.scale)
        
        RootViewController.scenes[currentScene].z += scale
        RootViewController.scenes[currentScene].prepareForRender()
        
        contr.translateCamera(RootViewController.scenes[currentScene].x, y: RootViewController.scenes[currentScene].y, z: RootViewController.scenes[currentScene].z)
        contr.loadModel(Int32(RootViewController.scenes[currentScene].indicesCount))
        
        print(recognizer.scale)
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.count > 1 {
            
        }
        print(touches.count)
        
        /*for touch in touches {
            let view = viewForTouch(touch: touch)
            // Move the view to the new location.
            let newLocation = touch.location(in: self)
            view?.center = newLocation
        }*/
    }
    
    func accHandler(x: Float, y: Float, z: Float) {
        
        //print(x)
        //print(y)
        //print(z)
        
        let lockZ = true
        
        if abs(x) >= 0.1 {
            RootViewController.scenes[currentScene].x += (x * 0.01)
        }
        if abs(y) >= 0.1 {
            RootViewController.scenes[currentScene].y += (y * 0.01)
        }
        
        if !lockZ {
            if abs(z + 1.0) >= 0.1 {
                RootViewController.scenes[currentScene].z += ((z + 1.0) * 0.01)
            }
        }
            //
        
        contr.translateCamera(RootViewController.scenes[currentScene].x, y: RootViewController.scenes[currentScene].y, z: RootViewController.scenes[currentScene].z)
        contr.setAngle(RootViewController.scenes[currentScene].xAngle, y: RootViewController.scenes[currentScene].yAngle)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        motionManager.accelerometerUpdateInterval = 0.01
        if motionManager.isAccelerometerAvailable {
            let queue = OperationQueue.current
            motionManager.startAccelerometerUpdates(to: queue!, withHandler: {(accelData: CMAccelerometerData?, error: Error?) in self.accHandler(x: Float((accelData?.acceleration.x)!), y: Float((accelData?.acceleration.y)!), z: Float((accelData?.acceleration.z)!))
            } as! CMAccelerometerHandler)
        }
        
        view.isMultipleTouchEnabled = true
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchAction(recognizer:)))
        view.addGestureRecognizer(pinchGestureRecognizer)
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(gestureRecognizerDidRecognize(recognizer:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tap(recognizer:)))
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)

        /*self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
            action:@selector(gestureRecognizerDidRecognize:)];
        [self.view addGestureRecognizer:self.panGestureRecognizer];
        
        self.lastFrameTime = CFAbsoluteTimeGetCurrent();*/

        //DataViewController.mainView = self.view
        RootViewController.contr = contr
        contr.setVertexArrays(RootViewController.scenes[currentScene].bigVertices, bigLineVertices: RootViewController.scenes[currentScene].bigLineVertices, selectedVertices:RootViewController.scenes[currentScene].selectionVertices, gridLineVertices: Grid.bigLineVertices, axisLineVertices: Axis.bigLineVertices, bigIndices: RootViewController.scenes[currentScene].bigIndices, bigLineIndices: RootViewController.scenes[currentScene].bigLineIndices, gridLineIndices: Grid.bigLineIndices)
        contr.customMetalLayer(self.view.layer, bounds: self.view.bounds, indicesCount: Int32(RootViewController.scenes[currentScene].indicesCount), x: RootViewController.scenes[currentScene].x, y: RootViewController.scenes[currentScene].y, z: RootViewController.scenes[currentScene].z, xAngle: RootViewController.scenes[currentScene].xAngle, yAngle: RootViewController.scenes[currentScene].yAngle)
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
        
        let sceneNth = arc4random()
        
        let sceneName = "Scene \(sceneNth)"
        let scene = Scene(name: sceneName, fromDatabase: false)
        
        scene.z = -4
        scene.xAngle = -225
        scene.yAngle = 45
        
        let dummy = Cube(x: 0, y: 0, z: 0, width: 0, height: 0, depth: 0, rgb: (0, 0, 0))
        //scene.appendObjectWithoutUpdate(object: dummy)
        
        let cube = Cube(x: -0.5, y: -0.5, z: 0.5, width: 1.0, height: 1.0, depth: 1.0, rgb: (255, 0, 0))
        //scene.appendObjectWithoutUpdate(object: cube)
        
        scene.prepareForRender()
        RootViewController.scenes.append(scene)
        //scenesListTableView.reloadData()
        
        RootViewController.currentScene = RootViewController.scenes.count - 1
        currentScene = RootViewController.currentScene
        
        contr.setVertexArrays(RootViewController.scenes[RootViewController.currentScene].bigVertices, bigLineVertices: RootViewController.scenes[RootViewController.currentScene].bigLineVertices, selectedVertices:RootViewController.scenes[RootViewController.currentScene].selectionVertices, gridLineVertices: Grid.bigLineVertices, axisLineVertices: Axis.bigLineVertices, bigIndices: RootViewController.scenes[RootViewController.currentScene].bigIndices, bigLineIndices: RootViewController.scenes[RootViewController.currentScene].bigLineIndices, gridLineIndices: Grid.bigLineIndices)
        
        contr.translateCamera(scene.x, y: scene.y, z: scene.z)
        contr.setAngle(RootViewController.scenes[RootViewController.currentScene].xAngle, y: RootViewController.scenes[RootViewController.currentScene].yAngle)
        contr.loadModel(Int32(RootViewController.scenes[RootViewController.currentScene].indicesCount))
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

