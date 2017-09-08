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

class userSettings: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    let modelManager = firebaseManager()
    var phone:String!
    let userD = UserDefaults.standard
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var phoneText: UITextField!
    @IBOutlet weak var Salir: UIBarButtonItem!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var editaguarda: UIBarButtonItem!
    @IBOutlet weak var inicioCam: UIButton!
    @IBOutlet weak var galeria: UIButton!
    @IBOutlet weak var userMail: UITextField!
    @IBOutlet weak var exit: UIBarButtonItem!
    
    @IBAction func guarda(_ sender: Any) {
        if (self.nameText.text == "" || self.userMail.text == "")
        {
            self.alert(message: "Por favor llena los datos necesarios")
            return
        }
        else{
            modelManager.setUserSetting(phone: self.phone, name: self.nameText.text!, mail: self.userMail.text!)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Salir(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
        
        imagePicker.delegate = self
        self.nameText.text = self.userD.string(forKey: "Name") ?? ""
        self.phone = self.userD.string(forKey: "Phone")
        self.userMail.text = self.userD.string(forKey: "Mail") ?? ""
        
        self.userPhoto.image = modelManager.getMemberPhoto(phone: self.phone)
        
        if (self.nameText.text == ""){
            self.Salir.isEnabled = false
        }
    }
    
    @IBAction func inicioGaleria(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true,completion: nil)
        }
    }
    
    @IBAction func inicioCamView(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.rear
            imagePicker.cameraCaptureMode = .photo
            self.present(imagePicker, animated: true,completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        self.dismiss(animated: true, completion: nil)
        
        if mediaType.isEqual(to: kUTTypeImage as String) {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            if(image.size.width > image.size.height){
                let imagenRec:UIImage =  cropToBounds(image: image, width: Double(image.size.width), height: Double(image.size.width))
                self.userPhoto.image = resizeImage(image: imagenRec, newSize: CGSize(width: 130, height: 130))
                self.modelManager.setUserPhoto(photo: self.userPhoto.image!, phone: self.phone)
            }
            if(image.size.width < image.size.height){
                let imagenRec:UIImage =  cropToBounds(image: image, width: Double(image.size.height), height: Double(image.size.height))
                self.userPhoto.image =  imageRotatedByDegrees(oldImage: resizeImage(image: imagenRec, newSize: CGSize(width: 130, height: 130)), deg: 90.0)
                self.modelManager.setUserPhoto(photo: self.userPhoto.image!, phone: self.phone)
            }
            else{
                self.userPhoto.image = resizeImage(image: image, newSize: CGSize(width: 130, height: 130))
                self.modelManager.setUserPhoto(photo: self.userPhoto.image!, phone: self.phone)
            }
        }
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSErrorPointer, contextInfo:UnsafeRawPointer) {
        
        if error != nil {
            let alert = UIAlertController(title: "Ups...",
                                          message: "Algo Fallo...",
                                          preferredStyle: UIAlertControllerStyle.alert)
            
            let cancelAction = UIAlertAction(title: "Listo",
                                             style: .cancel, handler: nil)
            
            alert.addAction(cancelAction)
            self.present(alert, animated: true,
                         completion: nil)
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
    }
}
