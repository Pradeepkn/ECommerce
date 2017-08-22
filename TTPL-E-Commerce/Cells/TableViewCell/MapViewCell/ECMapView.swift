//
//  ECMapView.swift
//  ECApp
//
//  Created by Pradeep on 7/18/17.
//  Copyright © 2017 Pradeep. All rights reserved.
//

import UIKit
import MapKit

class ECMapView: NSObject {
    let title: String
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String {
        return locationName
    }
}
