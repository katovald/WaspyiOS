//
//  MapViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/4/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController, GMSMapViewDelegate, UITableViewDelegate {
    
    //La vista original (mapa y navvar) reciben eventos
    
    var vistaAciva = true
    var arrayMenuOptions = [Dictionary<String,String>]()
    let manipulador = imageMan()
    
    // los elementos usados
    @IBOutlet weak var center: UIButton!                //boton para centrar el mapa en tu posicion original
    @IBOutlet weak var dron: UIButton!                  //modalidad de dron
    @IBOutlet weak var grupo: UIButton!                 //muestra y oculta la colleccion
    @IBOutlet weak var reload: UIButton!                //muestra la pantalla y sus componentes en la version original
    @IBOutlet weak var menuOculto: UITableView!         //tabla menu
    @IBOutlet weak var menuNavBar: UIButton!            //boton que muestra y oculta el menu
    @IBOutlet weak var gmapView: UIView!                //muestra el mapa en el fondo de la vista
    @IBOutlet weak var gruposNavBar: UIBarButtonItem!   //muestra un popup con los grupos que tienes activos
    @IBOutlet weak var foto: UIImageView!
    @IBOutlet weak var rounded: UIImageView!
    @IBOutlet weak var nombre: UILabel!
    
    @IBAction func localiza(_ sender: Any) {        //envia coordenadas y las centra en el mapa
    }
    
    @IBAction func dronInicio(_ sender: Any) {      //modo dron
    }
    
    @IBAction func openGroups(_ sender: Any) {      //popup para elegir grupo

        let alertController = UIAlertController(title: nil, message: "Grupos", preferredStyle: .alert)
        
        let height:NSLayoutConstraint = NSLayoutConstraint(item: alertController.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.40)
        
        alertController.view.addConstraint(height)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
            // ...
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Grupo 1", style: .default) { action in
            // ...
        }
        alertController.addAction(OKAction)
        
        let destroyAction = UIAlertAction(title: "Grupo 2", style: .default) { action in
            print(action)
        }
        alertController.addAction(destroyAction)
        
        
        self.present(alertController, animated: true) {
            // ...
        }
        
    }
    
    @IBAction func openMenu(_ sender: Any) {        //muestra y oculta el menu
        if (vistaAciva){
            self.menuOculto.frame.origin = (CGPoint(x: 0, y: foto.frame.maxY))
            grupo.isEnabled = false
            foto.frame.origin = CGPoint(x: 0, y: foto.frame.origin.y)
            foto.image = manipulador.blurEffect(foto: UIImage(named: "foto")!)
            var roundPhoto = UIImageView()
            roundPhoto = manipulador.roundPict(image: manipulador.resizeImage(image: UIImage(named: "foto")!, newSize: CGSize(width: foto.frame.width/3, height: foto.frame.width/3)))
            roundPhoto.frame.origin = CGPoint(x: 20, y: 20)
            foto.addSubview(roundPhoto)
            foto.bringSubview(toFront: roundPhoto)
            gruposNavBar.isEnabled = false
            vistaAciva = false
            reload.isHidden = false
        }else{
            self.menuOculto.frame.origin = CGPoint(x: -menuOculto.frame.width, y: 0)
            foto.frame.origin = CGPoint(x: -self.foto.frame.width, y: foto.frame.origin.y)
            rounded.frame.origin = CGPoint(x: rounded.frame.origin.x - foto.frame.width, y: rounded.frame.origin.y)
            grupo.isEnabled = true
            gruposNavBar.isEnabled = true
            vistaAciva = true
            reload.isHidden = true
        }
    }
    
    //todos los botones se reestablecen
    
    @IBAction func origen(_ sender: Any) {
        self.menuOculto.frame.origin = CGPoint(x: -menuOculto.frame.width, y: 0)
        self.grupo.frame.origin = CGPoint(x: 0, y: view.frame.maxY - grupo.frame.height)
        grupo.isEnabled = true
        vistaAciva = true
        reload.isHidden = true
        menuNavBar.isEnabled=true
        dron.isEnabled = true
        center.isEnabled = true
        gruposNavBar.isEnabled = true
    }
    
    //Muestra la lista de usuarios en el grupo
    @IBAction func s(_ sender: Any) {
        if (vistaAciva){
            vistaAciva = false
            gruposNavBar.isEnabled = false
            reload.isHidden = false
            menuNavBar.isEnabled = false
        }else{
            self.grupo.frame.origin = CGPoint(x: 0, y: view.frame.maxY - grupo.frame.height)
            vistaAciva = true
            gruposNavBar.isEnabled = true
            reload.isHidden = true
            menuNavBar.isEnabled=true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

