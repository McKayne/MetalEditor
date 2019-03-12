//
//  SceneTrashController.swift
//  MidJuly_Paged
//
//  Created by для интернета on 12.03.19.
//  Copyright © 2019 для интернета. All rights reserved.
//

import Foundation
import UIKit

class SceneTrashController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var mainController: RootViewController?
    
    let sceneList = UITableView()
    
    var nameList: [String] = []
    var dbNameList: [String] = []
    
    override func viewDidLoad() {
        //let applyButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(popToScene(sender:)))
        //navigationItem.rightBarButtonItem = applyButton
        navigationItem.title = "Trash"
        
        nameList = []
        dbNameList = []
        let dictionary = UserDefaults.standard.dictionaryRepresentation()
        for pair in dictionary {
            if pair.key.hasPrefix("MetalEditor") && !pair.key.hasSuffix("Trash") {
                //"MetalEditor Trash \(name)"
                if UserDefaults.standard.object(forKey: "MetalEditor \(pair.value) Trash") != nil {
                    let scene = Scene(name: String(describing: pair.value), fromDatabase: true)
                    //scene.prepareForRender()
                    
                    //RootViewController.scenes.append(scene)
                    
                    nameList.append(scene.name)
                    dbNameList.append(String(describing: pair.value))
                }
            }
        }
        
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
        return nameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
        
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = nameList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showMiscActions(nth: indexPath.row)
    }
    
    func showMiscActions(nth: Int) {
        let alert = UIAlertController(title: nameList[nth], message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Preview", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Restore scene", style: .default, handler: {_ in
            self.restoreAction(nth: nth)
        }))
        alert.addAction(UIAlertAction(title: "Remove scene", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "Empty trash", style: .destructive, handler: {_ in
            let alert = UIAlertController(title: "Confirm deletion", message: "Are you sure you want to empty trash? This cannot be undone", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Empty trash", style: .destructive, handler: {(action: UIAlertAction!) in
                self.emptyTrash()
            }))
            //alert.view.tintColor = .black
            self.present(alert, animated: true, completion: nil)
        }))
        alert.view.tintColor = UIColor(red: 141.0 / 255.0, green: 143.0 / 255.0, blue: 140.0 / 255.0, alpha: 1)
        
        if UI_USER_INTERFACE_IDIOM() == .phone {
            present(alert, animated: true, completion: nil)
        } else {
            if let popoverPresentationController = alert.popoverPresentationController {
                //self.currentPopover = popoverPresentationController
                popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                popoverPresentationController.sourceView = view
                popoverPresentationController.sourceRect = CGRect(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2, width: 1, height: 1)
            }
            present(alert, animated: true, completion: nil)
        }
    }
    
    func emptyTrash() {
        for i in 0..<nameList.count {
            UserDefaults.standard.removeObject(forKey: "MetalEditor \(dbNameList[i])")
            UserDefaults.standard.removeObject(forKey: "MetalEditor \(dbNameList[i]) Trash")
        
            let scene = Scene(name: nameList[i], fromDatabase: true)
            scene.deleteDatabase()
            
            
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    func restoreAction(nth: Int) {
        UserDefaults.standard.removeObject(forKey: "MetalEditor \(dbNameList[nth]) Trash")
        
        let scene = Scene(name: nameList[nth], fromDatabase: true)
        scene.prepareForRender()
        print(scene.name)
        
        RootViewController.scenes.append(scene)
        
        RootViewController.currentScene = RootViewController.scenes.count - 1
        
        RootViewController.sceneControllers[0].currentScene = RootViewController.currentScene
        
        RootViewController.sceneControllers[0].contr.setVertexArrays(RootViewController.scenes[RootViewController.currentScene].bigVertices, bigLineVertices: RootViewController.scenes[RootViewController.currentScene].bigLineVertices, selectedVertices:RootViewController.scenes[RootViewController.currentScene].selectionVertices, gridLineVertices: Grid.bigLineVertices, axisLineVertices: Axis.bigLineVertices, bigIndices: RootViewController.scenes[RootViewController.currentScene].bigIndices, bigLineIndices: RootViewController.scenes[RootViewController.currentScene].bigLineIndices, gridLineIndices: Grid.bigLineIndices)
        
        RootViewController.sceneControllers[0].contr.translateCamera(RootViewController.scenes[RootViewController.currentScene].x, y: RootViewController.scenes[RootViewController.currentScene].y, z: RootViewController.scenes[RootViewController.currentScene].z)
        RootViewController.sceneControllers[0].contr.setAngle(RootViewController.scenes[RootViewController.currentScene].xAngle, y: RootViewController.scenes[RootViewController.currentScene].yAngle)
        RootViewController.sceneControllers[0].contr.loadModel(Int32(RootViewController.scenes[RootViewController.currentScene].indicesCount))
        mainController?.navigationItem.title = RootViewController.scenes[RootViewController.currentScene].name
        
        if let main = mainController {
            _ = main.navigationController?.popToViewController(main, animated: true)
        }
    }
}
