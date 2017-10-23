//
//  MapViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/4/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import CoreLocation
import GeoFire
import FirebaseMessaging
import FirebaseAuth

protocol MenuActionDelegate {
    func openSegue(_ segueName: String, sender: AnyObject?)
    func exitAuth()
}

class MapViewController: UIViewController, CLLocationManagerDelegate {
    var phone: String!
    let userD = UserDefaults.standard
    let user = Auth.auth().currentUser
    let notificationObserver = NotificationCenter.default
    public let CenterRequest = NSNotification.Name("FixCameraPush")
    public let AlertRequest = NSNotification.Name("Alerts")
    public let LogInNotification = NSNotification.Name("CorrectLogIn")
    
    var alertas:Bool = false
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var fixed = true
    
    @IBOutlet weak var memberList: UIButton!
    @IBOutlet weak var center: UIButton!                //boton para centrar el mapa en tu posicion original
    @IBOutlet weak var dron: Rounded!                  //modalidad de dron
    @IBOutlet weak var gmapView: UIView!                //muestra el mapa en el fondo de la vista
    @IBOutlet weak var titleBar: UINavigationItem!

    @IBOutlet weak var plusBut: Rounded!
    @IBAction func localiza(_ sender: Any) {        //envia coordenadas y las centra en el mapa
        notificationObserver.post(name: CenterRequest, object: self)
        fixed = true
        changeIcon()
    }
    
    @IBAction func dronInicio(_ sender: Any) {      //modo dron
        if alertas{
            memberList.isHidden = false
            notificationObserver.post(name: AlertRequest, object: self)
            dron.normalBorderColor = UIColor.clear
            dron.borderWidth = 0
            plusBut.isHidden = true
            alertas = false
        }else{
            memberList.isHidden = true
            notificationObserver.post(name: AlertRequest, object: self)
            dron.normalBorderColor = UIColor.green
            dron.borderWidth = 3
            plusBut.isHidden = false
            alertas = true
        }
    }
    
    @IBAction func checkInGroup(_ sender: Any) {
        LocationServices.init().getAdress(completion: { (coordinate, speed, json, e) in
            if let a = json {
                let kilo = a["FormattedAddressLines"] as! [String]
                
                var direccion = ""
                
                for index in 0...(kilo.count - 1)
                {
                    direccion += kilo[index]
                    direccion += " "
                }
                
                FCmNotifications.init().chechIn(address: direccion)
            } 
        })
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
        firebaseManager.init().setUserRegToken(phone: self.phone)
        firebaseManager.init().userExist(phone: phone, completion: { (inSystem) in
                if inSystem
                {
                    self.userD.set(self.phone, forKey: "OwnerPhone")
                    if self.userD.array(forKey: "MembersActiveGroup") == nil{
                        firebaseManager.init().getOwnerData(phone: self.phone)
                    }else{
                        self.notificationObserver.post(name: self.LogInNotification, object: self)
                    }
                }else{
                    self.performSegue(withIdentifier: "datosUsuario", sender: self)
                }
            })
        
        self.titleBar.title = userD.string(forKey: "ActualGroupTitle")
        
        NotificationCenter.default.addObserver(self, selector: #selector(changedGroup), name: NSNotification.Name("UserGroupsChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeIcon), name: NSNotification.Name("LoseFocus"), object: nil)
    }

    @objc func changedGroup(){
        self.titleBar.title = self.userD.string(forKey: "ActualGroupTitle")
    }
    
    @objc func changeIcon(){
        if fixed {
            center.setImage(UIImage(named: "d41abb1b.png"), for: .normal)
        }else{
            center.setImage(UIImage(named: "map.i4a.png"), for: .normal)
        }
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension MapViewController: MenuActionDelegate {
    func openSegue(_ segueName: String, sender: AnyObject?) {
        dismiss(animated: false, completion: {
            self.performSegue(withIdentifier: segueName, sender: sender)
        })
    }
    
    func exitAuth(){
        self.userD.set(nil, forKey: "OwnerPhone")
        dismiss(animated: true, completion: {
            exit(0)
        })
    }
}

extension UIColor {
    // Usage: UIColor(hex: 0xFC0ACE)
    convenience init(hex: Int) {
        self.init(hex: hex, alpha: 1)
    }
    
    // Usage: UIColor(hex: 0xFC0ACE, alpha: 0.25)
    convenience init(hex: Int, alpha: Double) {
        self.init(
            red: CGFloat((hex >> 16) & 0xff) / 255,
            green: CGFloat((hex >> 8) & 0xff) / 255,
            blue: CGFloat(hex & 0xff) / 255,
            alpha: CGFloat(alpha))
    }
}

