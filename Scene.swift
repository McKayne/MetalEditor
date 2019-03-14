//
//  Scene.swift
//  MidJuly_Paged
//
//  Created by для интернета on 18.09.18.
//  Copyright © 2018 для интернета. All rights reserved.
//

import Foundation

@objc class Scene: NSObject {
    
    var multipleSelection = true
    
    var x: Float = 0.0, y: Float = 0.0, z: Float = 0.0
    var xAngle: Float = 0.0, yAngle: Float = 0.0
    
    var name: String!
    var objects: [SceneObject] = []
    
    var bigVertices = UnsafeMutablePointer<Vertex>.allocate(capacity: 100000)
    var bigLineVertices = UnsafeMutablePointer<Vertex>.allocate(capacity: 100000)
    
    var bigIndices = UnsafeMutablePointer<UInt16>.allocate(capacity: 100000)
    var bigLineIndices = UnsafeMutablePointer<UInt16>.allocate(capacity: 100000)
    
    var selectionVertices = UnsafeMutablePointer<Vertex>.allocate(capacity: 100000)
    
    var indicesCount: Int = 0
    
    var db: OpaquePointer?
    
    init(name: String, fromDatabase: Bool) {
        super.init()
        
        // create or open db
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(name).sqlite")
        
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("error opening database")
        }
        
        self.name = name
        if !fromDatabase {
            UserDefaults.standard.set("\(name)", forKey: "MetalEditor \(name)")
            createDatabase()
            
            createHistoryDatabase()
            UserDefaults.standard.set("0", forKey: "NthAction \(name)")
        } else {
            readDatabase()
            print(x)
            print(y)
            print(z)
            print(xAngle)
            print(yAngle)
        }
    }
    
    func moveToTrash() {
        UserDefaults.standard.set("true", forKey: "MetalEditor \(name ?? "") Trash")
    }
    
    func createHistoryDatabase() {
        // create tables
        if sqlite3_exec(db, "CREATE TABLE actions_history(id integer, name text, type text)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        if sqlite3_exec(db, "CREATE TABLE history_scene_objects(id integer, x real, y real, z real, red real, green real, blue real, alpha real)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    func createDatabase() {
        // create tables
        if sqlite3_exec(db, "CREATE TABLE camera_information(number_of_objects integer, x real, y real, z real, x_angle real, y_angle real)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        if sqlite3_exec(db, "CREATE TABLE scene_objects(nth integer, x real, y real, z real, red real, green real, blue real, alpha real)", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        // default camera params
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        var queryString = "INSERT INTO camera_information(number_of_objects, x, y, z, x_angle, y_angle) VALUES (?, ?, ?, ?, ?, ?)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //binding the parameters
        if sqlite3_bind_int(stmt, 1, Int32(objects.count)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_double(stmt, 2, Double(x)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_double(stmt, 3, Double(y)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_double(stmt, 4, Double(z)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_double(stmt, 5, Double(xAngle)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_double(stmt, 6, Double(yAngle)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
    }
    
    func updateDatabase() {
        // trunc
        if sqlite3_exec(db, "delete from scene_objects", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        
        // update camera params
        //creating a statement
        var stmt: OpaquePointer?
        
        //the insert query
        var queryString = "update camera_information set number_of_objects = ?, x = ?, y = ?, z = ?, x_angle = ?, y_angle = ?"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //binding the parameters
        if sqlite3_bind_int(stmt, 1, Int32(objects.count)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_double(stmt, 2, Double(x)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_double(stmt, 3, Double(y)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_double(stmt, 4, Double(z)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_double(stmt, 5, Double(xAngle)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        if sqlite3_bind_double(stmt, 6, Double(yAngle)) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            return
        }
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        for i in 0..<objects.count {
            
            for j in 0..<objects[i].vertices.count {
                
                //the insert query
                queryString = "insert into scene_objects(nth, x, y, z, red, green, blue, alpha) values(?, ?, ?, ?, ?, ?, ?, ?)"
                
                //preparing the query
                if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("error preparing insert: \(errmsg)")
                    return
                }
                
                //binding the parameters
                if sqlite3_bind_int(stmt, 1, Int32(i)) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name: \(errmsg)")
                    return
                }
                if sqlite3_bind_double(stmt, 2, Double(objects[i].vertices[j].position.x)) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name: \(errmsg)")
                    return
                }
                if sqlite3_bind_double(stmt, 3, Double(objects[i].vertices[j].position.y)) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name: \(errmsg)")
                    return
                }
                if sqlite3_bind_double(stmt, 4, Double(objects[i].vertices[j].position.z)) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name: \(errmsg)")
                    return
                }
                if sqlite3_bind_double(stmt, 5, Double(objects[i].vertices[j].customColor.x)) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name: \(errmsg)")
                    return
                }
                if sqlite3_bind_double(stmt, 6, Double(objects[i].vertices[j].customColor.y)) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name: \(errmsg)")
                    return
                }
                if sqlite3_bind_double(stmt, 7, Double(objects[i].vertices[j].customColor.z)) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name: \(errmsg)")
                    return
                }
                if sqlite3_bind_double(stmt, 8, Double(objects[i].vertices[j].customColor.w)) != SQLITE_OK{
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure binding name: \(errmsg)")
                    return
                }
                
                //executing the query to insert values
                if sqlite3_step(stmt) != SQLITE_DONE {
                    let errmsg = String(cString: sqlite3_errmsg(db)!)
                    print("failure inserting hero: \(errmsg)")
                    return
                }
            }
        }
    }
    
    func readDatabase() {
        // update camera params
        //creating a statement
        var stmt: OpaquePointer?
        
        //this is our select query
        var queryString = "SELECT * FROM camera_information"
        
        //statement pointer
        //stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        var numberOfObjects: Int = 0
        //traversing through all the records
        while(sqlite3_step(stmt) == SQLITE_ROW){
            numberOfObjects = Int(sqlite3_column_int(stmt, 0))
            let x = sqlite3_column_double(stmt, 1)
            let y = sqlite3_column_double(stmt, 2)
            let z = sqlite3_column_double(stmt, 3)
            
            let xAngle = sqlite3_column_double(stmt, 4)
            let yAngle = sqlite3_column_double(stmt, 5)
            
            
            
            self.x = Float(x)
            self.y = Float(y)
            self.z = Float(z)
            
            self.xAngle = Float(xAngle)
            self.yAngle = Float(yAngle)
            //print(Int(powerrank))
        }
        
        for i in 0..<numberOfObjects {
            objects.append(SceneObject())
        }
        queryString = "SELECT * FROM scene_objects"
        
        //statement pointer
        //stmt:OpaquePointer?
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        //traversing through all the records
        var nth: Int = 0
        while(sqlite3_step(stmt) == SQLITE_ROW){
            nth = Int(sqlite3_column_int(stmt, 0))
            
            let x = Float(sqlite3_column_double(stmt, 1))
            let y = Float(sqlite3_column_double(stmt, 2))
            let z = Float(sqlite3_column_double(stmt, 3))
            
            let red = Float(sqlite3_column_double(stmt, 4))
            let green = Float(sqlite3_column_double(stmt, 5))
            let blue = Float(sqlite3_column_double(stmt, 6))
            let alpha = Float(sqlite3_column_double(stmt, 7))
            
            //print(nth)
            
            //print(x)
            //print(y)
            //print(z)
            
            //print(red)
            //print(green)
            //print(blue)
            //print(alpha)
            
            let position = customFloat4(x: x, y: y, z: z, w: 1.0)
            let color = customFloat4(x: red, y: green, z: blue, w: alpha)
            let normal = customFloat4(x: 0, y: 0, z: 0, w: 0)
            let lineColor = customFloat4(x: 0, y: 0, z: 0, w: 1.0)
            
            let vertex = Vertex(position: position, normal: normal, customColor: color, texCoord: normal)
            let lineVertex = Vertex(position: position, normal: normal, customColor: lineColor, texCoord: normal)
            
            objects[nth].vertices.append(vertex)
            objects[nth].lineVertices.append(lineVertex)
        }
        
        // drop table
        /*if sqlite3_exec(db, "drop table camera_information", nil, nil, nil) != SQLITE_OK {
         let errmsg = String(cString: sqlite3_errmsg(db)!)
         print("error creating table: \(errmsg)")
         }*/
        
    }
    
    @objc func selectObjectWithColor(rgb: UnsafeMutablePointer<Int32>) {
        var nth = 0
        
        sel: for i in 0..<objects.count {
            let object = objects[i]
            
            for _ in 0..<object.vertices.count {
                if selectionVertices[nth].customColor.x == Float(rgb[0]) / 255.0 {
                    print("\(i) Selected")
                    
                    if !objects[i].isSelected {
                        objects[i].isSelected = true
                        
                        if !multipleSelection {
                            for j in 0..<objects.count {
                                if j != i {
                                    objects[j].isSelected = false
                                }
                            }
                        }
                    } else {
                        objects[i].isSelected = false
                        
                        if !multipleSelection {
                            for j in 0..<objects.count {
                                if j != i {
                                    objects[j].isSelected = false
                                }
                            }
                        }
                    }
                    
                    prepareForRender()
                    break sel
                }
                
                nth += 1
            }
            
        }
        
    }
    
    func deleteDatabase() {
        // create table
        if sqlite3_exec(db, "drop table camera_information", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
        if sqlite3_exec(db, "drop table scene_objects", nil, nil, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error creating table: \(errmsg)")
        }
    }
    
    func prepareForRender() {
        indicesCount = 0
        
        for i in 0..<objects.count {
            let object = objects[i]
            
            for j in 0..<object.vertices.count {
                bigVertices[indicesCount] = object.vertices[j]
                if object.isSelected {
                    
                    bigVertices[indicesCount].customColor = customFloat4(x: 1.0, y: 0.5, z: 0.0, w: 1.0)
                }
                
                selectionVertices[indicesCount] = object.vertices[j]
                selectionVertices[indicesCount].customColor = customFloat4(x: Float(i) / 255.0, y: Float(i) / 255.0, z: Float(i) / 255.0, w: 1.0)
                
                bigLineVertices[indicesCount] = object.lineVertices[j]
                bigIndices[indicesCount] = UInt16(indicesCount)
                
                indicesCount += 1
            }
            
        }
        
        for i in 0..<(indicesCount / 3) {
            bigLineIndices[i * 6] = UInt16(i * 3)
            bigLineIndices[i * 6 + 1] = UInt16(i * 3 + 1)
            
            bigLineIndices[i * 6 + 2] = UInt16(i * 3 + 1)
            bigLineIndices[i * 6 + 3] = UInt16(i * 3 + 2)
            
            bigLineIndices[i * 6 + 4] = UInt16(i * 3 + 2)
            bigLineIndices[i * 6 + 5] = UInt16(i * 3)
        }
    }
    
    func appendObjectWithoutUpdate(object: SceneObject) {
        objects.append(object)
        //updateDatabase()
    }
    
    func appendHistoryObject(id: Int, object: SceneObject) {
        for j in 0..<object.vertices.count {
            
            //creating a statement
            var stmt: OpaquePointer?
            
            //the insert query
            let queryString = "insert into history_scene_objects(id, x, y, z, red, green, blue, alpha) values(?, ?, ?, ?, ?, ?, ?, ?)"
            
            //preparing the query
            if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error preparing insert: \(errmsg)")
                return
            }
            
            //binding the parameters
            if sqlite3_bind_int(stmt, 1, Int32(id)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_double(stmt, 2, Double(object.vertices[j].position.x)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_double(stmt, 3, Double(object.vertices[j].position.y)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_double(stmt, 4, Double(object.vertices[j].position.z)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_double(stmt, 5, Double(object.vertices[j].customColor.x)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_double(stmt, 6, Double(object.vertices[j].customColor.y)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_double(stmt, 7, Double(object.vertices[j].customColor.z)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            if sqlite3_bind_double(stmt, 8, Double(object.vertices[j].customColor.w)) != SQLITE_OK{
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure binding name: \(errmsg)")
                return
            }
            
            //executing the query to insert values
            if sqlite3_step(stmt) != SQLITE_DONE {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("failure inserting hero: \(errmsg)")
                return
            }
            
            sqlite3_finalize(stmt)
        }
    }
    
    func appendObject(object: SceneObject) {
        objects.append(object)
        updateDatabase()
        
        var stmt: OpaquePointer?
        
        let queryString = "select nth from scene_objects"
        
        sqlite3_prepare(db, queryString, -1, &stmt, nil)
        
        var id = 0
        while sqlite3_step(stmt) == SQLITE_ROW {
            id = Int(sqlite3_column_int(stmt, 0))
        }
        print("Scene ID \(id)")
        
        sqlite3_finalize(stmt)
        
        updateHistory(id: id, msg: "Add \(object.name ?? "")", type: .addition)
        UserDefaults.standard.set("0", forKey: "NthAction \(name ?? "")")
        
        appendHistoryObject(id: id, object: object)
    }
    
    func appendObject(object: SceneObject, skipActionHistory: Bool) {
        objects.append(object)
        if !skipActionHistory {
            updateHistory(id: 0, msg: "Add \(object.name ?? "")", type: .addition)
        }
        updateDatabase()
    }
    
    func updateHistory(id: Int, msg: String, type: ActionType) {
        
        
        let value = UserDefaults.standard.value(forKey: "NthAction Undo \(name ?? "")")
        if let value = value {
            let str = String(describing: value)
            let n = Int(str)!
            print("UNDO \(n)")
            
            if sqlite3_exec(db, "delete from history_scene_objects where id IN (SELECT id from actions_history order by id desc limit \(n))", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
            }
            if sqlite3_exec(db, "delete from actions_history where id IN (SELECT id from actions_history order by id desc limit \(n))", nil, nil, nil) != SQLITE_OK {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error creating table: \(errmsg)")
            }
            
            
            UserDefaults.standard.set("0", forKey: "NthAction Undo \(name ?? "")")
        }
        
        //creating a statement
        var stmt: OpaquePointer?
        
        //CREATE TABLE actions_history(id integer primary key autoincrement, name text)
        //the insert query
        let queryString = "insert into actions_history(id, name, type) values(?, ?, ?)"
        
        //preparing the query
        if sqlite3_prepare(db, queryString, -1, &stmt, nil) != SQLITE_OK{
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("error preparing insert: \(errmsg)")
            return
        }
        
        if sqlite3_bind_int(stmt, 1, Int32(id)) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            sqlite3_finalize(stmt)
            return
        }
        
        if sqlite3_bind_text(stmt, 2, (msg as NSString).utf8String, -1, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            sqlite3_finalize(stmt)
            return
        }
        
        let typeStr: String
        switch type {
        case .addition:
            typeStr = "addition"
        case .deletion:
            typeStr = "deletion"
        }
        if sqlite3_bind_text(stmt, 3, (typeStr as NSString).utf8String, -1, nil) != SQLITE_OK {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure binding name: \(errmsg)")
            sqlite3_finalize(stmt)
            return
        }
        
        //executing the query to insert values
        if sqlite3_step(stmt) != SQLITE_DONE {
            let errmsg = String(cString: sqlite3_errmsg(db)!)
            print("failure inserting hero: \(errmsg)")
            return
        }
        
        sqlite3_finalize(stmt)
        
    }
    
    func attachObjects(objectsToAttach: [Int]) {
        let object = SceneObject()
        for nth in objectsToAttach {
            for i in 0..<objects[nth].vertices.count {
                object.vertices.append(objects[nth].vertices[i])
                object.lineVertices.append(objects[nth].lineVertices[i])
            }
        }
        
        object.isSelected = true
        objects = [object]
    }
    
    func removeObject(nth: Int) {
        objects.remove(at: nth)
        updateDatabase()
    }
    
    func removeAll(nth: Int) {
        objects.removeAll()
        updateDatabase()
    }
}
