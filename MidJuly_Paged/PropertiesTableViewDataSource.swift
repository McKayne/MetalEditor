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
    
    // Position
    let xText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let yText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let zText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    
    // Dimensions
    let widthText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let heightText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let depthText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    
    // Translation
    let xTranslationText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let yTranslationText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let zTranslationText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    
    // Rotation
    let xAngleText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let yAngleText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let zAngleText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    
    // Color
    let redText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let greenText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    let blueText = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
    
    func clearTranslationParams() {
        xTranslationText.text = "0.0"
        yTranslationText.text = "0.0"
        zTranslationText.text = "0.0"
    }
    
    func clearRotationParams() {
        xAngleText.text = "0.0"
        yAngleText.text = "0.0"
        zAngleText.text = "0.0"
    }
    
    func clearColorParams() {
        redText.text = "255"
        greenText.text = "0"
        blueText.text = "0"
    }
    
    init(controller: DataViewController) {
        self.controller = controller
        super.init()
        
        xText.borderStyle = .roundedRect
        yText.borderStyle = .roundedRect
        zText.borderStyle = .roundedRect
        
        xText.textAlignment = .center
        yText.textAlignment = .center
        zText.textAlignment = .center
        
        xText.text = "-0.5"
        yText.text = "-0.5"
        zText.text = "-0.5"
        
        widthText.borderStyle = .roundedRect
        heightText.borderStyle = .roundedRect
        depthText.borderStyle = .roundedRect
        
        widthText.textAlignment = .center
        heightText.textAlignment = .center
        depthText.textAlignment = .center
        
        widthText.text = "1.0"
        heightText.text = "1.0"
        depthText.text = "1.0"
        
        // Translation
        xTranslationText.borderStyle = .roundedRect
        yTranslationText.borderStyle = .roundedRect
        zTranslationText.borderStyle = .roundedRect
        
        xTranslationText.textAlignment = .center
        yTranslationText.textAlignment = .center
        zTranslationText.textAlignment = .center
        
        clearTranslationParams()
        
        // Rotation
        xAngleText.borderStyle = .roundedRect
        yAngleText.borderStyle = .roundedRect
        zAngleText.borderStyle = .roundedRect
        
        xAngleText.textAlignment = .center
        yAngleText.textAlignment = .center
        zAngleText.textAlignment = .center
        
        clearRotationParams()
        
        redText.borderStyle = .roundedRect
        greenText.borderStyle = .roundedRect
        blueText.borderStyle = .roundedRect
        
        redText.textAlignment = .center
        greenText.textAlignment = .center
        blueText.textAlignment = .center
        
        clearColorParams()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch controller.context {
        case .initial:
            return 1
        case .addition:
            switch controller.additionContext {
            case .stairs:
                return 14
            default:
                return 16
            }
        case .translation:
            return 3
        case .rotation:
            return 3
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
            case .initial:
                cell.textLabel!.text = "Dummy"
            case .addition:
                cell.textLabel!.text = "Position"
            case .translation:
                cell.textLabel!.text = "Translate X to "
                cell.accessoryView = xTranslationText
            case .rotation:
                cell.textLabel!.text = "Rotate X to "
                cell.accessoryView = xAngleText
            case .scaling:
                cell.textLabel!.text = "Scale X to "
                cell.accessoryView = widthText
            }
        case 1:
            switch controller.context {
            case .initial:
                cell.textLabel!.text = "Dummy"
            case .addition:
                cell.textLabel!.text = "X = "
                cell.accessoryView = xText
            case .translation:
                cell.textLabel!.text = "Translate Y to "
                cell.accessoryView = yTranslationText
            case .rotation:
                cell.textLabel!.text = "Rotate Y to "
                cell.accessoryView = yAngleText
            case .scaling:
                cell.textLabel!.text = "Scale Y to "
                cell.accessoryView = heightText
            }
        case 2:
            switch controller.context {
            case .initial:
                cell.textLabel!.text = "Dummy"
            case .addition:
                cell.textLabel!.text = "Y = "
                cell.accessoryView = yText
            case .translation:
                cell.textLabel!.text = "Translate Z to "
                cell.accessoryView = zTranslationText
            case .rotation:
                cell.textLabel!.text = "Rotate Z to "
                cell.accessoryView = zAngleText
            case .scaling:
                cell.textLabel!.text = "Scale Z to "
                cell.accessoryView = depthText
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
            switch controller.additionContext {
            case .stairs:
                cell.textLabel!.text = "Stairs properties"
            default:
                cell.textLabel!.text = "Rotation"
            }
        case 9:
            switch controller.additionContext {
            case .stairs:
                cell.textLabel!.text = "Number of steps = "
                
                Stairs.numberOfSteps.borderStyle = .roundedRect
                //Stairs.numberOfSteps.text = "5"
                
                cell.accessoryView = Stairs.numberOfSteps
            default:
                cell.textLabel!.text = "X angle = "
                cell.accessoryView = xAngleText
            }
        case 10:
            switch controller.additionContext {
            case .stairs:
                cell.textLabel!.text = "Rotation"
            default:
                cell.textLabel!.text = "Y angle = "
                cell.accessoryView = yAngleText
            }
        case 11:
            switch controller.additionContext {
            case .stairs:
                cell.textLabel!.text = "X angle = "
                
                Stairs.xAngle.borderStyle = .roundedRect
                //Stairs.xAngle.text = "0.0"
                
                cell.accessoryView = Stairs.xAngle
            default:
                cell.textLabel!.text = "Z angle = "
                cell.accessoryView = zAngleText
            }
        case 12:
            switch controller.additionContext {
            case .stairs:
                cell.textLabel!.text = "Y angle = "
                
                Stairs.yAngle.borderStyle = .roundedRect
                //Stairs.yAngle.text = "0.0"
                
                cell.accessoryView = Stairs.yAngle
            default:
                cell.textLabel!.text = "Color"
            }
        case 13:
            switch controller.additionContext {
            case .stairs:
                cell.textLabel!.text = "Z angle = "
                
                Stairs.zAngle.borderStyle = .roundedRect
                //Stairs.zAngle.text = "0.0"
                
                cell.accessoryView = Stairs.zAngle
            default:
                cell.textLabel!.text = "Red = "
                cell.accessoryView = redText
            }
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
