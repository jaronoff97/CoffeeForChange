//
//  DataInstance.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 5/19/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation
import Firebase

enum Instance {
    case User
    case Menu
    case Order
    func getRef()->FIRDatabaseReference{
        switch self {
        case .Menu:
            return DataInstance.sharedInstance.menuRef
        case .Order:
            return DataInstance.sharedInstance.orderRef
        case .User:
            return DataInstance.sharedInstance.userRef
        }
    }
}
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
                case .Menu:
                    return configInstances[0]
                case .User:
                    return configInstances[1]
                case .Order:
                    return configInstances[2]
            }
    }
    
    
    init(){
        FIRAuth.auth()!.signInAnonymouslyWithCompletion() { (user, error) in
            if let error = error {
                print("Sign in failed:", error.localizedDescription)
            } else {
                print ("Signed in with uid:", user!.uid)
                CCGeneratePDF.generate()
                for (instance) in self.configInstances {
                    instance.config(instance.instanceType.getRef(), completion: {
                        print("Completed \(instance.instanceType)")
                    })
                }
            }
        }
    }
    func setDelegate(delegate: FirebaseTableDelegate, instance: Instance) -> Void {
        if configInstances[configInstances.indexOf({$0.instanceType == instance})!].tableDelegate == nil{
            configInstances[configInstances.indexOf({$0.instanceType == instance})!].tableDelegate = delegate
            configInstances[configInstances.indexOf({$0.instanceType == instance})!].reloadDelegateData()
        }
    }
}