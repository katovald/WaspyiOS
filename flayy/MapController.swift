//
//  MapController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/12/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreFoundation

class MapController: UIViewController,  GMSMapViewDelegate, CLLocationManagerDelegate{
    
    let locationManager = CLLocationManager()
    var camera = GMSCameraPosition()
    var locValue = CLLocationCoordinate2D()
    var marker = GMSMarker()
    
    override func viewDidLoad() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locValue = locationManager.location!.coordinate
        self.locationManager.delegate = self
        setParameters()
    }
    
    func setParameters()
    {
        let marcador = UIImage(named: "marker_layout")!
        let markerView = UIImageView(image: resizeImage(image: marcador, newSize: CGSize(width: 35, height: 38)))
        
        let foto = UIImage(named: "logo")
        let fotoview = UIImageView(image: resizeImage(image: foto!, newSize: CGSize(width: 24, height: 24)))
        fotoview.layer.borderWidth = 1
        fotoview.layer.masksToBounds = false
        fotoview.backgroundColor = UIColor.blue
        fotoview.layer.cornerRadius = fotoview.frame.height/2
        fotoview.clipsToBounds = true
        fotoview.center.x = markerView.center.x
        fotoview.center.y = markerView.center.y - 7
        
        fotoview.backgroundColor = UIColor.clear
        
        markerView.addSubview(fotoview)
        
        marker.position = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        marker.title = "Kato"
        marker.iconView = markerView
        
        camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 15.0, bearing: -15, viewingAngle: 45)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        
        marker.map = mapView
        
        self.view = mapView
    }
    
    func resizeImage(image: UIImage, newSize: CGSize) -> UIImage {
        
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Set the quality level to use when rescaling
        context!.interpolationQuality = CGInterpolationQuality.default
        let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
        
        context!.concatenate(flipVertical)
        // Draw into the context; this scales the image
        context?.draw(image.cgImage!, in: CGRect(x: 0.0,y: 0.0, width: newRect.width, height: newRect.height))
        
        let newImageRef = context!.makeImage()! as CGImage
        let newImage = UIImage(cgImage: newImageRef)
        
        // Get the resized image from the context and a UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        marker.position = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        print("update")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        //geocerca
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //geocerca
    }
    
    override func didReceiveMemoryWarning() {
        
    }
}
