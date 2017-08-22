//
//  ECMenuCell.swift
//  ECApp
//
//  Created by Pradeep on 7/13/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import UIKit

class ECMenuCell: UICollectionViewCell {
    
    @IBOutlet weak var menuCellImageView: UIImageView!
    @IBOutlet weak var menuItemTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 6.0
        self.dropShadow()
    }
}
