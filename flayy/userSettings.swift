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
    
    var databaseref: DatabaseReference!
    let almacen = Storage.storage()
    var nombre:String!
    var phone:String!
    var mail:String!
    let userD = UserDefaults.standard
    let fileMan = FileManager.default
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
            enviaDatosFB()
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
        var datosPic:Data? = nil
        self.nombre = self.userD.string(forKey: "Name")
        self.nameText.text = nombre
        self.phone = self.userD.string(forKey: "Phone")
        self.mail = self.userD.string(forKey: "Mail")
        self.userMail.text = self.mail
        
        let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let photoURl = docUrl.appendingPathComponent(self.phone + ".png")
        
        if (fileMan.fileExists(atPath: photoURl.path)){
            self.userPhoto.image = UIImage(contentsOfFile: photoURl.path)
        }else{
            let userPictureLocation = almacen.reference(forURL: "gs://camasacontigo.appspot.com")
            let userPicture = userPictureLocation.child("/CAMUserPhotos/" + self.phone)
            userPicture.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
                if (error == nil) {
                    datosPic = data
                    let imageData = UIImage(data: datosPic!)
                    self.userPhoto.image = imageData
                    let variable = UIImagePNGRepresentation(imageData!)
                    try! variable?.write(to: photoURl)
                } 
            }
        }
        
        if (self.nombre == ""){
            self.Salir.isEnabled = false
        }
    }
    
    @IBAction func inicioGaleria(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
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
            if(image.size.width < image.size.height){
                let imagenRec:UIImage =  cropToBounds(image: image, width: Double(image.size.width), height: Double(image.size.width))
                self.userPhoto.image = resizeImage(image: imagenRec, newSize: CGSize(width: 130, height: 130))
            }
            if(image.size.width > image.size.height){
                let imagenRec:UIImage =  cropToBounds(image: image, width: Double(image.size.height), height: Double(image.size.height))
                self.userPhoto.image = resizeImage(image: imagenRec, newSize: CGSize(width: 130, height: 130))
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
    
    func enviaDatosFB()
    {
        self.databaseref = Database.database().reference()
        let reference = almacen.reference(forURL: "gs://camasacontigo.appspot.com/CAMUserPhotos/")
        let imageData: Data = UIImagePNGRepresentation(userPhoto.image!)!
        
        var urlDownload = ""
        
        let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let imageUrl = docUrl.appendingPathComponent(self.phone + ".png")
        
        try! imageData.write(to: imageUrl)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"                                 
        
        reference.child(self.phone + ".png").putData(imageData, metadata: metadata) { (metadata, error) in
            guard metadata != nil else {
                print(error ?? "")
                return
            }
            urlDownload = (metadata?.downloadURL()?.path)!
            self.databaseref.child("accounts/" + self.phone + "/photo_url").setValue(urlDownload)
        }
        
        self.databaseref.child("accounts/" + phone + "/name").setValue(self.nameText.text)
        self.databaseref.child("accounts/" + phone + "/phone").setValue(self.phone)
        self.databaseref.child("accounts/" + phone + "/mail").setValue(self.userMail.text)
    }
    
    
}


