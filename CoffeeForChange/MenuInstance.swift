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
        /*database.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                if(self.items.contains({$0.id==String(rest.value!["id"])})){
                    
                } else {
                    self.items.append(self.itemFactory(rest))
                }

            }
            completion()
            print(self.items)
            }, withCancelBlock: { error in
                print(error.description)
        })*/
        database.observeEventType(.ChildAdded, withBlock: { snapshot in
            let newItem = self.itemFactory(snapshot)
            if(self.items.contains({$0.id==newItem.id})){
                
            } else {
                self.items.append(newItem)
            }
        })
        database.observeEventType(.ChildRemoved, withBlock: { snapshot in
            let newItem = self.itemFactory(snapshot)
            self.items.removeAtIndex(self.items.indexOf({$0.id == newItem.id})!)
        })
        database.observeEventType(.ChildChanged, withBlock: { snapshot in
            let newItem = self.itemFactory(snapshot)
            self.items[self.items.indexOf({$0.id == newItem.id})!] = newItem
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