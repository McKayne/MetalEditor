//
//  RootViewController.swift
//  MidJuly_Paged
//
//  Created by для интернета on 12.07.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

class RootViewController: UIViewController, UIPageViewControllerDelegate {

    static var sceneControllers: [DataViewController] = []
    static var currentScene: Int = 0
    
    var pageViewController: UIPageViewController?
    
    static var contr: ViewController!

    @objc static var scenes: [Scene] = []

    static func performAutolayoutConstants(subview: UIView, view: UIView, left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left).isActive = true
        subview.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right).isActive = true
        subview.topAnchor.constraint(equalTo: view.topAnchor, constant: top).isActive = true
        subview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom).isActive = true
    }
    
    func initObjects() {
        Axis.appendAxis()
        Grid.appendGrid()
        
        Stairs.numberOfSteps.text = "5"
        Stairs.xAngle.text = "0.0"
        Stairs.yAngle.text = "0.0"
        Stairs.zAngle.text = "0.0"
    }
    
    func presentActionsList(sender: UIBarButtonItem) {
        let actionsController = ActionsController(mainController: self)
        navigationController?.pushViewController(actionsController, animated: true)
    }
    
    func exportOBJ(sender: UIBarButtonItem) {
        let url = Export.exportOBJ(scene: RootViewController.scenes[RootViewController.currentScene])
        
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        activityViewController.excludedActivityTypes = [.print, .copyToPasteboard, .assignToContact, .saveToCameraRoll, .airDrop] //[]
        activityViewController.popoverPresentationController?.sourceView = view
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.size.width / 2, y: view.bounds.size.height / 4, width: 0, height: 0)
        
        activityViewController.completionWithItemsHandler = {(type, completed, items, error) in
            print("COMPLETED")
            try! FileManager.default.removeItem(at: url)
        }
        
        DispatchQueue.main.async {
            self.present(activityViewController, animated: true, completion:nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initObjects()
        
        
        
        //Demo1.demo()
        
        //if true {
        /*let scene = Scene(name: "demoA", fromDatabase: false)
        scene.z = -2
        scene.xAngle = -45
        scene.yAngle = 45
        let cube = Cube(x: -0.25, y: -0.25, z: 0.25, width: 0.5, height: 0.5, depth: 0.5, rgb: (255, 0, 0))
        scene.appendObject(object: cube)
        let cube2 = Cube(x: 0.25, y: -0.25, z: 0.25, width: 0.5, height: 0.5, depth: 0.5, rgb: (0, 255, 0))
        scene.appendObject(object: cube2)
        scene.prepareForRender()
        
        RootViewController.scenes.append(scene)*/
        
        /*let scene2 = Scene(name: "demoB", fromDatabase: false)
        scene2.z = -2
        scene2.xAngle = -45
        scene2.yAngle = 45
        let cube3 = Cube(x: -0.25, y: -0.25, z: 0.25, width: 0.5, height: 0.5, depth: 0.5, rgb: (255, 0, 255))
        scene2.appendObject(object: cube3)
 */
 //}
            
        let dictionary = UserDefaults.standard.dictionaryRepresentation()
        for pair in dictionary {
            if pair.key.hasPrefix("MetalEditor") {
                print(pair.key)
            }
        }
        
        for pair in dictionary {
            if pair.key.hasPrefix("MetalEditor") && !pair.key.hasSuffix("Trash") {
                //"MetalEditor Trash \(name)"
                print("MetalEditor \(String(describing: pair.value)) Trash")
                if UserDefaults.standard.object(forKey: "MetalEditor \(String(describing: pair.value)) Trash") == nil {
                    let scene = Scene(name: String(describing: pair.value), fromDatabase: true)
                    scene.prepareForRender()
                    print(scene.name)
                
                    RootViewController.scenes.append(scene)
                }
            }
        }
        
        if RootViewController.scenes.count == 0 {
            let sceneNth = arc4random()
            
            let sceneName = "Scene \(sceneNth)"
            let scene = Scene(name: sceneName, fromDatabase: false)
            
            scene.z = -4
            scene.xAngle = -225
            scene.yAngle = 45
            
            let cube = Cube(x: -0.5, y: -0.5, z: 0.5, width: 1.0, height: 1.0, depth: 1.0, rgb: (255, 0, 0))
            scene.appendObjectWithoutUpdate(object: cube)
            
            scene.prepareForRender()
            RootViewController.scenes.append(scene)
        }
        
        /*RootViewController.currentScene = RootViewController.scenes.count - 1
        RootViewController.sceneControllers[0].currentScene = RootViewController.currentScene
        
        RootViewController.sceneControllers[0].contr.setVertexArrays(RootViewController.scenes[RootViewController.currentScene].bigVertices, bigLineVertices: RootViewController.scenes[RootViewController.currentScene].bigLineVertices, selectedVertices:RootViewController.scenes[RootViewController.currentScene].selectionVertices, gridLineVertices: Grid.bigLineVertices, axisLineVertices: Axis.bigLineVertices, bigIndices: RootViewController.scenes[RootViewController.currentScene].bigIndices, bigLineIndices: RootViewController.scenes[RootViewController.currentScene].bigLineIndices, gridLineIndices: Grid.bigLineIndices)
        
        RootViewController.sceneControllers[0].contr.translateCamera(RootViewController.scenes[RootViewController.currentScene].x, y: RootViewController.scenes[RootViewController.currentScene].y, z: RootViewController.scenes[RootViewController.currentScene].z)
        RootViewController.sceneControllers[0].contr.setAngle(RootViewController.scenes[RootViewController.currentScene].xAngle, y: RootViewController.scenes[RootViewController.currentScene].yAngle)
        RootViewController.sceneControllers[0].contr.loadModel(Int32(RootViewController.scenes[RootViewController.currentScene].indicesCount))*/
        
        //scene.deleteDatabase()
        //scene2.deleteDatabase()
        //scene3.deleteDatabase()
        
        //UIApplication.shared.statusBarStyle = .lightContent
        
        let actionsButton = UIBarButtonItem(title: "Actions", style: .plain, target: self, action: #selector(presentActionsList(sender:)))
        let exportButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(exportOBJ(sender:)))
        
        navigationItem.leftBarButtonItem = actionsButton
        navigationItem.rightBarButtonItem = exportButton
        navigationItem.title = RootViewController.scenes[0].name
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1)
        navigationController?.navigationBar.tintColor = .white
        
        // create db
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("MetalEditorDebugScene.sqlite")
        
        // open db
        var db: OpaquePointer?
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        // create table
        if sqlite3_exec(db, "CREATE TABLE IF NOT EXISTS Heroes (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, powerrank INTEGER)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        var queryString = "INSERT INTO Heroes (name, powerrank) VALUES (?,?)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //binding the parameters
        if sqlite3_bind_text(stmt, 1, "test", -1, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 2, 123) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        //executing the query to insert values
        /*if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }*/
        
        //this is our select query
        queryString = "SELECT * FROM Heroes"
        
        //statement pointer
        //stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            let id = sqlite3_column_int(stmt, 0)
            let name = String(cString: sqlite3_column_text(stmt, 1))
            let powerrank = sqlite3_column_int(stmt, 2)
            
            //adding values to list
            //print(Int(id))
            //print(String(describing: name))
            //print(Int(powerrank))
        }
        
        //RootViewController.scenes[0] = scene
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
        // Configure the page view controller and add it as a child view controller.
        self.pageViewController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        self.pageViewController!.delegate = self

        let startingViewController: DataViewController = self.modelController.viewControllerAtIndex(0, storyboard: self.storyboard!)!
        let viewControllers = [startingViewController]
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: false, completion: {done in })

        self.pageViewController!.dataSource = self.modelController

        self.addChildViewController(self.pageViewController!)
        
        //self.pageViewController?.view.isUserInteractionEnabled = false
        self.view.addSubview(self.pageViewController!.view)

        // Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
        var pageViewRect = self.view.bounds
        if UIDevice.current.userInterfaceIdiom == .pad {
            pageViewRect = pageViewRect.insetBy(dx: 40.0, dy: 40.0)
        }
        self.pageViewController!.view.frame = pageViewRect

        self.pageViewController!.didMove(toParentViewController: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    var modelController: ModelController {
        // Return the model controller object, creating it if necessary.
        // In more complex implementations, the model controller may be passed to the view controller.
        if _modelController == nil {
            _modelController = ModelController()
        }
        return _modelController!
    }

    var _modelController: ModelController? = nil

    // MARK: - UIPageViewController delegate methods

    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation {
        if (orientation == .portrait) || (orientation == .portraitUpsideDown) || (UIDevice.current.userInterfaceIdiom == .phone) {
            // In portrait orientation or on iPhone: Set the spine position to "min" and the page view controller's view controllers array to contain just one view controller. Setting the spine position to 'UIPageViewControllerSpineLocationMid' in landscape orientation sets the doubleSided property to true, so set it to false here.
            let currentViewController = self.pageViewController!.viewControllers![0]
            let viewControllers = [currentViewController]
            self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

            self.pageViewController!.isDoubleSided = false
            return .min
        }

        // In landscape orientation: Set set the spine location to "mid" and the page view controller's view controllers array to contain two view controllers. If the current page is even, set it to contain the current and next view controllers; if it is odd, set the array to contain the previous and current view controllers.
        let currentViewController = self.pageViewController!.viewControllers![0] as! DataViewController
        
        var viewControllers: [UIViewController]

        let indexOfCurrentViewController = self.modelController.indexOfViewController(currentViewController)
        if (indexOfCurrentViewController == 0) || (indexOfCurrentViewController % 2 == 0) {
            let nextViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerAfter: currentViewController)
            viewControllers = [currentViewController, nextViewController!]
        } else {
            let previousViewController = self.modelController.pageViewController(self.pageViewController!, viewControllerBefore: currentViewController)
            viewControllers = [previousViewController!, currentViewController]
        }
        self.pageViewController!.setViewControllers(viewControllers, direction: .forward, animated: true, completion: {done in })

        return .mid
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

