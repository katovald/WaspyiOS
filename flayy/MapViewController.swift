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
import BWWalkthrough

protocol MenuActionDelegate {
    func openSegue(_ segueName: String, sender: AnyObject?)
    func trigger()
    func exitAuth()
}

class MapViewController: UIViewController, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate, BWWalkthroughViewControllerDelegate {
    var phone: String!
    var userID: String!
    let userD = UserDefaults.standard
    let netReach = Reachability()
    let notificationObserver = NotificationCenter.default
    public let CenterRequest = NSNotification.Name("FixCameraPush")
    public let AlertRequest = NSNotification.Name("Alerts")
    public let LogInNotification = NSNotification.Name("CorrectLogIn")
    public let PlaceAlertRequest = NSNotification.Name("PushAlert")
    public let LogOutConfirm = NSNotification.Name("LogOut")
    
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
    @IBOutlet weak var flechaArriba: UIImageView!
    //
    @IBOutlet weak var checkInBTN: UIBarButtonItem!
    
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
    @IBAction func openMembersTap(_ sender: Any) {
         performSegue(withIdentifier: "miembros", sender: nil)
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
            flechaArriba.isHidden = false
            notificationObserver.post(name: AlertRequest, object: self)
            dron.setImage(UIImage(named: "map.i3a.png"), for: .normal)
            plusBut.isHidden = true
            alertas = false
        }else{
            memberList.isHidden = true
            flechaArriba.isHidden = true
            notificationObserver.post(name: AlertRequest, object: self)
            dron.setImage(UIImage(named: "map-a1shadowldpi.png"), for: .normal)
            plusBut.isHidden = false
            alertas = true
        }
    }
    
    @IBAction func checkInGroup(_ sender: Any) {
        if (netReach?.isReachable)!{
            LocationServices.init().getAdress(completion: { (coordinate, speed, json, e) in
                if let a = json {
                    let kilo = a["FormattedAddressLines"] as! [String]
                    
                    var direccion = ""
                    
                    for index in 0...(kilo.count - 1)
                    {
                        direccion += kilo[index]
                        direccion += " "
                    }
                    
                    let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "checkInBTN") as! CheckInViewController
                    vc.address = direccion
                    let width = self.view.frame.width/4
                    vc.preferredContentSize = CGSize(width: 3 * width, height: 3 * width)
                    vc.modalPresentationStyle = .popover
                    let popover = vc.popoverPresentationController!
                    popover.delegate = self
                    popover.permittedArrowDirections = .up
                    popover.barButtonItem = self.checkInBTN
                    self.present(vc, animated: true, completion: nil)
                }
            })
        }else{
            showToast(message: "Necesitas estar conectado a internet")
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
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
        userD.set(true, forKey: "InstaledBefore")
        self.phone = userD.string(forKey: "OwnerPhone")
        print(self.phone)
        print(self.userD.string(forKey: "ActualGroup") ?? "")
        firebaseManager.init().userExist(phone: phone, completion: { (inSystem) in
                if inSystem
                {
                    firebaseManager.init().setUserRegToken()
                    if self.userD.string(forKey: "ActualGroup") == nil {
                        firebaseManager.init().getOwnerData(phone: self.phone)
                    }else{
                        self.notificationObserver.post(name: self.LogInNotification, object: self)
                        self.notificationObserver.post(name: NSNotification.Name("UserGroupsChanged"), object: self)
                    }
                }else{
                    self.performSegue(withIdentifier: "datosUsuario", sender: self)
                }
            })
        
        self.titleBar.title = userD.string(forKey: "ActualGroupTitle") ?? ""
        
        NotificationCenter.default.addObserver(self, selector: #selector(changedGroup), name: NSNotification.Name("UserGroupsChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeIcon), name: NSNotification.Name("LoseFocus"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showWT), name: NSNotification.Name("HelpMe"), object: nil)
    }

    @objc func changedGroup(){
        self.titleBar.title = self.userD.string(forKey: "ActualGroupTitle")
    }
    
    @objc func changeIcon(){

    }
    
    @objc func showWT() {
        let stb = UIStoryboard(name: "Main", bundle: nil)
        let walkthrough = stb.instantiateViewController(withIdentifier: "WTContainer") as! BWWalkthroughViewController
        let page_one = stb.instantiateViewController(withIdentifier: "WT1")
        let page_two = stb.instantiateViewController(withIdentifier: "WT2")
        let page_three = stb.instantiateViewController(withIdentifier: "WT3")
        let page_four = stb.instantiateViewController(withIdentifier: "WT4")
        
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.add(viewController: page_one)
        walkthrough.add(viewController: page_two)
        walkthrough.add(viewController: page_three)
        walkthrough.add(viewController: page_four)
        // Do any additional setup after loading the view.
        walkthrough.modalPresentationStyle = .overFullScreen
        walkthrough.modalTransitionStyle = .crossDissolve
        present(walkthrough, animated: false, completion: nil)
    }

    func walkthroughCloseButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func animationPresent(){
        self.agression.isHidden = false
        self.harassment.isHidden = false
        self.thief.isHidden = false
        self.biker.isHidden = false
        self.robbery.isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: {
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
            self.agressionlbl.isHidden = false
            self.harassmentlbl.isHidden = false
            self.thieflbl.isHidden = false
            self.bikerlbl.isHidden = false
            self.robberylbl.isHidden = false
            
            self.marker.isHidden = false
        })
    }
    
    func animationHide(){
        UIView.animate(withDuration: 0.3, animations: {
            self.agressionlbl.isHidden = true
            self.harassmentlbl.isHidden = true
            self.thieflbl.isHidden = true
            self.bikerlbl.isHidden = true
            self.robberylbl.isHidden = true
            
            self.agression.center = self.plusBut.center
            self.harassment.center = self.plusBut.center
            self.thief.center = self.plusBut.center
            self.biker.center = self.plusBut.center
            self.robbery.center = self.plusBut.center
            
            
            self.agressionlbl.frame.origin.y = self.plusBut.center.y
            self.harassmentlbl.frame.origin.y = self.plusBut.center.y
            self.thieflbl.frame.origin.y = self.plusBut.center.y
            self.bikerlbl.frame.origin.y = self.plusBut.center.y
            self.robberylbl.frame.origin.y = self.plusBut.center.y
        }) { (_) in
            self.agression.isHidden = true
            self.harassment.isHidden = true
            self.thief.isHidden = true
            self.biker.isHidden = true
            self.robbery.isHidden = true
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
        firebaseManager.init().clearUserDefaults()
        NotificationCenter.default.post(name: LogOutConfirm, object: self)
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

