//
//  mapHandler.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 3/13/18.
//  Copyright © 2018 CAMSA. All rights reserved.
//

import Foundation
import GoogleMaps

class mapa: GMSMapView {
    private var members:[String:waspyMemberMarker]!
    private var places:[String:waspyPlaceMarker]!
    private var alerts:[String:waspyAlertMarker]!
    
    public func setConstrains(){
        
    }
}
