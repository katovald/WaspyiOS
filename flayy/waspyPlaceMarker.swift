//
//  waspyPlaceMarker.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 9/29/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import GoogleMaps

class waspyPlaceMarker: GMSMarker {

    var markerView:UIImageView!
    var adress:String!
    var nombre:String!
    var radioGeo:Int!
    var icono:Int!
    
    init(name: String, address: String, radio: Int, icon: Int) {
        adress = address
        nombre = name
        radioGeo = radio
        icono = icon
    }
    
    func setIconView(icono: Int) {
        var marcador = UIImage()
        switch icono {
        case 1:
            marcador = UIImage(named: "geoplace_house2")!
        case 2:
            marcador = UIImage(named: "geoplace_school")!
        case 3:
            marcador = UIImage(named: "geoplace_work")!
        case 4:
            marcador = UIImage(named: "geoplace_super")!
        case 5:
            marcador = UIImage(named: "geoplace_coffe")!
        case 6:
            marcador = UIImage(named: "geoplace_gym")!
        case 7:
            marcador = UIImage(named: "geoplace_mall")!
        case 8:
            marcador = UIImage(named: "geoplace_park")!
        default:
            marcador = UIImage(named: "geoplace_house1")!
        }
        let screenWidth = UIScreen.main.nativeBounds.width
        var markerSize:CGSize!
        
        if screenWidth > 1000 {
            markerSize = CGSize(width: 15, height: 15)
        }else{
            markerSize = CGSize(width: 20, height: 20)
        }
        
        markerView = UIImageView(image: resizeImage(image: marcador, newSize: markerSize))
        
        self.iconView = markerView
    }
    
    func setLocation(location: CLLocationCoordinate2D) {
        self.position = location
    }
}

extension waspyPlaceMarker{
    func updateMarker(coordinates: CLLocationCoordinate2D, degrees: CLLocationDegrees, duration: Double) {
        // Keep Rotation Short
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        self.rotation = degrees
        CATransaction.commit()
        
        // Movement
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        self.position = coordinates
        
        CATransaction.commit()
    }
    
    func updateRadius(radius: Int){
        radioGeo = radius
    }
    
    func updateMarkerIcon(icono: Int) {
        // Keep Rotation Short
        var marcador = UIImage()
        switch icono {
        case 1:
            marcador = UIImage(named: "geoplace_house2")!
        case 2:
            marcador = UIImage(named: "geoplace_school")!
        case 3:
            marcador = UIImage(named: "geoplace_work")!
        case 4:
            marcador = UIImage(named: "geoplace_super")!
        case 5:
            marcador = UIImage(named: "geoplace_coffe")!
        case 6:
            marcador = UIImage(named: "geoplace_gym")!
        case 7:
            marcador = UIImage(named: "geoplace_mall")!
        case 8:
            marcador = UIImage(named: "geoplace_park")!
        default:
            marcador = UIImage(named: "geoplace_house1")!
        }
        let screenWidth = UIScreen.main.nativeBounds.width
        var markerSize:CGSize!
        
        if screenWidth > 1000 {
            markerSize = CGSize(width: 15, height: 15)
        }else{
            markerSize = CGSize(width: 20, height: 20)
        }
        
        markerView = UIImageView(image: resizeImage(image: marcador, newSize: markerSize))
        
        self.iconView = markerView
        
        self.icono = icono
    }
    
    func getLocation() -> CLLocationCoordinate2D {
        return self.position
    }
    
    func getData() -> [String:Any] {
        var data = [String:Any]()
        data["address"] = self.adress
        data["icon"] = self.icono
        data["l"] = ["0":self.position.latitude,
                     "1":self.position.longitude]
        data["place_name"] = self.nombre
        data["radio"] = self.radioGeo
        return data
    }
}


