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

class MapController: UIViewController,  GMSMapViewDelegate, CLLocationManagerDelegate{
    
    var ref: DatabaseReference!
    let locationManager = CLLocationManager()
    var camera = GMSCameraPosition()
    var locValue = CLLocationCoordinate2D()
    var marker = GMSMarker()
    let userD = UserDefaults.standard
    let fileMan = FileManager.default
    
    override func viewDidLoad() {
        let status = CLLocationManager.authorizationStatus()
        if(status == CLAuthorizationStatus.notDetermined || status == CLAuthorizationStatus.denied)
        {
            locationManager.requestAlwaysAuthorization()
        }else{
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            locValue = locationManager.location!.coordinate
            self.locationManager.delegate = self
        }
        camera = GMSCameraPosition.camera(withLatitude: locValue.latitude, longitude: locValue.longitude, zoom: 15.0, bearing: -15, viewingAngle: 45)
        self.view = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        locationManager.delegate = self
    }
    
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
        
        marker.position = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
        marker.title = "Kato"
        marker.iconView = markerView
        
        marker.map = map

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let photoURl = docUrl.appendingPathComponent(userD.string(forKey: "Phone")! + ".png")
        
        if (fileMan.fileExists(atPath: photoURl.path)){
            setmarker(image: UIImage(contentsOfFile: photoURl.path)!, map: self.view as! GMSMapView)
            //self.ref.child("accounts/" + userD.string(forKey: "Phone")! + "/location/").setValue()
        }
        
        print(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        //geocerca
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //geocerca
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != CLAuthorizationStatus.denied{
            locationManager.startUpdatingLocation()
        }
    }
    
    override func didReceiveMemoryWarning() {
        
    }
}
