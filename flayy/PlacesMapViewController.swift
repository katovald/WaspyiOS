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
            let coordinates = data["l"] as? [Double] ?? [LocationServices.init().getLocationCoord().latitude,
                 LocationServices.init().getLocationCoord().longitude]
            locValue = CLLocationCoordinate2D(latitude: coordinates[0],
                                              longitude: coordinates[1])
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
        
        NotificationCenter.default.add(observer: self, selector: #selector(updateIcon), notification: .placeConfig)
        NotificationCenter.default.add(observer: self, selector: #selector(finishData), notification: .getPlaceData)
        NotificationCenter.default.add(observer: self, selector: #selector(setIconView), notification: .findAddress)
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
        location.drawcircle(self.view as! GMSMapView)
    }
    
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        location.updateMarker(coordinates: position.target, degrees: 0, duration: 0.2)
        self.userD.set([key:location.getData()], forKey: "EditingPlace")
    }
    
    @objc func finishData() {
        self.userD.set([key:location.getData()], forKey: "EditingPlace")
    }
    
    @objc func setIconView() {
        guard let punto = userD.array(forKey: "PointCoordinate") as? [Double] else { return }
        let coordenadas = CLLocationCoordinate2D(latitude: punto[0], longitude: punto[1])
        location.updateMarker(coordinates: coordenadas, degrees: 0, duration: 0.2)
        let pos = GMSCameraPosition(target: coordenadas, zoom: 15.0, bearing: -15, viewingAngle: 45)
        self.mapa = self.view as! GMSMapView!
        mapa.animate(to: pos)
        self.view = mapa
        self.userD.set([key:location.getData()], forKey: "EditingPlace")
    }
}

