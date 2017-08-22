//
//  ECGalleryDetailViewController.swift
//  ECApp
//
//  Created by Pradeep on 7/17/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import UIKit
import MapKit

class ECGalleryDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var galleryTableView: UITableView!
    var galleryItem : ECGalleryItems    = ECGalleryItems()
    var galleryDataSource               = [ECGalleryItems]()
    var selectedIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Details"
        let view : ECImageScrollViewCell = (Bundle.main.loadNibNamed("ECImageScrollViewCell", owner: self, options: nil)?[0] as? UIView as! ECImageScrollViewCell)
        view.profileImageView.image = (UIImage(named: galleryItem.galleryImagePath)!)
        view.profileNameLabel.text = galleryItem.galleryItemCreatedBy
        view.galleryDataSource = self.galleryDataSource
        view.selectedIndex = self.selectedIndex
        galleryTableView.tableHeaderView = view
        self.registerCells()
        self.addLeftBarBackButtonWithImage(UIImage(named: "icn_back")!)
        self.addRightBarButtonsWithImage(UIImage(named: "icn_bookmark")!, UIImage(named: "icn_share")!)
        self.addButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerCells() {
        let placeDetailCellNib = UINib(nibName:"ECPlaceDetailViewCell" , bundle: nil)
        galleryTableView.register(placeDetailCellNib, forCellReuseIdentifier:"ECPlaceDetailViewCell")
        let mapViewCellNib = UINib(nibName:"ECMapViewCell" , bundle: nil)
        galleryTableView.register(mapViewCellNib, forCellReuseIdentifier:"ECMapViewCell")

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell?
        
        switch (indexPath.row) {
        case 0:
            cell = loadPlaceDetailCell(tableView: tableView, forindexPath: indexPath as NSIndexPath)
            break
            
        case 1:
            cell = loadMapViewCell(tableView: tableView, forindexPath: indexPath as NSIndexPath)
            break
            
        default:
            break
        }
        
        return cell!
    }
    
    func loadPlaceDetailCell(tableView : UITableView ,forindexPath indexPath: NSIndexPath) -> ECPlaceDetailViewCell  {
        let placeDetailCell = tableView.dequeueReusableCell(withIdentifier: "ECPlaceDetailViewCell", for: indexPath as IndexPath) as! ECPlaceDetailViewCell
        placeDetailCell.placeTitleLabel.text = galleryItem.galleryTitle
        placeDetailCell.placeDescriptionLabel.text = galleryItem.galleryDescription
        return placeDetailCell
    }
    
    func loadMapViewCell(tableView : UITableView ,forindexPath indexPath: NSIndexPath) -> ECMapViewCell  {
        let mapViewCell = tableView.dequeueReusableCell(withIdentifier: "ECMapViewCell", for: indexPath as IndexPath) as! ECMapViewCell
        mapViewCell.shareButtonCallBack =  {(sender: UIButton) -> Void in
            let coordinate = mapViewCell.initialLocation
            let vCardURL = self.fileURL(from: coordinate, with: "ECApp")
            let activityViewController = UIActivityViewController(activityItems: [vCardURL], applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: nil)
        }

        return mapViewCell
    }

    // Calculating label height based on text
    func labeltitle(string: String, maximumLabelSize: CGSize) -> CGFloat {
        let expectedLabelSize = string.boundingRect(with: maximumLabelSize, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSFontAttributeName: UIFont.setECFont(fontType: .kECLightFontName, fontSize:.kECOMedium)], context: nil)
        var cellHeight: CGFloat = expectedLabelSize.size.height
        cellHeight = cellHeight < 20 ? 20 : cellHeight
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var rowHeight =  CGFloat()
        let maximumLabelSize = CGSize(width :tableView.frame.width, height : tableView.frame.height)
        if (indexPath.row == 0) {
            let labelHeight = self.labeltitle(string: galleryItem.galleryDescription, maximumLabelSize: maximumLabelSize)
            rowHeight = 100 + labelHeight
        } else {
            rowHeight = 250
        }
        return rowHeight
    }
    
    func addButton() {
        let button = UIButton()
        button.frame = CGRect(x: self.view.frame.size.width - 80, y: self.view.frame.size.height - 80, width: 70, height: 70)
        button.layer.cornerRadius = button.frame.width / 2
        button.layer.masksToBounds = true
        button.setImage(UIImage(named: "btn_call"), for: .normal)
        button.contentMode = .scaleAspectFill
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        self.view.addSubview(button)
    }
    
    func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }
    
    func fileURL(from coordinate: CLLocationCoordinate2D, with name: String?) -> URL {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("vCard.loc.vcf")
        
        let fileUrlString = [
            "BEGIN:VCARD",
            "VERSION:4.0",
            "FN:\(name ?? "Shared Location")",
            "item1.URL;type=pref:http://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)",
            "item1.X-ABLabel:map url",
            "END:VCARD"
            ].joined(separator: "\n")
        
        do {
            try fileUrlString.write(toFile: fileURL.path, atomically: true, encoding: .utf8)
        } catch let error {
            print("Error, \(error.localizedDescription), saving fileString: \(fileUrlString) to file path: \(fileURL.path).")
        }
        
        return fileURL
    }

}

extension UIViewController {
    public func addLeftBarBackButtonWithImage(_ buttonImage: UIImage) {
        let leftButton: UIBarButtonItem = UIBarButtonItem(image: buttonImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.backButtonClicked))
        navigationItem.leftBarButtonItem = leftButton
    }
    
    public func addRightBarButtonsWithImage(_ bookMarkButtonImage: UIImage, _ shareButtonImage: UIImage) {
        let bookMarkButton: UIBarButtonItem = UIBarButtonItem(image: bookMarkButtonImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.didTapBookMarkButton))
        let shareButton: UIBarButtonItem = UIBarButtonItem(image: shareButtonImage, style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.didTapShareButton))
        navigationItem.rightBarButtonItems = [shareButton, bookMarkButton]
    }
    
    func didTapBookMarkButton(){
        
    }
    
    func didTapShareButton() {
        
    }
    
    func backButtonClicked() {
        self.navigationController?.popViewController(animated: true)
    }
}



//        let headerView: ParallaxHeaderView = ParallaxHeaderView.parallaxHeaderView(withSubView: view) as! ParallaxHeaderView
//        headerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 300)
//        galleryTableView.tableHeaderView = headerView
//    func  scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let header: ParallaxHeaderView = self.galleryTableView.tableHeaderView as! ParallaxHeaderView
//        header.layoutHeaderView(forScrollOffset: scrollView.contentOffset)
//
//        self.galleryTableView.tableHeaderView = header
//    }
