//
//  DataInstance.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 5/19/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation
import Firebase

class DataInstance {
    
    static let sharedInstance = DataInstance()
    var user: User?
    var rootRef = FIRDatabase.database().reference()
    var menuRef: FIRDatabaseReference{
        return rootRef.child("menu")
    }
    var userRef: FIRDatabaseReference{
        return rootRef.child("users")
    }
    var orderRef: FIRDatabaseReference{
        return rootRef.child("orders")
    }
    var configInstances:[ConfigureData] = [(MenuInstance.getInstance()),(UsersInstance.getInstance()),(OrdersInstance.getInstance())]
    
    func getData(forInstance query:Instance)->(ConfigureData){
            switch query{
                case .menu:
                    return configInstances[0]
                case .user:
                    return configInstances[1]
                case .order:
                    return configInstances[2]
            }
    }
    
    
    init(){
        FIRAuth.auth()!.signInAnonymously() { (user, error) in
            if let error = error {
                print("Sign in failed:", error.localizedDescription)
            } else {
                print ("Signed in with uid:", user!.uid)
                for (instance) in self.configInstances {
                    instance.config(instance.instanceType.getRef(), completion: {
                        print("Completed \(instance.instanceType)")
                    })
                }
            }
        }
    }
    func setDelegate(_ delegate: FirebaseTableDelegate, instance: Instance) -> Void {
        if configInstances[configInstances.index(where: {$0.instanceType == instance})!].tableDelegate == nil{
            configInstances[configInstances.index(where: {$0.instanceType == instance})!].tableDelegate = delegate
            configInstances[configInstances.index(where: {$0.instanceType == instance})!].reloadDelegateData()
        }
    }
}
