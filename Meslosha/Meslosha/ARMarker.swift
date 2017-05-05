//
//  PlaceAnnotation.swift
//  AR-MapView
//
//  Created by Welcome on 4/20/17.
//  Copyright © 2017 bill. All rights reserved.
//

import Foundation
import MapKit
import GoogleMaps

class ARMarker: GMSMarker {
    
    
    init(location: CLLocationCoordinate2D, title: String) {
        super.init()
        self.position = location
        self.snippet = title
        
    }
}
