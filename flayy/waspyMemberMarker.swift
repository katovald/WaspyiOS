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
    let screenWidth = UIScreen.main.nativeBounds.width
    var markerSize:CGSize!
    var photoSize:CGSize!
    var dif:Int!
    let marcador = UIImage(named: "marker_layout")!
    var name:String!
    
    init(phone: String, name: String) {
        if screenWidth > 1000 {
            markerSize = CGSize(width: 21, height: 23)
            photoSize = CGSize(width: 15, height: 15)
            dif = 7
        }else{
            markerSize = CGSize(width: 32, height: 35)
            photoSize = CGSize(width: 23, height: 23)
            dif = 6
        }
        markerView = UIImageView(image: resizeImage(image: marcador, newSize: markerSize))
        
        let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let photoURl = docUrl.appendingPathComponent(phone + ".png")
        
        if (fileMan.fileExists(atPath: photoURl.path)){
            foto = UIImage(contentsOfFile: photoURl.path)
        }else{
            foto = UIImage(named: "default.png")
        }
        
        let fotoview = UIImageView(image: resizeImage(image: foto, newSize: photoSize))
        fotoview.layer.borderWidth = 1
        fotoview.layer.masksToBounds = false
        fotoview.layer.cornerRadius = fotoview.frame.height/2
        fotoview.clipsToBounds = true
        fotoview.center.x = markerView.center.x
        fotoview.center.y = markerView.center.y - CGFloat(dif)
        fotoview.backgroundColor = UIColor.clear
        
        markerView.addSubview(fotoview)
        self.name = name
    }
    
    func setIconView() {
        self.iconView = markerView
        self.snippet = self.name
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
    
    func updateMarkerdata(name: String, image: UIImage) {
        self.title = name
        
        if screenWidth > 1000 {
            markerSize = CGSize(width: 21, height: 23)
            photoSize = CGSize(width: 15, height: 15)
            dif = 7
        }else{
            markerSize = CGSize(width: 32, height: 35)
            photoSize = CGSize(width: 23, height: 23)
            dif = 6
        }
        markerView = UIImageView(image: resizeImage(image: marcador, newSize: markerSize))

        let fotoview = UIImageView(image: resizeImage(image: image, newSize: photoSize))
        fotoview.layer.borderWidth = 1
        fotoview.layer.masksToBounds = false
        fotoview.layer.cornerRadius = fotoview.frame.height/2
        fotoview.clipsToBounds = true
        fotoview.center.x = markerView.center.x
        fotoview.center.y = markerView.center.y - CGFloat(dif)
        fotoview.backgroundColor = UIColor.clear
        
        markerView.addSubview(fotoview)
        
        self.iconView = markerView
    }
    
    func getLocation() -> CLLocationCoordinate2D {
        return self.position
    }
}

