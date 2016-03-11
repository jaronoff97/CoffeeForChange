//
//  User.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 3/2/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation


class User {
    var id: String?
    var first_name: String?
    var user_id: String?
    var last_name: String?
    var full_name: String?
    var money: Double?
    var total_money: Double?
    var year: Int?
    var previous_orders: [String?]

    init(id: String?, first_name: String?, last_name: String?, money: Double?, year: Int?){
        self.id = id!
        self.first_name = first_name!
        self.last_name = last_name!
        self.full_name = "\(self.first_name) \(self.last_name)"
        self.money = money!
        self.year = year!
        self.previous_orders=[String?]()
    }
    init(){
        self.previous_orders=[String?]()
    }
    func print_info(){
        print("\(id) \(full_name) \(money) \(year)")
    }

}