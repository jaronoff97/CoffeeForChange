//
//  Menu.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 3/3/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation

struct Menu: FirebaseItem {
    var price: Double
    var name: String
    var id: String
    func toJSON() -> [String : AnyObject] {
        return [
            "id":self.id as AnyObject,
            "name":self.name as AnyObject,
            "price":self.price as AnyObject
        ]
    }
}
