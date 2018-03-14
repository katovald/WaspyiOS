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
    let reacNet = Reachability()
    
    @IBAction func searchBarBTN(_ sender: Any) {
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
            firebaseManager.init().getPlaces(group: self.userD.string(forKey: "ActualGroup")!, completion: { (places) in
                self.userD.set(places, forKey: "ActualGroupPlaces")
            })
            NotificationCenter.default.post(notification: .placesChanges)
        })
    }
    
    @IBAction func changeRadius(_ sender: Any) {
        self.infoRadius.text = String(Int(radio.value)) + " metros"
    }
    
    @IBAction func deletePlace(_ sender: Any) {
        if (reacNet?.isReachable)!{
            firebaseManager.init().deletePlace(code: userD.string(forKey: "ActualGroup")!,
                                               key: (place.first?.key)!)
            NotificationCenter.default.post(notification: .placesChanges)
            firebaseManager.init().getOwnerData(phone: self.userD.string(forKey: "OwnerPhone")!)
            self.dismiss(animated: true, completion: {
                self.userD.set(nil, forKey: "EditingPlace")
            })
        }else{
            showToast(message: "Necesitas estar conectado a internet")
        }
    }
    
    @IBAction func editSave(_ sender: Any) {
        if edicion {
            if (reacNet?.isReachable)! {
                NotificationCenter.default.post(notification: .getPlaceData)
                place = userD.dictionary(forKey: "EditingPlace") as! [String : [String : Any]]
                let key = place.first?.key
                var data = place.first?.value
                let location = data!["l"] as! [String:Double]
                if key! == "none"{
                    firebaseManager.init().saveGroupPlace(code: userD.string(forKey: "ActualGroup")!,
                                                          address: direccion.text!,
                                                          icon: icono,
                                                          l: location,
                                                          place_name: texto.text!,
                                                          radio: Int(radio.value))
                }else{
                    data!["place_name"] = texto.text!
                    firebaseManager.init().updatePlace(code: userD.string(forKey: "ActualGroup")!, key: key!, data: data!)
                }
                FCmNotifications.init().send(type: .placesUpdated)
                blockedView()
                firebaseManager.init().getOwnerData(phone: self.userD.string(forKey: "OwnerPhone")!)
                self.dismiss(animated: true, completion: {
                    self.userD.set(nil, forKey: "EditingPlace")
                    NotificationCenter.default.post(notification: .editPlace)
                })
            }else{
                showToast(message: "Necesitas Internet para poder guardar")
            }
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
        NotificationCenter.default.post(notification: .placeConfig)
    }
    
    var icono:Int = 0
    var edicion = false
    var userD:UserDefaults = UserDefaults.standard
    var place = [String:[String:Any]]()
    
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
            let point = value!["l"] as? [Double] ?? [LocationServices.init().getLocationCoord().latitude,  LocationServices.init().getLocationCoord().longitude]
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
                self.infoRadius.text = String(Int(radio.value)) + " metros"
                blockedView()
            }
        }
        setIcon(icono: icono)
        NotificationCenter.default.add(observer: self, selector: #selector(changeAddress), notification: .findAddress)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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
        let data = self.userD.dictionary(forKey: "EditingPlace") as? [String : [String : Any]] ?? [:]
        guard let point = data.first?.value["l"] as? [Double] else {return}
        LocationServices.init().getPointAddress(point: CLLocationCoordinate2D(latitude: point[0], longitude: point[1]) , completion: {(json, e)  in
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
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
            let pointSended = [place.coordinate.latitude, place.coordinate.longitude]
            self.userD.set(pointSended, forKey: "PointCoordinate")
            self.direccion.text = place.addressComponents?.first?.name
            NotificationCenter.default.post(notification: .findAddress)
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
