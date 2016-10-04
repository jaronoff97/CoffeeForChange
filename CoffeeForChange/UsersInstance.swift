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
        return .user
    }
    fileprivate static let sharedInstance = UsersInstance()
    var tableDelegate: FirebaseTableDelegate?

    init(){
        
    }
}
extension UsersInstance: ConfigureData{
    internal func config(_ database: FIRDatabaseReference, completion: @escaping () -> Void) {
        database.queryOrdered(byChild: "last").observeSingleEvent(of: .value, with: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                self.items.append(self.itemFactory(rest))
            }
            completion()
            })
        database.observe(.childChanged, with: { snapshot in
            let newUser = self.itemFactory(snapshot)
            self.items[self.items.index(where: {$0.id == newUser.id})!] = newUser
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
    func itemFactory(_ rest: FIRDataSnapshot) -> FirebaseItem{
        let snap = rest.toDict()
        let tempUser: User = User(id: (snap["id"] as? String)!,
         name: (snap["first"] as! String?)!,
         user_id: (snap["user_id"] as! String?)!,
         last_name: (snap["last"] as! String?)!,
         money: (snap["money_left"] as! Double?)!,
         total_money: (snap["total_money"] as! Double?)!,
         year: (snap["year"] as! Int?)!,
         previous_orders: [String]())
        
        return tempUser
    }
}
