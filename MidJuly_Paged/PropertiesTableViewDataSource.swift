//
//  PropertiesTableViewDataSource.swift
//  MidJuly_Paged
//
//  Created by для интернета on 18.09.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class PropertiesTableViewDataSource: NSObject, UITableViewDataSource {
    
    var controller: DataViewController
    let xText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let yText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let zText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let widthText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let heightText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let depthText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let xAngleText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let yAngleText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let zAngleText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let redText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let greenText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let blueText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    
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
        
        widthText.borderStyle = .roundedRect
        heightText.borderStyle = .roundedRect
        depthText.borderStyle = .roundedRect
        
        widthText.textAlignment = .center
        heightText.textAlignment = .center
        depthText.textAlignment = .center
        
        widthText.text = "1.0"
        heightText.text = "1.0"
        depthText.text = "1.0"
        
        xAngleText.borderStyle = .roundedRect
        yAngleText.borderStyle = .roundedRect
        zAngleText.borderStyle = .roundedRect
        
        xAngleText.textAlignment = .center
        yAngleText.textAlignment = .center
        zAngleText.textAlignment = .center
        
        xAngleText.text = "0.0"
        yAngleText.text = "0.0"
        zAngleText.text = "0.0"
        
        redText.borderStyle = .roundedRect
        greenText.borderStyle = .roundedRect
        blueText.borderStyle = .roundedRect
        
        redText.textAlignment = .center
        greenText.textAlignment = .center
        blueText.textAlignment = .center
        
        redText.text = "255"
        greenText.text = "0"
        blueText.text = "0"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch controller.context {
        case .initial:
            return 1
        case .scaling:
            return 3
        case .addition:
            return 16
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
            if controller.context == .scaling {
                cell.textLabel!.text = "Scale X to "
                cell.accessoryView = xText
            } else {
                cell.textLabel!.text = "Position"
            }
        case 1:
            if controller.context == .scaling {
                cell.textLabel!.text = "Scale Y to "
                cell.accessoryView = yText
            } else {
                cell.textLabel!.text = "X = "
                cell.accessoryView = xText
            }
        case 2:
            if controller.context == .scaling {
                cell.textLabel!.text = "Scale Z to "
                cell.accessoryView = zText
            } else {
                cell.textLabel!.text = "Y = "
                cell.accessoryView = yText
            }
        case 3:
            cell.textLabel!.text = "Z = "
            cell.accessoryView = zText
        case 4:
            cell.textLabel!.text = "Dimensions"
        case 5:
            cell.textLabel!.text = "Width = "
            cell.accessoryView = widthText
        case 6:
            cell.textLabel!.text = "Height = "
            cell.accessoryView = heightText
        case 7:
            cell.textLabel!.text = "Depth = "
            cell.accessoryView = depthText
        case 8:
            cell.textLabel!.text = "Rotation"
        case 9:
            cell.textLabel!.text = "X angle = "
            cell.accessoryView = xAngleText
        case 10:
            cell.textLabel!.text = "Y angle = "
            cell.accessoryView = yAngleText
        case 11:
            cell.textLabel!.text = "Z angle = "
            cell.accessoryView = zAngleText
        case 12:
            cell.textLabel!.text = "Color"
        case 13:
            cell.textLabel!.text = "Red = "
            cell.accessoryView = redText
        case 14:
            cell.textLabel!.text = "Green = "
            cell.accessoryView = greenText
        case 15:
            cell.textLabel!.text = "Blue = "
            cell.accessoryView = blueText
        default:
            cell.textLabel!.text = "Dummy"
        }
        
        return cell
    }
}
