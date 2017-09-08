//
//  markerUnique.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 9/4/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import GoogleMaps

class markerUnique: GMSMarker {
    private var telefono:String!
    private var nombre:String!
    private var posicion:CLLocationCoordinate2D?
    
    func setmarker(image: UIImage, map: GMSMapView)
    {
        
        let marcador = UIImage(named: "marker_layout")!
        let markerView = UIImageView(image: resizeImage(image: marcador, newSize: CGSize(width: 35, height: 38)))
        
        let foto = image
        let fotoview = UIImageView(image: resizeImage(image: foto, newSize: CGSize(width: 24, height: 24)))
        fotoview.layer.borderWidth = 1
        fotoview.layer.masksToBounds = false
        fotoview.backgroundColor = UIColor.blue
        fotoview.layer.cornerRadius = fotoview.frame.height/2
        fotoview.clipsToBounds = true
        fotoview.center.x = markerView.center.x
        fotoview.center.y = markerView.center.y - 7
        
        fotoview.backgroundColor = UIColor.clear
        
        markerView.addSubview(fotoview)
    }
}
