//
//  ECGalleryViewController.swift
//  ECApp
//
//  Created by Kavya on 7/14/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import UIKit

private let reuseIdentifier = "GalleryCell" // also enter this string as the cell identifier in the storyboard

class ECGalleryViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var selectedGalleryType : GalleryCategory?
    var moodArray : [String] = ["Relaxed", "Playful", "Happy", "Adventurous", "Wealthy", "Hungry", "Loved", "Active"]
    var bgGalleryImageArray : [String] = ["mood1", "mood2", "mood3", "mood4", "mood5", "mood6", "mood7", "mood8"]
    var galleryRowsDict             = [String : AnyObject]()
    var galleryDataSource           = [String : AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Register cell classes
        self.collectionView!.register(UINib(nibName: "ECGalleryCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        // Register to receive notification in your class
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadGalleryView(_:)), name:  refreshGalleryNotificationIdentifier, object: nil)

    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadGalleryCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadGalleryCollectionView() {
        // Register cell classes
        self.collectionView!.register(UINib(nibName: "ECGalleryCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.reloadData()
    }
    
    // handle notification
    func reloadGalleryView(_ notification: NSNotification) {
        self.galleryDataSource = notification.userInfo?[kGalleryDataSource] as! [String : AnyObject]
        self.selectedGalleryType = notification.userInfo?[kGalleryTypeValue] as? GalleryCategory
        self.collectionView?.reloadData()
    }
    
    func itemWidth() -> CGFloat {
        return (self.collectionView!.frame.size.width/2)-15
    }
    
    func itemHeight() -> CGFloat {
        return (self.collectionView!.frame.size.width/1.25)-20
    }
    
    var itemSize: CGSize {
        set {
            self.itemSize = CGSize(width:itemWidth(), height:itemHeight())
        }
        get {
            return CGSize(width:itemWidth(),height:itemHeight())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.galleryDataSource.values.count > 0 {
            let keyExists = self.galleryDataSource[(self.selectedGalleryType?.rawValue)!] != nil
            if keyExists {
                let dataSource : [ECGalleryItems] = self.galleryDataSource[(self.selectedGalleryType?.rawValue)!] as! [ECGalleryItems]
                return dataSource.count
            }
        }
        return 0        
//        return ECGalleryCBManager.sharedInstance.getGalleryDocumentsCountFor(menuType: self.selectedGalleryType!)
    }
    
    // MARK: - UICollectionViewDataSource protocol
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ECGalleryCell
        
        let dataSource : [ECGalleryItems] = self.galleryDataSource[(self.selectedGalleryType?.rawValue)!] as! [ECGalleryItems]
        print("Indexpath = \(indexPath.row)")
        let galleryItem : ECGalleryItems = dataSource[indexPath.row]
        cell.galleryImageView?.image = UIImage(named: (galleryItem.galleryImagePath))
        cell.userImageView?.image = UIImage(named: (galleryItem.galleryImagePath))
        cell.galleryTitleLabel?.text = galleryItem.galleryTitle
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dataSource : [ECGalleryItems] = self.galleryDataSource[(self.selectedGalleryType?.rawValue)!] as! [ECGalleryItems]
        print("Indexpath = \(indexPath.row)")
        let galleryItem : ECGalleryItems = dataSource[indexPath.row]
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let ecGalleryDetailViewController = storyBoard.instantiateViewController(withIdentifier: ECGalleryDetailViewController.className) as! ECGalleryDetailViewController
        ecGalleryDetailViewController.galleryItem = galleryItem
        ecGalleryDetailViewController.galleryDataSource = dataSource
        ecGalleryDetailViewController.selectedIndex = indexPath.row
        self.navigationController?.pushViewController(ecGalleryDetailViewController, animated: true)
    }
    
}
