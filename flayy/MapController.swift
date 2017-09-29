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

protocol usingMap {
    func centerMember(phone:String)
}

class MapController: UIViewController,  GMSMapViewDelegate, CLLocationManagerDelegate{

    let locationManager = CLLocationManager()
    var camera = GMSCameraPosition()
    var locValue = CLLocationCoordinate2D()
    let userD = UserDefaults.standard
    var getMembersData:Timer!
    var geoNotifications:[Geotification] = []
    var markers = [String:waspyMemberMarker]()
    var mapa:GMSMapView!
    
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
        
        drawMarkers(map: view as! GMSMapView)
        
        let region = self.regionMonitor()
        if(locationManager.monitoredRegions.count > 0)
        {
            locationManager.stopMonitoring(for: region)
        }else{
            locationManager.startMonitoring(for: region)
        }
        //public let DataChangueNotification = NSNotification.Name("UserDataChanged")
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMarkers), name: NSNotification.Name("UserPhotoChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(centerView), name: NSNotification.Name("FixCameraPush"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(drawNotifications), name: NSNotification.Name("ShowNotifications"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeInfo), name: NSNotification.Name("UserGroupsChanged"), object: nil)
        
    }
    
    @objc func changeInfo(){
        self.mapa.clear()
        let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 15.0, bearing: -15, viewingAngle: 45)
        self.view =  GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        drawMarkers(map: self.view as! GMSMapView)
    }
    
    @objc func centerView(){
        let OwnerLocation = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!), zoom: 15.0, bearing: -15, viewingAngle: 45)
        
        self.mapa = self.view as! GMSMapView!
        mapa.animate(to: OwnerLocation)
        self.view = mapa
    }
    
    @objc func updateMarkers()
    {
        var aux = userD.array(forKey: "MembersActiveGroup") as! [[String:[String:Any]]]
        var allMembers = [String]()
        for key in 0...aux.count - 1 {
            let memberPhone = (aux[key].first?.key)!
            allMembers.append(memberPhone)
            let data = aux[key].first?.value
            let location = data!["location"] as? [String:Any] ?? [:]
            
            if location.count > 0{
                let latitude = location["latitude"]! as! CLLocationDegrees
                let longitude = location["longitude"]! as! CLLocationDegrees
                if markers[memberPhone] == nil
                {
                    let marker = waspyMemberMarker(phone: memberPhone)
                    marker.setIconView()
                    marker.setLocation(location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    marker.map = self.view as? GMSMapView
                    markers[memberPhone] = marker
                }else{
                    markers[memberPhone]?.updateMarker(coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), degrees: 0, duration: 0.2)
                }
            }
        }
        
        if allMembers.count < markers.count
        {
            let borrar = markers.keys
            for marker in borrar
            {
                if allMembers.contains(marker)
                {
                    
                }else{
                    markers[marker]?.map = nil
                    markers[marker] = nil
                }
            }
        }
        
    }
    
    func drawMarkers(map: GMSMapView)
    {
        var aux = userD.array(forKey: "MembersActiveGroup") as! [[String:[String:Any]]]
        for key in 0...aux.count - 1 {
            let memberPhone = (aux[key].first?.key)!
            let marker = waspyMemberMarker(phone: memberPhone)
            let data = aux[key].first?.value
            let location = data!["location"] as? [String:Any] ?? [:]
            if location.count == 0
            {
    
            }else{
                let latitude = location["latitude"]! as! CLLocationDegrees
                let longitude = location["longitude"]! as! CLLocationDegrees
                marker.setIconView()
                marker.setLocation(location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                marker.map = map
                markers[memberPhone] = marker
            }
        }
        
    }
    
    func drawNotification(map: GMSMapView){
        
    }
    
    func drawGeoFences(map:GMSMapView){
        
    }
    
    func findMember(phone:String) {
        let focus = markers[phone]?.getLocation()
        if focus != nil{
            let memberLocation = GMSCameraPosition(target: focus!, zoom: 15.0, bearing: -15, viewingAngle: 45)
            
            self.mapa = self.view as! GMSMapView!
            mapa.animate(to: memberLocation)
            self.view = mapa
        }
    }
    
    @objc func drawNotifications()
    {
        
    }

    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        
    }
    
    func regionMonitor() -> CLCircularRegion {
        let autentia = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 40.453163, longitude: -3.509220), radius: 199, identifier: "prueba")
        autentia.notifyOnExit = true
        autentia.notifyOnEntry = true
        return autentia
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        alert(message: "Hola")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        alert(message: "Bye")
    }
}

extension MapController: usingMap{
    func centerMember(phone: String) {
        self.findMember(phone: phone)
    }
}

