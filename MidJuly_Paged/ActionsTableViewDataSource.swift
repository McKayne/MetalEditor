//
//  ActionsTableViewDataSource.swift
//  MidJuly_Paged
//
//  Created by для интернета on 14.09.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class ActionsTableViewDataSource: NSObject, UITableViewDataSource {
    
    var controller: DataViewController
    let xText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let yText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let zText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    
    init(controller: DataViewController) {
        self.controller = controller
        super.init()
        
        xText.borderStyle = .roundedRect
        yText.borderStyle = .roundedRect
        zText.borderStyle = .roundedRect
        
        xText.textAlignment = .center
        yText.textAlignment = .center
        zText.textAlignment = .center
        
        xText.text = "1.0"
        yText.text = "1.0"
        zText.text = "1.0"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch controller.context {
        case .initial:
            return 13
        case .scaling:
            return 3
        case .addition:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "actionCell")
        
        
        let frame = CGRect(x: 0, y: 0, width: 160, height: 50)
        let label = UILabel(frame: frame)
        label.textAlignment = .center
        label.tag = 1;
        
        switch indexPath.row {
        case 0:
            switch controller.context {
            case .initial:
                cell.textLabel!.text = "Undo or redo"
            case .scaling:
                cell.textLabel!.text = "Scale X to "
                cell.accessoryView = xText
            default:
                cell.textLabel!.text = "Cube"
            }
        case 1:
            if controller.context == .initial {
                cell.textLabel!.text = "New scene"
            } else {
                cell.textLabel!.text = "Scale Y to "
                cell.accessoryView = yText
            }
            switch controller.context {
            case .initial:
                cell.textLabel!.text = "New scene"
            case .scaling:
                cell.textLabel!.text = "Scale Y to "
                cell.accessoryView = yText
            default:
                cell.textLabel!.text = "Face"
            }
        case 2:
            if controller.context == .initial {
                cell.textLabel!.text = "Manage scenes"
            } else {
                cell.textLabel!.text = "Scale Z to "
                cell.accessoryView = zText
            }
        case 3:
            cell.textLabel!.text = "Add object"
        case 4:
            cell.textLabel!.text = "Translate"
        case 5:
            cell.textLabel!.text = "Rotate"
        case 6:
            cell.textLabel!.text = "Scale object"
        case 7:
            cell.textLabel!.text = "Mirror"
        case 8:
            cell.textLabel!.text = "Clone object"
        case 9:
            cell.textLabel!.text = "Remove last"
        case 10:
            cell.textLabel!.text = "Import or export"
        case 11:
            cell.textLabel!.text = "Textures library"
        case 12:
            cell.textLabel!.text = "About"
        default:
            cell.textLabel!.text = "Dummy"
        }
        
        return cell
    }
}
