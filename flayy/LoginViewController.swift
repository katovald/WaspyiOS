//
//  ViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 6/30/17.
//  Copyright © 2017 Jose Katzuo Valdez Carmona. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var sendCode: UIButton!
    @IBOutlet weak var Code: UITextField!

    @IBOutlet weak var getCode: UIButton!
    @IBOutlet weak var Telefono: UITextField!
    
    @IBOutlet weak var resendBtn: UIButton!
    
    var verID = ""
    
    @IBAction func Clicked(_ sender: Any) {
        PhoneAuthProvider.provider().verifyPhoneNumber("+52"+Telefono.text!, completion: { (verificationID, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            if (verificationID == ""){
                return
            }else{
                self.verID = verificationID!
            }
            
            self.sendCode.isHidden = false
            self.Code.isHidden = false
            self.resendBtn.isHidden = false
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Code.isHidden = true
        sendCode.isHidden = true
        resendBtn.isHidden = true
        self.Telefono.delegate = self
        self.Code.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
        
    }
        
    @IBAction func resendCode(_ sender: UIButton) {
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
                    self.performSegue(withIdentifier: "datosListos", sender: nil)
                        // [END_EXCLUDE]
                    }
                }
                // [END signin_credential]
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
    }

}

