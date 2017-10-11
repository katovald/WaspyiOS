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
import GeoFire

class MapController: UIViewController,  GMSMapViewDelegate, CLLocationManagerDelegate{

    let locationManager = CLLocationManager()
    var camera = GMSCameraPosition()
    var locValue = CLLocationCoordinate2D()
    let userD = UserDefaults.standard
    var getMembersData:Timer!
    var markers = [String:waspyMemberMarker]()
    var places = [String:waspyPlaceMarker]()
    var alerts = [String:waspyAlertMarker]()
    var mapa:GMSMapView!
    var alertas:Bool = false
    let workingView = UIActivityIndicatorView()
    let backView = UIView()

    override func viewDidLoad() {
        backView.frame = view.frame
        backView.frame.origin = view.frame.origin
        backView.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
        workingView.activityIndicatorViewStyle = .whiteLarge
        workingView.hidesWhenStopped = true
        workingView.center = backView.center
        backView.addSubview(workingView)
        workingView.startAnimating()
        
        self.mapa = GMSMapView(frame: self.view.frame)
        self.mapa.delegate = self
        self.view = mapa
        
        let status = CLLocationManager.authorizationStatus()
        if(status == CLAuthorizationStatus.notDetermined || status == CLAuthorizationStatus.denied)
        {
            locationManager.requestAlwaysAuthorization()
        }else{
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locValue = locationManager.location!.coordinate
        }
        
        camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 15.0, bearing: -15, viewingAngle: 45)
        self.view = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        locationManager.delegate = self
        
        self.view.addSubview(backView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMarkers), name: NSNotification.Name("UserPhotoChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(centerView), name: NSNotification.Name("FixCameraPush"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeInfo), name: NSNotification.Name("UserGroupsChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(locateUser), name: NSNotification.Name("UserAsked"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(updateFences), name: NSNotification.Name("PlacesAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(turnAlertsOnOFF), name: NSNotification.Name("Alerts"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(initWaspy), name: NSNotification.Name("CorrectLogIn"), object: nil)
        
    }
    
    @objc func initWaspy() {
        workingView.stopAnimating()
        backView.removeFromSuperview()
        
        getMembersData =  Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateMarkers), userInfo: nil, repeats: true)
        
        drawMarkers(map: view as! GMSMapView)
        updateFences()
        
        let region = self.regionMonitor()
        if(locationManager.monitoredRegions.count > 0)
        {
            locationManager.stopMonitoring(for: region)
        }else{
            locationManager.startMonitoring(for: region)
        }
    }
    
    @objc func changeInfo(){
        self.view.addSubview(backView)
        workingView.startAnimating()
        self.mapa.clear()
        let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 15.0, bearing: -15, viewingAngle: 45)
        self.view =  GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        drawMarkers(map: self.view as! GMSMapView)
        updateFences()
        workingView.stopAnimating()
        backView.removeFromSuperview()
    }
    
    @objc func turnAlertsOnOFF()
    {
        if alertas{
            hideAlerts()
            alertas = false
        }else{
            drawAlerts(map: self.view as! GMSMapView)
            alertas = true
        }
    }
    
    @objc func centerView(){
        let OwnerLocation = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!), zoom: 15.0, bearing: -15, viewingAngle: 45)
        
        self.mapa = self.view as! GMSMapView!
        mapa.animate(to: OwnerLocation)
        self.view = mapa
    }
    
    @objc func locateUser(){
        let userPhone = userD.dictionary(forKey: "UserAsked")
        guard let location = userPhone!["location"] as? [String:Any] else {return}
        
        let userLocation = GMSCameraPosition(target:
            CLLocationCoordinate2D(latitude: location["latitude"] as! Double,
                                   longitude: location["longitude"] as! Double),
                                   zoom: 15.0,
                                   bearing: -15,
                                   viewingAngle: 45)
        
        self.mapa = self.view as! GMSMapView!
        mapa.animate(to: userLocation)
        self.view = mapa
        self.userD.set(nil, forKey: "UserAsked")
    }
    
    @objc func updateFences(){
        let lugares = userD.array(forKey: "ActualGroupPlaces") as? [[String:[String:Any]]] ?? []
        
        for lugar in lugares
        {
            let key = lugar.first?.key
            let info = lugar.first?.value
            let placeMarker = waspyPlaceMarker(name: info!["place_name"] as! String,
                                               address: info!["address"] as! String,
                                               radio: info!["radio"] as! Int,
                                               icon: info!["icon"] as! Int)
            let coordinate = info!["l"] as! [Double]
            let point = CLLocationCoordinate2D(latitude: coordinate[0] ,
                                               longitude: coordinate[1])
            placeMarker.setLocation(location: point)
            placeMarker.setIconView(icono: info!["icon"] as! Int)
            places[key!] = placeMarker
            placeMarker.map = self.view as? GMSMapView
        }
    }
    
    @objc func updateMarkers()
    {
        var aux = userD.array(forKey: "MembersActiveGroup") as? [[String:[String:Any]]] ?? []
        var allMembers = [String]()
        if aux.count > 0 {
        for key in 0...aux.count - 1 {
            let memberPhone = (aux[key].first?.key)!
            allMembers.append(memberPhone)
            let data = aux[key].first?.value
            let location = data!["location"] as? [String:Any] ?? [:]
            let visible = data!["visibility"] as? Bool ?? true
            
            if location.count > 0{
                let latitude = location["latitude"]! as! CLLocationDegrees
                let longitude = location["longitude"]! as! CLLocationDegrees
                if markers[memberPhone] == nil
                {
                    let marker = waspyMemberMarker(phone: memberPhone)
                    marker.setIconView()
                    marker.setLocation(location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    markers[memberPhone] = marker
                }else{
                    markers[memberPhone]?.updateMarker(coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), degrees: 0, duration: 0.2)
                }
            }
            
            if !visible
            {
                markers[memberPhone]?.map = nil
            }else{
                markers[memberPhone]?.map = self.view as? GMSMapView
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
        //NotificationCenter.default.post(name: NSNotification.Name("DataUpdated"), object: self)
    }
    
    func drawMarkers(map: GMSMapView)
    {
        var aux = userD.array(forKey: "MembersActiveGroup") as? [[String:[String:Any]]] ?? []
        if aux.count > 0 {
        for key in 0...aux.count - 1 {
            let memberPhone = (aux[key].first?.key)!
            let marker = waspyMemberMarker(phone: memberPhone)
            let data = aux[key].first?.value
            let location = data!["location"] as? [String:Any] ?? [:]
            let visible = data!["visibility"] as? Bool ?? true
            if location.count == 0 || !visible
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
        
    }
    
    func drawAlerts(map: GMSMapView)
    {
        let theGeoFire = GeoFire(firebaseRef: Database.database().reference().child("alerts_geo"))
        let circleQuery = theGeoFire!.query(at: locationManager.location, withRadius: 200/1000)
        
        _ = circleQuery!.observe(.keyEntered, with: { (key, location) in
            let llave = key
            let marcador = waspyAlertMarker(tipo: 0, coment: "lajfbauf", title: "ejfofug")
            marcador.setIconView(icono: 0)
            marcador.setLocation(location: (location?.coordinate)!)
            marcador.map = map
            self.alerts[llave!] = marcador
        })
    }
    
    func hideAlerts()
    {
        let keys = alerts.keys
        for key in keys
        {
            let marker = alerts[key]
            marker?.map = nil
        }
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
