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
    var markers = [String:waspyMemberMarker]()
    var places = [String:waspyPlaceMarker]()
    var alerts = [String:waspyAlertMarker]()
    var mapa:GMSMapView!
    var alertas:Bool = false
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    let backView = UIView()
    var radius:Int!
    var ownerPhone:String!
    var fixed:Bool!
    var putAlert:Bool!
    var onBackground:Bool!
    
    var timer = Timer()
    var timer1 = Timer()

    override func viewDidLoad() {
        
        ownerPhone = userD.string(forKey: "OwnerPhone")
        self.onBackground = true
        fixed = false
        putAlert = false
        
        camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 15, bearing: -15, viewingAngle: 45)
        
        self.mapa = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.mapa.frame = view.frame
        self.mapa.setMinZoom(13, maxZoom: 20)
        self.mapa.delegate = self
        self.view = mapa
    
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = false
        } else {
            // Fallback on earlier versions
        }
        locationManager.distanceFilter = 5.0
        locationManager.delegate = self
        
        NotificationCenter.default.add(observer: self, selector: #selector(updateOwnerMarkerPhoto), notification: .userDataChange)
        
        NotificationCenter.default.add(observer: self, selector: #selector(centerView), notification: .fxCameraMap)
        
        NotificationCenter.default.add(observer: self, selector: #selector(changeInfo), notification: .groupsChanges)
        
        NotificationCenter.default.add(observer: self, selector: #selector(locateUser), notification: .findUser)
        
        NotificationCenter.default.add(observer: self, selector: #selector(updateFences), notification: .placesChanges)
        
        NotificationCenter.default.add(observer: self, selector: #selector(turnAlertsOnOFF), notification: .alert)
        
        NotificationCenter.default.add(observer: self, selector: #selector(initWaspy), notification: .logIn)
        
        NotificationCenter.default.add(observer: self, selector: #selector(presetnDialog), notification: .pushAlert)
        
        NotificationCenter.default.add(observer: self, selector: #selector(turnEdit), notification: .tryToPush)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: .UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: .UIApplicationDidBecomeActive, object: nil)

    }
    
    @objc func turnEdit(){
        putAlert = !putAlert
    }
    
    @objc func initWaspy() {
        startLoading()
        
        getMembersData =  Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateMarkers), userInfo: nil, repeats: true)
        
        drawMarkers(map: view as! GMSMapView)
        updateFences()
        
        stopLoading()
    }
    
    @objc func changeInfo(){
        self.view.addSubview(backView)
        self.view = UIView()
        self.mapa.clear()
        startLoading()
        if locationManager.location != nil{
            let camera = GMSCameraPosition.camera(withLatitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, zoom: 15.0, bearing: -15, viewingAngle: 45)
            self.mapa = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        }else{
            self.mapa = GMSMapView()
        }
        mapa.delegate = self
        self.view = mapa
        updateMarkers()
        updateFences()
        stopLoading()
    }
    
    @objc func turnAlertsOnOFF()
    {
        if alertas{
            hideAlerts()
            alertas = false
            fixed = false
        }else{
            drawAlerts(map: self.view as! GMSMapView)
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
        let keys = places.keys
        for key in keys{
            places[key]?.map = nil
        }
        
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
        startGeofences()
    }
    
    @objc func updateMarkers()
    {
        var aux = userD.array(forKey: "MembersActiveGroup") as? [[String:[String:Any]]] ?? []
        print(aux)
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
                    let marker = waspyMemberMarker(phone: memberPhone, name: data!["name"] as! String)
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
        updateFences()
    }
    
    @objc func updateOwnerMarkerPhoto()
    {
        let name = userD.string(forKey: "OwnerName") ?? ""
        let image = firebaseManager.init().getMemberPhoto(phone: ownerPhone)
        markers[ownerPhone]?.updateMarkerdata(name: name, image: image)
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
    
    func drawMarkers(map: GMSMapView)
    {
        var aux = userD.array(forKey: "MembersActiveGroup") as? [[String:[String:Any]]] ?? []
        if aux.count > 0 {
            for key in 0...aux.count - 1 {
                let memberPhone = (aux[key].first?.key)!
                let data = aux[key].first?.value
                let marker = waspyMemberMarker(phone: memberPhone,name: data!["name"] as? String ?? "Usuario")
                let location = data!["location"] as? [String:Any] ?? [:]
                let visible = data!["visibility"] as? Bool ?? true
                if location.count == 0 || !visible
                {
                    return
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
    
    func drawAlerts(map: GMSMapView)
    {
        fixed = true
        let center = getCenterCoordinate()
        let theGeoFire = GeoFire(firebaseRef: Database.database().reference().child("alerts_geo"))
        let circleQuery = theGeoFire!.query(at: CLLocation(latitude: center.latitude,
                                                           longitude: center.longitude),
                                            withRadius: getRadius()/3000)
        _ = circleQuery!.observe(.keyEntered, with: { (key, location) in
            let llave = key
            firebaseManager.init().getAlertData(key: llave!, completion: { (value) in
                let marcador = waspyAlertMarker(tipo: value["type"] as? Int ?? 0,
                                                coment: value["comments"] as? String ?? "",
                                                title: value["title"] as? String ?? "",
                                                date: value["date"] as? String ?? "")
                marcador.setIconView()
                marcador.setLocation(location: (location?.coordinate)!)
                marcador.map = map
                self.alerts[llave!] = marcador
            })
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
        alerts.removeAll()
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if !alertas{
            let controller = storyboard?.instantiateViewController(withIdentifier: "ConfigPlace") as! PlacesConfigViewController
            let placeEdited = ["none": ["l": ["0":coordinate.latitude, "1": coordinate.longitude]]]
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
        hideAlerts()
        if alertas
        {
            drawAlerts(map: mapView)
        }
    }
    
    func getLocation() {
        let status = CLLocationManager.authorizationStatus()
        handleLocationAuthorizationStatus(status: status)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(defaultAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func statusDeniedAlert() {
        let alertController = UIAlertController(title: "Compartir ubicacion esta desabilitado", message: "Esta aplicacion necesita permisos de SIEMPRE compartir localizacion.", preferredStyle: .alert)
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
    
    @objc func willResignActive(){
        onBackground = !onBackground
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
        if let currentLocation = locations.last {
            if markers[ownerPhone] != nil{
                markers[ownerPhone]?.updateMarker(coordinates: currentLocation.coordinate, degrees: 0, duration: 0)
            }else{
                let ownerMarker = waspyMemberMarker(phone: ownerPhone, name: self.userD.string(forKey: "OwnerName") ?? "")
                ownerMarker.setIconView()
                markers[ownerPhone] = ownerMarker
                markers[ownerPhone]?.updateMarker(coordinates: currentLocation.coordinate, degrees: 0, duration: 0)
            }
            let mapa = self.view as! GMSMapView
            if fixed && putAlert {
                mapa.animate(to: GMSCameraPosition(target: (locations.last?.coordinate)!, zoom: 15, bearing: -15, viewingAngle: 45))
            }
        }
        
        if onBackground {
            updateDataBG(_coordintates: (manager.location?.coordinate)!, _speed: (manager.location?.speed)!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    }
    
    func handleLocationAuthorizationStatus(status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            startMonitoring()
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
            timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
            timer1 = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)
        }
    
        @objc func startTimer()
        {
            firebaseManager.init().updateUserLocation()
        }
    
        @objc func updateData()
        {
            let groupCode = self.userD.string(forKey: "ActualGroup") ?? ""
            if groupCode != ""{
                firebaseManager.init().getGroupMembersInfo(code: groupCode, completion: {(members) in
                    self.userD.set(members, forKey: "MembersActiveGroup")
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
