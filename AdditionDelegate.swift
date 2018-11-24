//
//  AdditionDelegate.swift
//  MidJuly_Paged
//
//  Created by для интернета on 31.10.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import UIKit

class AdditionDelegate: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var mainController: RootViewController?
    let controller: AdditionController
    
    private let actionsList = [["Plane", "Cube", "Cone", "Pyramid", "Cylinder", "Pipe", "Sphere", "Hemisphere", "Capsule", "Torus", "Teapot", "Diamond", "Roof", "Gear"],
                               ["Bent Pipe", "Stairs", "Ladder", "Chessboard", "Vertex Set"],
                               ["Spline", "Bezier Curve", "NURBS CV-Curve"],
                               ["Random Surface", "Height Map", "Surface of Revolution", "Two-Dimensional Spline", "Bezier Surface", "NURBS Surface", "Math Function Surface"],
                               ["Freeform Trim", "Hyperplane"]]
    private let sectionsList = ["Standard Primitives", "Advanced Primitives", "Curves", "Surfaces"]
    
    init(mainController: RootViewController?, controller: AdditionController) {
        self.mainController = mainController
        self.controller = controller
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionsList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return actionsList[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionsList[section]
    }
    
    /*func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.contentView.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
            header.textLabel?.textColor = .white
        }
    }*/
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor(red: 114.0 / 255.0, green: 114.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
        
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = actionsList[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var objectController: UIViewController?
        
        switch actionsList[indexPath.section][indexPath.row] {
        case "Plane":
            objectController = PlaneController(mainController: mainController)
        case "Cube":
            objectController = CubeController(mainController: mainController)
        case "Cone":
            objectController = ConeController(mainController: mainController)
        case "Pyramid":
            objectController = PyramidController(mainController: mainController)
        case "Cylinder":
            objectController = CylinderController(mainController: mainController)
        case "Pipe":
            objectController = PipeController(mainController: mainController)
        case "Bent Pipe":
            objectController = CurvedPipeController(mainController: mainController)
        case "Sphere":
            objectController = SphereController(mainController: mainController)
        case "Hemisphere":
            objectController = HemisphereController(mainController: mainController)
        case "Capsule":
            objectController = CapsuleController(mainController: mainController)
        case "Torus":
            objectController = TorusController(mainController: mainController)
        case "Diamond":
            objectController = DiamondController(mainController: mainController)
        case "Roof":
            objectController = RoofController(mainController: mainController)
        case "Stairs":
            objectController = StairsController(mainController: mainController)
        case "Ladder":
            objectController = LadderController(mainController: mainController)
        case "Gear":
            objectController = GearController(mainController: mainController)
        case "Chessboard":
            objectController = ChessboardController(mainController: mainController)
        case "Vertex Set":
            objectController = VertexSetController(mainController: mainController)
        case "Spline":
            objectController = SplineController(mainController: mainController)
        case "Bezier Curve":
            objectController = BezierCurveController(mainController: mainController)
        case "NURBS CV-Curve":
            objectController = NURBSCurveController(mainController: mainController)
        case "Random Surface":
            objectController = SurfaceController(mainController: mainController)
        case "Height Map":
            objectController = HeightMapController(mainController: mainController)
        case "Surface of Revolution":
            objectController = SurfaceOfRevolutionController(mainController: mainController)
        case "Two-Dimensional Spline":
            objectController = Spline2DController(mainController: mainController)
        case "Bezier Surface":
            objectController = BezierSurfaceController(mainController: mainController)
        case "NURBS Surface":
            objectController = NURBSSurfaceController(mainController: mainController)
        case "Math Function Surface":
            objectController = MathSurfaceController(mainController: mainController)
        default:
            print("Dummy")
        }
        
        if let obj = objectController {
            controller.navigationController?.pushViewController(obj, animated: true)
        }
    }
}
