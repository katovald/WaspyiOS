//
//  File.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 3/13/18.
//  Copyright © 2018 CAMSA. All rights reserved.
//

import Foundation
import GoogleMaps
import GeoFire
import FirebaseDatabase

class paintMarkers: NSObject {
    
    private var members:[String:waspyMemberMarker] = [:]
    private var places:[String:waspyPlaceMarker] = [:]
    private var alerts:[String:waspyAlertMarker] = [:]
    private var mapa:GMSMapView!
    private var userD:UserDefaults = UserDefaults.standard
    let theGeoFire = GeoFire(firebaseRef: Database.database().reference().child("alerts_geo"))
    var circleQuery:GFCircleQuery?
    
    init(_ view: GMSMapView) {
        mapa = view
    }
    
    public func drawMembers() {
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
                    marker.setIconView()
                    marker.map = nil
                    self.members[memberPhone] = marker
                }else{
                    let latitude = location["latitude"]! as! CLLocationDegrees
                    let longitude = location["longitude"]! as! CLLocationDegrees
                    marker.setIconView()
                    marker.setLocation(location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                    marker.map = self.mapa
                    self.members[memberPhone] = marker
                }
            }
        }
    }
    
    public func drawAlerts(center: CLLocationCoordinate2D, radius: CLLocationDistance)
    {
        if radius/3000 < 23 {
            circleQuery = theGeoFire!.query(at: CLLocation(latitude: center.latitude,
                                                           longitude: center.longitude),
                                        withRadius: radius/3000)
        
            _ = circleQuery!.observe(.keyEntered, with: { (key, location) in
                if self.alerts[key!] != nil{
                    
                }else{
                    let llave = key
                    firebaseManager.init().getAlertData(key: llave!, completion: { (value) in
                        let marcador = waspyAlertMarker(tipo: value["type"] as? Int ?? 0,
                                                        coment: value["comments"] as? String ?? "",
                                                        title: value["title"] as? String ?? "",
                                                        date: value["date"] as? String ?? "")
                        marcador.setIconView()
                        marcador.setLocation(location: (location?.coordinate)!)
                        marcador.map = self.mapa
                        self.alerts[llave!] = marcador
                    })
                }
            })
            
            _ = circleQuery!.observe(.keyExited, with: { (key, location) in
                if self.alerts[key!] != nil{
                    
                }else{
                    self.alerts[key!]?.map = nil
                    self.alerts.removeValue(forKey: key!)
                }
            })
        }
    }
    
    public func drawFences(){
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
            placeMarker.map = mapa
            placeMarker.drawcircle(mapa)
        }
    }
    
    public func updateOwner(phone:String, location: CLLocationCoordinate2D){
        if members[phone] != nil {
            members[phone]?.updateMarker(coordinates: location, degrees: 0, duration: 0)
        }else{
            members[phone] = waspyMemberMarker(phone: phone, name: self.userD.string(forKey: "OwnerName") ?? "Wasper")
            members[phone]?.setIconView()
            members[phone]?.updateMarker(coordinates: location, degrees: 0, duration: 0)
        }
        members[phone]?.map = mapa
    }
    
    public func updateOwnerPhoto(){
        guard let ownerPhone = userD.string(forKey: "OwnerPhone") else {return}
        let name = userD.string(forKey: "OwnerName") ?? ""
        let image = firebaseManager.init().getMemberPhoto(phone: ownerPhone)
        members[ownerPhone]?.updateMarkerdata(name: name, image: image)
    }
    
    public func updateMembers() {
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
                    if members[memberPhone] == nil
                    {
                        let marker = waspyMemberMarker(phone: memberPhone, name: data!["name"] as! String)
                        marker.setIconView()
                        marker.setLocation(location: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                        members[memberPhone] = marker
                    }else{
                        members[memberPhone]?.updateMarker(coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), degrees: 0, duration: 0.2)
                    }
                }
                
                if !visible
                {
                    members[memberPhone]?.map = nil
                }else{
                    members[memberPhone]?.map = mapa
                }
            }
        }
        if allMembers.count < members.count
        {
            let borrar = members.keys
            for marker in borrar
            {
                if allMembers.contains(marker)
                {
                    
                }else{
                    members[marker]?.map = nil
                    members[marker] = nil
                }
            }
        }
    }
    
    public func updateAlerts(center: CLLocationCoordinate2D, radius: CLLocationDistance)
    {
        circleQuery?.center = CLLocation(latitude: center.latitude, longitude: center.longitude)
        circleQuery?.radius = radius.magnitude/3000
    }
    
    public func updateFences(){
        let keys = places.keys
        for key in keys{
            places[key]?.map = nil
            places[key]?.deleteCircle()
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
            placeMarker.map = mapa
            placeMarker.drawcircle(mapa)
        }
    }
    
    public func deleteAlerts()
    {
        let keys = alerts.keys
        for key in keys
        {
            let marker = alerts[key]
            marker?.map = nil
        }
        alerts.removeAll()
        circleQuery?.removeAllObservers()
    }
    
    public func deleteFences()
    {
        let keys = places.keys
        for key in keys
        {
            places[key]?.map = nil
        }
        places.removeAll()
    }
    
    public func deleteMembers()
    {
        let keys = members.keys
        for key in keys
        {
            members[key]?.map = nil
        }
        members.removeAll()
    }
}
