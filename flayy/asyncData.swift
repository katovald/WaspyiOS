//
//  asyncData.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/26/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import FirebaseDatabase
import CoreLocation
import CoreMotion

class asyncData: NSObject, CLLocationManagerDelegate{
    var ref: DatabaseReference!
    var loctionManager: CLLocationManager!
    var motionManager: CMMotionManager!
    
}
