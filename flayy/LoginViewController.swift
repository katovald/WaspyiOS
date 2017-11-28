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
    
    //variables necesarias
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var pausa: Bool = false
    var animated:Bool = false
    var areaCode = "+52"
    let userD:UserDefaults = UserDefaults.standard
    var ownerPhone:String!
    
    //acciones de los componentes
    
    @IBAction func loginAttemp(_ sender: Any) {
        
        self.ownerPhone = phoneAreaCode(phone: phone.text!, areacode: areaCode)
        
        if self.ownerPhone.count == 11 || self.ownerPhone.count == 13
        {
            firebaseManager.init().userExist(phone: self.ownerPhone, completion: { (exist) in
                if exist
                {
                    firebaseManager.init().getUserMail(phone: self.ownerPhone, completion: { (mail) in
                        let alertView = UIAlertController(title: "Inicio de sesion", message: "Introduce tu contraseña", preferredStyle: .alert)
                        let inicio = UIAlertAction(title: "Inicio", style: .default, handler: { (_) in
                            self.firebaseLogin(mail: mail, pass: alertView.textFields![0].text!)
                        })
                        let cancel = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
                        
                        alertView.addTextField(configurationHandler: { (textfield) in
                            textfield.placeholder = "Contraseña"
                            textfield.isSecureTextEntry = true
                        })
                        
                        alertView.addAction(inicio)
                        alertView.addAction(cancel)
                        
                        self.present(alertView, animated: true, completion: nil)
                    })
                }
                else{
                    let alertView = UIAlertController(title: "Registrate con nosotros", message: "Introduce tus datos", preferredStyle: .alert)
                    let registro = UIAlertAction(title: "Registro", style: .default, handler: { (_) in
                        if alertView.textFields![1].text == alertView.textFields![2].text!{
                            let correo = alertView.textFields![0].text!
                            let pass = alertView.textFields![1].text!
                            self.firebaseregister(mail: correo, pass: pass)
                        }
                        else{
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
            alert(message: "Numero Invalido")
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
        
    }
    
    @objc func termino(notification: Notification){
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero, completionHandler: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        player.play()
        pausa = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.pause()
        pausa = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func firebaseLogin(mail: String, pass: String) {
        Auth.auth().signIn(withEmail: mail, password: pass) { (user, e) in
            if (e != nil){
                self.alert(message: "Error: " + (e?.localizedDescription)!)
            }else{
                let correo = mail
                self.userD.set(self.ownerPhone, forKey: "OwnerPhone")
                self.userD.set(correo, forKey:"OwnerMail")
                firebaseManager.init().getOwnerData(phone: self.ownerPhone)
                self.performSegue(withIdentifier: "InicioApp", sender: self)
            }
        }
    }
    
    func firebaseregister(mail: String, pass: String){
        Auth.auth().createUser(withEmail: mail, password: pass) { (user, e) in
            if (e != nil){
                self.alert(message: "Error al crear el usuario: " + (e?.localizedDescription)!)
            }else{
                let correo = mail
                self.userD.set(self.ownerPhone, forKey: "OwnerPhone")
                self.userD.set(correo, forKey:"OwnerMail")
                self.performSegue(withIdentifier: "InicioApp", sender: self)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
        self.countryCode.isHidden = true
        self.flagCountry.isEnabled = true
        self.okSelected.isHidden = true
    }

}

extension UIViewController {
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}

