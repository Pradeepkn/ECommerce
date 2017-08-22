//
//  ECBaseViewController.swift
//  ECApp
//
//  Created by Pradeep on 7/2/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import UIKit
import SlideMenuControllerSwift

enum selctedMenuItem : Int {
    case All
    case iOS
    case Android
    case Events
    case Mobility
}

// Define identifier
let refreshGalleryNotificationIdentifier = Notification.Name("RefreshGalleryNotificationIdentifier")

enum GalleryCategory : String {
    case All = "All", iOS = "iOS", Android = "Android", Events = "Events", Mobility = "Mobility"
    static let allValues = [All, iOS, Android, Events, Mobility]
}

private let nibNameIdentifier = "ECGalleryViewController"

let kGalleryDataSource = "galleryDataSource"

var moodArray           : [String] = ["Relaxed", "Playful", "Happy", "Adventurous",
                                      "Wealthy", "Hungry", "Loved", "Active"]
var bgGalleryImageArray : [String] = ["mood1", "mood2", "mood3", "mood4",
                                      "mood5", "mood6", "mood7", "mood8"]
var galleryItemsLiveQuery: CBLLiveQuery!
var galleryItemRows : [CBLQueryRow]?
var galleryItemsArray : [ECGalleryItems] = []

class ECBaseViewController: UIViewController, CAPSPageMenuDelegate {

    var pageMenu                    : CAPSPageMenu?
    var controllerArray             : [UIViewController] = []
    var selectedGalleryCategoryType : GalleryCategory? = GalleryCategory.All
    var galleryLiveQueryDict        = [String : CBLLiveQuery]()
    var galleryRowsDict             = [String : AnyObject]()
    var galleryDataSource           = [String : AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "EC App"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.navigationBar()
        self.setNavigationBarItem()
        self.addMenuControllers()
        self.pageMenu?.delegate=self
        self.addButton()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func addMenuControllers() {
        for category in GalleryCategory.allValues{
            switch category {
            case .All:
                let allGalleryVC : ECGalleryViewController = ECGalleryViewController(nibName: nibNameIdentifier, bundle: nil)
                allGalleryVC.title = GalleryCategory.All.rawValue
                allGalleryVC.selectedGalleryType = GalleryCategory.All
                controllerArray.append(allGalleryVC)
                self.initializeAllGalleryItems(allController: allGalleryVC, dbName: GalleryCategory.All.rawValue, galleryType: GalleryCategory.All)
            case .iOS:
                let iOSGalleryVC : ECGalleryViewController = ECGalleryViewController(nibName: nibNameIdentifier, bundle: nil)
                iOSGalleryVC.title = GalleryCategory.iOS.rawValue
                controllerArray.append(iOSGalleryVC)
                self.initializeAllGalleryItems(allController: iOSGalleryVC, dbName: GalleryCategory.iOS.rawValue, galleryType: GalleryCategory.iOS)
            case .Android:
                let attractionGalleryVC : ECGalleryViewController = ECGalleryViewController(nibName: nibNameIdentifier, bundle: nil)
                attractionGalleryVC.title = GalleryCategory.Android.rawValue
                controllerArray.append(attractionGalleryVC)
                self.initializeAllGalleryItems(allController: attractionGalleryVC, dbName: GalleryCategory.Android.rawValue, galleryType: GalleryCategory.Android)
            case .Events:
                let eventsGalleryVC : ECGalleryViewController = ECGalleryViewController(nibName: nibNameIdentifier, bundle: nil)
                eventsGalleryVC.title = GalleryCategory.Events.rawValue
                controllerArray.append(eventsGalleryVC)
                self.initializeAllGalleryItems(allController: eventsGalleryVC, dbName: GalleryCategory.Events.rawValue, galleryType: GalleryCategory.Events)
            case .Mobility:
                let templeGalleryVC : ECGalleryViewController = ECGalleryViewController(nibName: nibNameIdentifier, bundle: nil)
                templeGalleryVC.title = GalleryCategory.Mobility.rawValue
                controllerArray.append(templeGalleryVC)
                self.initializeAllGalleryItems(allController: templeGalleryVC, dbName: GalleryCategory.Mobility.rawValue, galleryType: GalleryCategory.Mobility)
            }
        }
        
        // Customize menu (Optional)
        let parameters: [CAPSPageMenuOption] = [
            .ScrollMenuBackgroundColor(UIColor.selectedPageMenuLabel()),
            .MenuItemSeparatorWidth(0.0),
            .ViewBackgroundColor(UIColor.selectedPageMenuLabel()),
            .SelectionIndicatorColor(UIColor.selectedPageMenuLabel()),
            .MenuItemFont(UIFont(name: "HelveticaNeue", size: 14.0)!),
            .MenuMargin(0.0),
            .MenuHeight(40.0),
            .MenuItemWidth(80.0),
            .CenterMenuItems(true),
            .UnselectedMenuItemLabelColor(UIColor.unselectedPageMenuLabel())
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: 64, width: self.view.frame.width, height: self.view.frame.height - 64), pageMenuOptions: parameters)
        
        self.addChildViewController(pageMenu!)
        self.view.addSubview(pageMenu!.view)
        pageMenu!.didMove(toParentViewController: self)
        self.setupViewAndQuery()
    }
    
    func setupViewAndQuery() {
        // TRAINING: Running a Query
        galleryItemsLiveQuery = ECGalleryCBManager.sharedInstance.queryGalleryItems().asLive()
        galleryItemsLiveQuery.addObserver(self, forKeyPath: "rows", options: .new, context: nil)
        galleryItemsLiveQuery.start()
    }
    
    func initializeAllGalleryItems(allController:AnyObject, dbName:String, galleryType:GalleryCategory) {
//        self.setupViewAndQuery(galleryType: galleryType.rawValue)
    }
    
    // TRAINING: Responding to Live Query changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == galleryItemsLiveQuery {
            self.updateGalleryItems()
        }
//
//        for (galleryType, liveQuery) in self.galleryLiveQueryDict {
//            if (object as? NSObject)! == liveQuery as NSObject {
//                print(galleryType)
//                if galleryType == self.selectedGalleryCategoryType?.rawValue {
//                    let listRows = liveQuery.rows?.allObjects as? [CBLQueryRow] ?? nil
//                    print(listRows?.count ?? 0)
//                    self.updateMenuItemRows(liveQuery: liveQuery, galleryType: galleryType)
//                }
//            }
//        }
    }
    
    func updateGalleryItems() {
        galleryItemRows = (galleryItemsLiveQuery.rows?.allObjects as? [CBLQueryRow] ?? nil)!
        if (galleryItemRows != nil && (galleryItemRows?.count)! > 0) {
            for index in 0..<(galleryItemRows?.count)! {
                let queryRow = galleryItemRows![index] as CBLQueryRow
                let galleryItemObject = ECGalleryItems()
                let userProperties = queryRow.document?.userProperties
                let galleryType = (userProperties?[kGalleryTypeValue] as? String)!
                galleryItemObject.galleryTitle      = (userProperties?[kGalleryTitle] as? String)!
                galleryItemObject.galleryDescription = (userProperties?[kGalleryDescription] as? String)!
                galleryItemObject.galleryImagePath  = (userProperties?[kGalleryImagePath] as? String)!
                galleryItemObject.galleryTypeKey = kGalleryTypeKey
                galleryItemObject.galleryLikeCount  = 0
                galleryItemObject.galleryCommentsCount = 0
                galleryItemObject.galleryCreatedDate = self.dateToString(date: Date())
                galleryItemObject.galleryTypeValue = galleryType
                galleryItemObject.galleryOrderNumber = index
                galleryItemObject.galleryDocumentId = queryRow.documentID!
                galleryItemObject.galleryItemCreatedBy = (userProperties?[kGalleryItemCreatedBy] as? String)!
                self.updateDataSourceWith(galleryItemObject: galleryItemObject, galleryType: galleryType)
            }
        }
        self.postUpdateNotification()
    }

    func updateDataSourceWith(galleryItemObject :ECGalleryItems, galleryType:String) {
        if self.galleryDataSource[galleryType] != nil {
            var dataSourceArray : [ECGalleryItems] = self.galleryDataSource[galleryType] as! [ECGalleryItems]
            if dataSourceArray.contains(where: { $0.galleryDocumentId == galleryItemObject.galleryDocumentId }) {
            }else {
                dataSourceArray.append(galleryItemObject)
            }
            self.galleryDataSource[galleryType] = dataSourceArray as AnyObject
        }else {
            var galleryItemsArray : [ECGalleryItems] = []
            galleryItemsArray.append(galleryItemObject)
            self.galleryDataSource[galleryType] = galleryItemsArray as AnyObject
        }
    }
    
    func postUpdateNotification() {
        let dataSorceNotificationDict:[String: AnyObject] = [kGalleryDataSource: (self.galleryDataSource as AnyObject), kGalleryTypeValue : self.selectedGalleryCategoryType as AnyObject]
        // post a notification
        NotificationCenter.default.post(name: refreshGalleryNotificationIdentifier, object: nil, userInfo: dataSorceNotificationDict)
    }
    
    deinit {
        for (galleryType, liveQuery) in self.galleryLiveQueryDict {
            print(galleryType)
            liveQuery.removeObserver(self, forKeyPath: "rows")
            liveQuery.stop()
        }
        // Stop listening notification
        NotificationCenter.default.removeObserver(self, name: refreshGalleryNotificationIdentifier, object: nil)
    }

    // MARK: - Database
    
    func setupViewAndQuery(galleryType:String) {
        // TRAINING: Running a Query
        let galleryItemsLiveQuery :CBLLiveQuery  = ECGalleryCBManager.sharedInstance.queryGalleryItemsInDataBase(galleryType: galleryType).asLive()
        galleryItemsLiveQuery.addObserver(self, forKeyPath: "rows", options: .new, context: nil)
        galleryItemsLiveQuery.start()
        self.galleryLiveQueryDict[galleryType] = galleryItemsLiveQuery
    }
    
    func updateMenuItemRows(liveQuery : CBLLiveQuery, galleryType:String) {
        var galleryItemRows : [CBLQueryRow] = []
        if liveQuery.rows == nil {
            return
        }
        self.sortArrayElements(galleryType: galleryType)
        galleryItemRows = (liveQuery.rows?.allObjects as? [CBLQueryRow] ?? nil)!
        if (galleryItemRows.count > 0) {
            var galleryItemsArray : [ECGalleryItems] = []
            for index in 0..<(galleryItemRows.count) {
                let queryRow : CBLQueryRow = galleryItemRows[index]
                let galleryItemObject = ECGalleryItems()
                let userProperties = queryRow.document?.userProperties

                galleryItemObject.galleryTitle      = (userProperties?[kGalleryTitle] as? String)!
                galleryItemObject.galleryDescription = (userProperties?[kGalleryDescription] as? String)!
                galleryItemObject.galleryImagePath  = (userProperties?[kGalleryImagePath] as? String)!
                galleryItemObject.galleryTypeKey = kGalleryTypeKey
                galleryItemObject.galleryLikeCount  = 0
                galleryItemObject.galleryCommentsCount = 0
                galleryItemObject.galleryCreatedDate = self.dateToString(date: Date())
                galleryItemObject.galleryTypeValue = (self.selectedGalleryCategoryType?.rawValue)!
                galleryItemObject.galleryOrderNumber = index
                galleryItemObject.galleryDocumentId = queryRow.documentID!
                galleryItemObject.galleryItemCreatedBy = (userProperties?[kGalleryItemCreatedBy] as? String)!
                galleryItemsArray.append(galleryItemObject)
            }
            self.galleryRowsDict[galleryType] = galleryItemRows as AnyObject
            self.galleryDataSource[galleryType] = galleryItemsArray as AnyObject
            
            let dataSorceNotificationDict:[String: AnyObject] = ["datasource": (self.galleryDataSource as AnyObject),"queryRowArray": (self.galleryRowsDict as AnyObject)]

            // post a notification
            NotificationCenter.default.post(name: refreshGalleryNotificationIdentifier, object: nil, userInfo: dataSorceNotificationDict)
            // `default` is now a property, not a method call
        }
    }
    
    func sortArrayElements(galleryType : String) {
        let app = UIApplication.shared.delegate as! AppDelegate
        let galleryView = app.database.viewNamed(galleryType)
        galleryView.setMapBlock({ (doc, emit) in
            if (doc[kGalleryTypeKey] as? String == self.selectedGalleryCategoryType?.rawValue) {
                emit([doc[kGalleryOrderNumber]!],nil)
            }
        }, version: "1")
        
        let query = galleryView.createQuery()
        query.limit = 1
        do { let result = try query.run()
            while let row = result.nextRow() {
                if row.document?.properties?[kGalleryTypeKey] != nil {
                } else {
                }
            }
        } catch { return }
    }
    
    func stringToDate(dateString:String) -> Date {
        //String to Date Convert
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateFromString = dateFormatter.date(from:dateString)
        print(dateFromString!)
        return dateFromString!
    }
    
    func dateToString(date : Date) -> String {
        //CONVERT FROM NSDate to String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from:date as Date)
        print(dateString)
        return dateString
    }
    
    override func shouldAutomaticallyForwardRotationMethods() -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func willMoveToPage(controller: UIViewController, index: Int) {
        self.updateCategoryType(controller: controller, index: index)
    }
    
    func didMoveToPage(controller: UIViewController, index: Int) {
        self.updateCategoryType(controller: controller, index: index)
        self.postUpdateNotification()
    }
    
    func updateCategoryType(controller: UIViewController, index : Int) {
        let subview = controller as! ECGalleryViewController
        switch index {
        case 0:
            subview.selectedGalleryType = .All
        case 1:
            subview.selectedGalleryType = .iOS
        case 2:
            subview.selectedGalleryType = .Android
        case 3:
            subview.selectedGalleryType = .Events
        case 4:
            subview.selectedGalleryType = .Mobility
        default:
            break
        }
        self.selectedGalleryCategoryType = subview.selectedGalleryType
    }
    
    func addButton() {
        let button = UIButton()
        button.frame = CGRect(x: self.view.frame.size.width - 80, y: self.view.frame.size.height - 80, width: 70, height: 70)
        button.layer.cornerRadius = button.frame.width / 2
        button.layer.masksToBounds = true
        button.setImage(UIImage(named: "btn_upload"), for: .normal)
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    func buttonAction(sender: UIButton!) {
        let randomIndex = Int(arc4random_uniform(7) + 1)
        let orderNumberIndex = self.galleryDataSource.values.count
        let galleryType = (self.selectedGalleryCategoryType?.rawValue)!
        let galleryItemObject = ECGalleryItems()
        galleryItemObject.galleryTitle      = moodArray[randomIndex]
        galleryItemObject.galleryDescription = kSampleGalleryDescription
        galleryItemObject.galleryImagePath  = bgGalleryImageArray[randomIndex]
        galleryItemObject.galleryLikeCount  = 0
        galleryItemObject.galleryCommentsCount = 0
        galleryItemObject.galleryCreatedDate = self.dateToString(date: Date())
        galleryItemObject.galleryTypeValue = galleryType
        galleryItemObject.galleryOrderNumber = orderNumberIndex
        galleryItemObject.galleryTypeKey = kGalleryTypeValue
        galleryItemObject.galleryItemCreatedBy = "Pradeep"
        ECGalleryCBManager.sharedInstance.createGalleryDocWith(galleryItem: galleryItemObject)
    }

}

extension ECBaseViewController : SlideMenuControllerDelegate {
    
    func leftWillOpen() {
//        print("SlideMenuControllerDelegate: leftWillOpen")
    }
    
    func leftDidOpen() {
//        print("SlideMenuControllerDelegate: leftDidOpen")
    }
    
    func leftWillClose() {
//        print("SlideMenuControllerDelegate: leftWillClose")
    }
    
    func leftDidClose() {
//        print("SlideMenuControllerDelegate: leftDidClose")
    }
    
    func rightWillOpen() {
        self.slideMenuController()?.closeRight()
//        print("SlideMenuControllerDelegate: rightWillOpen")
    }
    
    func rightDidOpen() {
        self.slideMenuController()?.closeRight()
//        print("SlideMenuControllerDelegate: rightDidOpen")
    }
    
    func rightWillClose() {
//        print("SlideMenuControllerDelegate: rightWillClose")
    }
    
    func rightDidClose() {
//        print("SlideMenuControllerDelegate: rightDidClose")
    }
}

extension UIViewController {
    
    func setNavigationBarItem() {
        self.addLeftBarButtonWithImage(UIImage(named: "icn_list")!)
        self.addRightBarButtonWithImage(UIImage(named: "icn_search")!)
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
        self.slideMenuController()?.addLeftGestures()
        self.slideMenuController()?.addRightGestures()
    }
    
    func removeNavigationBarItem() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.rightBarButtonItem = nil
        self.slideMenuController()?.removeLeftGestures()
        self.slideMenuController()?.removeRightGestures()
    }
}
