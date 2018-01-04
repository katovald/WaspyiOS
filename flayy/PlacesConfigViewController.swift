//
//  PlacesConfigViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/19/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces


class PlacesConfigViewController: UIViewController {
    
    @IBOutlet weak var eliminar: UIButton!
    @IBOutlet weak var radio: UISlider!
    @IBOutlet weak var vistaMapa: UIView!
    @IBOutlet weak var texto: UITextField!
    @IBOutlet weak var tipo: UIImageView!
    @IBOutlet weak var editarGuardar: UIBarButtonItem!
    @IBOutlet weak var barraNav: UINavigationBar!
    @IBOutlet weak var infoRadius: UILabel!
    @IBOutlet weak var direccion: UILabel!
    
    
    var searcController:UISearchController!
    var annotation:MKAnnotation!
    var localsearchRequest:MKLocalSearchRequest!
    var localsearch:MKLocalSearch!
    var localSearchResponse:MKLocalSearchResponse!
    var error:NSError!
    var pointAnnotation:MKPointAnnotation!
    var pinAnnottion:MKPinAnnotationView!
    
    @IBAction func searchBarBTN(_ sender: Any) {
//        searcController = UISearchController(searchResultsController: nil)
//        searcController.hidesNavigationBarDuringPresentation = false
//        self.searcController.searchBar.delegate = self
//        present(searcController, animated: true, completion: nil)
        let autocomplete = GMSAutocompleteViewController()
        autocomplete.delegate = self
        
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        autocomplete.autocompleteFilter = filter
        
        present(autocomplete, animated: true, completion: nil)
    }
    
    @IBAction func getBack(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.userD.set(nil, forKey: "EditingPlace")
            self.userD.set(nil, forKey: "PlaceAddressFind")
        })
    }
    
    @IBAction func changeRadius(_ sender: Any) {
        self.infoRadius.text = String(Int(radio.value)) + " metros"
    }
    
    @IBAction func deletePlace(_ sender: Any) {
        firebaseManager.init().deletePlace(code: userD.string(forKey: "ActualGroup")!,
                                           key: (place.first?.key)!)
        self.dismiss(animated: true, completion: {
            self.userD.set(nil, forKey: "EditingPlace")
            NotificationCenter.default.post(name: NSNotification.Name("PlacesUpdated"),
                                            object: self)
            firebaseManager.init().getOwnerData(phone: self.userD.string(forKey: "OwnerPhone")!)
        })
    }
    
    @IBAction func editSave(_ sender: Any) {
        if edicion {
            NotificationCenter.default.post(name: NSNotification.Name("GivemePlaceData"), object: self)
            place = userD.dictionary(forKey: "EditingPlace") as! [String : [String : Any]]
            let key = place.first?.key
            let data = place.first?.value
            let location = data!["l"] as! [String:Double]
            if key! == "none"{
                firebaseManager.init().saveGroupPlace(code: userD.string(forKey: "ActualGroup")!,
                                                      address: direccion.text!,
                                                      icon: icono,
                                                      l: location,
                                                      place_name: texto.text!,
                                                      radio: Int(radio.value))
            }
            FCmNotifications.init().placesUpdated()
            blockedView()
            NotificationCenter.default.post(name: NSNotification.Name("PlacesUpdated"), object: self)
            self.dismiss(animated: true, completion: {
                self.userD.set(nil, forKey: "EditingPlace")
                firebaseManager.init().getOwnerData(phone: self.userD.string(forKey: "OwnerPhone")!)
            })
        }else{
            editingView()
        }
    }
    @IBAction func changeIcon(_ sender: Any) {
        icono += 1
        if icono == 9
        {
            icono = 0
        }
        
        setIcon(icono: icono)
        NotificationCenter.default.post(name: IconChangedNotification, object: self)
    }
    
    var icono:Int = 0
    var edicion = false
    var userD:UserDefaults = UserDefaults.standard
    var place = [String:[String:Any]]()
    let IconChangedNotification = NSNotification.Name("PlaceDataUpdated")
    let PlaceFinded = NSNotification.Name("PlaceAdressFind")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        place = userD.dictionary(forKey: "EditingPlace") as? [String : [String : Any]] ?? [:]
        if place.count == 0{
            editingView()
            eliminar.isHidden = true
            LocationServices.init().getAdress(completion: { (coordinate, speed, json, e) in
                if let a = json {
                    let kilo = a["FormattedAddressLines"] as! [String]
                    
                    var direccion = ""
                    
                    for index in 0...(kilo.count - 1)
                    {
                        direccion += kilo[index]
                        direccion += " "
                    }
                    
                    self.direccion.text = direccion
                } else {
                    self.direccion.text = "Obteniendo direccion..."
                }
            })
            self.texto.text = "Nombre"
            self.infoRadius.text = "100 metros"
        }else{
            let key = place.first?.key
            let value = place.first?.value
            let point = value!["l"] as? [Double] ?? [LocationServices.init().getLocationCoord().latitude,LocationServices.init().getLocationCoord().longitude]
            if key == "none" {
                LocationServices.init().getPointAddress(point: CLLocationCoordinate2D(latitude: point[0], longitude: point[1]), completion: { (json, e) in
                    if let a = json {
                        let kilo = a["FormattedAddressLines"] as! [String]
                        
                        var direccion = ""
                        
                        for index in 0...(kilo.count - 1)
                        {
                            direccion += kilo[index]
                            direccion += " "
                        }
                        
                        self.direccion.text = direccion
                    } else {
                        self.direccion.text = "Obteniendo direccion..."
                    }
                })
                editingView()
            }else{
                let data = place.first?.value
                self.texto.text = data!["place_name"] as? String
                self.direccion.text = data!["address"] as? String
                self.icono = (data!["icon"] as? Int)!
                self.radio.setValue(Float((data!["radio"] as? Int)!), animated: false)
                blockedView()
            }
        }
        setIcon(icono: icono)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(changeAddress),
                                               name: NSNotification.Name("UpdatePlaceLocation"), object: nil)
        //Do any additional setup after loading the view.
    }
    
    func editingView(){
        editarGuardar.title = "Guardar"
        editarGuardar.tintColor = UIColor.init(hex: 0xEEC61B)
        edicion = true
        vistaMapa.layer.borderColor = UIColor.red.cgColor
        vistaMapa.isUserInteractionEnabled = true
        tipo.isUserInteractionEnabled = true
        texto.isEnabled = true
        eliminar.isEnabled = true
        tipo.layer.borderWidth = 0
        tipo.layer.masksToBounds = false
        tipo.clipsToBounds = true
        radio.isEnabled = true
    }
    
    func blockedView(){
        edicion = false
        vistaMapa.layer.borderWidth = 4
        vistaMapa.layer.borderColor = UIColor.green.cgColor
        radio.isEnabled=false
        vistaMapa.isUserInteractionEnabled = false
        texto.isEnabled = false
        eliminar.isEnabled = false
        tipo.isUserInteractionEnabled = false
        tipo.layer.borderWidth = 0
        tipo.layer.masksToBounds = false
        tipo.clipsToBounds = true
    }
    
    func setIcon(icono: Int){
        switch icono {
        case 1:
            tipo.image = resizeImage(image: UIImage(named: "geoplace_house2")!, newSize: CGSize(width: 35, height: 35))
        case 2:
            tipo.image = resizeImage(image: UIImage(named: "geoplace_school")!, newSize: CGSize(width: 35, height: 35))
        case 3:
            tipo.image = resizeImage(image: UIImage(named: "geoplace_work")!, newSize: CGSize(width: 35, height: 35))
        case 4:
            tipo.image = resizeImage(image: UIImage(named: "geoplace_super")!, newSize: CGSize(width: 35, height: 35))
        case 5:
            tipo.image = resizeImage(image: UIImage(named: "geoplace_coffe")!, newSize: CGSize(width: 35, height: 35))
        case 6:
            tipo.image = resizeImage(image: UIImage(named: "geoplace_gym")!, newSize: CGSize(width: 35, height: 35))
        case 7:
            tipo.image = resizeImage(image: UIImage(named: "geoplace_mall")!, newSize: CGSize(width: 35, height: 35))
        case 8:
            tipo.image = resizeImage(image: UIImage(named: "geoplace_park")!, newSize: CGSize(width: 35, height: 35))
        default:
            tipo.image = resizeImage(image: UIImage(named: "geoplace_house1")!, newSize: CGSize(width: 35, height: 35))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func changeAddress()
    {
        let data = self.userD.dictionary(forKey: "EditingPlace") as! [String : [String : Any]]
        let point = data.first?.value["l"] as! [String:Double]
        LocationServices.init().getPointAddress(point: CLLocationCoordinate2D(latitude: point["0"]!, longitude: point["1"]!) , completion: {(json, e)  in
            if let a = json {
                let kilo = a["FormattedAddressLines"] as! [String]
            
                var direccion = ""
            
                for index in 0...(kilo.count - 1)
                {
                    direccion += kilo[index]
                    direccion += " "
                }
            
                self.direccion.text = direccion
            } else {
                self.direccion.text = "Obteniendo direccion..."
            }
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        //1
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        //2
        localsearchRequest = MKLocalSearchRequest()
        localsearchRequest.naturalLanguageQuery = searchBar.text
        localsearch = MKLocalSearch(request: localsearchRequest)
        localsearch.start { (localSearchResponse, error) -> Void in
            
            if localSearchResponse == nil{
                let alertController = UIAlertController(title: nil, message: "Place Not Found", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            //3
            self.pointAnnotation = MKPointAnnotation()
            self.pointAnnotation.title = searchBar.text
            self.pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: localSearchResponse!.boundingRegion.center.latitude, longitude:     localSearchResponse!.boundingRegion.center.longitude)
            print("Coordenada: \(self.pointAnnotation.coordinate)")
        }
    }
}

extension PlacesConfigViewController: GMSAutocompleteViewControllerDelegate {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Print place info to the console.
        print("Place attributions: \(String(describing: place.coordinate))")
        // Call custom function zcto populate the address form.
        
        // Close the autocomplete widget.
        self.dismiss(animated: true, completion: {
            let pointSended = ["lat":place.coordinate.latitude,
                               "long":place.coordinate.longitude]
            self.userD.set(pointSended, forKey: "PointCoordinate")
            NotificationCenter.default.post(name: NSNotification.Name("PlaceAddressFind"), object: self)
        })
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
