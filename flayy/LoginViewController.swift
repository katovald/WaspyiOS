//
//  ViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 6/30/17.
//  Copyright © 2017 Jose Katzuo Valdez Carmona. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class LoginViewController: UIViewController, UITextFieldDelegate{
    
    //// nombres de los coponentes de la view (para animaciones)
    @IBOutlet weak var sendCode: UIButton!
    @IBOutlet weak var Code: UITextField!
    @IBOutlet weak var getCode: UIButton!
    @IBOutlet weak var Telefono: UITextField!
    @IBOutlet weak var resendBtn: UIButton!
    
    //variables necesarias
    var activeField:UITextField? = nil
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var pausa: Bool = false
    let ref = Database.database().reference()
    var verID = ""
    var tel = ""
    
    //acciones de los componentes
    @IBAction func Clicked(_ sender: Any) {
        tel = "+52" + Telefono.text!
        PhoneAuthProvider.provider().verifyPhoneNumber(tel, completion: { (verificationID, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if (verificationID == ""){
                return
            }else{
                self.verID = verificationID!
                self.getCode.isHidden = true
                self.sendCode.isHidden = false
                self.resendBtn.isHidden = false
                self.Code.isHidden = false
                self.Telefono.isEnabled = false
                UIView.animate(withDuration: 1, animations: {
                    self.Telefono.frame.origin.y -= 50
                    self.Code.frame.origin.y += 50
                })
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
        self.resendBtn.isHidden = true
        self.sendCode.isHidden = true
        self.Telefono.delegate = self
        self.Code.delegate = self
        self.Telefono.keyboardType = .phonePad
        self.Telefono.setBottomBorder(color: .black)
        self.Code.keyboardType = .numberPad
        self.Code.setBottomBorder(color: .black)
        
        let url = Bundle.main.url(forResource: "prueba12", withExtension: "mp4")
        
        player = AVPlayer(url: url!)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
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
    
    func termino(notification: Notification){
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        self.activeField?.frame.origin.y -= keyboardSize!.height
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        self.activeField?.frame.origin.y += keyboardSize!.height
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
                    // [START_EXCLUDE silent]
                        // [END_EXCLUDE]
                        if let error = error {
                            // [START_EXCLUDE]
                            print(error.localizedDescription)
                            // [END_EXCLUDE]
                            return
                        }
                        // User is signed in
                        // [START_EXCLUDE]
                        // Merge prevUser and currentUser accounts and data
                        // ...
                    UserDefaults.standard.set(user, forKey: "authVerificationID")
                    self.ref.child("accounts").child(self.tel).observeSingleEvent(of: .value, with: { (snapshot) in
                        // Get user value
                        let value = snapshot.value as? NSDictionary
                        let username = value?["name"] as? String ?? ""
                        
                        if (username == "")
                        {
                            self.performSegue(withIdentifier: "faltanDatos", sender: nil)
                        }
                        else{
                            self.performSegue(withIdentifier: "datosListos", sender: nil)
                        }
                        
                        // ...
                    }) { (error) in
                        print(error.localizedDescription)
                    }
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
