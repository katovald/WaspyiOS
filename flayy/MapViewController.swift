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
import GeoFire

protocol MenuActionDelegate {
    func openSegue(_ segueName: String, sender: AnyObject?)
    func reopenMenu()
    func exitAuth()
}

class MapViewController: UIViewController, CLLocationManagerDelegate {
    var handle:AuthStateDidChangeListenerHandle?
    var ref: DatabaseReference!
    var phone: String!
    let userD = UserDefaults.standard
    let user = Auth.auth().currentUser
    let notificationObserver = NotificationCenter.default
    public let CenterRequest = NSNotification.Name("FixCameraPush")
    public let AlertRequest = NSNotification.Name("Alerts")
    public let LogInNotification = NSNotification.Name("CorrectLogIn")
    
    var alertas:Bool = false
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    @IBOutlet weak var memberList: UIButton!
    @IBOutlet weak var center: UIButton!                //boton para centrar el mapa en tu posicion original
    @IBOutlet weak var dron: Rounded!                  //modalidad de dron
    @IBOutlet weak var gmapView: UIView!                //muestra el mapa en el fondo de la vista
    @IBOutlet weak var titleBar: UINavigationItem!

    @IBOutlet weak var plusBut: Rounded!
    @IBAction func localiza(_ sender: Any) {        //envia coordenadas y las centra en el mapa
        notificationObserver.post(name: CenterRequest, object: self)
    }
    
    @IBAction func dronInicio(_ sender: Any) {      //modo dron
        if alertas{
            notificationObserver.post(name: AlertRequest, object: self)
            dron.normalBorderColor = UIColor.clear
            dron.borderWidth = 0
            plusBut.isHidden = true
            alertas = false
        }else{
            notificationObserver.post(name: AlertRequest, object: self)
            dron.normalBorderColor = UIColor.green
            dron.borderWidth = 3
            plusBut.isHidden = false
            alertas = true
        }
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
        
        plusBut.isHidden = true
        
        self.phone = (user?.phoneNumber)!
        
        firebaseManager.init().userExist(phone: phone, completion: { (inSystem) in
                if inSystem
                {
                    if self.userD.array(forKey: "MembersActiveGroup") == nil{
                        firebaseManager.init().getOwnerData(phone: self.phone)
                    }else{
                        self.notificationObserver.post(name: self.LogInNotification, object: self)
                    }
                }else{
                    self.performSegue(withIdentifier: "datosUsuario", sender: self)
                }
            })
        
//        if userD.string(forKey: "ActualGroupTitle") == nil
//        {
//            self.performSegue(withIdentifier: "datosUsuario", sender: nil)
//        }
//
//        if userD.array(forKey: "MembersActiveGroup") == nil{
//            var code = self.userD.string(forKey: "ActualGroup")
//            if code == nil {
//                let grupo = self.userD.dictionary(forKey: "OwnerGroups")?.first
//                code = grupo?.key
//            }else{
//                firebaseManager.init().getGroupMembersInfo(code: self.userD.string(forKey: "ActualGroup")!, completion: {(members) in
//                    self.userD.set(members, forKey: "MembersActiveGroup")
//                })
//            }
//        }
        
        self.titleBar.title = userD.string(forKey: "ActualGroupTitle")
        
        NotificationCenter.default.addObserver(self, selector: #selector(changedGroup), name: NSNotification.Name("UserGroupsChanged"), object: nil)
    }

    @objc func changedGroup(){
        self.titleBar.title = self.userD.string(forKey: "ActualGroupTitle")
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
        self.userD.set(nil, forKey: "OwnerPhone")
        
        dismiss(animated: true, completion: {
            exit(0)
        })
    }
}

