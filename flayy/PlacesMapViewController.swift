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

    var icon:Int = 0
    public var location:waspyPlaceMarker!
    var mapa:GMSMapView!
    var data = [String:Any]()
    var key = String()
    let userD: UserDefaults = UserDefaults.standard
    let notificationCenter = NotificationCenter.default
    
    override func viewDidLoad() {
        let place = userD.dictionary(forKey: "EditingPlace") ?? nil
        if place != nil{
            key = (place?.first?.key)!
            data = place?.first?.value as! [String:Any]
        }else{
            key = "none"
        }
        
        var locValue: CLLocationCoordinate2D!
        
        if data.count > 0{
            let coordinates = data["l"] as? [Double] ?? [LocationServices.init().getLocationCoord().latitude,LocationServices.init().getLocationCoord().longitude]
            locValue = CLLocationCoordinate2D(latitude: coordinates[0], longitude: coordinates[1])
            location = waspyPlaceMarker(name: data["place_name"] as? String ?? "",
                                        address: data["address"] as? String ?? "",
                                        radio: data["radio"] as? Int ?? 100,
                                        icon: data["icon"] as? Int ?? 0)
            location.setLocation(location: locValue)
            location.setIconView(icono: data["icon"] as? Int ?? 0)
        }else{
            locValue = LocationServices.init().getLocationCoord()
            location = waspyPlaceMarker(name: "", address: "", radio: 100, icon: icon)
            location.setLocation(location: locValue)
            location.setIconView(icono: icon)
        }
        
        let camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 15.0, bearing: -15, viewingAngle: 45)
        
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.delegate = self
        location.map = mapView
        
        self.view = mapView
        
        notificationCenter.addObserver(self, selector: #selector(updateIcon), name: NSNotification.Name("PlaceDataUpdated"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(finishData), name: NSNotification.Name("GivemePlaceData"), object: nil)
        notificationCenter.addObserver(self, selector: #selector(setIconView), name: NSNotification.Name("PlaceAddressFind"), object: nil)
    }

    @objc func updateIcon(){
        if icon == 9
        {
            icon = 0
        }else{
            icon += 1
        }
        location.updateMarkerIcon(icono: icon)
    }
    
    func setIcon(icon:Int){
        location.setIconView(icono: icon)
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        location.updateMarker(coordinates: position.target, degrees: 0, duration: 0.2)
        self.userD.set([key:location.getData()], forKey: "EditingPlace")
        notificationCenter.post(name: NSNotification.Name("UpdatePlaceLocation"), object: self)
    }
    
    @objc func finishData() {
        self.userD.set([key:location.getData()], forKey: "EditingPlace")
    }
    
    @objc func setIconView() {
        let punto = userD.object(forKey: "PointCoordinate") as! [String:CLLocationDegrees]
        let coordeadas = CLLocationCoordinate2D(latitude: punto["lat"]!, longitude: punto["long"]!)
        location.updateMarker(coordinates: coordeadas, degrees: 0, duration: 0.2)
        let pos = GMSCameraPosition(target: coordeadas, zoom: 15.0, bearing: -15, viewingAngle: 45)
        self.mapa = self.view as! GMSMapView!
        mapa.animate(to: pos)
        self.view = mapa
        self.userD.set([key:location.getData()], forKey: "EditingPlace")
        notificationCenter.post(name: NSNotification.Name("UpdatePlaceLocation"), object: self)
    }
    
}

