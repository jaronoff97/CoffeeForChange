//
//  UsersInstance.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 5/20/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation
import Firebase

class UsersInstance: FirebaseItemDelegate {
    var items: [FirebaseItem] = [] {
        didSet {
            self.reloadDelegateData()
        }
    }
    var instanceType: Instance {
        return .User
    }
    private static let sharedInstance = MenuInstance()
    var tableDelegate: FirebaseTableDelegate?

    init(){
        
    }
}
extension UsersInstance: ConfigureData{
    func config(database: FIRDatabaseReference,completion:()->Void){
        database.queryOrderedByChild("last").observeSingleEventOfType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                self.items.append(self.itemFactory(rest))
            }
            completion()
            
            }, withCancelBlock: { error in
                print(error.description)
        })
        database.observeEventType(.ChildChanged, withBlock: { snapshot in
            let newUser = self.itemFactory(snapshot)
            self.items[self.items.indexOf({$0.id == newUser.id})!] = newUser
        })
    }
    static func getInstance() -> ConfigureData {
        return sharedInstance
    }
}
extension UsersInstance {
    func reloadDelegateData() {
        if var tableDelegate = self.tableDelegate{
            tableDelegate.items = self.items
            tableDelegate.reloadData()
        }
    }
    func itemFactory(rest: FIRDataSnapshot) -> FirebaseItem{
        let tempUser: User = User(id: (rest.value!["id"] as? String)!,
         name: (rest.value!["first"] as! String?)!,
         user_id: (rest.value!["user_id"] as! String?)!,
         last_name: (rest.value!["last"] as! String?)!,
         money: (rest.value!["money_left"] as! Double?)!,
         total_money: (rest.value!["total_money"] as! Double?)!,
         year: (rest.value!["year"] as! Int?)!,
         previous_orders: [String]())
        
        return tempUser
    }
}