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
    func config(completion:()->Void)
}
protocol FirebaseItem {
    var id: String { get set }
    var name: String { get set }
}
protocol FirebaseItemDelegate {
    var items: [FirebaseItem] { get set }
    var firebaseRef: FIRDatabaseReference { get }
    var tableDelegate: FirebaseTableDelegate? { get set }
    func reloadDelegateData()
}
protocol FirebaseTableDelegate {
    func reloadData()
}