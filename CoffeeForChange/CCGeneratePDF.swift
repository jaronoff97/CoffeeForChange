//
//  CCGeneratePDF.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 6/19/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation
import SimplePDF
import Firebase

class CCGeneratePDF {
    init(){
        
    }
    static func generate(){
        let pdf = SimplePDF(pageSize: CGSize(width: 595,height: 842), pageMargin: 20.0)
        var final_array:Array<Array<String>> = [[]]
        DataInstance.sharedInstance.userRef.observeEventType(.Value, withBlock: { (snapshot) in
            let enumerator = snapshot.children
            print("begin")
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
                if let previous_orders = rest.value?.objectForKey("all_orders"){
                    for order in previous_orders.allValues{
                        let signature_image: UIImage? = OrdersInstance.makeImageFromString(order.valueForKey("signature")! as! String)
                        //print(order.allKeys)
                        if(!order.allKeys.contains({$0 as! String=="price"})){
                            continue
                        }
                        final_array.append([order.valueForKey("user")! as! String,order.valueForKey("price")! as! String,order.valueForKey("signature")! as! String])
                    }
                }
                
            }
            print("end")
            }, withCancelBlock: { error in
            
        })
        pdf.addTable(final_array.count, columnCount: final_array[0].count, rowHeight: CGFloat(100), columnWidth: CGFloat(50), tableLineWidth: CGFloat(1), font: UIFont(name: "Times New Roman", size: 12)!, dataArray: final_array)
        
    }
}