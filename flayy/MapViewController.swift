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
    func trigger()
    func exitAuth()
}

class MapViewController: UIViewController, CLLocationManagerDelegate {
    var phone: String!
    var userID: String!
    let userD = UserDefaults.standard
    let user = Auth.auth().currentUser
    let notificationObserver = NotificationCenter.default
    public let CenterRequest = NSNotification.Name("FixCameraPush")
    public let AlertRequest = NSNotification.Name("Alerts")
    public let LogInNotification = NSNotification.Name("CorrectLogIn")
    public let PlaceAlertRequest = NSNotification.Name("PushAlert")
    
    var alertas:Bool = false
    var alertBtn:Bool = true
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var fixed = true
    
    @IBOutlet weak var memberList: UIButton!
    @IBOutlet weak var center: UIButton!                //boton para centrar el mapa en tu posicion original
    @IBOutlet weak var dron: Rounded!                  //modalidad de dron
    @IBOutlet weak var gmapView: UIView!                //muestra el mapa en el fondo de la vista
    @IBOutlet weak var titleBar: UINavigationItem!
    @IBOutlet weak var marker: UIImageView!
    
    //Alerts Menu Items
    //For animations
    //
    @IBOutlet weak var agression: Rounded!
    @IBOutlet weak var agressionlbl: UILabel!
    @IBOutlet weak var harassment: Rounded!
    @IBOutlet weak var harassmentlbl: UILabel!
    @IBOutlet weak var thief: UIButton!
    @IBOutlet weak var thieflbl: UILabel!
    @IBOutlet weak var biker: UIButton!
    @IBOutlet weak var bikerlbl: UILabel!
    @IBOutlet weak var robbery: Rounded!
    @IBOutlet weak var robberylbl: UILabel!
    //
    //
    
    @IBOutlet weak var plusBut: Rounded!
    @IBAction func alerts(_ sender: Any) {
        if alertBtn
        {
            animationPresent()
            alertBtn = false
        }else{
            animationHide()
            alertBtn = true
        }
        
    }
    
    @IBAction func localiza(_ sender: Any) {        //envia coordenadas y las centra en el mapa
        notificationObserver.post(name: CenterRequest, object: self)
        fixed = true
        changeIcon()
    }
    
    @IBAction func dronInicio(_ sender: Any) {      //modo dron
        if alertas{
            animationHide()
            alertBtn = true
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
    
    //Actions Alert BTNs
    //
    //
    @IBAction func alertaAgres(_ sender: Any) {
        userD.set(1, forKey: "AlertType")
        notificationObserver.post(name: PlaceAlertRequest, object: self)
    }
    
    @IBAction func alertaAco(_ sender: Any) {
        userD.set(2, forKey: "AlertType")
        notificationObserver.post(name: PlaceAlertRequest, object: self)
    }
    
    @IBAction func alertaAsal(_ sender: Any) {
        userD.set(3, forKey: "AlertType")
        notificationObserver.post(name: PlaceAlertRequest, object: self)
    }
    
    @IBAction func alertaMoto(_ sender: Any) {
        userD.set(4, forKey: "AlertType")
        notificationObserver.post(name: PlaceAlertRequest, object: self)
    }
    
    @IBAction func alertaRobo(_ sender: Any) {
        userD.set(5, forKey: "AlertType")
        notificationObserver.post(name: PlaceAlertRequest, object: self)
    }
    
    ////
    /////
    /////
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        plusBut.isHidden = true
        self.agression.isHidden = true    //// type 1
        self.agressionlbl.isHidden = true
        self.harassment.isHidden = true  //// type 2
        self.harassmentlbl.isHidden = true
        self.thief.isHidden = true      ///type 3
        self.thieflbl.isHidden = true
        self.biker.isHidden = true      ///// type 4
        self.bikerlbl.isHidden = true
        self.robbery.isHidden = true    ////type 5
        self.robberylbl.isHidden = true
        animationHide()
        self.phone = ""
        self.userID = user?.uid ?? ""
        if self.userID != ""{
            self.userD.set(self.userID, forKey: "OwnerUserID")
        }
        
        if self.phone == "" && self.userID != ""{
            self.userD.set(user?.email, forKey: "OwnerMail")
            firebaseManager.init().useriOSExist(userID: self.userID, completion: { (inSystem, phone) in
                if inSystem
                {
                    firebaseManager.init().setUserRegToken(phone: self.phone)
                    if self.userD.array(forKey: "MembersActiveGroup") == nil{
                        firebaseManager.init().getOwnerData(phone: phone)
                    }else{
                        self.notificationObserver.post(name: self.LogInNotification, object: self)
                    }
                }else{
                    self.performSegue(withIdentifier: "datosUsuario2", sender: self)
                }
            })
        }else if phone != nil{
            firebaseManager.init().setUserRegToken(phone: self.phone)
            firebaseManager.init().userExist(phone: phone, completion: { (inSystem) in
                if inSystem
                {
                    if self.userD.array(forKey: "MembersActiveGroup") == nil{
                        firebaseManager.init().getOwnerData(phone: self.phone)
                    }else{
                        self.notificationObserver.post(name: self.LogInNotification, object: self)
                    }
                }else{
                    self.performSegue(withIdentifier: "datosUsuario2", sender: self)
                }
            })
            
            self.titleBar.title = userD.string(forKey: "ActualGroupTitle")
        }
        
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
    
    func animationPresent(){
        self.agression.isHidden = false
        self.agressionlbl.isHidden = false
        self.harassment.isHidden = false
        self.harassmentlbl.isHidden = false
        self.thief.isHidden = false
        self.thieflbl.isHidden = false
        self.biker.isHidden = false
        self.bikerlbl.isHidden = false
        self.robbery.isHidden = false
        self.robberylbl.isHidden = false
        
        UIView.animate(withDuration: 0.5, animations: {
            self.robbery.center.x = self.plusBut.center.x
            self.robbery.center.y = self.plusBut.center.y - 60
            self.robberylbl.center.y = self.robbery.center.y
            
            self.biker.center.x = self.plusBut.center.x
            self.biker.center.y = self.plusBut.center.y - 120
            self.bikerlbl.center.y = self.biker.center.y
            
            self.thief.center.x = self.plusBut.center.x
            self.thief.center.y = self.plusBut.center.y - 180
            self.thieflbl.center.y = self.thief.center.y
            
            self.harassment.center.x = self.plusBut.center.x
            self.harassment.center.y = self.plusBut.center.y - 240
            self.harassmentlbl.center.y = self.harassment.center.y
            
            self.agression.center.x = self.plusBut.center.x
            self.agression.center.y = self.plusBut.center.y - 300
            self.agressionlbl.center.y = self.agression.center.y
        }, completion: {(_) in
            self.marker.isHidden = false
        })
    }
    
    func animationHide(){
        UIView.animate(withDuration: 0.5, animations: {
            self.agression.center = self.plusBut.center
            self.agressionlbl.frame.origin.y = self.plusBut.center.y
            self.harassment.center = self.plusBut.center
            self.harassmentlbl.frame.origin.y = self.plusBut.center.y
            self.thief.center = self.plusBut.center
            self.thieflbl.frame.origin.y = self.plusBut.center.y
            self.biker.center = self.plusBut.center
            self.bikerlbl.frame.origin.y = self.plusBut.center.y
            self.robbery.center = self.plusBut.center
            self.robberylbl.frame.origin.y = self.plusBut.center.y
        }) { (_) in
            self.agression.isHidden = true
            self.agressionlbl.isHidden = true
            self.harassment.isHidden = true
            self.harassmentlbl.isHidden = true
            self.thief.isHidden = true
            self.thieflbl.isHidden = true
            self.biker.isHidden = true
            self.bikerlbl.isHidden = true
            self.robbery.isHidden = true
            self.robberylbl.isHidden = true
            self.marker.isHidden = true
        }
    }

}

extension MapViewController: MenuActionDelegate {
    func openSegue(_ segueName: String, sender: AnyObject?) {
        dismiss(animated: false, completion: {
            self.performSegue(withIdentifier: segueName, sender: sender)
        })
    }
    
    func trigger() {
        dismiss(animated: false, completion: {
            self.dronInicio(self)
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

