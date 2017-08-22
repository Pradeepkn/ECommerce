//
//  ECLocalizationString.swift
//  ECApp
//
//  Created by Kavya on 7/17/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import Foundation

extension String {
    
    static func localizedValueForKey(key : String) -> String {
        let value: String = NSLocalizedString(key, comment: key)
        return value
    }
    
}
