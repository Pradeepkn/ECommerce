//
//  ECPlaceDetailViewCell.swift
//  ECApp
//
//  Created by Kavya on 7/17/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import UIKit

class ECPlaceDetailViewCell: UITableViewCell {

    @IBOutlet weak var placeTitleLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var placeDescriptionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
