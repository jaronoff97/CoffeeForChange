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
    var rootRef = FIRDatabase.database().reference()
    var menuRef: FIRDatabaseReference{
        get {
            return rootRef.child("menu")
        }
    }
    var userRef: FIRDatabaseReference{
        get {
            return rootRef.child("users")
        }
    }
    var orderRef: FIRDatabaseReference{
        get {
            return rootRef.child("orders")
        }
    }
    
    init(){
        FIRAuth.auth()!.signInAnonymouslyWithCompletion() { (user, error) in
            if let error = error {
                print("Sign in failed:", error.localizedDescription)
            } else {
                print ("Signed in with uid:", user!.uid)
            }
        }
        
    }
}