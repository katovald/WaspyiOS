//
//  ViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 6/30/17.
//  Copyright © 2017 Jose Katzuo Valdez Carmona. All rights reserved.
//

import UIKit
import FirebaseAuth
import AVFoundation
import CountryPicker
import LocalAuthentication

class LoginViewController: UIViewController, UITextFieldDelegate, AuthUIDelegate, CountryPickerDelegate {
    
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        areaCode = phoneCode
        areaInfo.text = phoneCode
        flagCountry.setImage(flag, for: .normal)
    }
    
    @IBAction func selectCountry(_ sender: Any) {
        self.countryCode.isHidden = false
        self.flagCountry.isEnabled = false
        self.okSelected.isHidden = false
    }
    @IBAction func selected(_ sender: Any) {
        self.countryCode.isHidden = true
        self.flagCountry.isEnabled = true
        self.okSelected.isHidden = true
    }
    
    //// nombres de los coponentes de la view (para animaciones)
    @IBOutlet weak var inicioSesion: UIButton!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var appMessages: UILabel!
    @IBOutlet weak var countryCode: CountryPicker!
    @IBOutlet weak var flagCountry: UIButton!
    @IBOutlet weak var areaInfo: UILabel!
    @IBOutlet weak var okSelected: UIButton!
    
    @IBOutlet weak var icono: UIImageView!
    
    var window: UIWindow?
    
    private var reahcNet:Reachability!
    
    //variables necesarias
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var pausa: Bool = false
    var animated:Bool = false
    var areaCode = "+52"
    let userD:UserDefaults = UserDefaults.standard
    var ownerPhone:String!
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()
    
    //acciones de los componentes
    
    @IBAction func loginAttemp(_ sender: Any) {
        if reahcNet.currentReachabilityStatus == .notReachable {
            alert(message: "Es posible que los servicios se encuentren fuera de linea o no cuentes con datos")
        }
        
        if (phone.text?.count == 10) {
            self.ownerPhone = phoneAreaCode(phone: phone.text!, areacode: areaCode)
            firebaseManager.init().userExist(phone: self.ownerPhone, completion: { (exist) in
                if exist
                {
                    firebaseManager.init().getUserMail(phone: self.ownerPhone, completion: { (mail) in
                        let alertView = UIAlertController(title: "Inicio de sesion", message: "Introduce tu contraseña", preferredStyle: .alert)
                        let inicio = UIAlertAction(title: "Inicio", style: .default, handler: { (_) in
                            self.startLoading()
                            let attempt = LogingAttemps(contra: alertView.textFields![0].text!, correo: mail, telefono: self.ownerPhone)
                            attempt.passwordAttempt(completion: { (success) in
                                if success {
                                    self.userD.set(self.ownerPhone, forKey: "OwnerPhone")
                                    self.userD.set(mail, forKey:"OwnerMail")
                                    firebaseManager.init().getOwnerData(phone: self.ownerPhone)
                                    self.stopLoading()
                                    self.performSegue(withIdentifier: "InicioApp", sender: self)
                                } else {
                                    self.stopLoading()
                                    self.alert(message: attempt.tell())
                                }
                            })
                            })
                        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
                        let restore = UIAlertAction(title: "Resetear", style: .default, handler: { (_) in
                            LogingAttemps.init().restore(mail: mail)
                        })
                        alertView.addTextField(configurationHandler: { (textfield) in
                            textfield.placeholder = "Contraseña"
                            textfield.isSecureTextEntry = true
                        })
                        
                        alertView.addAction(inicio)
                        alertView.addAction(restore)
                        alertView.addAction(cancel)
                        
                        self.present(alertView, animated: true, completion: nil)
                    })
                }
                else{
                    let alertView = UIAlertController(title: "Registrate con nosotros", message: "Introduce tus datos", preferredStyle: .alert)
                    let registro = UIAlertAction(title: "Registro", style: .default, handler: { (_) in
                        self.startLoading()
                        if alertView.textFields![1].text == alertView.textFields![2].text!{
                            let correo = alertView.textFields![0].text!
                            let pass = alertView.textFields![1].text!
                            let attempt = LogingAttemps(contra: pass, correo: correo, telefono: self.ownerPhone)
                            attempt.registerAttempt(completion: { (success) in
                                if success {
                                    self.stopLoading()
                                    self.userD.set(self.ownerPhone, forKey: "OwnerPhone")
                                    self.userD.set(correo, forKey: "OwnerMail")
                                    self.performSegue(withIdentifier: "InicioApp", sender: self)
                                }else{
                                    self.stopLoading()
                                    self.alert(message: attempt.tell())
                                }
                            })
                        }
                        else{
                            self.stopLoading()
                            self.alert(message: "Tus contraseñas no coinciden por favor vuelve a intentarlo.")
                        }
                    })
                    let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
                    
                    alertView.addTextField(configurationHandler: { (textfield) in
                        textfield.placeholder = "Correo"
                    })
                    alertView.addTextField(configurationHandler: { (textfield) in
                        textfield.placeholder = "Contraseña"
                        textfield.isSecureTextEntry = true
                    })
                    alertView.addTextField(configurationHandler: { (textfield) in
                        textfield.placeholder = "Repite tu Contraseña"
                        textfield.isSecureTextEntry = true
                    })
                    
                    alertView.addAction(registro)
                    alertView.addAction(cancel)
                    
                    self.present(alertView, animated: true, completion: nil)
                }
            })
        }else{
            self.alert(message: "Recuerda que tu telefono debe ser a 10 digitos")
        }
    }
    
    
    //Funciones de la view
    override func viewDidLoad() {
        super.viewDidLoad()
        let locale = Locale.current
        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String?
        countryCode.countryPickerDelegate = self
        countryCode.showPhoneNumbers = true
        countryCode.setCountry(code!)
        countryCode.isHidden = true
        self.okSelected.isHidden = true
        
        let url = Bundle.main.url(forResource: "video_login", withExtension: "mov")
        
        player = AVPlayer(url: url!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        player.volume = 0
        player.actionAtItemEnd = .none
        
        playerLayer.frame = view.layer.bounds
        view.backgroundColor = UIColor.clear
        view.layer.insertSublayer(playerLayer, at: 0)
        
        icono.loadGif(name: "eye.a")
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(termino(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)
        // Do any additional setup after loading the view, typically from a nib.
        
        let context = LAContext()
        var error:NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error){
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Podemos usar tu huella para el inicio", reply: { [unowned self] (success, error) in
                if success {
                    self.startLoading()
                    let atempt = LogingAttemps()
                    atempt.fingerPrintAttempt(completion: { (login) in
                        if login {
                            firebaseManager.init().getOwnerData(phone: self.userD.string(forKey: "OwnerPhone")!)
                            self.stopLoading()
                            self.performSegue(withIdentifier: "InicioApp", sender: self)
                        } else {
                            self.stopLoading()
                            self.alert(message: atempt.tell())
                        }
                    })
                }
            })
        }
    }
    
    @objc func termino(notification: Notification){
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero, completionHandler: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reahcNet = Reachability(hostname: "https://waspy.com.mx")
        super .viewWillAppear(animated)
        player.play()
        pausa = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        reahcNet.stopNotifier()
        super.viewWillAppear(animated)
        player.pause()
        pausa = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
        self.countryCode.isHidden = true
        self.flagCountry.isEnabled = true
        self.okSelected.isHidden = true
    }
    
    func startLoading(){
        DispatchQueue.main.async { // Correct
            self.activityIndicator.center = self.view.center
            self.activityIndicator.hidesWhenStopped = true
            self.activityIndicator.activityIndicatorViewStyle = .whiteLarge
            self.activityIndicator.backgroundColor = UIColor.blue
            self.view.addSubview(self.activityIndicator)
            
            self.activityIndicator.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    func stopLoading(){
        DispatchQueue.main.async { // Correct
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }

}

extension UIViewController {
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func alertTrouble(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

