//
//  ConeController.swift
//  MidJuly_Paged
//
//  Created by для интернета on 15.11.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

class ConeController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var mainController: RootViewController?
    
    let conePropertiesTableView = UITableView()
    //var actionsDelegate:ActionsDelegate?
    
    let rgbPicker = UIPickerView(), rgbPickerCell = UITableViewCell()
    var redCurrent = 0, greenCurrent = 0, blueCurrent = 0
    
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 100.0
        default:
            return 30.0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "RGB Color"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            return rgbPickerCell
        default:
            cell.textLabel?.text = "Dummy"
            //return rgbPickerCell
        }
        /*switch indexPath.row {
         case 0:
         cell.textLabel?.text = "RGB Color"
         case 1:
         return rgbPickerCell
         default:
         cell.textLabel?.text = "Dummy"
         }*/
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.contentView.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
            header.textLabel?.textColor = .white
        }
    }
    
    // picker
    
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
    
    override func viewDidLoad() {
        let applyButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(popToScene(sender:)))
        navigationItem.rightBarButtonItem = applyButton
        navigationItem.title = "Cone"
        
        rgbPicker.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
        rgbPicker.delegate = self
        rgbPicker.dataSource = self
        rgbPickerCell.contentView.addSubview(rgbPicker)
        RootViewController.performAutolayoutConstants(subview: rgbPicker, view: rgbPickerCell.contentView, left: 0, right: 0, top: 0, bottom: 0)
        
        conePropertiesTableView.separatorStyle = .none
        conePropertiesTableView.allowsSelection = false
        conePropertiesTableView.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
        conePropertiesTableView.tableFooterView = UIView(frame: .zero)
        //actionsDelegate = ActionsDelegate(controller: self)
        conePropertiesTableView.delegate = self
        conePropertiesTableView.dataSource = self
        view.addSubview(conePropertiesTableView)
        RootViewController.performAutolayoutConstants(subview: conePropertiesTableView, view: view, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    func popToScene(sender: UIBarButtonItem) {
        
        let cone = Cone(x: -0.25, y: 0, z: -0.25, radius: 1, height: 2, segments: 72, rgb: (redCurrent, greenCurrent, blueCurrent))
        
        /*set.appendVertexWithCoords(xyz: (-0.5, 0, -0.5))
         set.appendVertexWithCoords(xyz: (0, 0, 0.5))
         set.appendVertexWithCoords(xyz: (0.5, 0, -0.5))
         set.appendVertexWithCoords(xyz: (0, 0, -1))*/
        
        
        //surface.shiftTo(xShift: 0, yShift: 0, zShift: 0.5)
        
        RootViewController.scenes[RootViewController.currentScene].appendObjectWithoutUpdate(object: cone)
        
        RootViewController.scenes[RootViewController.currentScene].prepareForRender()
        RootViewController.sceneControllers[0].contr.loadModel(Int32(RootViewController.scenes[RootViewController.currentScene].indicesCount))
        
        /*let surface = SurfaceOfRevolution(x: -2, y: 0, z: 2, width: 4, depth: 4, rgb: (255, 0, 255))
         //let mathSurface = MathSurface(x: -2, y: 0, z: 2, width: 8, depth: 5, rgb: (255, 0, 255))
         */
        
        if let main = mainController {
            _ = navigationController?.popToViewController(main, animated: true)
        } else {
            print("Nil controller")
        }
    }
}