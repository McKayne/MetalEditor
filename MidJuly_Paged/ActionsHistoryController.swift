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
    
    override func viewDidLoad() {
        //let applyButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(popToScene(sender:)))
        //navigationItem.rightBarButtonItem = applyButton
        navigationItem.title = "History"
        
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
            
            return 3
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
            cell.textLabel?.text = "123"
        }
        
        return cell
    }
}
