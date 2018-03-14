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
    var newPhoto:Bool!
    var keyboardHigth:CGFloat = 0.0
    let user = Auth.auth().currentUser!
    let activityIndicator:UIActivityIndicatorView = UIActivityIndicatorView()

    @IBOutlet weak var Salir: UIBarButtonItem!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var editaguarda: UIBarButtonItem!
    @IBOutlet weak var inicioCam: UIButton!
    @IBOutlet weak var userMail: UITextField!
    
    @IBAction func guarda(_ sender: Any) {
        startLoading()
        if newPhoto {
            firebaseManager.init().saveUserPhotoFB(photo: userPhoto.image!, phone: phone) {
                firebaseManager.init().setUserSetting(name: self.nameText.text!)
                self.userD.set(self.nameText.text, forKey: "OwnerName")
                self.stopLoading()
                self.dismiss(animated: true, completion: nil)
            }
        }else{
            firebaseManager.init().setUserSetting(name: self.nameText.text!)
            self.userD.set(self.nameText.text, forKey: "OwnerName")
            self.stopLoading()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func Salir(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func help(_ sender: Any) {
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(notification: .helpMe)
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
        editaguarda.tintColor = UIColor.red
        editaguarda.title = "Guardar"
        
        if (self.nameText.text == "") {
            self.Salir.isEnabled = false
            nameText.isEnabled = true
            userMail.isEnabled = false
            inicioCam.isEnabled = true
        } else {
            nameText.isEnabled = true
            userMail.isEnabled = false
            inicioCam.isEnabled = true
        }
        newPhoto = false
    }
    
    @IBAction func inicioCamView(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let param = CroppingParameters(isEnabled: true, allowResizing: true, allowMoving: true, minimumSize: CGSize(width: 130, height: 130))
            let cameraViewController = CameraViewController.init(croppingParameters: param, allowsLibraryAccess: true, allowsSwapCameraOrientation: true, allowVolumeButtonCapture: true) { [weak self] image, asset in
                // Do something with your image here.
                if image != nil {
                    self?.userPhoto.image = image
                    firebaseManager.init().saveOwnerPhoto(photo: image!, phone: (self?.phone)!)
                    self?.newPhoto = true
                }
                self?.dismiss(animated: true, completion: nil)
            }
            present(cameraViewController, animated: true, completion: nil)
        }else{
            showToast(message: "No esta presente la camara")
        }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
    }
}
