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
import UserNotifications

class MapController: UIViewController,  GMSMapViewDelegate {

    let locationManager = CLLocationManager()
    var camera = GMSCameraPosition()
    var locValue = CLLocationCoordinate2D()
    let userD = UserDefaults.standard
    var getMembersData:Timer!
    var mapa:GMSMapView!
    var alertas:Bool = false
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    let backView = UIView()
    var radius:Int!
    var ownerPhone:String!
    var fixed:Bool!
    var putAlert:Bool!
    var onBackground:Bool!
    var draw:paintMarkers!
    
    var timer = Timer()
    var timer1 = Timer()
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.add(observer: self, selector: #selector(updateOwnerMarkerPhoto), notification: .userDataChange)
        NotificationCenter.default.add(observer: self, selector: #selector(centerView), notification: .fxCameraMap)
        NotificationCenter.default.add(observer: self, selector: #selector(changeInfo), notification: .groupsChanges)
        NotificationCenter.default.add(observer: self, selector: #selector(locateUser), notification: .findUser)
        NotificationCenter.default.add(observer: self, selector: #selector(updateFences), notification: .placesChanges)
        NotificationCenter.default.add(observer: self, selector: #selector(turnAlertsOnOFF), notification: .alert)
        NotificationCenter.default.add(observer: self, selector: #selector(presetnDialog), notification: .pushAlert)
        NotificationCenter.default.add(observer: self, selector: #selector(turnEdit), notification: .tryToPush)
        NotificationCenter.default.addObserver(self, selector: #selector(inactive), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(active), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.remove(observer: self, notification: .userDataChange)
        NotificationCenter.default.remove(observer: self, notification: .fxCameraMap)
        NotificationCenter.default.remove(observer: self, notification: .groupsChanges)
        NotificationCenter.default.remove(observer: self, notification: .findUser)
        NotificationCenter.default.remove(observer: self, notification: .placesChanges)
        NotificationCenter.default.remove(observer: self, notification: .alert)
        NotificationCenter.default.remove(observer: self, notification: .pushAlert)
        NotificationCenter.default.remove(observer: self, notification: .tryToPush)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ownerPhone = userD.string(forKey: "OwnerPhone")
        fixed = false
        putAlert = false
        onBackground = true
        
        handleLocationAuthorizationStatus(status:  CLLocationManager.authorizationStatus())
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.delegate = self
    }
    
    @objc func turnEdit(){
        putAlert = !putAlert
    }
    
    func initWaspy() {
        startLoading()
        
        if locationManager.location != nil{
            let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 15.0, bearing: -15, viewingAngle: 45)
            self.mapa = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        }else{
            self.mapa = GMSMapView()
        }
        mapa.delegate = self
        self.view = mapa
        
        draw = paintMarkers.init(view as! GMSMapView)
        
        draw.drawMembers()
        draw.drawFences()
        
        startMonitoring()
        
        stopLoading()
    }
    
    @objc func changeInfo(){
        self.mapa.clear()
        self.view = mapa
        startLoading()
        draw.deleteMembers()
        draw.deleteFences()
        draw.drawMembers()
        draw.drawFences()
        stopLoading()
    }
    
    @objc func turnAlertsOnOFF()
    {
        if alertas{
            draw.deleteAlerts()
            alertas = false
            fixed = false
        }else{
            draw.drawAlerts(center: self.getCenterCoordinate(), radius: self.getRadius())
            alertas = true
            fixed = true
        }
    }
    
    @objc func centerView(){
        let OwnerLocation = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!), zoom: 15.0, bearing: -15, viewingAngle: 45)
        
        self.mapa = self.view as! GMSMapView!
        mapa.animate(to: OwnerLocation)
        mapa.delegate = self
        self.view = mapa
        if !fixed && alertas {
            self.fixed = true
        }
    }
    
    @objc func locateUser(){
        let userPhone = userD.dictionary(forKey: "UserAsked")
        guard let location = userPhone!["location"] as? [String:Any] else {return}
        
        let userLocation = GMSCameraPosition(target:
            CLLocationCoordinate2D(latitude: location["latitude"] as! Double,
                                   longitude: location["longitude"] as! Double),
                                   zoom: 18.0,
                                   bearing: -15,
                                   viewingAngle: 45)
        
        self.mapa = self.view as! GMSMapView!
        mapa.animate(to: userLocation)
        mapa.delegate = self
        self.view = mapa
        self.userD.set(nil, forKey: "UserAsked")
        if fixed && alertas {
            self.fixed = false
        }
    }
    
    @objc func updateFences(){
        stopGeofences()
        draw.updateFences()
        startGeofences()
    }
    
    @objc func updateMarkers()
    {
        draw.updateMembers()
        updateFences()
    }
    
    @objc func updateOwnerMarkerPhoto()
    {
        draw.updateOwnerPhoto()
    }
    
    @objc func presetnDialog(){
        let alertController = UIAlertController(title: "Alerta de ", message: "Ayuda a otros a prevenir malas experiencias. Si lo viste reportalo", preferredStyle: .alert)
        let confirmation = UIAlertAction(title: "Listo", style: .default, handler: {(_) in
            let field = alertController.textFields![0]
            let ref = Database.database().reference().child("alerts_geo").childByAutoId()
            let key = ref.key
            let theGeoFire = GeoFire(firebaseRef: Database.database().reference().child("alerts_geo"))
            theGeoFire?.setLocation(CLLocation(latitude: self.getCenterCoordinate().latitude, longitude: self.getCenterCoordinate().longitude), forKey: key)
            firebaseManager.init().createAlertGeo(key: key, coment: field.text ?? "")
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler:{(_) in
        })
        alertController.addTextField(configurationHandler: {(textfield) in
            textfield.placeholder = "Comentario (opcional)"
        })
        
        let call911 = UIAlertAction(title: "911", style: .default) { (_) in
            guard let number = URL(string: "tel://911") else { return }
            UIApplication.shared.open(number)
        }
        
        alertController.addAction(call911)
        alertController.addAction(confirmation)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func startGeofences(){
        stopGeofences()
        let places = userD.array(forKey: "ActualGroupPlaces") as? [[String:Any]] ?? []
        for place in places {
            let region = self.regionMonitor(geo: place)
            locationManager.startMonitoring(for: region)
        }
    }
    
    func stopGeofences(){
        if(locationManager.monitoredRegions.count > 0){
            let regiones = locationManager.monitoredRegions
            for region in regiones{
                locationManager.stopMonitoring(for: region)
            }
        }
    }
    
    func getCenterCoordinate() -> CLLocationCoordinate2D {
        let centerPoint = self.mapa.center
        let centerCoordinate = self.mapa.projection.coordinate(for: centerPoint)
        return centerCoordinate
    }
    
    func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        // to get coordinate from CGPoint of your map
        let topCenterCoor = self.mapa.convert(CGPoint(x: self.mapa.frame.size.width / 2.0, y: 0),
                                              from: self.mapa)
        let point = self.mapa.projection.coordinate(for: topCenterCoor)
        return point
    }
    
    func getRadius() -> CLLocationDistance {
        let centerCoordinate = getCenterCoordinate()
        // init center location from center coordinate
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let topCenterCoordinate = self.getTopCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        
        let radius = CLLocationDistance(centerLocation.distance(from: topCenterLocation))
        
        return round(radius)
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if !alertas{
            let controller = storyboard?.instantiateViewController(withIdentifier: "ConfigPlace") as! PlacesConfigViewController
            let placeEdited = ["none": ["l": [coordinate.latitude,coordinate.longitude]]]
            userD.set(placeEdited, forKey: "EditingPlace")
            present(controller, animated: true, completion: nil)
        }
    }
    
    func regionMonitor(geo: [String:Any]) -> CLCircularRegion {
        let key = geo.first?.key
        let info = geo.first?.value as! [String:Any]
        let coord = info["l"] as! [Double]
        let autentia = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coord[0], longitude: coord[1]), radius: CLLocationDistance(info["radio"] as? Int ?? 100), identifier: key!)
        autentia.notifyOnExit = true
        autentia.notifyOnEntry = true
        return autentia
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        FCmNotifications.init().send(type: .enterGeo)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        FCmNotifications.init().send(type: .exitGeo)
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if alertas
        {
            draw.updateAlerts(center: self.getCenterCoordinate(), radius: self.getRadius())
        }
    }

    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func statusDeniedAlert() {
        let alertController = UIAlertController(title: "Compartir ubicacion esta desabilitado", message: "Esta aplicacion necesita permisos de SIEMPRE usar ubicacion.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Abrir Configuracion", style: .default, handler: { action in
            if #available(iOS 10.0, *) {
                let settingsURL = URL(string: UIApplicationOpenSettingsURLString)!
                UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
            } else {
                if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.openURL(url as URL)
                }
            }
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func inactive(){
        locationManager.distanceFilter = 60
    }
    
    @objc func active(){
        locationManager.distanceFilter = 5
    }
    
    func startLoading(){
        DispatchQueue.main.async { // Correct
            self.activityIndicator.center = self.view.center
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.activityIndicatorViewStyle = .gray
            self.activityIndicator.backgroundColor = UIColor.blue
            self.view.addSubview(self.activityIndicator)
            
            self.activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    func stopLoading(){
        DispatchQueue.main.async { // Correct
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
}

extension MapController : CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleLocationAuthorizationStatus(status: status)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateLocation()
        if let currentLocation = locations.last {
            if fixed && putAlert {
                mapa.animate(to: GMSCameraPosition(target: currentLocation.coordinate, zoom: 15, bearing: -15, viewingAngle: 45))
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestAlwaysAuthorization()
        case .authorizedWhenInUse:
            statusDeniedAlert()
            stopMonitoring()
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            initWaspy()
        case .denied:
            statusDeniedAlert()
            stopMonitoring()
        case .restricted:
            showAlert(title: "La localizacion esta restringida", message: "Esta aplicacion necesita permisos de SIEMPRE compartir localizacion.")
            stopMonitoring()
        }
    }
}

extension MapController {
    //[INICIO DE SERVICIO]
        func startMonitoring()
        {
            timer1 = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)
        }

        func updateLocation()
        {
            firebaseManager.init().updateUserLocation()
        }
    
        @objc func updateData()
        {
            let groupCode = self.userD.string(forKey: "ActualGroup") ?? ""
            if groupCode != ""{
                firebaseManager.init().getGroupMembersInfo(code: groupCode, completion: {(members) in
                    self.userD.set(members, forKey: "MembersActiveGroup")
                    self.draw.updateMembers()
                    self.draw.updateFences()
                })
            }
        }
    
        @objc func updateDataBG(_coordintates: CLLocationCoordinate2D, _speed: CLLocationSpeed)
        {
            firebaseManager.init().updateUserLocationBKG(coordinades: _coordintates, speed: _speed)
        }
    
        @objc func stopMonitoring()
        {
            timer.invalidate()
            timer1.invalidate()
        }
}
