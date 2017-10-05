//
//  PlacesMapViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/19/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import GoogleMaps

class PlacesMapViewController: UIViewController, GMSMapViewDelegate{
    
    func dataSaved() -> waspyPlaceMarker {
        return location
    }
    
    
    var icon:Int = 0
    var location:waspyPlaceMarker!
    
    override func viewDidLoad() {
        
        
    }
    
    override func loadView() {
        let locValue: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 19.415306357651144, longitude: -99.13663986116934)
        location = waspyPlaceMarker(name: "Casa", address: "Aqui", radio: 200)
        location.setLocation(location: locValue)
        location.setIconView(icono: icon)
        
        let camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 15.0, bearing: -15, viewingAngle: 45)
        
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        location.map = mapView
        
        self.view = mapView
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
    }
    
    func setIcon(icon:Int){
        location.setIconView(icono: icon)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        location.updateMarker(coordinates: position.target, degrees: 0, duration: 0.2)
    }
    
}

