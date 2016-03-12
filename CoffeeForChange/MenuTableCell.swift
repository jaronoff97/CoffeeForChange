//
//  MenuTableCell.swift
//  CoffeeForChange
//
//  Created by Jacob Aronoff on 3/11/16.
//  Copyright © 2016 Milton Academy. All rights reserved.
//

import Foundation
import UIKit

class MenuTableCell: UITableViewCell{
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}