//
//  Order.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 3/11/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation
import UIKit

struct Order: FirebaseItem {
    var menu_item: String
    var description_of_item: String
    var user: String
    var name: String{
        get{
            return menu_item
        }
        set(newVal){
            menu_item=newVal
        }
    }
    var id: String
    var timestamp: NSDate
    var price: Double
    var userid: String
    var pay_with_IA: Bool
    var signature: UIImage?
}