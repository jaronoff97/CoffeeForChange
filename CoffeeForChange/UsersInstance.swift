//
//  UsersInstance.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 5/20/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation
import Firebase

class UsersInstance: ConfigureData, FirebaseItemDelegate {
    var items: [FirebaseItem] = []
    static let sharedMenu = MenuInstance()
    var firebaseRef: FIRDatabaseReference{
        get {
            return DataInstance.sharedInstance.userRef
        }
    }
    var tableDelegate: FirebaseTableDelegate?

    init(){
        firebaseRef.observeEventType(.ChildChanged, withBlock: { snapshot in
            let newUser = self.makeUserFromData(snapshot)
            self.items[self.items.indexOf({$0.id == newUser.id})!] = newUser
            self.reloadDelegateData()
        })
    }
    func reloadDelegateData() {
        if let tableDelegate = self.tableDelegate{
            tableDelegate.reloadData()
        }
    }
    func config(completion:()->Void){
        firebaseRef.queryOrderedByChild("last").observeSingleEventOfType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                self.items.append(self.makeUserFromData(rest))
            }
            completion()
            
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    func makeUserFromData(rest: FIRDataSnapshot) -> User {
        let tempUser: User = User()
        if let temp_id:String = rest.valueForKey("id") as? String{
            tempUser.id = temp_id
        }
        if let temp_First = rest.value!["first"] as! String?{
            tempUser.first_name = temp_First
        }
        if let temp_uid = rest.value!["user_id"] as! String?{
            tempUser.user_id = temp_uid
        }
        if let temp_Last = rest.value!["last"] as! String?{
            tempUser.last_name = temp_Last
        }
        if let temp_money = rest.value!["money_left"] as! Double?{
            tempUser.money = temp_money
        }
        if let temp_money = rest.value!["total_money"] as! Double?{
            tempUser.total_money = temp_money
        }
        if let temp_year = (rest.value!["year"] as! Int?){
            tempUser.year = temp_year
        }
        tempUser.full_name="\(tempUser.first_name) \(tempUser.last_name)"
        return tempUser
    }
    
}
