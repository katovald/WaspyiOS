//
//  waspyAlertMarker.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 10/3/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import GoogleMaps

class waspyAlertMarker: GMSMarker {
    var titulo:String!
    var comentario:String!
    var imagen:Int!
    var markerView = UIImageView()
    
    init(tipo:Int, coment:String, title: String){
        titulo = title
        comentario = coment
        imagen = tipo
    }
    
    func setIconView(icono: Int) {
        var marcador = UIImage()
        switch icono {
        case 0:
            marcador = UIImage(named: "map-m1.png")!
        case 1:
            marcador = UIImage(named: "map-m2.png")!
        case 2:
            marcador = UIImage(named: "map-m3.png")!
        case 3:
            marcador = UIImage(named: "map-m4.png")!
        case 4:
            marcador = UIImage(named: "map-m5.png")!
        default:
            marcador = UIImage(named: "map-m1.png")!
        }
        
        markerView = UIImageView(image: resizeImage(image: marcador, newSize: CGSize(width: 12, height: 15)))
        
        self.iconView = markerView
    }
    
    func setLocation(location: CLLocationCoordinate2D) {
        self.position = location
    }
    
}
