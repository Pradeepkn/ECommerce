//
//  ECLabel.swift
//  ECApp
//
//  Created by Kavya on 7/17/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import Foundation
import UIKit

extension UILabel {
    
    func IBDefaultAppLabelUI() {
        self.textColor = UIColor.appThemeColor()
        self.textAlignment = NSTextAlignment.left
    }
    
    func requiredHeight() -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRect(x :0, y :0, width :self.frame.width, height :CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = self.font
        label.text = self.text
        label.sizeToFit()
        
        return label.frame.height
    }
}
