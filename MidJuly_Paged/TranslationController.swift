//
//  TranslationController.swift
//  MidJuly_Paged
//
//  Created by для интернета on 14.03.19.
//  Copyright © 2019 для интернета. All rights reserved.
//

import Foundation
import UIKit

class TranslationController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var mainController: RootViewController?
    
    let cubePropertiesTableView = UITableView()
    //var actionsDelegate:ActionsDelegate?
    
    let rgbPicker = UIPickerView(), rgbPickerCell = UITableViewCell()
    var redCurrent = 0, greenCurrent = 0, blueCurrent = 0
    
    let xPositionText = UITextField(), yPositionText = UITextField(), zPositionText = UITextField()
    let xRotationText = UITextField(), yRotationText = UITextField(), zRotationText = UITextField()
    let widthText = UITextField(), heightText = UITextField(), depthText = UITextField()
    
    convenience init(mainController: RootViewController?) {
        self.init(nibName: nil, bundle: nil)
        self.mainController = mainController
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 256
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            redCurrent = row
        case 1:
            greenCurrent = row
        case 2:
            blueCurrent = row
        default:
            print("Dummy")
        }
        
        print(redCurrent)
        print(greenCurrent)
        print(blueCurrent)
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: String(row), attributes: [NSForegroundColorAttributeName: UIColor.white])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 30.0
        case 1:
            return 30.0
        case 2:
            return 30.0
        default:
            return 100.0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 3
        case 2:
            return 3
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Translate at"
        case 1:
            return "Rotation"
        case 2:
            return "Dimensions"
        default:
            return "RGB Color"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            cell.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
            cell.textLabel?.textColor = .white
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "X = "
                cell.contentView.addSubview(xPositionText)
                RootViewController.performAutolayoutConstants(subview: xPositionText, view: cell.contentView, left: 100, right: -15, top: 0, bottom: 0)
            case 1:
                cell.textLabel?.text = "Y = "
                cell.contentView.addSubview(yPositionText)
                RootViewController.performAutolayoutConstants(subview: yPositionText, view: cell.contentView, left: 100, right: -15, top: 0, bottom: 0)
            default:
                cell.textLabel?.text = "Z = "
                cell.contentView.addSubview(zPositionText)
                RootViewController.performAutolayoutConstants(subview: zPositionText, view: cell.contentView, left: 100, right: -15, top: 0, bottom: 0)
            }
        case 1:
            cell.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
            cell.textLabel?.textColor = .white
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "X = "
                cell.contentView.addSubview(xRotationText)
                RootViewController.performAutolayoutConstants(subview: xRotationText, view: cell.contentView, left: 100, right: -15, top: 0, bottom: 0)
            case 1:
                cell.textLabel?.text = "Y = "
                cell.contentView.addSubview(yRotationText)
                RootViewController.performAutolayoutConstants(subview: yRotationText, view: cell.contentView, left: 100, right: -15, top: 0, bottom: 0)
            default:
                cell.textLabel?.text = "Z = "
                cell.contentView.addSubview(zRotationText)
                RootViewController.performAutolayoutConstants(subview: zRotationText, view: cell.contentView, left: 100, right: -15, top: 0, bottom: 0)
            }
        case 2:
            cell.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
            cell.textLabel?.textColor = .white
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Width = "
                cell.contentView.addSubview(widthText)
                RootViewController.performAutolayoutConstants(subview: widthText, view: cell.contentView, left: 100, right: -15, top: 0, bottom: 0)
            case 1:
                cell.textLabel?.text = "Height = "
                cell.contentView.addSubview(heightText)
                RootViewController.performAutolayoutConstants(subview: heightText, view: cell.contentView, left: 100, right: -15, top: 0, bottom: 0)
            default:
                cell.textLabel?.text = "Depth = "
                cell.contentView.addSubview(depthText)
                RootViewController.performAutolayoutConstants(subview: depthText, view: cell.contentView, left: 100, right: -15, top: 0, bottom: 0)
            }
        default:
            return rgbPickerCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.contentView.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
            header.textLabel?.textColor = .white
        }
    }
    
    override func viewDidLoad() {
        let applyButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(popToScene(sender:)))
        navigationItem.rightBarButtonItem = applyButton
        navigationItem.title = "Translate"
        
        // position
        xPositionText.borderStyle = .roundedRect
        yPositionText.borderStyle = .roundedRect
        zPositionText.borderStyle = .roundedRect
        
        xPositionText.textAlignment = .center
        yPositionText.textAlignment = .center
        zPositionText.textAlignment = .center
        
        xPositionText.backgroundColor = UIColor(red: CGFloat(165.0 / 255.0), green: CGFloat(165.0 / 255.0), blue: CGFloat(165.0 / 255.0), alpha: 1.0)
        yPositionText.backgroundColor = UIColor(red: CGFloat(165.0 / 255.0), green: CGFloat(165.0 / 255.0), blue: CGFloat(165.0 / 255.0), alpha: 1.0)
        zPositionText.backgroundColor = UIColor(red: CGFloat(165.0 / 255.0), green: CGFloat(165.0 / 255.0), blue: CGFloat(165.0 / 255.0), alpha: 1.0)
        
        xPositionText.text = "0.0"
        yPositionText.text = "0.0"
        zPositionText.text = "0.0"
        
        // rotation
        xRotationText.borderStyle = .roundedRect
        yRotationText.borderStyle = .roundedRect
        zRotationText.borderStyle = .roundedRect
        
        xRotationText.textAlignment = .center
        yRotationText.textAlignment = .center
        zRotationText.textAlignment = .center
        
        xRotationText.backgroundColor = UIColor(red: CGFloat(165.0 / 255.0), green: CGFloat(165.0 / 255.0), blue: CGFloat(165.0 / 255.0), alpha: 1.0)
        yRotationText.backgroundColor = UIColor(red: CGFloat(165.0 / 255.0), green: CGFloat(165.0 / 255.0), blue: CGFloat(165.0 / 255.0), alpha: 1.0)
        zRotationText.backgroundColor = UIColor(red: CGFloat(165.0 / 255.0), green: CGFloat(165.0 / 255.0), blue: CGFloat(165.0 / 255.0), alpha: 1.0)
        
        xRotationText.text = "0.0"
        yRotationText.text = "0.0"
        zRotationText.text = "0.0"
        
        // dimensions
        widthText.borderStyle = .roundedRect
        heightText.borderStyle = .roundedRect
        depthText.borderStyle = .roundedRect
        
        widthText.textAlignment = .center
        heightText.textAlignment = .center
        depthText.textAlignment = .center
        
        widthText.backgroundColor = UIColor(red: CGFloat(165.0 / 255.0), green: CGFloat(165.0 / 255.0), blue: CGFloat(165.0 / 255.0), alpha: 1.0)
        heightText.backgroundColor = UIColor(red: CGFloat(165.0 / 255.0), green: CGFloat(165.0 / 255.0), blue: CGFloat(165.0 / 255.0), alpha: 1.0)
        depthText.backgroundColor = UIColor(red: CGFloat(165.0 / 255.0), green: CGFloat(165.0 / 255.0), blue: CGFloat(165.0 / 255.0), alpha: 1.0)
        
        widthText.text = "0.0"
        heightText.text = "0.0"
        depthText.text = "0.0"
        
        rgbPicker.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
        rgbPicker.delegate = self
        rgbPicker.dataSource = self
        rgbPickerCell.contentView.addSubview(rgbPicker)
        RootViewController.performAutolayoutConstants(subview: rgbPicker, view: rgbPickerCell.contentView, left: 0, right: 0, top: 0, bottom: 0)
        
        cubePropertiesTableView.separatorStyle = .none
        cubePropertiesTableView.allowsSelection = false
        cubePropertiesTableView.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
        cubePropertiesTableView.tableFooterView = UIView(frame: .zero)
        //actionsDelegate = ActionsDelegate(controller: self)
        cubePropertiesTableView.delegate = self
        cubePropertiesTableView.dataSource = self
        view.addSubview(cubePropertiesTableView)
        RootViewController.performAutolayoutConstants(subview: cubePropertiesTableView, view: view, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    func popToScene(sender: UIBarButtonItem) {
        
        if let xPositionText = xPositionText.text, let yPositionText = yPositionText.text, let zPositionText = zPositionText.text {
            if let xPosition = Float(xPositionText), let yPosition = Float(yPositionText), let zPosition = Float(zPositionText) {
                
                var isAnyObjectSelected = false
                // TODO fix multiple selection
                for i in 0..<RootViewController.scenes[RootViewController.currentScene].objects.count {
                    if RootViewController.scenes[RootViewController.currentScene].objects[i].isSelected {
                        
                        RootViewController.scenes[RootViewController.currentScene].updateHistory(id: i, msg: "Translate object", type: .translation)
                        RootViewController.scenes[RootViewController.currentScene].appendHistoryObjectProperties(id: i, x: xPosition, y: yPosition, z: zPosition)
                        
                        isAnyObjectSelected = true
                        RootViewController.scenes[RootViewController.currentScene].objects[i].translateTo(xTranslate: xPosition, yTranslate: yPosition, zTranslate: zPosition)  //.removeObject(nth: i)
                        break
                    }
                }
                
                if !isAnyObjectSelected {
                    RootViewController.scenes[RootViewController.currentScene].removeAll(nth: 0)
                }
                
                RootViewController.scenes[RootViewController.currentScene].prepareForRender()
                RootViewController.sceneControllers[0].contr.loadModel(Int32(RootViewController.scenes[RootViewController.currentScene].indicesCount))
                
            }
        }
        
        //let xPosition = xPositionText.text
        
        
        RootViewController.scenes[RootViewController.currentScene].prepareForRender()
        RootViewController.sceneControllers[0].contr.loadModel(Int32(RootViewController.scenes[RootViewController.currentScene].indicesCount))
        
        if let main = mainController {
            _ = navigationController?.popToViewController(main, animated: true)
        } else {
            print("Nil controller")
        }
    }
}
