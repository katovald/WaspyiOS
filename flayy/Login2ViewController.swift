//
//  Login2ViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 8/23/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseAuth

class Login2ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var regiterBtn: Rounded!
    @IBOutlet weak var loginBtn: Rounded!
    @IBOutlet weak var challengeField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var helpBtn: UIButton!
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var pausa: Bool = false
    var animated:Bool = false
    var activeField:UITextField? = nil
    var registrando:Bool = false
    var ayuda:Bool = false
    
    @IBAction func login(_ sender: Any) {
        if(registrando)
        {
            Auth.auth().signIn(withEmail: self.mailField.text!, password: self.passField.text!) { (user, error) in
                if (error != nil)
                {
                    print(error?.localizedDescription ?? "")
                    return
                }
                
                print(user ?? "")
            }

        }else{
            Auth.auth().createUser(withEmail: self.mailField.text!, password: self.passField.text!) { (user, error) in
                if (error != nil)
                {
                    print(error?.localizedDescription ?? "")
                    return
                }
            }
        }

    }
    
    
    @IBAction func registro(_ sender: Any) {
        if(ayuda)
        {
            Auth.auth().sendPasswordReset(withEmail: self.mailField.text!){ (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }else{
                    self.alert(message: "Enviado")
                }
            }
        }else{
            animation()
        }
    }
    
    
    @IBAction func help(_ sender: Any) {
        self.alert(message: "Escribe tu correo y presiona Enviar")
        helpAnimation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.passField.delegate = self
        self.mailField.delegate = self
        self.challengeField.delegate = self
        self.challengeField.isHidden = true
        
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

        // Do any additional setup after loading the view.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
    }
    
    func animation()
    {
        self.loginBtn.setTitle("Listo", for: .normal)
        self.registrando = true
        self.challengeField.isHidden = false
        UIView.animate(withDuration: 1, animations: {
            self.regiterBtn.isHidden = true
            self.loginBtn.center.x = self.view.center.x
        })
    }
    
    func helpAnimation()
    {
        self.regiterBtn.setTitle("Enviar", for: .normal)
        self.ayuda = true
        self.passField.isHidden = true
        UIView.animate(withDuration: 1, animations: {
            self.loginBtn.isHidden = true
            self.regiterBtn.center.x = self.view.center.x
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.play()
        pausa=false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        player.pause()
        pausa=true
    }
    @objc func termino(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero, completionHandler: nil)
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
    
    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        self.activeField?.frame.origin.y -= keyboardSize!.height
        self.activeField?.frame.size.height = (self.activeField?.frame.size.height)! * 1.3
        self.activeField?.frame.size.width = (self.activeField?.frame.width)! * 1.3
        self.activeField?.frame.origin.x = (self.activeField?.frame.origin.x)! * 0.6
        self.activeField?.backgroundColor = .white
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        self.activeField?.frame.origin.y += keyboardSize!.height
        self.activeField?.frame.size.height = (self.activeField?.frame.size.height)! / 1.3
        self.activeField?.frame.size.width = (self.activeField?.frame.width)! / 1.3
        self.activeField?.frame.origin.x = (self.activeField?.frame.origin.x)! / 0.6
        self.activeField?.backgroundColor = .clear
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

extension UIViewController {
    func alert(message: String, title: String = "") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
