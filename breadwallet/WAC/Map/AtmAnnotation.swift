// 
//  AtmAnnotation.swift
//
//  Created by Giancarlo Pacheco on 5/12/20.
//

import MapKit
import WacSDK

class AtmAnnotation : NSObject, MKAnnotation {
    
    var atm: WacSDK.AtmMachine
    var coordinate: CLLocationCoordinate2D {
        if let latitude = Double(atm.latitude!),
            let longitude = Double(atm.longitude!) {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        return kCLLocationCoordinate2DInvalid
    }
    
    var id: String {
        return atm.atmId!
    }
    
    init(atm: WacSDK.AtmMachine) {
        self.atm = atm
        super.init()
    }
    
}
