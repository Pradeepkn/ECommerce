//
//  APIKeys.swift
//  APIManager-Alamofire
//
//  Created by Pradeep on 2/8/16.
//  Copyright © 2016 Pradeep. All rights reserved.
//

import Foundation

struct APIConfig {
    
    // Config
    static var isProduction: Bool = false
    
    static var ProductionURL: String = "http://mapunity.com/api/usn/"
    static var StagingURL: String = "http://mapunity.com/api/usn/"
    
    static var ImageProductionURL: String = "http://mapunity.com"
    static var ImageStagingURL: String = "http://mapunity.com"
    
    static var BaseURL: String {
        if isProduction  {
            return ProductionURL
        } else {
            return StagingURL
        }
    }
    
    static var ImageBaseURL: String {
        if isProduction  {
            return ImageProductionURL
        } else {
            return ImageStagingURL
        }
    }
    
    static let  timeoutInterval = 30.0 // In Seconds

}

