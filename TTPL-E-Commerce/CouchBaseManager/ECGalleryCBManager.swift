//
//  ECGalleryCBManager.swift
//  ECApp
//
//  Created by Pradeep on 8/1/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import UIKit

// Define identifier
let galleryNotificationIdentifier: String = "GalleryNotificationIdentifier"
let galleryDataBase             = "galleryDataBase"

let kGalleryTitle               = "galleryTitle"
let kGalleryImagePath           = "galleryImagePath"
let kGalleryDescription         = "galleryDescription"
let kGalleryLikeCount           = "galleryLikeCount"
let kGalleryCommentsCount       = "galleryCommentsCount"
let kGalleryCreatedDate         = "galleryCreatedDate"
let kGalleryOrderNumber         = "galleryOrderNumber"
let kGalleryTypeKey             = "type"
let kGalleryTypeValue           = "galleryItemValue"
let kGalleryItemCreatedBy       = "galleryItemCreatedBy"
let kGalleryQueryView           = "gallery/GalleryByName"
//let kGalleryTypeValue           = "galleryTypeValue"
let kSampleGalleryDescription : String = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."

class ECGalleryItems: NSObject {
    var galleryDocumentId       : String = ""
    var galleryImagePath        : String = ""
    var galleryTitle            : String = ""
    var galleryItemCreatedBy    : String = ""
    var galleryDescription      : String = ""
    var galleryCreatedDate      : String = ""
    var galleryTypeValue        : String = ""
    var galleryTypeKey          : String = ""
    var galleryLikeCount        : NSInteger = 0
    var galleryCommentsCount    : NSInteger = 0
    var galleryOrderNumber      : NSInteger = 0
}

class ECGalleryCBManager: NSObject {
    // Shared Instance of MenuDB
    static let sharedInstance = ECGalleryCBManager()
    // CBLManager instance
    let cbManager:CBLManager = CBLManager.sharedInstance()
    var liveQuery:CBLLiveQuery?
    var liveQueryDictionary = [String : Any]()
    var documentsDictionary = [String : Any]() {
        didSet {
            // Post notification
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: galleryNotificationIdentifier), object: nil)
        }
    }
    
    // Query gallery view based on gallery type selected
    func queryGalleryItems() -> CBLQuery {
        // TRAINING: Writing a View
        let app = UIApplication.shared.delegate as! AppDelegate
        let galleryView = app.database.viewNamed(kGalleryQueryView)
        if galleryView.mapBlock == nil {
            galleryView.setMapBlock({ (doc, emit) in
                if let type: String = doc[kGalleryTypeKey] as? String,
                    let galleryTitle        = doc[kGalleryTitle],
                    let galleryImagePath    = doc[kGalleryImagePath],
                    let galleryDescription  = doc[kGalleryDescription],
                    let galleryLikeCount    = doc[kGalleryLikeCount],
                    let galleryCommentsCount = doc[kGalleryCommentsCount],
                    let galleryCreatedDate  = doc[kGalleryCreatedDate],
                    let galleryOrderNumber  = doc[kGalleryOrderNumber],
                    let galleryItemCreatedBy = doc[kGalleryItemCreatedBy],
                    let galleryType  = doc[kGalleryTypeValue],
                    type == kGalleryTypeValue {
                    emit([galleryTitle,galleryImagePath,galleryDescription,galleryLikeCount, galleryCommentsCount, galleryCreatedDate, galleryOrderNumber, galleryItemCreatedBy, galleryType], nil)
                }
            }, version: "1.0")
        }
        // TRAINING: Running a Query
        let query : CBLQuery = galleryView.createQuery()
        query.descending = false
        return query
    }
    
    // Query gallery view based on gallery type selected
    func queryGalleryItemsInDataBase(galleryType : String) -> CBLQuery {
        // TRAINING: Writing a View
        let app = UIApplication.shared.delegate as! AppDelegate
        let galleryView = app.database.viewNamed(galleryType)
        if galleryView.mapBlock == nil {
            galleryView.setMapBlock({ (doc, emit) in
                if let type: String = doc[kGalleryTypeKey] as? String,
                    let galleryTitle        = doc[kGalleryTitle],
                    let galleryImagePath    = doc[kGalleryImagePath],
                    let galleryDescription  = doc[kGalleryDescription],
                    let galleryLikeCount    = doc[kGalleryLikeCount],
                    let galleryCommentsCount = doc[kGalleryCommentsCount],
                    let galleryCreatedDate  = doc[kGalleryCreatedDate],
                    let galleryOrderNumber  = doc[kGalleryOrderNumber],
                    let galleryItemCreatedBy = doc[kGalleryItemCreatedBy],
                    type == galleryType {
                    emit([galleryTitle,galleryImagePath,galleryDescription,galleryLikeCount, galleryCommentsCount, galleryCreatedDate, galleryOrderNumber, galleryItemCreatedBy], nil)
                }
            }, version: "1.0")
        }
        // TRAINING: Running a Query
        let query : CBLQuery = galleryView.createQuery()
        query.descending = false
        return query
    }

    // MARK: - Create Gallery Document
    func createGalleryDocWith(galleryItem : ECGalleryItems) {
        // Create a manager
        let app = UIApplication.shared.delegate as! AppDelegate
        let galleryDataBase: CBLDatabase = app.database
        
        do {
            // 1: Create Document with unique Id else open existing one
            // Create a new document
//            let documentId = galleryItem.galleryTypeValue
//            var galleryDocument = galleryDataBase.existingDocument(withID: documentId)
//            if (galleryDocument == nil){
//                galleryDocument = galleryDataBase.document(withID: documentId)
//            }else {
//                print(galleryDocument?[kGalleryTitle] as Any)
//            }
            let galleryDocument: CBLDocument = galleryDataBase.createDocument()

            // 2: Construct user properties Object
            let galleryProperties = [kGalleryTitle      : galleryItem.galleryTitle,
                                     kGalleryDescription : galleryItem.galleryDescription,
                                     kGalleryImagePath  : galleryItem.galleryImagePath,
                                     kGalleryLikeCount  : galleryItem.galleryLikeCount,
                                     kGalleryCommentsCount : galleryItem.galleryCommentsCount,
                                     kGalleryCreatedDate : galleryItem.galleryCreatedDate,
                                     kGalleryOrderNumber : galleryItem.galleryOrderNumber,
                                     kGalleryTypeKey    : galleryItem.galleryTypeKey,
                                     kGalleryItemCreatedBy    : galleryItem.galleryItemCreatedBy,
                                     kGalleryTypeValue : galleryItem.galleryTypeValue] as [String : Any]
            // 3: Add a new revision with specified user properties
            let _ = try galleryDocument.putProperties(galleryProperties)
        }
        catch  {
            print("Failed to create database named \(galleryItem)")
        }
    }
    // MARK:
    
    func queryAllDocuments(controller : ECGalleryViewController, dbName : String) {
        NotificationCenter.default.addObserver(controller, selector: #selector(controller.reloadGalleryCollectionView), name: NSNotification.Name(rawValue: galleryNotificationIdentifier), object: nil)
        let galleryDataBase: CBLDatabase
        do {
            // 1. Get handle to DB with specified name
            galleryDataBase = try cbManager.existingDatabaseNamed(dbName.lowercased())
            
            // 2. Create Query to fetch all documents. You can set a number of properties on the query object
            let liveQuery:CBLLiveQuery? = galleryDataBase.createAllDocumentsQuery().asLive()
            
            // 3: You can optionally set a number of properties on the query object.
            // Explore other properties on the query object
            liveQuery?.limit = UInt(UINT32_MAX) // All documents
            
            // 4. Start observing for changes to the database
            self.addLiveQueryObserverAndStartObserving(keyPath: dbName)
            
//            let sortDesc : NSSortDescriptor = NSSortDescriptor(key: DocumentGalleryProperties.placeName.rawValue, ascending: true)
//            liveQuery?.sortDescriptors = [sortDesc]
            
            // 5: Run the query to fetch documents asynchronously
            liveQuery?.runAsync({ (enumerator, error) in
                switch error {
                case nil:
                    // 6: The "enumerator" is of type CBLQueryEnumerator and is an enumerator for the results

                    self.documentsDictionary[dbName] = enumerator
                default: break
                    
                }
            })
            self.liveQueryDictionary[dbName] = liveQuery
            
        }catch {
            
        }
    }
    
    func getGalleryDocumentsCountFor(menuType : GalleryCategory) -> Int {
        let docsEnumerator:CBLQueryEnumerator?
        if let enumerator = self.documentsDictionary[menuType.rawValue] {
            // now val is not nil and the Optional has been unwrapped, so use it
            docsEnumerator = enumerator as? CBLQueryEnumerator
            return Int(docsEnumerator!.count)
        }
        return 0
    }
    
    // MARK:
    func getGalleryDocumentsAtIndex(index : Int, dbName : String) -> ECGalleryItems? {
        let galleryItems = ECGalleryItems()
        let document = ECGalleryCBManager.sharedInstance.docAtIndex(index, keyName: dbName)
        let userProperties = document?.userProperties
        galleryItems.galleryTitle = (userProperties?[kGalleryTitle] as! String)
        galleryItems.galleryDescription = (userProperties?[kGalleryDescription] as! String)
        galleryItems.galleryImagePath = (userProperties?[kGalleryImagePath] as! String)
        galleryItems.galleryLikeCount = (userProperties?[kGalleryLikeCount] as! NSInteger)
        galleryItems.galleryCommentsCount = (userProperties?[kGalleryCommentsCount] as! NSInteger)
        galleryItems.galleryCreatedDate = (userProperties?[kGalleryCreatedDate] as! String)
        print("Place name = \(galleryItems.galleryTitle)")
        return galleryItems
    }
    
    // Deletes a Document in database
    func deleteDocAtIndex(_ index:Int, keyName : String) {
        do {
            // 1: Get the document associated with the row
            let document = ECGalleryCBManager.sharedInstance.docAtIndex(index, keyName: keyName)
            print("doc to remove  \(String(describing: document?.userProperties))")
            
            // 2: Delete the document
            try document?.delete()
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
    func docAtIndex(_ index:Int, keyName : String) -> CBLDocument? {
        let docsEnumerator:CBLQueryEnumerator? = self.documentsDictionary[keyName] as? CBLQueryEnumerator
        // 1. Get the CBLQueryRow object at specified index
        let queryRow = docsEnumerator?.row(at: UInt(index))
        
//        let sortDesc : NSSortDescriptor = NSSortDescriptor(key: DocumentGalleryProperties.placeName.rawValue, ascending: true)
//        docsEnumerator?.sort(usingDescriptors: [sortDesc])
        // 2: Get the document associated with the row
        let doc = queryRow?.document
        return doc
    }
    
    func addLiveQueryObserverAndStartObserving(keyPath : String) {
        guard let liveQuery = liveQuery else {
            return
        }
        
        // 1. iOS Specific. Add observer to the live Query object
        liveQuery.addObserver(self as NSObject, forKeyPath: keyPath, options: NSKeyValueObservingOptions.new, context: nil)
        
        // 2. Start observing changes
        liveQuery.start()
    }
    
    func removeLiveQueryObserverAndStopObserving(controller : AnyObject, keyPath : String) {
        guard let liveQuery = liveQuery else {
            return
        }
        // 1. iOS Specific. Remove observer from the live Query object
        liveQuery.removeObserver(self as NSObject, forKeyPath: keyPath)
        
        // 2. Stop observing changes
        liveQuery.stop()
    }
}
