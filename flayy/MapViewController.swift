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
import FirebaseDynamicLinks
import BWWalkthrough
import GoogleMaps

protocol MenuActionDelegate {
    func openSegue(_ segueName: String, sender: AnyObject?)
    func trigger()
    func exitAuth()
    func shareAPP()
}

class MapViewController: UIViewController, CLLocationManagerDelegate, UIPopoverPresentationControllerDelegate, BWWalkthroughViewControllerDelegate {
    var phone: String!
    var userID: String!
    let userD = UserDefaults.standard
    let netReach = Reachability()
    
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
        NotificationCenter.default.post(notification: .fxCameraMap)
        fixed = true
    }
    
    @IBAction func dronInicio(_ sender: Any) {      //modo dron
        if alertas{
            animationHide()
            alertBtn = true
            memberList.isHidden = false
            flechaArriba.isHidden = false
            NotificationCenter.default.post(notification: .alert)
            dron.setImage(UIImage(named: "map.i3a.png"), for: .normal)
            center.setImage(UIImage(named:"map-focus.png"), for: .normal)
            showToast(message: "Saliendo de Modo Navegacion")
            plusBut.isHidden = true
            alertas = false
        }else{
            memberList.isHidden = true
            flechaArriba.isHidden = true
            NotificationCenter.default.post(notification: .alert)
            dron.setImage(UIImage(named: "map-a1shadowldpi.png"), for: .normal)
            center.setImage(UIImage(named:"gps-navi-arrow-512.png"), for: .normal)
            showToast(message: "Modo de navegacion activo")
            plusBut.isHidden = false
            alertas = true
        }
    }
    
    @IBAction func checkInGroup(_ sender: Any) {
        if (netReach?.isReachable)!{
            LocationServices.init().getAdress(location: CLLocationManager.init().location!, completion: { (address, e) in
                if e == nil {
                    let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "checkInBTN") as! CheckInViewController
                    vc.address = address!
                    vc.point = CLLocationManager.init().location!
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
    
    @objc func presentInvite(){
        NotificationCenter.default.post(notification: .groupsChanges)
        let storyBoard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "InviteView") as! InviteViewController
        vc.modalPresentationStyle = .popover
        if let popover = vc.popoverPresentationController {
            popover.sourceView = memberList
            popover.sourceRect = memberList.bounds
            vc.preferredContentSize = CGSize(width: 200, height: 160)
            popover.delegate = self
        }
        
        self.present(vc, animated: true, completion: nil)
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
        if let destinationViewController = segue.destination as? mainMenuViewController {
            destinationViewController.menuActionDelegate = self
        }
    }
    
    //Actions Alert BTNs
    //
    //
    @IBAction func alertaAgres(_ sender: Any) {
        userD.set(1, forKey: "AlertType")
        NotificationCenter.default.post(notification: .pushAlert)
    }
    
    @IBAction func alertaAco(_ sender: Any) {
        userD.set(2, forKey: "AlertType")
        NotificationCenter.default.post(notification: .pushAlert)
    }
    
    @IBAction func alertaAsal(_ sender: Any) {
        userD.set(3, forKey: "AlertType")
        NotificationCenter.default.post(notification: .pushAlert)
    }
    
    @IBAction func alertaMoto(_ sender: Any) {
        userD.set(4, forKey: "AlertType")
        NotificationCenter.default.post(notification: .pushAlert)
    }
    
    @IBAction func alertaRobo(_ sender: Any) {
        userD.set(5, forKey: "AlertType")
        NotificationCenter.default.post(notification: .pushAlert)
    }
    
    ////
    /////
    /////
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.add(observer: self, selector: #selector(changedGroup), notification: .groupsChanges)
        NotificationCenter.default.add(observer: self, selector: #selector(showWT), notification: .helpMe)
        NotificationCenter.default.add(observer: self, selector: #selector(presentInvite), notification: .groupCreated)
//        NotificationCenter.default.add(observer: self, selector: #selector(checkData), notification: .logIn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.plusBut.isHidden = true
        self.marker.isHidden = true
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
        
        self.phone = userD.string(forKey: "OwnerPhone")
        
        if userD.string(forKey: "OwnerName") != nil{
            firebaseManager.init().setUserRegToken()
            firebaseManager.init().getOwnerData(phone: self.phone)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if userD.string(forKey: "OwnerName") == nil{
            let story = UIStoryboard(name: "Main", bundle: nil)
            let set = story.instantiateViewController(withIdentifier: "datosUsuario")
            self.present(set, animated: true, completion: nil)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.remove(observer: self, notification: .groupsChanges)
        NotificationCenter.default.remove(observer: self, notification: .helpMe)
        NotificationCenter.default.remove(observer: self, notification: .groupCreated)
    }

    @objc func changedGroup(){
        self.titleBar.title = self.userD.string(forKey: "ActualGroupTitle")
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
        
        NotificationCenter.default.post(notification: .turnOnPush)
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
        
        NotificationCenter.default.post(notification: .turnOnPush)
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
        dismiss(animated: true, completion: {
            exit(0)
        })
    }
    
    func shareAPP(){
        dismiss(animated: false, completion: {
            //https://s2ek9.app.goo.gl/
            let domain = "s2ek9.app.goo.gl"
            let bundleID = "com.camsa.waspy"
            let minVersion = "1.0"
            guard let deepLink = URL(string: "https://waspy.com.mx/") else { return }
            
            let components = DynamicLinkComponents(link: deepLink, domain: domain)
            
            let androidPKG = "com.dev.camsa.waspy"
            
            let iOSParams = DynamicLinkIOSParameters(bundleID: bundleID)
            iOSParams.minimumAppVersion = minVersion
            iOSParams.appStoreID = "1291916724"
            components.iOSParameters = iOSParams
            
            let androidParams = DynamicLinkAndroidParameters(packageName: androidPKG)
            androidParams.minimumVersion = 1
            components.androidParameters = androidParams
            
            // Or create a shortened dynamic link
            components.shorten { (shortURL, warnings, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                // TODO: Handle shortURL.
                let textMSG = "Descarga Waspy y cuida de tus seres queridos\n"
                let textMSG1 = "\nWaspy v1.0 \nCAMSA development"
                let obj2Share = [textMSG, shortURL!, textMSG1] as [Any]
                let activity = UIActivityViewController(activityItems: obj2Share, applicationActivities: nil)
                activity.completionWithItemsHandler = { activity, success, items, error in
                }
                self.present(activity, animated: true, completion: nil)
            }
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

