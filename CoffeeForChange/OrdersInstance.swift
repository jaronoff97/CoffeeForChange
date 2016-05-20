//
//  OrdersInstance.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 5/20/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation
import Firebase


class OrdersInstance: ConfigureData, FirebaseItemDelegate {
    
    var items: [FirebaseItem] = []
    static let sharedMenu = MenuInstance()
    var firebaseRef: FIRDatabaseReference{
        get {
            return DataInstance.sharedInstance.menuRef
        }
    }
    var tableDelegate: FirebaseTableDelegate?

    
    init(){
        
    }
    func reloadDelegateData() {
        if let tableDelegate = self.tableDelegate{
            tableDelegate.reloadData()
        }
    }
    func config(completion:()->Void){
        firebaseRef.observeEventType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                let results = self.items.filter { $0.id == (rest.value!["id"] as! String)}
                let exists = results.isEmpty == false
                if exists == true{
                    continue
                }
                
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
                let date = dateFormatter.dateFromString(rest.value!["timestamp"] as! String)
                var sig = ""
                if let signature:String = rest.value!["signature"] as? String{
                    sig=signature
                }
                let tempItem: Order = Order(menu_item: rest.value!["menu_item"] as! String,
                    description_of_item: rest.value!["description"] as! String,
                    user:rest.value!["user"] as! String,
                    id: rest.value!["id"] as! String,
                    timestamp: date!,
                    price: Double(rest.value!["price"] as! String)!,
                    userid: rest.value!["userid"] as! String,
                    pay_with_IA: (rest.value!["pay_with_IA"] as! String).toBool()!,
                    signature: self.makeImageFromString(sig)
                )
                self.items.append(tempItem)
                self.reloadDelegateData()
                
            }
            self.items.sortInPlace({ $0.timestamp.compare($1.timestamp) == NSComparisonResult.OrderedDescending })
            }, withCancelBlock: { error in
                print(error.description)
        })
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
