//
//  APIManager.swift
//  APIManager-Alamofire
//
//  Created by Pradeep on 2/8/16.
//  Copyright © 2016 Pradeep. All rights reserved.
//

import Foundation
import Alamofire

typealias ResponseHandler = (AnyObject?, NSError?) -> Void

class APIManager {
    
    // Class Stored Properties
    static let sharedInstance = APIManager()
    // Avoid initialization
    fileprivate init() {
    }
    
    static let rootKey = "Root";
    static let expireKey = "Expires"
    
    // MARK : Initialize API Request
    func initiateRequest(_ apiObject: APIBase,
                         apiRequestCompletionHandler:@escaping ResponseHandler) {
        var urlString = apiObject.urlForRequest()
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        
        if apiObject.isMultipartRequest() == true  {
            var urlString = apiObject.urlForRequest()
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            Alamofire.upload(multipartFormData: { (multipartFormData) -> Void in
                apiObject.multipartData(multipartData: multipartFormData)
            }, to: urlString,
               encodingCompletion: { (encodingResult) -> Void in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseData(){  [unowned self] response in
                        if let data = response.result.value {
                            self.serializeAPIResponse(apiObject, response: data as Data?, apiRequestCompletionHandler: apiRequestCompletionHandler, serializerCompletionHandler: nil)
                        } else {
                            apiRequestCompletionHandler(nil,nil)
                        }
                    }
                case .failure(_):
                    let error = NSError(domain: apiObject.urlForRequest(), code: 404, userInfo: nil)
                    apiRequestCompletionHandler(nil,error)
                }
                
            })
            
            
        } else {
            
            var urlString = apiObject.urlForRequest()
            urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            let request = Alamofire.request(urlString, method: apiObject.requestType(), parameters: apiObject.requestParameter(), encoding: ((apiObject.isJSONRequest() == true) ? JSONEncoding.default : URLEncoding.default), headers: apiObject.customHTTPHeaders())
            
            self.requestCompleted(request, apiObject: apiObject,apiRequestCompletionHandler: apiRequestCompletionHandler)
        }
        
    }
    
    
    
    // MARK: Request Completion Logic
    func requestCompleted(_ request: DataRequest?,
                          apiObject: APIBase,
                          apiRequestCompletionHandler:@escaping ResponseHandler) {
        if let request = request {
            
            // Mannual parsing
            request.responseData { [unowned self] response in
                if let data = response.result.value {
                    self.serializeAPIResponse(apiObject, response: data as Data?, apiRequestCompletionHandler: apiRequestCompletionHandler) {
                        [unowned self, request, apiObject] responseDictionary in
                        self.cacheResponse(request, apiObject: apiObject, resposneDictionary: responseDictionary)
                    }
                } else {
                    apiRequestCompletionHandler(nil,nil)
                }
            }
        } else {
            let error = NSError(domain: apiObject.urlForRequest(), code: 404, userInfo: nil)
            apiRequestCompletionHandler(nil,error)
        }
    }
    
    
    
    // MARK: Cache API Response
    func cacheResponse(_ requestObject: DataRequest, apiObject: APIBase, resposneDictionary: Dictionary<String, AnyObject>) {
        guard apiObject.enableCacheControl() == true else {
            return
        }
        requestObject.response { responseStruct in
            if let _ = responseStruct.data {
                // Cache Control
                if let ttl = responseStruct.response?.allHeaderFields[APIManager.expireKey] as? String{
                    let resposneData = NSKeyedArchiver.archivedData(withRootObject: resposneDictionary)
                    APICache.saveResponse(uniqueKey: apiObject.cacheKey(), apiObject: apiObject, cacheData: resposneData as Data as NSData, ttl: ttl)
                }
                
            }
        }
    }
    
    // MARK: Response serializer
    func serializeAPIResponse(_ apiObject: APIBase, response: Data?, apiRequestCompletionHandler:ResponseHandler, serializerCompletionHandler: ((Dictionary<String, AnyObject>) -> Void)?) {
        if let data = response {
            do {
                // Check if it is Dictionary
                if let jsonDictionary = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as? Dictionary<String, AnyObject> {
                    apiObject.parseAPIResponse(response: jsonDictionary)
                    apiRequestCompletionHandler(jsonDictionary as AnyObject?, nil)
                    if let _ = serializerCompletionHandler {
                        serializerCompletionHandler!(jsonDictionary)
                    }
                } else if let jsonArray = try JSONSerialization.jsonObject(with: data as Data, options:
                    JSONSerialization.ReadingOptions.mutableContainers) as? Array<AnyObject> {
                    // Check if it is Array of Dictionary/String
                    let jsonDictionary = [APIManager.rootKey : jsonArray]
                    apiObject.parseAPIResponse(response: jsonDictionary as Dictionary<String, AnyObject>?)
                    apiRequestCompletionHandler(jsonDictionary as AnyObject?, nil)
                    if let _ = serializerCompletionHandler {
                        serializerCompletionHandler!(jsonDictionary as Dictionary<String, AnyObject>)
                    }
                } else {
                    apiRequestCompletionHandler(nil, nil)
                }
                
            } catch let error as NSError {
                apiRequestCompletionHandler(nil, error)
            }
        }
    }
}
