//
//  userSettings.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/4/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import Photos
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import ALCameraViewController

class userSettings: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate{
    var phone:String!
    let userD:UserDefaults = UserDefaults.standard
    var edit = false
    var keyboardHigth:CGFloat = 0.0
    public let LogInNotification = NSNotification.Name("CorrectLogIn")
    public let HelpNotification = NSNotification.Name("HelpMe")
    let user = Auth.auth().currentUser!

    @IBOutlet weak var Salir: UIBarButtonItem!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var editaguarda: UIBarButtonItem!
    @IBOutlet weak var inicioCam: UIButton!
    @IBOutlet weak var userMail: UITextField!
    
    
    let workingView = UIActivityIndicatorView()
    let backView = UIView()
    
    @IBAction func guarda(_ sender: Any) {
        backView.frame = view.frame
        backView.frame.origin = view.frame.origin
        backView.backgroundColor = UIColor.gray.withAlphaComponent(0.9)
        workingView.activityIndicatorViewStyle = .whiteLarge
        workingView.hidesWhenStopped = true
        workingView.center = backView.center
        backView.addSubview(workingView)
        workingView.startAnimating()
        
        if edit {
            if (self.nameText.text == "" || self.userMail.text == "")
            {
                alert(message: "Necesitamos tus datos completos")
                return
            }
            else{
                self.view.addSubview(backView)
                firebaseManager.init().saveUserPhotoFB(photo: userPhoto.image!, phone: phone, completion:{
                    firebaseManager.init().setUserSetting(phone: self.phone,
                                                          name: self.nameText.text!,
                                                          mail: self.userMail.text!)
                    self.edit = false
                    self.editaguarda.tintColor = UIColor.yellow
                    self.editaguarda.title = "Editar"
                    self.workingView.stopAnimating()
                    self.backView.removeFromSuperview()
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }else{
            nameText.isEnabled = true
            userMail.isEnabled = true
            inicioCam.isEnabled = true
            editaguarda.tintColor = UIColor.init(hex: 0xEEC61B)
            editaguarda.title = "Guardar"
            edit = true
        }
    }
    
    @IBAction func Salir(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func help(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: self.HelpNotification, object: self)
        })
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status != .authorized {
            PHPhotoLibrary.requestAuthorization() {
                status in
            }
        }
    }
    
    override func viewDidLoad() {
        nameText.delegate = self
        userMail.delegate = self
        
        nameText.layer.cornerRadius = 4
        nameText.layer.borderColor = UIColor.white.cgColor
        nameText.layer.borderWidth = 1.0
        
        userMail.layer.cornerRadius = 4
        userMail.layer.borderWidth = 1.0
        userMail.layer.borderColor = UIColor.white.cgColor
        
        self.nameText.text = self.userD.string(forKey: "OwnerName") ?? ""
        self.phone = self.userD.string(forKey: "OwnerPhone")
        self.userMail.text = user.email ?? ""
        
        self.userPhoto.image = firebaseManager.init().getMemberPhoto(phone: self.phone)
        
        if (self.nameText.text == ""){
            self.Salir.isEnabled = false
            nameText.isEnabled = true
            userMail.isEnabled = true
            inicioCam.isEnabled = true
            editaguarda.tintColor = UIColor.red
            editaguarda.title = "Guardar"
            edit = true
        }else{
            nameText.isEnabled = false
            userMail.isEnabled = false
            inicioCam.isEnabled = false
        }
    }
    
    @IBAction func inicioCamView(_ sender: Any) {
        let param = CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: CGSize(width: 130, height: 130))
        let cameraViewController = CameraViewController.init(croppingParameters: param, allowsLibraryAccess: true, allowsSwapCameraOrientation: true, allowVolumeButtonCapture: true) { [weak self] image, asset in
            // Do something with your image here.
            if image != nil {
                self?.userPhoto.image = image
            }
            self?.dismiss(animated: true, completion: nil)
        }
        present(cameraViewController, animated: true, completion: nil)
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
    }
}
