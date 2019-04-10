//
//  ScenesListTableViewDataSource.swift
//  MidJuly_Paged
//
//  Created by для интернета on 19.10.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class ScenesListTableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {

    let controller: DataViewController
    
    init(controller: DataViewController) {
        self.controller = controller
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RootViewController.scenes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "actionCell")
        
        cell.textLabel?.text = RootViewController.scenes[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        controller.currentScene = indexPath.row
        controller.contr.setVertexArrays(RootViewController.scenes[controller.currentScene].bigVertices, bigLineVertices: RootViewController.scenes[controller.currentScene].bigLineVertices, selectedVertices:RootViewController.scenes[controller.currentScene].selectionVertices, gridLineVertices: Grid.bigLineVertices, axisLineVertices: Axis.bigLineVertices, bigIndices: RootViewController.scenes[controller.currentScene].bigIndices, bigLineIndices: RootViewController.scenes[controller.currentScene].bigLineIndices, gridLineIndices: Grid.bigLineIndices)
        controller.contr.translateCamera(RootViewController.scenes[controller.currentScene].x, y: RootViewController.scenes[controller.currentScene].y, z: RootViewController.scenes[controller.currentScene].z)
        controller.contr.setAngle(RootViewController.scenes[controller.currentScene].xAngle, y: RootViewController.scenes[controller.currentScene].yAngle)
        controller.contr.loadModel(Int32(RootViewController.scenes[controller.currentScene].indicesCount))
        controller.item.title = RootViewController.scenes[controller.currentScene].name
        
        controller.actionsButton.title = "Actions"
        tableView.isHidden = true
        
    }
}
