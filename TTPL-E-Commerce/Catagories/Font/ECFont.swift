//
//  ECFont.swift
//  ECsoreApp
//
//  Created by Kavya on 7/17/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import Foundation
import UIKit

enum ECFontFamily: String {
    case kECRegularFontName = "HelveticaNeue"
    case kECBoldFontName = "HelveticaNeue-Bold"
    case kECMediumBoldFontName = "HelveticaNeue-Medium"
    case kECThinFontName = "HelveticaNeue-Thin"
    case kECLightFontName = "HelveticaNeue-Light"
}

//static NSString * const kNSNormalFontName = @"HelveticaNeue";
//static NSString * const kNSBoldFrontName = @"HelveticaNeue-Bold";
//static NSString * const kNSMediumBoldFontName = @"HelveticaNeue-Medium";
//static NSString * const kNSThinFontName = @"HelveticaNeue-Thin";
//static NSString * const kNSLightFontName = @"HelveticaNeue-Light";

enum ECFontSize : CGFloat {
    case kECOExtraSmall = 9
    case kECEExtraSmall = 10
    case kECOSmall = 11
    case kECESmall = 12
    case kECOMedium = 13
    case kECEMedium = 14
    case kECORegular = 15
    case kECERegular = 16
    case kECONormal = 17
    case kECENormal = 18
    case kECOLarge = 19
    case kECELarge = 20
    case kECOExtraLarge = 21
    case kECEExtraLarge = 22
}

extension UIFont {
    
    // MARK:- Font method
    
    class func setECFont(fontType : ECFontFamily, fontSize :ECFontSize) -> UIFont {
        return UIFont(name: fontType.rawValue, size: fontSize.rawValue)!
    }
    
}
