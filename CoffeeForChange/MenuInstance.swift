//
//  MenuInstance.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 5/20/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation
import Firebase

class MenuInstance: FirebaseItemDelegate {
    var items: [FirebaseItem] = [] {
        didSet {
            self.reloadDelegateData()
        }
    }
    var instanceType: Instance {
        return .Menu
    }
    private static let sharedInstance = MenuInstance()
    var tableDelegate: FirebaseTableDelegate?
    init(){
        
    }
}
extension MenuInstance: ConfigureData {
    static func getInstance() -> ConfigureData {
        return sharedInstance
    }
    func config(database: FIRDatabaseReference,completion:()->Void){
        database.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                let secondEnum = rest.children
                while let nextLevel = secondEnum.nextObject() as? FIRDataSnapshot{
                    self.items.append(self.itemFactory(nextLevel))
                }
            }
            completion()
            }, withCancelBlock: { error in
                print(error.description)
        })
        
    }
}
extension MenuInstance {
    func reloadDelegateData() {
        if var tableDelegate = self.tableDelegate{
            tableDelegate.items = self.items
            tableDelegate.reloadData()
        }
    }
    func itemFactory(rest: FIRDataSnapshot) -> FirebaseItem{
        return Menu(price: ((rest.value!["price"] as! NSNumber).doubleValue as Double?)!, name: rest.value!["name"] as! String, id: rest.value!["id"] as! String)
    }
}