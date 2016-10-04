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
    var timestamp: String
    var price: Double
    var userid: String
    var pay_with_IA: Bool
    var signature: String?
    func toJSON() -> [String : AnyObject] {
        return [
            "description":self.description_of_item as AnyObject,
            "id":self.id as AnyObject,
            "menu_item":self.menu_item as AnyObject,
            "price":self.price as AnyObject,
            "pay_with_IA":self.pay_with_IA.description as AnyObject,
            "timestamp":self.timestamp as AnyObject,
            "signature":self.signature as AnyObject? ?? "" as AnyObject,
            "user": self.user as AnyObject,
            "userid": self.userid as AnyObject
        ]
    }
}
