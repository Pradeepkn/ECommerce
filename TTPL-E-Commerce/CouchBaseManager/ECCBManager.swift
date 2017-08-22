//
//  ECCBManager.swift
//  ECsoreApp
//
//  Created by Pradeep on 7/23/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import UIKit

let ecommerceAppDataBase = "ecommerceAppDataBase"
let menuItemKVOKey = "menuItems"
let kEncryptionKey = "seekrit"

class ECCBManager: NSObject {

    let cbManager:CBLManager = CBLManager.sharedInstance()
    
    var dbNames:[String]?
    
    var database:CBLDatabase?
    
    var loggedInUser:String?
    
    // This is the remote URL of the Sync Gateway (public Port)
    let kRemoteSyncUrl = "https://cdb.citypost.us:4984"
    
    let kDbName:String = "ecommerceapp" // CHANGE THIS TO THE NAME OF DATABASE THAT YOU HAVE CREATED ON YOUR SYNC GATEWAY VIA ADMIN PORT
    
    let kPublicDoc:String = "public"
    let kPrivateDoc:String = "private"
    
    var docsEnumerator:CBLQueryEnumerator? {
        didSet {
            
        }
    }
    
    var dbName:String? {
        didSet {
            getAllDatabases()
        }
    }

    var liveQuery:CBLLiveQuery?

    static let sharedInstance = ECCBManager()
    
    private override init() {
        print("ECCBManager Initialized")
    }
    
    // Creates a DB in local store
    func createDBWithName(_ name:String) {
        do {
            // 1: Set Database Options
            let options = CBLDatabaseOptions()
            options.storageType  = kCBLSQLiteStorage
            options.create = true
            if kEncryptionEnabled {
                options.encryptionKey = kEncryptionKey
            }
            // 2: Create a DB if it does not exist else return handle to existing one
            self.database  = try cbManager.openDatabaseNamed(name.lowercased(), with: options)
            print("Database \(name) was created succesfully at path \(CBLManager.defaultDirectory())")
        }
        catch  {
            print("Database \(name) creation failed:\(error.localizedDescription)")
        }
    }
    
    func getAllDatabases() {
        self.dbNames = cbManager.allDatabaseNames
    }
    
    func getAllDocumentsForDataBase(name : String) -> CBLDatabase {
        // 1. Get handle to DB with specified name
        
        do {
            if dbName != nil{
                self.database = try cbManager.existingDatabaseNamed(name)
            }
        }catch {
            
        }
        return self.database!
    }
    
    // Deletes a Document in database
    func deleteDocAtIndex(_ index:Int) {
        do {
            // 1: Get the document associated with the row
            let doc = self.docAtIndex(index)
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
    
    // Creates a DB in local store if it does not exist
    func openDatabaseForUser(dbName:String, user:String, password:String)-> Bool {
        
        do {
            // 1: Set Database Options
            let options = CBLDatabaseOptions()
            options.storageType  = kCBLSQLiteStorage
            options.create = true
            
            // 2: Create a DB for logged in user if it does not exist else return handle to existing one
            self.database  = try cbManager.openDatabaseNamed(dbName.lowercased(), with: options)
            
            // 3. Start replication with remote Sync Gateway
            startDatabaseReplicationForUser(user, password: password)
            return true
        }
        catch  {
            print("Failed to create database named \(user)")
        }
        return false
    }
    
    // Start Replication/ Synching with remote Sync Gateway
    func startDatabaseReplicationForUser(_ user:String, password:String) {
        
        // 1. Create Authenticator to be sent with every request.
                let auth = CBLAuthenticator.basicAuthenticator(withName: user, password: password)
        
        // 2. Create a Pull replication to start pulling from remote source
                self.startPullReplicationWithAuthenticator(auth)
        
        // 3. Create a Push replication to start pushing to  remote source
                self.startPushReplicationWithAuthenticator(auth)
        
        self.startPullReplication();
        
        // 4: Start Observing push/pull changes to/from remote database
        self.addRemoteDatabaseChangesObserverAndStartObserving()
        
    }
    
    func startPullReplication() {
        
        // 1: Create a Pull replication to start pulling from remote source
        let pullRepl = database?.createPullReplication(URL(string: kDbName, relativeTo: URL.init(string: kRemoteSyncUrl))!)
        
        // 2. Set Authenticator for pull replication
        //        pullRepl?.authenticator = auth
        
        // Continuously look for changes
        pullRepl?.continuous = true
        
        // Optionally, Set channels from which to pull
        // pullRepl?.channels = [...]
        
        // 4. Start the pull replicator
        pullRepl?.start()
        
    }
    
    func startPullReplicationWithAuthenticator(_ auth:CBLAuthenticatorProtocol?) {
        
        // 1: Create a Pull replication to start pulling from remote source
        let pullRepl = database?.createPullReplication(URL(string: kDbName, relativeTo: URL.init(string: kRemoteSyncUrl))!)
        
        // 2. Set Authenticator for pull replication
        pullRepl?.authenticator = auth
        
        // Continuously look for changes
        pullRepl?.continuous = true
        
        // Optionally, Set channels from which to pull
        // pullRepl?.channels = [...]
        
        // 4. Start the pull replicator
        pullRepl?.start()
    }
    
    func startPushReplicationWithAuthenticator(_ auth:CBLAuthenticatorProtocol?) {
        // 1: Create a push replication to start pushing to remote source
        let pushRepl = database?.createPushReplication(URL(string: kDbName, relativeTo: URL.init(string:kRemoteSyncUrl))!)
        
        // 2. Set Authenticator for push replication
        pushRepl?.authenticator = auth
        
        // Continuously push  changes
        pushRepl?.continuous = true
        
        // 3. Start the push replicator
        pushRepl?.start()
        
    }
    
    func addRemoteDatabaseChangesObserverAndStartObserving() {
        // 1. iOS Specific. Add observer to the NOtification Center to observe replicator changes
        NotificationCenter.default.addObserver(forName: NSNotification.Name.cblReplicationChange, object: nil, queue: nil) {_ in
            // Handle changes to the replicator status - Such as displaying progress
            // indicator when status is .running
        }
    }
    
    func removeRemoteDatabaseObserverAndStopObserving(controller:AnyObject) {
        // 1. iOS Specific. Remove observer from Replication state changes
        NotificationCenter.default.removeObserver(controller, name: NSNotification.Name.cblReplicationChange, object: nil)
    }
    
    func addLiveQueryObserverAndStartObserving() {
        guard let liveQuery = liveQuery else {
            return
        }
        
        // 1. iOS Specific. Add observer to the live Query object
        liveQuery.addObserver(self, forKeyPath: "rows", options: NSKeyValueObservingOptions.new, context: nil)
        
        // 2. Start observing changes
        liveQuery.start()
    }
    
    func removeLiveQueryObserverAndStopObserving() {
        guard let liveQuery = liveQuery else {
            return
        }
        // 1. iOS Specific. Remove observer from the live Query object
        liveQuery.removeObserver(self, forKeyPath: "rows")
        
        // 2. Stop observing changes
        liveQuery.stop()
    }

    func updateInputParameters(properties:[String : Any]?) {
        // Create a manager
//        let manager = CBLManager.sharedInstance()
        let database: CBLDatabase
        do {
            // Create or open the database named app
            database = try cbManager.databaseNamed("ecommerceapp".lowercased())
        } catch {
            print("Database creation or opening failed")
            return
        }
        
        // Create a new document
        let document: CBLDocument = database.createDocument()
        
        do {
            // Save the document to the database
            try document.putProperties(properties!)
        } catch {
            print("Can't save document in database")
            return
        }
        
        // Log the document ID (generated by the database)
        // and properties
        print("Document ID :: \(document.documentID)")
        print("Learning \(document.property(forKey: "sdk")!)")
        
//        // Create replicators to push & pull changes to & from Sync Gateway
//        let url = URL(string: "http://localhost:4984/hello")!
//        let push = database.createPushReplication(url)
//        let pull = database.createPullReplication(url)
//        push.continuous = true
//        pull.continuous = true
//        
//        // Start replicators
//        push.start()
//        pull.start()
    }
}
