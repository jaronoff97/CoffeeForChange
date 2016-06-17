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
    func config(database: FIRDatabaseReference, completion:()->Void)
    var instanceType: Instance { get }
    func reloadDelegateData()
    static func getInstance()->ConfigureData
    var tableDelegate: FirebaseTableDelegate? { get set }
}
protocol FirebaseItem {
    var id: String { get set }
    var name: String { get set }
}
protocol FirebaseItemDelegate {
    var items: [FirebaseItem] { get set }
    func itemFactory(rest: FIRDataSnapshot) -> FirebaseItem
}
protocol FirebaseTableDelegate {
    func reloadData()
    var items: [FirebaseItem] { get set }
}