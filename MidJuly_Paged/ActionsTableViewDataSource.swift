//
//  ActionsTableViewDataSource.swift
//  MidJuly_Paged
//
//  Created by для интернета on 14.09.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class ActionsTableViewDataSource: NSObject, UITableViewDataSource {
    
    private let actionsList = ["Undo or redo", "New scene", "Switch scene", "Duplicate scene", "Delete scene", "Add object", "Translate", "Rotate", "Scale object", "Mirror", "Copy objects", "Paste objects", "Attach", "Remove", "Import or export", "Textures library", "About"]
    
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
        case .initial, .addition:
            return actionsList.count
        case .translation:
            return 3
        case .rotation:
            return 5
        case .scaling:
            return 3
        
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
            case .initial, .addition:
                cell.textLabel!.text = actionsList[indexPath.row]
            case .scaling:
                cell.textLabel!.text = "Scale X to "
                cell.accessoryView = xText
            default:
                cell.textLabel!.text = "Dummy"
            }
        case 1:
            switch controller.context {
            case .initial, .addition:
                cell.textLabel!.text = actionsList[indexPath.row]
            case .scaling:
                cell.textLabel!.text = "Scale Y to "
                cell.accessoryView = yText
            default:
                cell.textLabel!.text = "Dummy"
            }
        case 2:
            switch controller.context {
            case .initial, .addition:
                cell.textLabel!.text = actionsList[indexPath.row]
            case .scaling:
                cell.textLabel!.text = "Scale Z to "
                cell.accessoryView = zText
            default:
                cell.textLabel!.text = "Dummy"
            }
        case 3:
            switch controller.context {
            case .initial, .addition:
                cell.textLabel!.text = actionsList[indexPath.row]
            default:
                cell.textLabel!.text = "Dummy"
            }
        case 4:
            switch controller.context {
            case .initial, .addition:
                cell.textLabel!.text = actionsList[indexPath.row]
            default:
                cell.textLabel!.text = "Dummy"
            }
        case 5:
            switch controller.context {
            case .initial, .addition:
                cell.textLabel!.text = actionsList[indexPath.row]
            default:
                cell.textLabel!.text = "Dummy"
            }
        case 6...12:
            cell.textLabel!.text = actionsList[indexPath.row]
        default:
            cell.textLabel!.text = "Dummy"
        }
        
        return cell
    }
}
