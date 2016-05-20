//
//  MenuInstance.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 5/20/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation
import Firebase

class MenuInstance: ConfigureData, FirebaseItemDelegate {
    var items: [FirebaseItem] = []
    var firebaseRef: FIRDatabaseReference{
        get {
            return DataInstance.sharedInstance.menuRef
        }
    }
    static let sharedMenu = MenuInstance()
    var tableDelegate: FirebaseTableDelegate?
    init(){
        
    }
    func config(completion:()->Void){
        firebaseRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                let secondEnum = rest.children
                while let nextLevel = secondEnum.nextObject() as? FIRDataSnapshot{
                    let tempItem: Menu = Menu(price: ((nextLevel.value!["price"] as! NSNumber).doubleValue as Double?)!, name: nextLevel.value!["name"] as! String, id: nextLevel.value!["id"] as! String)
                    self.items.append(tempItem)
                    self.reloadDelegateData()
                }
            }
            }, withCancelBlock: { error in
                print(error.description)
        })

    }
    func reloadDelegateData() {
        if let tableDelegate = self.tableDelegate{
            tableDelegate.reloadData()
        }
    }
}
