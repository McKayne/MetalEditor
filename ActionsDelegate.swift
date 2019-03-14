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
    
    private let actionsList = ["Undo or Redo", "New Scene", "Switch Scene", "Duplicate Scene", "Move Scene to Trash", "Add Object", "Translate", "Rotate", "Scale object", "Mirror", "Bend", "Subdivide", "Face Split", "Warp", "Copy objects", "Paste objects", "Attach", "Remove", "Import or export", "Textures library", "Trash Bin", "About"]
    
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
        case "Undo or Redo":
            toActionsHistory()
        case "New Scene":
            createAndPresentScene()
        case "Switch Scene":
            toSceneChooser()
        case "Duplicate Scene":
            duplicateScene()
        case "Move Scene to Trash":
            trashScene()
        case "Add Object":
            presentAdditionList()
        case "Remove":
            removeAction()
        case "Trash Bin":
            toTrash()
        default:
            print("Dummy")
        }
    }
    
    func removeAction() {
        var isAnyObjectSelected = false
        // TODO fix multiple selection
        for i in 0..<RootViewController.scenes[RootViewController.currentScene].objects.count {
            if RootViewController.scenes[RootViewController.currentScene].objects[i].isSelected {
                
                RootViewController.scenes[RootViewController.currentScene].updateHistory(id: i, msg: "Delete object", type: .deletion)
                RootViewController.scenes[RootViewController.currentScene].appendHistoryObject(id: i, object: RootViewController.scenes[RootViewController.currentScene].objects[i])
                
                isAnyObjectSelected = true
                RootViewController.scenes[RootViewController.currentScene].removeObject(nth: i)
                break
            }
        }
        
        if !isAnyObjectSelected {
            RootViewController.scenes[RootViewController.currentScene].removeAll(nth: 0)
        }
        
        RootViewController.scenes[RootViewController.currentScene].prepareForRender()
        RootViewController.sceneControllers[0].contr.loadModel(Int32(RootViewController.scenes[RootViewController.currentScene].indicesCount))
        
        //hideActions()
        if let main = mainController {
            _ = controller.navigationController?.popToViewController(main, animated: true)
        } else {
            print("Nil controller")
        }
    }
    
    func duplicateScene() {
        let sceneNth = arc4random()
        
        let sceneName = "Scene \(sceneNth)"
        let scene = Scene(name: sceneName, fromDatabase: false)
        
        scene.x = RootViewController.scenes[RootViewController.currentScene].x
        scene.y = RootViewController.scenes[RootViewController.currentScene].y
        scene.z = RootViewController.scenes[RootViewController.currentScene].z
        
        scene.xAngle = RootViewController.scenes[RootViewController.currentScene].xAngle
        scene.yAngle = RootViewController.scenes[RootViewController.currentScene].yAngle
        //scene.zAngle = RootViewController.scenes[RootViewController.currentScene].zAngle
        
        for object in RootViewController.scenes[RootViewController.currentScene].objects {
            scene.appendObject(object: object, skipActionHistory: true)
        }
        
        scene.prepareForRender()
        
        var stmt: OpaquePointer?
        
        var prevSceneQuery = "select * from actions_history"
        
        if sqlite3_prepare(RootViewController.scenes[RootViewController.currentScene].db, prevSceneQuery, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(RootViewController.scenes[RootViewController.currentScene].db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        var prevHistoryIDs: [Int] = []
        var prevHistoryActions: [String] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            prevHistoryIDs.append(Int(sqlite3_column_int(stmt, 0)))
            prevHistoryActions.append(String(cString: sqlite3_column_text(stmt, 1)))
        }
        
        sqlite3_finalize(stmt)
        
        prevSceneQuery = "select * from history_scene_objects"
        
        if sqlite3_prepare(RootViewController.scenes[RootViewController.currentScene].db, prevSceneQuery, -1, &stmt, nil) != SQLITE_OK {
            print(String(cString: sqlite3_errmsg(RootViewController.scenes[RootViewController.currentScene].db)!))
        }
        
        var prevHistorySceneObjects: [(id: Int, x: Float, y: Float, z: Float, red: Float, green: Float, blue: Float, alpha: Float)] = []
        //history_scene_objects(id, x, y, z, red, green, blue, alpha)
        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(stmt, 0))
            let x = Float(sqlite3_column_double(stmt, 1))
            let y = Float(sqlite3_column_double(stmt, 2))
            let z = Float(sqlite3_column_double(stmt, 3))
            let red = Float(sqlite3_column_double(stmt, 4))
            let green = Float(sqlite3_column_double(stmt, 5))
            let blue = Float(sqlite3_column_double(stmt, 6))
            let alpha = Float(sqlite3_column_double(stmt, 7))
            
            prevHistorySceneObjects.append((id, x, y, z,
                                            red, green, blue, alpha))
        }
        
        var nextSceneQuery = "insert into actions_history(id, name) values(?, ?)"
        
        for i in 0..<prevHistoryIDs.count {
            var stmt: OpaquePointer?
            
            if sqlite3_prepare(scene.db, nextSceneQuery, -1, &stmt, nil) != SQLITE_OK {
                print(String(cString: sqlite3_errmsg(scene.db)!))
            }
            
            if sqlite3_bind_int(stmt, 1, Int32(prevHistoryIDs[i])) != SQLITE_OK {
                print(String(cString: sqlite3_errmsg(scene.db)!))
            }
            
            if sqlite3_bind_text(stmt, 2, (prevHistoryActions[i] as NSString).utf8String, -1, nil) != SQLITE_OK {
                print(String(cString: sqlite3_errmsg(scene.db)!))
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                print(String(cString: sqlite3_errmsg(scene.db)!))
            }
            
            sqlite3_finalize(stmt)
        }
        
        nextSceneQuery = "insert into history_scene_objects(id, x, y, z, red, green, blue, alpha) values(?, ?, ?, ?, ?, ?, ?, ?)"
        
        for i in 0..<prevHistoryIDs.count {
            var stmt: OpaquePointer?
            
            if sqlite3_prepare(scene.db, nextSceneQuery, -1, &stmt, nil) != SQLITE_OK {
                print(String(cString: sqlite3_errmsg(scene.db)!))
            }
            
            if sqlite3_bind_int(stmt, 1, Int32(prevHistorySceneObjects[i].id)) != SQLITE_OK {
                print(String(cString: sqlite3_errmsg(scene.db)!))
            }
            
            if sqlite3_bind_double(stmt, 2, Double(prevHistorySceneObjects[i].x)) != SQLITE_OK {
                print(String(cString: sqlite3_errmsg(scene.db)!))
            }
            
            if sqlite3_bind_double(stmt, 3, Double(prevHistorySceneObjects[i].y)) != SQLITE_OK {
                print(String(cString: sqlite3_errmsg(scene.db)!))
            }
            
            if sqlite3_bind_double(stmt, 4, Double(prevHistorySceneObjects[i].z)) != SQLITE_OK {
                print(String(cString: sqlite3_errmsg(scene.db)!))
            }
            
            if sqlite3_bind_double(stmt, 5, Double(prevHistorySceneObjects[i].red)) != SQLITE_OK {
                print(String(cString: sqlite3_errmsg(scene.db)!))
            }
            
            if sqlite3_bind_double(stmt, 6, Double(prevHistorySceneObjects[i].green)) != SQLITE_OK {
                print(String(cString: sqlite3_errmsg(scene.db)!))
            }
            
            if sqlite3_bind_double(stmt, 7, Double(prevHistorySceneObjects[i].blue)) != SQLITE_OK {
                print(String(cString: sqlite3_errmsg(scene.db)!))
            }
            
            if sqlite3_bind_double(stmt, 8, Double(prevHistorySceneObjects[i].alpha)) != SQLITE_OK {
                print(String(cString: sqlite3_errmsg(scene.db)!))
            }
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                print(String(cString: sqlite3_errmsg(scene.db)!))
            }
        }
        
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
    
    func toActionsHistory() {
        let history = ActionsHistoryController()
        history.mainController = mainController
        controller.navigationController?.pushViewController(history, animated: true)
    }
    
    func toTrash() {
        let trash = SceneTrashController()
        trash.mainController = mainController
        controller.navigationController?.pushViewController(trash, animated: true)
    }
    
    func trashAction() {
        RootViewController.scenes[RootViewController.currentScene].moveToTrash()
        
        RootViewController.scenes.remove(at: RootViewController.currentScene)
        RootViewController.currentScene = RootViewController.scenes.count - 1
        
        RootViewController.sceneControllers[0].currentScene = RootViewController.currentScene
        
        RootViewController.sceneControllers[0].contr.setVertexArrays(RootViewController.scenes[RootViewController.currentScene].bigVertices, bigLineVertices: RootViewController.scenes[RootViewController.currentScene].bigLineVertices, selectedVertices:RootViewController.scenes[RootViewController.currentScene].selectionVertices, gridLineVertices: Grid.bigLineVertices, axisLineVertices: Axis.bigLineVertices, bigIndices: RootViewController.scenes[RootViewController.currentScene].bigIndices, bigLineIndices: RootViewController.scenes[RootViewController.currentScene].bigLineIndices, gridLineIndices: Grid.bigLineIndices)
        
        RootViewController.sceneControllers[0].contr.translateCamera(RootViewController.scenes[RootViewController.currentScene].x, y: RootViewController.scenes[RootViewController.currentScene].y, z: RootViewController.scenes[RootViewController.currentScene].z)
        RootViewController.sceneControllers[0].contr.setAngle(RootViewController.scenes[RootViewController.currentScene].xAngle, y: RootViewController.scenes[RootViewController.currentScene].yAngle)
        RootViewController.sceneControllers[0].contr.loadModel(Int32(RootViewController.scenes[RootViewController.currentScene].indicesCount))
        mainController?.navigationItem.title = RootViewController.scenes[RootViewController.currentScene].name
        
        if let main = mainController {
            _ = controller.navigationController?.popToViewController(main, animated: true)
        } else {
            print("Nil controller")
        }
    }
    
    func trashScene() {
        if RootViewController.scenes.count > 1 {
            let alert = UIAlertController(title: "Confirm deletion", message: "Are you sure you want to move to trash scene \(RootViewController.scenes[RootViewController.currentScene].name ?? "")?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Move to trash", style: .destructive, handler: {(action: UIAlertAction!) in
                self.trashAction()
            }))
            //alert.view.tintColor = .black
            controller.present(alert, animated: true, completion: nil)
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
        scene.appendObjectWithoutUpdate(object: cube)
        
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
