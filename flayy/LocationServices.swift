//
//  LocationServices.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 9/12/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import Foundation
import MapKit

typealias JSONDictionary = [String:Any]

class LocationServices {
    
    func getAdress(location: CLLocation, completion: @escaping (_ address: String?, _ error: Error?) -> ()) {
            
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location) { placemarks, error in
                
        if let e = error {
            completion(nil, e)
        } else {
            let placeArray = placemarks
            var placeMark: CLPlacemark!
            var lines:[String]!
            placeMark = placeArray?[0]
            let address = placeMark.addressDictionary as? JSONDictionary
                
            if address != nil {
                lines = address!["FormattedAddressLines"] as? [String]
            }
                    
            var direccion = ""
                    
            for index in 0...(lines.count - 1)
            {
                direccion += lines[index]
                direccion += " "
            }
            
            completion(direccion, nil)
            }
        }
        
    }
    
    
    func getPointAddress(point: CLLocationCoordinate2D, completion: @escaping (_ address: String?, _ error: Error?) -> ()) {
            
        let currentLocation = CLLocation(latitude: point.latitude, longitude: point.longitude)
        let geoCoder = CLGeocoder()
            
        geoCoder.reverseGeocodeLocation(currentLocation) { placemarks, error in
                
            if let e = error {
                completion(nil, e)
            } else {
                let placeArray = placemarks
                var placeMark: CLPlacemark!
                var lines:[String]!
                placeMark = placeArray?[0]
                let address = placeMark.addressDictionary as? JSONDictionary
                
                if address != nil {
                    lines = address!["FormattedAddressLines"] as? [String]
                }
                
                var direccion = ""
                
                for index in 0...(lines.count - 1)
                {
                    direccion += lines[index]
                    direccion += " "
                }
                
                completion(direccion, nil)
            }
        }
    }
}
