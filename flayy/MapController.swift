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
    var radius:Int!
    
    var geotification: [Geotification] = []

    override func viewDidLoad() {
        backView.frame = view.frame
        backView.frame.origin = view.frame.origin
        backView.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
        workingView.activityIndicatorViewStyle = .whiteLarge
        workingView.hidesWhenStopped = true
        workingView.center = backView.center
        backView.addSubview(workingView)
        workingView.startAnimating()

        let status = CLLocationManager.authorizationStatus()
        if(status == CLAuthorizationStatus.notDetermined || status == CLAuthorizationStatus.denied)
        {
            locationManager.requestAlwaysAuthorization()
        }else{
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locValue = locationManager.location!.coordinate
        }
        
        camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 15, bearing: -15, viewingAngle: 45)
        
        self.mapa = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.mapa.frame = view.frame
        self.mapa.setMinZoom(13, maxZoom: 20)
        self.mapa.delegate = self
        self.view = mapa
    
        locationManager.delegate = self
        
        self.view.addSubview(backView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMarkers), name: NSNotification.Name("UserPhotoChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(centerView), name: NSNotification.Name("FixCameraPush"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(changeInfo), name: NSNotification.Name("UserGroupsChanged"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(locateUser), name: NSNotification.Name("UserAsked"), object: nil)
        
         NotificationCenter.default.addObserver(self, selector: #selector(updateFences), name: NSNotification.Name("PlacesAdded"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(turnAlertsOnOFF), name: NSNotification.Name("Alerts"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(initWaspy), name: NSNotification.Name("CorrectLogIn"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presetnDialog), name: NSNotification.Name("PushAlert"), object: nil)
        
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
        updateMarkers()
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
        updateFences()
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
    
    func loadAllGeonotifications(){
        geotification = []
        let places = userD.array(forKey: "ActualGroupPlaces")
        for place in places!{
            
        }
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
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        hideAlerts()
        if alertas
        {
            drawAlerts(map: mapView)
        }else{
            NotificationCenter.default.post(name: NSNotification.Name("LoseFocus"), object: self)
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
        let center = getCenterCoordinate()
        let theGeoFire = GeoFire(firebaseRef: Database.database().reference().child("alerts_geo"))
        let circleQuery = theGeoFire!.query(at: CLLocation(latitude: center.latitude,
                                                           longitude: center.longitude),
                                            withRadius: getRadius()/1000)
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
    
    func regionMonitor() -> CLCircularRegion {
        let autentia = CLCircularRegion(center: CLLocationCoordinate2D(latitude: 40.453163, longitude: -3.509220), radius: 199, identifier: "prueba")
        autentia.notifyOnExit = true
        autentia.notifyOnEntry = true
        return autentia
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if alertas {
            
        }
    }
    
    func startMonitor(){
        
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        alert(message: "Hola")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        alert(message: "Bye")
    }
    

}
