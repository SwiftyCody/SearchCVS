//
//  CVSAnnotation.swift
//  SearchCVS
//
//  Created by Cody on 2022/12/03.
//

import Foundation
import MapKit

class CVSAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    var tag: Int = 0
    
    init(coordinate: CLLocationCoordinate2D, title: String = "", subtitle: String = "", tag: Int = 0) {
        self.coordinate = coordinate
        self.tag = tag
    }
}
