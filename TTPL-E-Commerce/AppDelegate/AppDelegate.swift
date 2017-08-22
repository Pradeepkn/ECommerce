//
//  AppDelegate.swift
//  ECApp
//
//  Created by Pradeep on 6/26/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import UIKit
import CoreData
import SlideMenuControllerSwift

let kLoginFlowEnabled = false
let kEncryptionEnabled = false
let kSyncEnabled = false
let kSyncGatewayUrl = URL(string: "http://localhost:4984/todo/")!
let kLoggingEnabled = false
let kUsePrebuiltDb = false
let kConflictResolution = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var database: CBLDatabase!
    var pusher: CBLReplication!
    var puller: CBLReplication!
    var syncError: NSError?
    var conflictsLiveQuery: CBLLiveQuery?
    var accessDocuments: Array<CBLDocument> = [];
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        if kLoggingEnabled {
            enableLogging()
        }
        
        if kLoginFlowEnabled {
            login()
        } else {
            do {
                try startSession(username: "ecommerceapp")
            } catch let error as NSError {
                NSLog("Cannot start a session: %@", error)
                return false
            }
        }
        self.createMenuView()
        return true
    }
    
    fileprivate func createMenuView() {
        
        // create viewController code...
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainViewController = storyboard.instantiateViewController(withIdentifier: ECBaseViewController.self.className) as! ECBaseViewController
        let leftViewController = storyboard.instantiateViewController(withIdentifier: ECMenuViewController.self.className) as! ECMenuViewController

        let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
        
        UINavigationBar.appearance().tintColor = UIColor.blue
        leftViewController.mainViewController = nvc
        
        let slideMenuController = SlideMenuController(mainViewController:nvc, leftMenuViewController: leftViewController, rightMenuViewController: UIViewController())
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        slideMenuController.delegate = mainViewController
        slideMenuController.changeLeftViewWidth((self.window?.frame.size.width)! - 60)
        self.window?.backgroundColor = mainViewController.view.backgroundColor
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
        UIApplication.shared.statusBarStyle = .lightContent
    }

    // MARK: - Logging
    func enableLogging() {
        CBLManager.enableLogging("CBLDatabase")
        CBLManager.enableLogging("View")
        CBLManager.enableLogging("ViewVerbose")
        CBLManager.enableLogging("Query")
        CBLManager.enableLogging("Sync")
        CBLManager.enableLogging("SyncVerbose")
    }
    
    // MARK: - Session
    
    func startSession(username:String, withPassword password:String? = nil,
                      withNewPassword newPassword:String? = nil) throws {
//        installPrebuiltDb()
        try openDatabase(username: username, withKey: password, withNewKey: newPassword)
        Session.username = username
        startReplication(withUsername: username, andPassword: newPassword ?? password)
        showApp()
        startConflictLiveQuery()
    }
    
    func installPrebuiltDb() {
        // TRAINING: Install pre-built database
        guard kUsePrebuiltDb else {
            return
        }
        
        let db = CBLManager.sharedInstance().databaseExistsNamed("ecommerceapp")
        
        if (!db) {
            let dbPath = Bundle.main.path(forResource: "ecommerceapp", ofType: "cblite2")
            do {
                try CBLManager.sharedInstance().replaceDatabaseNamed("ecommerceapp", withDatabaseDir: dbPath!)
            } catch let error as NSError {
                NSLog("Cannot replace the database %@", error)
            }
        }
    }
    
    func openDatabase(username:String, withKey key:String?,
                      withNewKey newKey:String?) throws {
        // TRAINING: Create a database
        let dbname = username
        let options = CBLDatabaseOptions()
        options.create = true
        
        if kEncryptionEnabled {
            if let encryptionKey = key {
                options.encryptionKey = encryptionKey
            }
        }
        
        try database = CBLManager.sharedInstance().openDatabaseNamed(dbname, with: options)
        if newKey != nil {
            try database.changeEncryptionKey(newKey)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.observeDatabaseChange), name:Notification.Name.cblDatabaseChange, object: database)
    }
    
    func observeDatabaseChange(notification: Notification) {
        if(!(notification.userInfo?["external"] as! Bool)) {
            return;
        }
        
        for change in notification.userInfo?["changes"] as! Array<CBLDatabaseChange> {
            if(!change.isCurrentRevision) {
                continue;
            }
            
            let changedDoc = database.existingDocument(withID: change.documentID);
            if(changedDoc == nil) {
                return;
            }
            
            let docType = changedDoc?.properties?["type"] as! String?;
            if(docType == nil) {
                continue;
            }
            
            if(docType != "menu-list.user") {
                continue;
            }
            
            let username = changedDoc?.properties?["username"] as! String?;
            if(username != database.name) {
                continue;
            }
            
            accessDocuments.append(changedDoc!);
            NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.handleAccessChange), name: NSNotification.Name.cblDocumentChange, object: changedDoc);
        }
    }
    
    func handleAccessChange(notification: Notification) throws {
        let change = notification.userInfo?["change"] as! CBLDatabaseChange;
        let changedDoc = database.document(withID: change.documentID);
        if(changedDoc == nil || !(changedDoc?.isDeleted)!) {
            return;
        }
        
        let deletedRev = try changedDoc?.getLeafRevisions()[0];
        let listId = (deletedRev?["menuList"] as! Dictionary<String, NSObject>)["id"] as! String?;
        if(listId == nil) {
            return;
        }
        
        accessDocuments.remove(at: accessDocuments.index(of: changedDoc!)!);
        let listDoc = database.existingDocument(withID: listId!);
        try listDoc?.purgeDocument();
        try changedDoc?.purgeDocument()
    }
    
    func closeDatabase() throws {
        stopConflictLiveQuery()
        try database.close()
    }
    
    // MARK: - Login
    
    func login(username: String? = nil) {
        let storyboard =  window!.rootViewController!.storyboard
        let navigation = storyboard!.instantiateViewController(
            withIdentifier: "ECLoginViewController") as! UINavigationController
        let loginController = navigation.topViewController as! ECLoginViewController
//        loginController.delegate = self
//        loginController.username = username
        window!.rootViewController = navigation
    }
    
    func logout() {
        stopReplication()
        do {
            try closeDatabase()
        } catch let error as NSError {
            NSLog("Cannot close database: %@", error)
        }
        let oldUsername = Session.username
        Session.username = nil
        login(username: oldUsername)
    }
    
    func showApp() {
        guard let root = window?.rootViewController, let storyboard = root.storyboard else {
            return
        }
        
        let controller = storyboard.instantiateInitialViewController()
        window!.rootViewController = controller
    }
    
    // MARK: - LoginViewControllerDelegate
    
    func login(controller: UIViewController, withUsername username: String,
               andPassword password: String) {
        processLogin(controller: controller, withUsername: username, withPassword: password)
    }
    
    func processLogin(controller: UIViewController, withUsername username: String,
                      withPassword password: String, withNewPassword newPassword: String? = nil) {
        do {
            try startSession(username: username, withPassword: password,
                             withNewPassword: newPassword)
        } catch let error as NSError {
            if error.code == 401 {
                handleEncryptionError(controller: controller, withUsername: username,
                                      withPassword: password)
            } else {
                Ui.showMessageDialog(
                    onController: controller,
                    withTitle: "Error",
                    withMessage: "Login has an error occurred, code = \(error.code).")
                NSLog("Cannot start a session: %@", error)
            }
        }
    }
    
    func handleEncryptionError(controller: UIViewController, withUsername username: String,
                               withPassword password: String) {
        Ui.showEncryptionErrorDialog(
            onController: controller,
            onMigrateAction: { oldPassword in
                self.processLogin(controller: controller, withUsername: username,
                                  withPassword: oldPassword, withNewPassword: password)
        },
            onDeleteAction: {
                // Delete database:
                self.deleteDatabase(dbName: username)
                // login:
                self.processLogin(controller: controller, withUsername: username,
                                  withPassword: password)
        }
        )
    }
    
    func deleteDatabase(dbName: String) {
        // Delete the database by using file manager. Currently CBL doesn't have
        // an API to delete an encrypted database so we remove the database
        // file manually as a workaround.
        let dir = NSURL(fileURLWithPath: CBLManager.sharedInstance().directory)
        let dbFile = dir.appendingPathComponent("\(dbName).cblite2")
        do {
            try FileManager.default.removeItem(at: dbFile!)
        } catch let err as NSError {
            NSLog("Error when deleting the database file: %@", err)
        }
    }
    
    // MARK: - Replication
    
    func startReplication(withUsername username:String, andPassword password:String? = "") {
        guard kSyncEnabled else {
            return
        }
        
        syncError = nil
        
        // TRAINING: Start push/pull replications
        pusher = database.createPushReplication(kSyncGatewayUrl)
        pusher.continuous = true  // Runs forever in background
        NotificationCenter.default.addObserver(self, selector: #selector(replicationProgress(notification:)),
                                               name: NSNotification.Name.cblReplicationChange, object: pusher)
        
        puller = database.createPullReplication(kSyncGatewayUrl)
        puller.continuous = true  // Runs forever in background
        NotificationCenter.default.addObserver(self, selector: #selector(replicationProgress(notification:)),
                                               name: NSNotification.Name.cblReplicationChange, object: puller)
        
        if kLoginFlowEnabled {
            let authenticator = CBLAuthenticator.basicAuthenticator(withName: username, password: password!)
            pusher.authenticator = authenticator
            puller.authenticator = authenticator
        }
        
        pusher.start()
        puller.start()
    }
    
    func stopReplication() {
        guard kSyncEnabled else {
            return
        }
        
        pusher.stop()
        NotificationCenter.default.removeObserver(
            self, name: NSNotification.Name.cblReplicationChange, object: pusher)
        
        puller.stop()
        NotificationCenter.default.removeObserver(
            self, name: NSNotification.Name.cblReplicationChange, object: puller)
    }
    
    func replicationProgress(notification: NSNotification) {
        UIApplication.shared.isNetworkActivityIndicatorVisible =
            (pusher.status == .active || puller.status == .active)
        
        let error = pusher.lastError as NSError?;
        if (error != syncError) {
            syncError = error
            if let errorCode = error?.code {
                NSLog("Replication Error: \(error!)")
                if errorCode == 401 {
                    Ui.showMessageDialog(
                        onController: self.window!.rootViewController!,
                        withTitle: "Authentication Error",
                        withMessage:"Your username or password is not correct.",
                        withError: nil,
                        onClose: {
                            self.logout()
                    })
                }
            }
        }
    }
    
    // MARK: - Conflicts Resolution
    
    // TRAINING: Responding to Live Query changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == conflictsLiveQuery {
            resolveConflicts()
        }
    }
    
    func startConflictLiveQuery() {
        guard kConflictResolution else {
            return
        }
        
        // TRAINING: Detecting when conflicts occur
        conflictsLiveQuery = database.createAllDocumentsQuery().asLive()
        conflictsLiveQuery!.allDocsMode = .onlyConflicts
        conflictsLiveQuery!.addObserver(self, forKeyPath: "rows", options: .new, context: nil)
        conflictsLiveQuery!.start()
    }
    
    func stopConflictLiveQuery() {
        conflictsLiveQuery?.removeObserver(self, forKeyPath: "rows")
        conflictsLiveQuery?.stop()
        conflictsLiveQuery = nil
    }
    
    func resolveConflicts() {
        let rows = conflictsLiveQuery?.rows
        while let row = rows?.nextRow() {
            if let revs = row.conflictingRevisions, revs.count > 1 {
                let defaultWinning = revs[0]
                let type = (defaultWinning["type"] as? String) ?? ""
                switch type {
                // TRAINING: Automatic conflict resolution
                case "menu-list", "menu-list.user":
                    let props = defaultWinning.userProperties
                    let image = defaultWinning.attachmentNamed("image")
                    resolveConflicts(revisions: revs, withProps: props, andImage: image)
                // TRAINING: N-way merge conflict resolution
                case "menu":
                    let merged = nWayMergeConflicts(revs: revs)
                    resolveConflicts(revisions: revs, withProps: merged.props, andImage: merged.image)
                default:
                    break
                }
            }
        }
    }
    
    func resolveConflicts(revisions revs: [CBLRevision], withProps desiredProps: [String: Any]?,
                          andImage desiredImage: CBLAttachment?) {
        database.inTransaction {
            var i = 0
            for rev in revs as! [CBLSavedRevision] {
                let newRev = rev.createRevision()  // Create new revision
                if (i == 0) { // That's the current / winning revision
                    
                    
                    newRev.userProperties = desiredProps // Set properties to desired properties
                    if rev.attachmentNamed("image") != desiredImage {
                        newRev.setAttachmentNamed("image", withContentType: "image/jpg",
                                                  content: desiredImage?.content)
                    }
                } else {
                    // That's a conflicting revision, delete it
                    newRev.isDeletion = true
                }
                
                do {
                    try newRev.saveAllowingConflict()  // Persist the new revisions
                } catch let error as NSError {
                    NSLog("Cannot resolve conflicts with error: %@", error)
                    return false
                }
                i += 1
            }
            return true
        }
    }
    
    func nWayMergeConflicts(revs: [CBLRevision]) ->
        (props: [String: Any]?, image: CBLAttachment?) {
            guard let parent = findCommonParent(revisions: revs) else {
                let defaultWinning = revs[0]
                let props = defaultWinning.userProperties
                let image = defaultWinning.attachmentNamed("image")
                return (props, image)
            }
            
            var mergedProps = parent.userProperties ?? [:]
            var mergedImage = parent.attachmentNamed("image")
            var gotTask = false, gotComplete = false, gotImage = false
            for rev in revs {
                if let props = rev.userProperties {
                    if !gotTask {
                        let task = props["menu"] as? String
                        if task != mergedProps["menu"] as? String {
                            mergedProps["menu"] = task
                            gotTask = true
                        }
                    }
                    
                    if !gotComplete {
                        let complete = props["complete"] as? Bool
                        if complete != mergedProps["complete"] as? Bool {
                            mergedProps["complete"] = complete
                            gotComplete = true
                        }
                    }
                }
                
                if !gotImage {
                    let attachment = rev.attachmentNamed("image")
                    let attachmentDiggest = attachment?.metadata["digest"] as? String
                    if (attachmentDiggest != mergedImage?.metadata["digest"] as? String) {
                        mergedImage = attachment
                        gotImage = true
                    }
                }
                
                if gotTask && gotComplete && gotImage {
                    break
                }
            }
            return (mergedProps, mergedImage)
    }
    
    func findCommonParent(revisions: [CBLRevision]) -> CBLRevision? {
        var minHistoryCount = 0
        var histories : [[CBLRevision]] = []
        for rev in revisions {
            let history = (try? rev.getHistory()) ?? []
            histories.append(history)
            minHistoryCount =
                minHistoryCount > 0 ? min(minHistoryCount, history.count) : history.count
        }
        
        if minHistoryCount == 0 {
            return nil
        }
        
        var commonParent : CBLRevision? = nil
        for i in 0...minHistoryCount {
            var rev: CBLRevision? = nil
            for history in histories {
                if rev == nil {
                    rev = history[i]
                } else if rev!.revisionID != history[i].revisionID {
                    rev = nil
                    break
                }
            }
            if rev == nil {
                break
            }
            commonParent = rev
        }
        
        if let deleted = commonParent?.isDeletion , deleted {
            commonParent = nil
        }
        return commonParent
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ecommerceapp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

