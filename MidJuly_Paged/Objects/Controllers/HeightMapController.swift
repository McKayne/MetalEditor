//
//  HeightMapController.swift
//  MidJuly_Paged
//
//  Created by для интернета on 31.10.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import UIKit

class HeightMapController: UIViewController {
    
    var mainController: RootViewController?
    
    let heightMapPropertiesTableView = UITableView()
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
        navigationItem.title = "Height Map"
        
        heightMapPropertiesTableView.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
        heightMapPropertiesTableView.tableFooterView = UIView(frame: .zero)
        //actionsDelegate = ActionsDelegate(controller: self)
        //actionsTableView.delegate = actionsDelegate
        //actionsTableView.dataSource = actionsDelegate
        view.addSubview(heightMapPropertiesTableView)
        RootViewController.performAutolayoutConstants(subview: heightMapPropertiesTableView, view: view, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    func popToScene(sender: UIBarButtonItem) {
        
        let heightMap = HeightMap(x: -2, y: 0, z: 2, width: 4, depth: 4, rgb: (255, 0, 255))
        RootViewController.scenes[RootViewController.currentScene].appendObjectWithoutUpdate(object: heightMap)
        
        RootViewController.scenes[RootViewController.currentScene].prepareForRender()
        RootViewController.sceneControllers[0].contr.loadModel(Int32(RootViewController.scenes[RootViewController.currentScene].indicesCount))
        
        if let main = mainController {
            _ = navigationController?.popToViewController(main, animated: true)
        } else {
            print("Nil controller")
        }
    }
}
