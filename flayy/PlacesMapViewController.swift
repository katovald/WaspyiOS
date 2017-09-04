//
//  PlacesMapViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/19/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import GoogleMaps

class PlacesMapViewController: UIViewController,  GMSMapViewDelegate{
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        let locValue: CLLocationCoordinate2D = locationManager.location!.coordinate
        let marker = GMSMarker()
        let marcador = UIImage(named: "ic28_casita.jpg")
        let markerView = UIImageView(image: resizeImage(image: marcador!, newSize: CGSize(width: 35, height: 38)))

        markerView.layer.borderWidth = 1
        markerView.layer.masksToBounds = false
        markerView.backgroundColor = UIColor.blue
        markerView.clipsToBounds = true
        
        marker.position = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        marker.title = "Kato"
        marker.iconView = markerView
        
        let camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 15.0, bearing: -15, viewingAngle: 45)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        marker.map = mapView
        
        self.view = mapView
    }
    

    
    override func didReceiveMemoryWarning() {
        
    }
}
