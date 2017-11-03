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

class LoginViewController: UIViewController, UITextFieldDelegate, AuthUIDelegate{
    
    //// nombres de los coponentes de la view (para animaciones)
    @IBOutlet weak var sendCode: UIButton!
    @IBOutlet weak var Code: UITextField!
    @IBOutlet weak var getCode: UIButton!
    @IBOutlet weak var Telefono: UITextField!
    
    @IBOutlet weak var banderaArea: UIImageView!
    
    @IBAction func changeArea(_ sender: Any) {
        if areaCode == "+52"{
            areaCode = "+1"
            banderaArea.image = UIImage(named: "flag_usa.png")
        }else{
            areaCode = "+52"
            banderaArea.image = UIImage(named: "flag_mexico.png")
        }
    }
    
    //variables necesarias
    var activeField:UITextField? = nil
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var pausa: Bool = false
    var verID = ""
    var tel = ""
    var animated:Bool = false
    let userInfo:UserDefaults = UserDefaults.standard
    var keyboardHigth:CGFloat = 0.0
    var areaCode = "+52"
    let notifications:NotificationCenter = NotificationCenter.default
    
    //acciones de los componentes
    @IBAction func Clicked(_ sender: Any) {
        tel = areaCode + Telefono.text!
        PhoneAuthProvider.provider().verifyPhoneNumber(tel,
                                                       uiDelegate: nil,
                                                       completion: { (verificationID, error) in
                                                        if let error = error {
                                                            self.alert(message: "Ocurrio un error:" + error.localizedDescription)
                                                            return
                                                        }
            
                                                        if (verificationID != "" && !self.animated){
                                                            self.alert(message: "En un mometo recibiras un SMS con un token, introducelo")
                                                            self.verID = verificationID!
                                                            self.sendCode.isHidden = false
                                                            self.Code.isHidden = false
                                                            self.Telefono.isEnabled = false
                                                            self.getCode.isHidden = true
            }else{
                return
            }
        })
    }
    
    @IBAction func checkCode(_ sender: Any) {
        if (Code.text == "")
        {
            return
        }else
        {
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verID, verificationCode: Code.text!)
            firebaseLogin(credential)
        }
    }
    
    //Funciones de la view
    override func viewDidLoad() {
        super.viewDidLoad()
        self.Code.isHidden = true
        self.sendCode.isHidden = true
        self.Telefono.delegate = self
        self.Code.delegate = self
        
        Telefono.layer.cornerRadius = 4
        Telefono.layer.borderColor = UIColor.white.cgColor
        Telefono.layer.borderWidth = 1.0
        
        Code.layer.cornerRadius = 4
        Code.layer.borderColor = UIColor.white.cgColor
        Code.layer.borderWidth = 1.0
        
        self.Telefono.keyboardType = .phonePad
        self.Code.keyboardType = .numberPad
        
        self.Telefono.layer.cornerRadius = 4
        self.Telefono.layer.borderColor = UIColor.white.cgColor
        
        let url = Bundle.main.url(forResource: "prueba12", withExtension: "mp4")
        
        player = AVPlayer(url: url!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        player.volume = 0
        player.actionAtItemEnd = .none
        
        playerLayer.frame = view.layer.bounds
        view.backgroundColor = UIColor.clear
        view.layer.insertSublayer(playerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(termino(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem)

        
        registerForKeyboardNotifications()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
    }
    
    @objc func termino(notification: Notification){
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero, completionHandler: nil)
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillBeHidden(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        var info = notification.userInfo!
        if keyboardHigth == 0.0 {
            let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
            keyboardHigth = keyboardSize!.height
        }
        self.activeField?.frame.origin.y -= keyboardHigth
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        self.activeField?.frame.origin.y += keyboardHigth
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
    
    func firebaseLogin(_ credential: AuthCredential) {
            if let user = Auth.auth().currentUser {
                // [START link_credential]
                user.link(with: credential) { (user, error) in
                    // [START_EXCLUDE]
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                    // [END_EXCLUDE]
                }
                // [END link_credential]
            } else {
                // [START signin_credential]
                Auth.auth().signIn(with: credential) { (user, error) in
                        if let error = error as NSError? {
                            // [START_EXCLUDE]
                            guard let code = AuthErrorCode(rawValue: error.code)
                                else {
                                    return
                            }
                            switch code{
                            case .invalidVerificationCode:
                                self.alert(message: "El codigo es invalido, por favor revisalo e intenta de nuevo" , title: "Ups...")
                            default:
                                self.alert(message: "Algo salio mal", title: "Ups...")
                            }
                            //print(error.localizedDescription)
                            // [END_EXCLUDE]
                            return
                        }
                        // User is signed in
                        // [START_EXCLUDE]
                        // Merge prevUser and currentUser accounts and data
                        // ...
                    self.performSegue(withIdentifier: "InicioApp", sender: nil)
                        // [END_EXCLUDE]
                    }
                }
                // [END signin_credential]
        
    }

    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
    }

}

