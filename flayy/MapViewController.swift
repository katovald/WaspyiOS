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

protocol MenuActionDelegate {
    func openSegue(_ segueName: String, sender: AnyObject?)
    func reopenMenu()
    func exitAuth()
}

class MapViewController: UIViewController {
    var handle:AuthStateDidChangeListenerHandle?
    
    var ref: DatabaseReference!
    
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
        let userPhone = Auth.auth().currentUser?.providerData
        var username = ""
        self.ref = Database.database().reference()
        ref.child("accounts").child("+525530127033").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            username = value?["name"] as? String ?? ""
            self.title = username
        })
        
        
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

