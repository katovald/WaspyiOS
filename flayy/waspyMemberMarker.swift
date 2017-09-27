//
//  waspyMarker.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 9/8/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import AVKit
import GoogleMaps

class waspyMemberMarker: GMSMarker {
    let fileMan = FileManager.default
    var foto:UIImage!
    var userD:UserDefaults = UserDefaults.standard
    var markerView:UIImageView!
    
    init(phone: String) {
        let marcador = UIImage(named: "marker_layout")!
        markerView = UIImageView(image: resizeImage(image: marcador, newSize: CGSize(width: 35, height: 38)))
        
        let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let photoURl = docUrl.appendingPathComponent(phone + ".png")
        
        if (fileMan.fileExists(atPath: photoURl.path)){
            foto = UIImage(contentsOfFile: photoURl.path)
        }else{
            foto = UIImage(named: "defaultIMG.png")
        }
        
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
    
    func setIconView() {
        self.iconView = markerView
    }
    
    func setLocation(location: CLLocationCoordinate2D) {
        self.position = location
    }
}

extension waspyMemberMarker{
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
    
    func updateMarkerdata(name: String, degrees: CLLocationDegrees, duration: Double) {
        // Keep Rotation Short
        
    }
    
    func getLocation() -> CLLocationCoordinate2D {
        return self.position
    }
}

