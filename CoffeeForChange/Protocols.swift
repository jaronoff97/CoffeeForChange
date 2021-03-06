//
//  Protocols.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 5/19/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation
import Firebase

protocol ConfigureData {
    func config(_ database: FIRDatabaseReference, completion: @escaping () -> Void)
    var instanceType: Instance { get }
    func reloadDelegateData()
    static func getInstance()->ConfigureData
    var tableDelegate: FirebaseTableDelegate? { get set }
}
protocol FirebaseItem {
    var id: String { get set }
    var name: String { get set }
    func toJSON()->[String:AnyObject]
}
protocol FirebaseItemDelegate {
    var items: [FirebaseItem] { get set }
    func itemFactory(_ rest: FIRDataSnapshot) -> FirebaseItem
}
protocol FirebaseTableDelegate {
    func reloadData()
    var items: [FirebaseItem] { get set }
}
