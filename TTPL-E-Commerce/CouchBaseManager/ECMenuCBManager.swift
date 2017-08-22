//
//  ECMenuCBManager.swift
//  ECApp
//
//  Created by Pradeep on 7/30/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import UIKit

// Define identifier
let menuNotificationIdentifier: String = "MenuNotificationIdentifier"

let kMenuItemName       = "menuItemName"
let kMenuItemImageName  = "menuItemImage"
let kMenuTypeKey        = "type"
let kMenuTypeValue      = "menu-list"
let kMenuQueryView      = "menu/menuByName"
let kMenuOrderNumber    = "orderNumber"

class ECMenuItems: NSObject {
    var menuItemName        : String = ""
    var menuItemImageName   : String = ""
    var menuItemId          : String = ""
    var orderNumber         : Int = 0
    
    init(menuItemName: String, menuItemImageName: String, orderNumber : Int) {
        self.menuItemName = menuItemName
        self.menuItemImageName = menuItemImageName
        self.orderNumber = orderNumber
    }
}

class ECMenuCBManager: NSObject {
    // Shared Instance of MenuDB
    static let sharedInstance = ECMenuCBManager()
    // CBLManager instance
    let cbManager:CBLManager = CBLManager.sharedInstance()
    var liveQuery:CBLLiveQuery?
    var docsEnumerator:CBLQueryEnumerator? {
        didSet {
            docsEnumerator = self.liveQuery?.rows
            // Post notification
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: menuNotificationIdentifier), object: nil)
        }
    }
    
    func queryMenuItemsInDataBase() -> CBLQuery {
        // TRAINING: Writing a View
        let app = UIApplication.shared.delegate as! AppDelegate
        let menuView = app.database.viewNamed(kMenuQueryView)
        if menuView.mapBlock == nil {
            menuView.setMapBlock({ (doc, emit) in
                if let type: String     = doc[kMenuTypeKey] as? String,
                    let menuItemName    = doc[kMenuItemName],
                    let menuItemImage   = doc[kMenuItemImageName],
                    let orderNumber     = doc[kMenuOrderNumber],
                    type == kMenuTypeValue {
                    emit([menuItemName, menuItemImage, orderNumber], nil)
                }
            }, version: "1.0")
        }
        // TRAINING: Running a Query
        let query : CBLQuery = menuView.createQuery()
        query.descending = false
        return query
    }
    
    // MARK: - Create Menu Document
    func createMenuDocWith(menuItem : ECMenuItems) {
        // Create a manager
        let app = UIApplication.shared.delegate as! AppDelegate
        let menuDataBase = app.database
        do {
            // 1: Create Document with unique Id else open existing one
            // Create a new document
            let documentId = menuItem.menuItemName
            var menuDocument = menuDataBase?.existingDocument(withID: documentId)
            if (menuDocument == nil){
                menuDocument = menuDataBase!.document(withID: documentId)
            }else {
                print(menuDocument?[kMenuItemName] as Any)
            }
            
            // 2: Construct user properties Object
            let menuProperties = [kMenuItemName     : menuItem.menuItemName,
                                  kMenuItemImageName : menuItem.menuItemImageName,
                                  kMenuOrderNumber   : menuItem.orderNumber,
                                  kMenuTypeKey       : kMenuTypeValue] as [String : Any]
            // 3: Add a new revision with specified user properties
            let _ = try menuDocument?.putProperties(menuProperties)
        }
        catch  {
            print("Failed to create database named \(menuItem)")
        }
    }
    // MARK:
    
    func queryAllDocuments(controller : ECMenuViewController) {
        NotificationCenter.default.addObserver(controller, selector: #selector(controller.reloadMenuCollectionView), name: NSNotification.Name(rawValue: menuNotificationIdentifier), object: nil)
        // 1. Get handle to DB with specified name
        let app = UIApplication.shared.delegate as! AppDelegate
        let menuDataBase = app.database
        
        // 2. Create Query to fetch all documents. You can set a number of properties on the query object
        liveQuery = menuDataBase?.createAllDocumentsQuery().asLive()
        
        guard let liveQuery = liveQuery else {
            return
        }
        
        // 3: You can optionally set a number of properties on the query object.
        // Explore other properties on the query object
        liveQuery.limit = UInt(UINT32_MAX) // All documents
        
        //            4. Start observing for changes to the database
        self.addLiveQueryObserverAndStartObserving()
        
        // 5: Run the query to fetch documents asynchronously
        liveQuery.runAsync({ (enumerator, error) in
            switch error {
            case nil:
                // 6: The "enumerator" is of type CBLQueryEnumerator and is an enumerator for the results
                self.docsEnumerator = enumerator
            default: break
                
            }
        })
    }
    
    // MARK:
    func getMenuDocumentsAtIndex(index : Int) -> ECMenuItems? {
        let document = ECMenuCBManager.sharedInstance.docAtIndex(index)
        let userProperties = document?.userProperties
        
        let menuItemName = (userProperties?[kMenuItemName] as? String)!
        let menuImageName = (userProperties?[kMenuItemImageName] as? String)!
        let menuItem = ECMenuItems(menuItemName: menuItemName, menuItemImageName: menuImageName, orderNumber: index)
        menuItem.menuItemId = (userProperties? [kMenuOrderNumber] as? String)!

        return menuItem
    }

    // Deletes a Document in database
    func deleteDocAtIndex(_ index:Int) {
        do {
            // 1: Get the document associated with the row
            let doc = ECMenuCBManager.sharedInstance.docAtIndex(index)
            print("doc to remove  \(String(describing: doc?.userProperties))")
            
            // 2: Delete the document
            try doc?.delete()
        }
        catch  {
            
        }
    }
    
    func deleteDoc(doc : CBLDocument) {
        do {
            // Delete the document
            try doc.delete()
        } catch {
            
        }
    }

    // Helper function to get document at specified index
    func docAtIndex(_ index:Int) -> CBLDocument? {
        // 1. Get the CBLQueryRow object at specified index
        let queryRow = self.docsEnumerator?.row(at: UInt(index))
        // 2: Get the document associated with the row
        let doc = queryRow?.document
        return doc
    }
    
    func addLiveQueryObserverAndStartObserving() {
        guard let liveQuery = liveQuery else {
            return
        }
        
        // 1. iOS Specific. Add observer to the live Query object
        liveQuery.addObserver(self as NSObject, forKeyPath: menuItemKVOKey, options: NSKeyValueObservingOptions.new, context: nil)
        
        // 2. Start observing changes
        liveQuery.start()
    }
    
    func removeLiveQueryObserverAndStopObserving(controller : AnyObject) {
        guard let liveQuery = liveQuery else {
            return
        }
        // 1. iOS Specific. Remove observer from the live Query object
        liveQuery.removeObserver(self as NSObject, forKeyPath: menuItemKVOKey)
        
        // 2. Stop observing changes
        liveQuery.stop()
    }
}
//
//// MARK: KVO
//extension ECMenuCBManager {
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == menuItemKVOKey {
//
//        }
//    }
//}
