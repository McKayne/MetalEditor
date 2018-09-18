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
        if controller.context == .initial {
            return 1
        } else {
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
            if controller.context == .initial {
                cell.textLabel!.text = "Scale object"
            } else {
                cell.textLabel!.text = "Scale X to "
                cell.accessoryView = xText
            }
        case 1:
            cell.textLabel!.text = "Scale Y to "
            
            
            
            cell.accessoryView = yText
        case 2:
            cell.textLabel!.text = "Scale Z to "
            cell.accessoryView = zText
        default:
            cell.textLabel!.text = "Dummy"
        }
        
        return cell
    }
}
