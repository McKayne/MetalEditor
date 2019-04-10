//
//  AdditionTableViewDataSource.swift
//  MidJuly_Paged
//
//  Created by для интернета on 23.10.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class AdditionTableViewDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    private let actionsList = ["Face", "Cube", "Cone", "Pyramid", "Cylinder", "Stairs", "Random surface", "Height map"]
    let controller: DataViewController
    
    init(controller: DataViewController) {
        self.controller = controller
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "actionCell")
        
        cell.textLabel?.text = actionsList[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Addition selected")
        
        controller.item.rightBarButtonItem = controller.applyButton
        
        switch actionsList[indexPath.row] {
        case "Face":
            print("Add Face")
            controller.additionContext = .face
        case "Cube":
            print("Add Cube")
            controller.additionContext = .cube
        case "Cone":
            print("Add Cone")
            controller.additionContext = .cone
        case "Pyramid":
            print("Add Pyramid")
            controller.additionContext = .pyramid
        case "Cylinder":
            print("Add Cylinder")
            controller.additionContext = .cylinder
        case "Stairs":
            print("Add Stairs")
            controller.additionContext = .stairs
        case "Random surface":
            print("Add surface")
        case "Height map":
            print("Add map")
        default:
            print("dummy")
        }
        
        controller.propertiesTableView.reloadData()
        controller.propertiesTableView.isHidden = false
    }
}
