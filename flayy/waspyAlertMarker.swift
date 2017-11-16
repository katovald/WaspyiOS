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
    var fecha:String!
    var markerView = UIImageView()
    
    init(tipo:Int, coment:String, title: String, date: String){
        titulo = title
        comentario = coment
        imagen = tipo
        fecha = date
    }
    
    func setIconView() {
        var marcador = UIImage()
        switch imagen {
        case 1:
            marcador = UIImage(named: "map-m1.png")!
        case 2:
            marcador = UIImage(named: "map-m2.png")!
        case 3:
            marcador = UIImage(named: "map-m3.png")!
        case 4:
            marcador = UIImage(named: "map-m4.png")!
        case 5:
            marcador = UIImage(named: "map-m5.png")!
        default:
            marcador = UIImage(named: "map-m1.png")!
        }
        
        markerView = UIImageView(image: marcador)
        markerView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        markerView.contentMode = .scaleAspectFit
        
        self.iconView = markerView
        self.title = titulo
        self.snippet = fecha
    }
    
    func setLocation(location: CLLocationCoordinate2D) {
        self.position = location
    }
}
