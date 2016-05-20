//
//  OrderTableCell.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 3/11/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation
import UIKit
import MGSwipeTableCell

class OrderTableCell: MGSwipeTableCell{
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var userLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}