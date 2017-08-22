//
//  ECGalleryCell.swift
//  ECApp
//
//  Created by Pradeep on 7/2/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import UIKit

class ECGalleryCell: UICollectionViewCell {
    
    @IBOutlet weak var galleryImageView: UIImageView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var galleryTitleLabel: UILabel!
    @IBOutlet weak var galleryTitleDescription: UILabel!
    @IBOutlet weak var likeCountLabel: UIButton!
    @IBOutlet weak var commentsCountLabel: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dropShadow()
    }
}

extension UIView {
    func dropShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.layer.shadowRadius = 1
    }
    
    func addGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.frame
        gradientLayer.colors = [UIColor.navigationBar().cgColor, UIColor.subTheme().cgColor]
        self.layer.addSublayer(gradientLayer)
    }
}
