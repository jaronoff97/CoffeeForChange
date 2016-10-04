//
//  Enums.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 10/4/16.
//  Copyright © 2016 CoffeeForChange. All rights reserved.
//

import Foundation
import Firebase

enum Instance {
    case user
    case menu
    case order
    func getRef()->FIRDatabaseReference{
        switch self {
        case .menu:
            return DataInstance.sharedInstance.menuRef
        case .order:
            return DataInstance.sharedInstance.orderRef
        case .user:
            return DataInstance.sharedInstance.userRef
        }
    }
}
