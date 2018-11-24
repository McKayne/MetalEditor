//
//  BezierSurfaceController.swift
//  MidJuly_Paged
//
//  Created by для интернета on 13.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class BezierSurfaceController: UIViewController {
    
    var mainController: RootViewController?
    
    let mathSurfacePropertiesTableView = UITableView()
    //var actionsDelegate:ActionsDelegate?
    
    convenience init(mainController: RootViewController?) {
        self.init(nibName: nil, bundle: nil)
        self.mainController = mainController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        let applyButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(popToScene(sender:)))
        navigationItem.rightBarButtonItem = applyButton
        navigationItem.title = "Bezier Surface"
    }
    
    func popToScene(sender: UIBarButtonItem) {
        
        let surface = BezierSurface(x: -2, y: 0, z: 2, width: 4, depth: 4, rgb: (255, 0, 255))
        
        /*set.appendVertexWithCoords(xyz: (-0.5, 0, -0.5))
         set.appendVertexWithCoords(xyz: (0, 0, 0.5))
         set.appendVertexWithCoords(xyz: (0.5, 0, -0.5))
         set.appendVertexWithCoords(xyz: (0, 0, -1))*/
        
        
        //surface.shiftTo(xShift: 0, yShift: 0, zShift: 0.5)
        
        RootViewController.scenes[RootViewController.currentScene].appendObjectWithoutUpdate(object: surface)
        
        RootViewController.scenes[RootViewController.currentScene].prepareForRender()
        RootViewController.sceneControllers[0].contr.loadModel(Int32(RootViewController.scenes[RootViewController.currentScene].indicesCount))
        
        /*let surface = SurfaceOfRevolution(x: -2, y: 0, z: 2, width: 4, depth: 4, rgb: (255, 0, 255))
         //let mathSurface = MathSurface(x: -2, y: 0, z: 2, width: 8, depth: 5, rgb: (255, 0, 255))
         */
        
        if let main = mainController {
            _ = navigationController?.popToViewController(main, animated: true)
        } else {
            print("Nil controller")
        }
    }
}
