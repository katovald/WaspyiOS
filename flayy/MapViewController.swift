//
//  MapViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/4/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

protocol MenuActionDelegate {
    func openSegue(_ segueName: String, sender: AnyObject?)
    func reopenMenu()
    func exitAuth()
}

class MapViewController: UIViewController, CLLocationManagerDelegate {
    var handle:AuthStateDidChangeListenerHandle?
    var ref: DatabaseReference!
    var phone: String!
    let change = UserDefaults.standard
    let user = Auth.auth().currentUser
    
    @IBOutlet weak var memberList: UIButton!
    @IBOutlet weak var center: UIButton!                //boton para centrar el mapa en tu posicion original
    @IBOutlet weak var dron: UIButton!                  //modalidad de dron
    @IBOutlet weak var gmapView: UIView!                //muestra el mapa en el fondo de la vista
    
    @IBAction func localiza(_ sender: Any) {        //envia coordenadas y las centra en el mapa
        
    }
    
    @IBAction func dronInicio(_ sender: Any) {      //modo dron
    }
    
    @IBAction func openGroups(_ sender: Any) {      //popup para elegir grupo
        performSegue(withIdentifier: "grupos", sender: nil)
    }
    
    @IBAction func members(_ sender: Any) {
        performSegue(withIdentifier: "miembros", sender: nil)
    }
    
    @IBAction func openMenu(_ sender: Any) {        //muestra y oculta el menu
        performSegue(withIdentifier: "menu", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? menuDesignViewController {
            destinationViewController.menuActionDelegate = self
        }
        if let destinationViewController = segue.destination as? gruposSelectViewController {
            destinationViewController.menuActionDelegate = self
        }
        if let destinationViewController = segue.destination as? membersSelectViewController {
            destinationViewController.menuActionDelegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.phone = (user?.phoneNumber)!
        if(self.change.string(forKey: "name") != "")
        {
            self.ref = Database.database().reference()
            ref.child("accounts").child(self.phone).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                let username = value?["name"] as? String ?? ""
                let mail = value?["mail"] as? String ?? ""
            
                if (username != "")
                {
                    self.title = username
                    self.change.set(self.phone, forKey: "Phone")
                    self.change.set(username, forKey: "Name")
                    self.change.set(mail, forKey: "Mail")
                }else{
                    self.change.set(self.phone, forKey: "Phone")
                    self.performSegue(withIdentifier: "datosUsuario", sender: nil)
                
                }
            }){ (error) in
            print(error.localizedDescription)
        }
    }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MapViewController: MenuActionDelegate {
    func openSegue(_ segueName: String, sender: AnyObject?) {
        dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: segueName, sender: sender)
        })
    }
    
    func reopenMenu() {
        performSegue(withIdentifier: "menu", sender: nil)
    }
    
    func exitAuth(){
        dismiss(animated: true, completion: {
            exit(0)
        })
    }
}

