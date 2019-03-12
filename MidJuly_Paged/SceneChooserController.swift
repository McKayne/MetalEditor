//
//  SceneChooserController.swift
//  MidJuly_Paged
//
//  Created by для интернета on 12.03.19.
//  Copyright © 2019 для интернета. All rights reserved.
//

import Foundation
import UIKit

class SceneChooserController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var mainController: RootViewController?
    
    let sceneList = UITableView()
    
    override func viewDidLoad() {
        //let applyButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(popToScene(sender:)))
        //navigationItem.rightBarButtonItem = applyButton
        navigationItem.title = "Scene Selection"
        
        sceneList.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
        sceneList.tableFooterView = UIView(frame: .zero)
        //actionsDelegate = ActionsDelegate(controller: self)
        sceneList.delegate = self
        sceneList.dataSource = self
        view.addSubview(sceneList)
        RootViewController.performAutolayoutConstants(subview: sceneList, view: view, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RootViewController.scenes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
        
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = RootViewController.scenes[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        RootViewController.currentScene = indexPath.row
        RootViewController.sceneControllers[0].currentScene = RootViewController.currentScene
        
        RootViewController.sceneControllers[0].contr.setVertexArrays(RootViewController.scenes[RootViewController.currentScene].bigVertices, bigLineVertices: RootViewController.scenes[RootViewController.currentScene].bigLineVertices, selectedVertices:RootViewController.scenes[RootViewController.currentScene].selectionVertices, gridLineVertices: Grid.bigLineVertices, axisLineVertices: Axis.bigLineVertices, bigIndices: RootViewController.scenes[RootViewController.currentScene].bigIndices, bigLineIndices: RootViewController.scenes[RootViewController.currentScene].bigLineIndices, gridLineIndices: Grid.bigLineIndices)
        
        RootViewController.sceneControllers[0].contr.translateCamera(RootViewController.scenes[indexPath.row].x, y: RootViewController.scenes[indexPath.row].y, z: RootViewController.scenes[indexPath.row].z)
        RootViewController.sceneControllers[0].contr.setAngle(RootViewController.scenes[RootViewController.currentScene].xAngle, y: RootViewController.scenes[RootViewController.currentScene].yAngle)
        RootViewController.sceneControllers[0].contr.loadModel(Int32(RootViewController.scenes[RootViewController.currentScene].indicesCount))
        mainController?.navigationItem.title = RootViewController.scenes[RootViewController.currentScene].name
        
        _ = navigationController?.popToViewController(mainController!, animated: true)
    }
}
