//
//  MapController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/12/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseDatabase

class MapController: UIViewController,  GMSMapViewDelegate, CLLocationManagerDelegate{

    let locationManager = CLLocationManager()
    var camera = GMSCameraPosition()
    var locValue = CLLocationCoordinate2D()
    var marker = GMSMarker()
    let userD = UserDefaults.standard
    var getMembersData:Timer!
    
    var mapa:GMSMapView!
    var longitudes:[Double]!
    var latitudes:[Double]!
    var architectNames:[String]!
    var completedYear:[String]!
    var miembros:[String:AnyObject]!
    
    override func viewDidLoad() {
        self.mapa = GMSMapView(frame: self.view.frame)
        self.mapa.delegate = self
        self.view = mapa
        
        getMembersData =  Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateMarkers), userInfo: nil, repeats: true)
        
        let status = CLLocationManager.authorizationStatus()
        if(status == CLAuthorizationStatus.notDetermined || status == CLAuthorizationStatus.denied)
        {
            locationManager.requestAlwaysAuthorization()
        }else{
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locValue = locationManager.location!.coordinate
            self.locationManager.delegate = self
        }
        
        camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 15.0, bearing: -15, viewingAngle: 45)
        self.view = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        locationManager.delegate = self
        
        
        
        //public let DataChangueNotification = NSNotification.Name("UserDataChanged")
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMarkers), name: NSNotification.Name("UserPhotoChanged"), object: nil)
    }

    func updateMarkers()
    {
    //        for i in 0...2 {
    //            let coordinates = CLLocationCoordinate2D(latitude: latitudes[i], longitude: longitudes[i])
    //            let marker = GMSMarker(position: coordinates)
    //            marker.map = self.mapa
    //            marker.icon = UIImage(named: "\(i)")
    //            marker.infoWindowAnchor = CGPoint(x: 0.5, y: 0.2)
    //            marker.accessibilityLabel = "\(i)"
    //        }
    }
    
    func drawMarker(telefono: String, map: GMSMapView)
    {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.marker.updateMarker(coordinates: (locations.last?.coordinate)!, degrees: .init(0), duration: 0.5)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        //geocerca
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //geocerca
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        /*if status != CLAuthorizationStatus.denied{
            locationManager.startUpdatingLocation()
        }*/
    }
}

