//
//  User.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 3/2/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation


struct User: FirebaseItem {
    var id: String
    var name: String
    var user_id: String
    var last_name: String
    var full_name: String {
        get {
            return("\(name) \(last_name)")
        }
    }
    var money: Double
    var total_money: Double
    var year: Int
    var previous_orders: [String] = []
    func toJSON() -> [String : AnyObject] {
        return [
            "first":self.name,
            "id":self.id,
            "last":self.last_name,
            "money_left":self.money,
            "total_money":self.total_money,
            "user_id":self.user_id,
            "year":self.year
        ]
    }
}