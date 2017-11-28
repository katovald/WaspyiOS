//
//  PlacesConfigViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/19/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
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
    
    @IBAction func getBack(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            self.userD.set(nil, forKey: "EditingPlace")
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
            NotificationCenter.default.post(name: NSNotification.Name("PlacesAdded"),
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
            let point = value!["l"] as! [Double]
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
        editarGuardar.tintColor = UIColor.red
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
}
