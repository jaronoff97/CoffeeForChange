//
//  User.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 3/2/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation


class User: FirebaseItem {
    var id: String = ""
    var name: String = ""
    var first_name: String = ""
    var user_id: String = ""
    var last_name: String = ""
    var full_name: String = ""
    var money: Double = 0
    var total_money: Double = 0
    var year: Int = 0
    var previous_orders: [String] = []

    init(id: String?, first_name: String?, last_name: String?, money: Double?, year: Int?){
        self.id = id!
        self.first_name = first_name!
        self.last_name = last_name!
        self.full_name = "\(self.first_name) \(self.last_name)"
        self.money = money!
        self.year = year!
        self.previous_orders=[String]()
        self.name=self.first_name
    }
    init(){
        
    }
    func print_info(){
        print("\(id) \(full_name) \(money) \(year)")
    }

}