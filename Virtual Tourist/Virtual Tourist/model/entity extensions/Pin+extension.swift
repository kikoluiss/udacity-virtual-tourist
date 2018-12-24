//
//  Pin+extension.swift
//  Virtual Tourist
//
//  Created by Kiko Santos on 11/12/18.
//  Copyright © 2018 Kiko Santos. All rights reserved.
//

import Foundation
import MapKit

extension Pin: MKAnnotation {

    public var coordinate: CLLocationCoordinate2D {

        guard let latitude = latitude, let longitude = longitude else {
            return kCLLocationCoordinate2DInvalid
        }
        
        let latDegrees = CLLocationDegrees(latitude.doubleValue)
        let longDegrees = CLLocationDegrees(longitude.doubleValue)
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)

    }
}
