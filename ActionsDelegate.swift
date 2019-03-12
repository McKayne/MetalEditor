//
//  ActionsDelegate.swift
//  MidJuly_Paged
//
//  Created by для интернета on 31.10.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import UIKit
import Darwin

class ActionsDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var mainController: RootViewController?
    let controller: ActionsController
    
    private let actionsList = ["Undo or redo", "New Scene", "Switch Scene", "Duplicate scene", "Delete scene", "Add Object", "Translate", "Rotate", "Scale object", "Mirror", "Bend", "Subdivide", "Face Split", "Warp", "Copy objects", "Paste objects", "Attach", "Remove", "Import or export", "Textures library", "About"]
    
    init(mainController: RootViewController?, controller: ActionsController) {
        self.mainController = mainController
        self.controller = controller
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
        
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = actionsList[indexPath.row]
        
        if actionsList[indexPath.row] == "Add Object" {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch actionsList[indexPath.row] {
        case "New Scene":
            createAndPresentScene()
        case "Switch Scene":
            toSceneChooser()
        case "Add Object":
            presentAdditionList()
        default:
            print("Dummy")
        }
    }
    
    func toSceneChooser() {
        let chooser = SceneChooserController()
        chooser.mainController = mainController
        controller.navigationController?.pushViewController(chooser, animated: true)
    }
    
    func createAndPresentScene() {
        let sceneNth = arc4random()
        
        let sceneName = "Scene \(sceneNth)"
        let scene = Scene(name: sceneName, fromDatabase: false)
        
        scene.z = -4
        scene.xAngle = -225
        scene.yAngle = 45
        
        let cube = Cube(x: -0.5, y: -0.5, z: 0.5, width: 1.0, height: 1.0, depth: 1.0, rgb: (255, 0, 0))
        //scene.appendObjectWithoutUpdate(object: cube)
        
        scene.prepareForRender()
        RootViewController.scenes.append(scene)
        //scenesListTableView.reloadData()
        
        RootViewController.currentScene = RootViewController.scenes.count - 1
        RootViewController.sceneControllers[0].currentScene = RootViewController.currentScene
        
        RootViewController.sceneControllers[0].contr.setVertexArrays(RootViewController.scenes[RootViewController.currentScene].bigVertices, bigLineVertices: RootViewController.scenes[RootViewController.currentScene].bigLineVertices, selectedVertices:RootViewController.scenes[RootViewController.currentScene].selectionVertices, gridLineVertices: Grid.bigLineVertices, axisLineVertices: Axis.bigLineVertices, bigIndices: RootViewController.scenes[RootViewController.currentScene].bigIndices, bigLineIndices: RootViewController.scenes[RootViewController.currentScene].bigLineIndices, gridLineIndices: Grid.bigLineIndices)
        
        RootViewController.sceneControllers[0].contr.translateCamera(scene.x, y: scene.y, z: scene.z)
        RootViewController.sceneControllers[0].contr.setAngle(RootViewController.scenes[RootViewController.currentScene].xAngle, y: RootViewController.scenes[RootViewController.currentScene].yAngle)
        RootViewController.sceneControllers[0].contr.loadModel(Int32(RootViewController.scenes[RootViewController.currentScene].indicesCount))
        mainController?.navigationItem.title = RootViewController.scenes[RootViewController.currentScene].name
        
        if let main = mainController {
            _ = controller.navigationController?.popToViewController(main, animated: true)
        } else {
            print("Nil controller")
        }
    }
    
    func presentAdditionList() {
        let additionController = AdditionController(mainController: mainController)
        controller.navigationController?.pushViewController(additionController, animated: true)
    }
}
