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
        return .menu
    }
    fileprivate static let sharedInstance = MenuInstance()
    var tableDelegate: FirebaseTableDelegate?
    init(){
        
    }
}
extension MenuInstance: ConfigureData {
    static func getInstance() -> ConfigureData {
        return sharedInstance
    }
    internal func config(_ database: FIRDatabaseReference,completion:@escaping ()->Void){
        database.observe(.childAdded, with: { snapshot in
            let newItem = self.itemFactory(snapshot)
            if(self.items.contains(where: {$0.id==newItem.id})){
                
            } else {
                self.items.append(newItem)
            }
            completion()
        })
        database.observe(.childRemoved, with: { snapshot in
            let newItem = self.itemFactory(snapshot)
            self.items.remove(at: self.items.index(where: {$0.id == newItem.id})!)
        })
        database.observe(.childChanged, with: { snapshot in
            let newItem = self.itemFactory(snapshot)
            self.items[self.items.index(where: {$0.id == newItem.id})!] = newItem
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
    func itemFactory(_ rest: FIRDataSnapshot) -> FirebaseItem{
        let snap = rest.toDict()
        return Menu(price: ((snap["price"] as! NSNumber).doubleValue as Double?)!, name: snap["name"] as! String, id: snap["id"] as! String)
    }
}
