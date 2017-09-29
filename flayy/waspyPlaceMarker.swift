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
    var iconType:Int!
    var radioGeo:Int!
    
    init(name: String, address: String, icono: Int, radio: Int) {
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
        
        markerView = UIImageView(image: resizeImage(image: marcador, newSize: CGSize(width: 40, height: 40)))
        
        markerView.addSubview(markerView)
        
        adress = address
        nombre = name
        iconType = icono
        radioGeo = radio
    }
    
    func setIconView() {
        self.iconView = markerView
    }
    
    func setLocation(location: CLLocationCoordinate2D) {
        self.position = location
    }
}
