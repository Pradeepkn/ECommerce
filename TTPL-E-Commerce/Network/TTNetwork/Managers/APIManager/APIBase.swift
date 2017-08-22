//
//  APIBase.swift
//  APIManager-Alamofire
//
//  Created by Pradeep on 2/8/16.
//  Copyright © 2016 Pradeep. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper

class APIBase: NSObject {

    
    // MARK: URL
    func urlForRequest() -> String {
        return ""
    }
    
    // MARK: HTTP method type
    func requestType() -> Alamofire.HTTPMethod {
        return Alamofire.HTTPMethod.get
    }
    
    // MARK: API parameters
    func requestParameter() -> [String : Any]?{
        return nil
    }
    
    // MARK: Response parser
    func parseAPIResponse(response: Dictionary<String, AnyObject>?) {
        
    }
    
    // MARK: Is Multipart Request
    func isMultipartRequest() -> Bool {
        return false
    }
    
    // MARK: MultipartData
    func multipartData(multipartData : MultipartFormData?) {
        
    }
    
    // MARK: Object Mapper Logic
    func enableCacheControl() -> Bool {
        return false
    }
    
    // MARK: Object Mapper Logic
    func cacheKey() -> String? {
        return nil
    }
    
    // Add custom headers
    func customHTTPHeaders() -> Alamofire.HTTPHeaders? {
        return nil
    }
    
    // Enable true if it is JSON request (application/json)
    func isJSONRequest() -> Bool {
        return false
    }

    
}
