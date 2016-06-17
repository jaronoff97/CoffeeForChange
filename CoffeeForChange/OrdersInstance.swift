//
//  OrdersInstance.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 5/20/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation
import Firebase


class OrdersInstance: FirebaseItemDelegate {
    
    var items: [FirebaseItem] = [] {
        didSet {
            self.reloadDelegateData()
        }
    }
    var instanceType: Instance {
        return .Order
    }
    private static let sharedInstance = OrdersInstance()
    var tableDelegate: FirebaseTableDelegate?

    
    init(){
        
    }
    func makeImageFromString(imageSnap: String) -> UIImage?{
        if(imageSnap==""){
            return nil
        }else{
            
            let base64String = imageSnap
            let imageData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
            let decodedImage = UIImage(data:imageData!)
            return decodedImage
        }
    }
}
extension OrdersInstance: ConfigureData{
    func config(database: FIRDatabaseReference,completion:()->Void){
        database.observeEventType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                if self.items.contains({$0.id == (rest.value!["id"] as! String)}) == true{
                    continue
                }
                
                self.items.append(self.itemFactory(rest))
            }
            completion()
            }, withCancelBlock: { error in
                print(error.description)
        })
    }

    static func getInstance() -> ConfigureData {
        return sharedInstance
    }
}
extension OrdersInstance {
    func reloadDelegateData() {
        if var tableDelegate = self.tableDelegate{
            tableDelegate.items = self.items
            tableDelegate.reloadData()
        }
    }
    func itemFactory(rest: FIRDataSnapshot) -> FirebaseItem{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        let date = dateFormatter.dateFromString(rest.value!["timestamp"] as! String)
        var sig = ""
        if let signature:String = rest.value!["signature"] as? String{
            sig=signature
        }
        return Order(menu_item: rest.value!["menu_item"] as! String,
                     description_of_item: rest.value!["description"] as! String,
                     user:rest.value!["user"] as! String,
                     id: rest.value!["id"] as! String,
                     timestamp: date!,
                     price: Double(rest.value!["price"] as! String)!,
                     userid: rest.value!["userid"] as! String,
                     pay_with_IA: (rest.value!["pay_with_IA"] as! String).toBool()!,
                     signature: self.makeImageFromString(sig)
        )

    }
}
