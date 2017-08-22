//
//  TTNetworkContants.swift
//  TTNetwork
//
//  Created by Pradeep on 5/11/16.
//

import Foundation


/// MARK : Database
struct Database {
    struct Entities {
        static let APICache = "APICache"
    }
    
    struct APICacheFields {
        static let Key = "key"
        static let Value = "value"
        static let CreatedAt = "createdAt"
        static let ExpiresAt = "expiresAt"
    }
}
