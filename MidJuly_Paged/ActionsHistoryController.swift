//
//  ActionsHistoryController.swift
//  MidJuly_Paged
//
//  Created by для интернета on 12.03.19.
//  Copyright © 2019 для интернета. All rights reserved.
//

import Foundation
import UIKit

class ActionsHistoryController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var mainController: RootViewController?
    
    let sceneList = UITableView()
    
    var actionsList: [String] = []
    var objectIDs: [Int] = []
    
    override func viewDidLoad() {
        //let applyButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(popToScene(sender:)))
        //navigationItem.rightBarButtonItem = applyButton
        navigationItem.title = "History"
        
        objectIDs = []
        actionsList = []
        
        // create or open db
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(RootViewController.scenes[RootViewController.currentScene].name ?? "").sqlite")
        
        var db: OpaquePointer?
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        //creating a statement
        var stmt: OpaquePointer?
        
        //this is our select query
        let queryString = "select * from actions_history"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing select: \(errmsg)")
            sqlite3_finalize(stmt)
        }
        
        while sqlite3_step(stmt) == SQLITE_ROW {
            objectIDs.append(Int(sqlite3_column_int(stmt, 0)))
            actionsList.append(String(cString: sqlite3_column_text(stmt, 1)))
        }
        
        sqlite3_finalize(stmt)
        
        objectIDs.reverse()
        actionsList.reverse()
        
        sceneList.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
        sceneList.tableFooterView = UIView(frame: .zero)
        //actionsDelegate = ActionsDelegate(controller: self)
        sceneList.delegate = self
        sceneList.dataSource = self
        view.addSubview(sceneList)
        RootViewController.performAutolayoutConstants(subview: sceneList, view: view, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return actionsList.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Edit"
        } else {
            return "Undo to action"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
        cell.textLabel?.textColor = .white
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "Undo last action"
            } else {
                cell.textLabel?.text = "Redo last action"
            }
        } else {
            
            if let value = UserDefaults.standard.value(forKey: "NthAction \(RootViewController.scenes[RootViewController.currentScene].name ?? "")") {
                
                let str = String(describing: value)
                if let nth = Int(str) {
                    if nth == indexPath.row {
                        cell.accessoryType = .checkmark
                    }
                }
            }
            
            cell.textLabel?.text = actionsList[indexPath.row]
            
            cell.tintColor = .white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var name = "NthAction \(RootViewController.scenes[RootViewController.currentScene].name ?? "")"
        UserDefaults.standard.set(String(indexPath.row + 1), forKey: name)
        
        name = "NthAction Undo \(RootViewController.scenes[RootViewController.currentScene].name ?? "")"
        UserDefaults.standard.set(String(indexPath.row + 1), forKey: name)
        
        print(objectIDs[indexPath.row])
        
        RootViewController.scenes[RootViewController.currentScene].objects.remove(at: objectIDs[indexPath.row])
        RootViewController.scenes[RootViewController.currentScene].updateDatabase()
        RootViewController.scenes[RootViewController.currentScene].prepareForRender()
        
        RootViewController.sceneControllers[0].contr.setVertexArrays(RootViewController.scenes[RootViewController.currentScene].bigVertices, bigLineVertices: RootViewController.scenes[RootViewController.currentScene].bigLineVertices, selectedVertices:RootViewController.scenes[RootViewController.currentScene].selectionVertices, gridLineVertices: Grid.bigLineVertices, axisLineVertices: Axis.bigLineVertices, bigIndices: RootViewController.scenes[RootViewController.currentScene].bigIndices, bigLineIndices: RootViewController.scenes[RootViewController.currentScene].bigLineIndices, gridLineIndices: Grid.bigLineIndices)
        
        RootViewController.sceneControllers[0].contr.translateCamera(RootViewController.scenes[RootViewController.currentScene].x, y: RootViewController.scenes[RootViewController.currentScene].y, z: RootViewController.scenes[RootViewController.currentScene].z)
        RootViewController.sceneControllers[0].contr.setAngle(RootViewController.scenes[RootViewController.currentScene].xAngle, y: RootViewController.scenes[RootViewController.currentScene].yAngle)
        RootViewController.sceneControllers[0].contr.loadModel(Int32(RootViewController.scenes[RootViewController.currentScene].indicesCount))
        
        if let main = mainController {
            _ = main.navigationController?.popToViewController(main, animated: true)
        }
    }
}
