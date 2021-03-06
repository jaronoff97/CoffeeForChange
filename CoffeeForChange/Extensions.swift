//
//  Extensions.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 5/20/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation
import Firebase

extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
}
extension FIRDataSnapshot {
    func toDict() -> NSDictionary {
        let value = self.value as? NSDictionary
        guard let dict = value else {
            return [:]
        }
        return dict
    }
}
