//
//  AdditionConroller.swift
//  MidJuly_Paged
//
//  Created by для интернета on 31.10.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import UIKit

class AdditionController: UIViewController {
    
    var mainController: RootViewController?
    
    let additionTableView = UITableView()
    var additionDelegate:AdditionDelegate?
    
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
    
    override func viewDidLoad() {
        let exportButton = UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
        navigationItem.rightBarButtonItem = exportButton
        navigationItem.title = "Add Object"
        
        additionTableView.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
        additionTableView.tableFooterView = UIView(frame: .zero)
        additionDelegate = AdditionDelegate(mainController: mainController, controller: self)
        additionTableView.delegate = additionDelegate
        additionTableView.dataSource = additionDelegate
        view.addSubview(additionTableView)
        RootViewController.performAutolayoutConstants(subview: additionTableView, view: view, left: 0, right: 0, top: 0, bottom: 0)
    }
}
