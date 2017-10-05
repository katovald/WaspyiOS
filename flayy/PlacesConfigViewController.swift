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
    
    @IBAction func getBack(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func editSave(_ sender: Any) {
        if edicion{
            edicion = false
            vistaMapa.layer.borderColor = UIColor.green.cgColor
            vistaMapa.isUserInteractionEnabled = false
            tipo.isUserInteractionEnabled = false
            editarGuardar.title = "Editar"
            editarGuardar.tintColor = UIColor.yellow
            var l = ["0": 19.415306357651144]
            l["1"] = -99.13663986116934
            firebaseManager.init().saveGroupPlace(code: userD.string(forKey: "ActualGroup")!, address: "address", icon: icono, l: l, place_name: "asffafe", radio: 100)
        }else{
            editarGuardar.title = "Guardar"
            editarGuardar.tintColor = UIColor.red
            edicion = true
            vistaMapa.layer.borderColor = UIColor.red.cgColor
            vistaMapa.isUserInteractionEnabled = true
            tipo.isUserInteractionEnabled = true
            eliminar.isHidden = false
            texto.isEnabled = true
        }
    }
    @IBAction func changeIcon(_ sender: Any) {
        icono += 1
        if icono == 9
        {
            icono = 0
        }
        
        setIcon(icono: icono)
    }
    
    var icono:Int = 0
    var edicion = false
    var userD:UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        vistaMapa.layer.borderWidth = 4
        vistaMapa.layer.borderColor = UIColor.green.cgColor
        
        tipo.layer.borderWidth = 0
        tipo.layer.masksToBounds = false
        tipo.clipsToBounds = true
        
        setIcon(icono: icono)
        
        radio.isEnabled=false
        vistaMapa.isUserInteractionEnabled = false
        texto.isEnabled = false
        eliminar.isHidden = true
        tipo.isUserInteractionEnabled = false
        //Do any additional setup after loading the view.
    }
    
    func setIcon(icono: Int){
        switch icono {
        case 1:
            tipo.image = resizeImage(image: UIImage(named: "geoplace_school")!, newSize: CGSize(width: 35, height: 35))
        case 2:
            tipo.image = resizeImage(image: UIImage(named: "geoplace_work")!, newSize: CGSize(width: 35, height: 35))
        case 3:
            tipo.image = resizeImage(image: UIImage(named: "geoplace_house2")!, newSize: CGSize(width: 35, height: 35))
        case 4:
            tipo.image = resizeImage(image: UIImage(named: "geoplace_coffe")!, newSize: CGSize(width: 35, height: 35))
        case 5:
            tipo.image = resizeImage(image: UIImage(named: "geoplace_super")!, newSize: CGSize(width: 35, height: 35))
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
