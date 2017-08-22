//
//  ECMapViewCell.swift
//  ECApp
//
//  Created by Kavya on 7/17/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import UIKit
import MapKit

typealias ButtonCallBack = (_ sender: UIButton) -> Void


class ECMapViewCell: UITableViewCell {

    let initialLocation = CLLocationCoordinate2D(latitude: 21.282778, longitude: -157.829444)

    @IBOutlet weak var shareLocationButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var shareButtonCallBack: ButtonCallBack?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.centerMapOnLocation(location: initialLocation)
        self.mapView.delegate = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    let regionRadius: CLLocationDistance = 1000
    
    func centerMapOnLocation(location: CLLocationCoordinate2D) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        self.addAnnotationPin()
    }
    
    func addAnnotationPin() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = initialLocation
        annotation.title = "Big Ben"
        annotation.subtitle = "London"
        self.mapView.addAnnotation(annotation)
    }
    
    
    @IBAction func shareLocationButtonClicked(_ sender: Any) {
        if shareButtonCallBack != nil {
            shareButtonCallBack!(sender as! UIButton)
        }

    }
    
}

extension ECMapViewCell : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.animatesDrop = true
            pinView?.pinTintColor = .green
            pinView?.calloutOffset = CGPoint(x: -5, y: 5)
            pinView?.rightCalloutAccessoryView = UIButton.init(type: .detailDisclosure) as UIView
        }
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }

}
