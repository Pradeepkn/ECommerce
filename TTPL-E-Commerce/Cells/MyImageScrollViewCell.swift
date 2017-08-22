//
//  MyImageScrollViewCell.swift
//  MysoreApp
//
//  Created by Kavya on 7/17/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import UIKit

class MyImageScrollViewCell: UIView {
    
    var totalPages = 0
    
    var images : [String] = ["mood1", "mood2", "mood3", "mood4", "mood5", "mood6", "mood7", "mood8"]

    @IBOutlet weak var imageScrollView: UIScrollView!

    @IBOutlet weak var imagePageView: UIPageControl!
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.setUpScrollView()
        self.totalPages = self.images.count
        self.configurePageControl()
        self.setUpImageSliderView()
    }
    
    @IBAction func imageChanged(_ sender: Any) {
        var newFrame = imageScrollView.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(imagePageView.currentPage)
        imageScrollView.scrollRectToVisible(newFrame, animated: true)
    }
    
    func setUpScrollView()  {
        // Enable paging.
        imageScrollView.isPagingEnabled = true
        
        // Set the following flag values.
        imageScrollView.showsHorizontalScrollIndicator = false
        imageScrollView.showsVerticalScrollIndicator = false
        imageScrollView.scrollsToTop = false
        
        // Set self as the delegate of the scrollview.
        imageScrollView.delegate = self
    }
    
    func setUpImageSliderView() {
        // Set the scrollview content size.
        imageScrollView.contentSize = CGSize(width : imageScrollView.frame.size.width * CGFloat(self.totalPages), height :imageScrollView.frame.size.height)
        
        if self.totalPages == 0 {
            imageScrollView.layer.borderWidth = 0.0
            let imageContainerView = Bundle.main.loadNibNamed("MyImageView", owner: self, options: nil)![0] as! UIView
            
            // Set its frame and the background color.
            imageContainerView.frame = CGRect(x :CGFloat(0) * imageScrollView.frame.size.width, y: 2, width :imageScrollView.frame.size.width, height :imageScrollView.frame.size.height)
            
            let pageImage = imageContainerView.viewWithTag(1) as! UIImageView
            let locationImage = UIImage(named: "Gallery")
            pageImage.image = locationImage
            imageContainerView.backgroundColor = UIColor.clear
            pageImage.backgroundColor = UIColor.clear
            pageImage.contentMode = UIViewContentMode.scaleAspectFit
            self.imageScrollView.addSubview(imageContainerView)
        }else{
            // Load the TestView view from the TestView.xib file and configure it properly.
            for i in 0 ..< self.totalPages {
                let imageContainerView = Bundle.main.loadNibNamed("MyImageView", owner: self, options: nil)![0] as! UIView
                // Set its frame and the background color.
                imageContainerView.frame = CGRect(x :CGFloat(i) * imageScrollView.frame.size.width, y :2, width :imageScrollView.frame.size.width, height :imageScrollView.frame.size.height)
                
                let pageImage = imageContainerView.viewWithTag(1) as! UIImageView
                let allImages = images[i]
                pageImage.image = UIImage(named: allImages)
                
                imageContainerView.backgroundColor = UIColor.clear
                pageImage.backgroundColor = UIColor.clear
                pageImage.contentMode = UIViewContentMode.scaleAspectFill
                self.imageScrollView.addSubview(imageContainerView)
            }
        }
    }
    
    func configurePageControl() {
        self.imagePageView.numberOfPages = self.totalPages
        self.imagePageView.currentPage = 0
        self.imagePageView.pageIndicatorTintColor = UIColor.lightGray
        self.imagePageView.currentPageIndicatorTintColor = UIColor.white
    }
}

extension MyImageScrollViewCell : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Calculate the new page index depending on the content offset.
        let currentPage = floor(scrollView.contentOffset.x / UIScreen.main.bounds.size.width);
        
        // Set the new page index to the page control.
        imagePageView.currentPage = Int(currentPage)
    }
}

