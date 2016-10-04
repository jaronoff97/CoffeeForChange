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
        return .order
    }
    fileprivate static let sharedInstance = OrdersInstance()
    var tableDelegate: FirebaseTableDelegate?

    
    init(){
        
    }
    static func makeImageFromString(_ imageSnap: String) -> UIImage?{
        if(imageSnap==""){
            return nil
        }else{
            
            let base64String = imageSnap
            let imageData = Data(base64Encoded: base64String, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
            let decodedImage = UIImage(data:imageData!)
            return decodedImage
        }
    }
}
extension OrdersInstance: ConfigureData{
    func config(_ database: FIRDatabaseReference,completion:@escaping ()->Void){
        database.observe(.value, with: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                let child_info = rest.toDict()
                if self.items.contains(where: {$0.id == (child_info["id"] as! String)}) == true{
                    continue
                }
                
                self.items.append(self.itemFactory(rest))
            }
            completion()
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
    func itemFactory(_ rest: FIRDataSnapshot) -> FirebaseItem{
        var sig = ""
        let rest_dict = rest.toDict()
        if let signature:String = rest_dict["signature"] as? String{
            sig=signature
        }
        return Order(menu_item: rest_dict["menu_item"] as! String,
                     description_of_item: rest_dict["description"] as! String,
                     user:rest_dict["user"] as! String,
                     id: rest_dict["id"] as! String,
                     timestamp: rest_dict["timestamp"] as! String,
                     price: rest_dict["price"] as! Double,
                     userid: rest_dict["userid"] as! String,
                     pay_with_IA: (rest_dict["pay_with_IA"] as! String).toBool()!,
                     signature: (sig)
        )

    }
}
