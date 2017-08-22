//
//  ECMenuViewController.swift
//  ECApp
//
//  Created by Pradeep on 7/13/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import UIKit

class ECMenuViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var mainViewController: UIViewController!
    var selectedIndex : NSInteger = 0
    
    @IBOutlet weak var menuCollectionView: UICollectionView!
    
    let reuseIdentifier = "ECMenuCellIdentifier" // also enter this string as the cell identifier in the storyboard
    let menuHeaderIdentifier = "MenuHeaderViewIdentifier"
    
    var menuArray : [String] = ["Home", "Local News", "Movies", "Transit", "Civic", "Dasara", "Jobs", "Blood Bank"]
    
    var menuItemsLiveQuery: CBLLiveQuery!
    var menuItemRows : [CBLQueryRow]?
    
    var menuItemsArray : [ECMenuItems] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        if menuItemsLiveQuery != nil {
            menuItemsLiveQuery.removeObserver(self, forKeyPath: "rows")
            menuItemsLiveQuery.stop()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuCollectionView!.register(UINib(nibName: ECMenuCell.self.className, bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.menuCollectionView!.register(UINib(nibName: ECMenuHeaderView.self.className, bundle: nil), forCellWithReuseIdentifier: menuHeaderIdentifier)
        self.setNavigationBarItem()
        self.setupViewAndQuery()
    }
    
    // MARK: - Database
    
    func setupViewAndQuery() {
        // TRAINING: Running a Query
        menuItemsLiveQuery = ECMenuCBManager.sharedInstance.queryMenuItemsInDataBase().asLive()
        menuItemsLiveQuery.addObserver(self, forKeyPath: "rows", options: .new, context: nil)
        menuItemsLiveQuery.start()
        self.initializeMenuItems()
    }
    
    func initializeMenuItems() {
        for index in 0...(menuArray.count - 1) {
            let menuItemObject = ECMenuItems(menuItemName: menuArray[index], menuItemImageName: "icn_fav_normal", orderNumber:index)
            ECMenuCBManager.sharedInstance.createMenuDocWith(menuItem: menuItemObject)
        }
    }

    func updateMenuItemRows() {
        self.sortArrayElements()
        menuItemRows = menuItemsLiveQuery.rows?.allObjects as? [CBLQueryRow] ?? nil
        if (menuItemRows != nil && (menuItemRows?.count)! > 0) {
            self.menuItemsArray.removeAll()
            for index in 0..<(menuItemRows?.count)! {
                let row = menuItemRows![index] as CBLQueryRow
                let menuModel = row.document
                let userProperties = menuModel?.userProperties
                
                let menuItemName = (userProperties?[kMenuItemName] as? String)!
                let menuItemImageName = (userProperties?[kMenuItemImageName] as? String)!
                let menuItem = ECMenuItems(menuItemName: menuItemName, menuItemImageName: menuItemImageName, orderNumber:index)
                menuItem.menuItemId = row.documentID!
                self.menuItemsArray.append(menuItem)
            }
        }
    }
    
    // TRAINING: Responding to Live Query changes
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as? NSObject == menuItemsLiveQuery {
            self.reloadMenuCollectionView()
        }
    }
    
    func reloadMenuCollectionView() {
        self.updateMenuItemRows()
        menuCollectionView.reloadData()
    }
    
    func sortArrayElements() {
        let app = UIApplication.shared.delegate as! AppDelegate
        let menuView = app.database.viewNamed(kMenuQueryView)
        menuView.setMapBlock({ (doc, emit) in
            if (doc[kMenuTypeKey] as? String == kMenuTypeValue) {
                emit([doc[kMenuOrderNumber]!],nil)
            }
        }, version: "1")
        
        let query = menuView.createQuery()
        query.limit = 1
        do { let result = try query.run()
            while let row = result.nextRow() {
                if row.document?.properties?[kMenuTypeKey] != nil {
                } else {
                }
            }
        } catch { return }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func itemWidth() -> CGFloat {
        return (menuCollectionView!.frame.size.width/2)-35
    }
    
    func itemHeight() -> CGFloat {
        return (menuCollectionView!.frame.size.width/2)-35
    }
    
    var itemSize: CGSize {
        set {
            self.itemSize = CGSize(width:itemWidth(), height:itemHeight())
        }
        get {
            return CGSize(width:itemWidth(),height:itemHeight())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width:self.menuCollectionView.frame.size.width, height:150)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header:ECMenuHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: menuHeaderIdentifier, for: indexPath) as! ECMenuHeaderView
        header.profileName?.text = "Jessica Tyalor"
        header.profileAddress?.text = "Bengaluru, India"
        header.profileImageView?.image = UIImage(named: "mood3")
        header.profileName.verticalAlignment = .bottom
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int (self.menuItemsArray.count)
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ECMenuCell
        
        let myMenuItem : ECMenuItems = self.menuItemsArray[indexPath.row]
        cell.menuCellImageView?.image = UIImage(named: (myMenuItem.menuItemImageName))
        cell.menuItemTitleLabel?.text = myMenuItem.menuItemName
        if self.selectedIndex == indexPath.row {
            cell.backgroundColor = UIColor.subTheme()
        }else {
            cell.backgroundColor = UIColor.menuItemBg()
        }
        return cell
    }    
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
        self.selectedIndex = indexPath.row
        self.menuCollectionView.reloadData()
        self.slideMenuController()?.closeLeft()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

