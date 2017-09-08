//
//  firebaseManager.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 9/5/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import UIKit
import CoreLocation

func batteryState()-> UIDeviceBatteryState {
    return UIDevice.current.batteryState
}

func batteryLevel()-> Int {
    return Int(UIDevice.current.batteryLevel) * 100
}

public class firebaseManager {
    private var reference: DatabaseReference!
    private var userD:UserDefaults = UserDefaults.standard
    private var almacen = Storage.storage()
    private var urlDownload:String!
    private let fileMan = FileManager.default
    
    public var notificationCenter: NotificationCenter = NotificationCenter.default
    
    public let DataChangueNotification = NSNotification.Name("UserDataChanged")
    public let PhotoChangueNotification = NSNotification.Name("UserPhotoChanged")
    public let GroupsChangeNotification = NSNotification.Name("UserGroupsChanged")
    
    init()
    {
        UIDevice.current.isBatteryMonitoringEnabled = true
        reference = Database.database().reference()
        urlDownload = ""
    }
    
    //    set functions that use firebase methods
    //    please pay atention about the notifications and error handling
    //    created by kato
    
    public func setUserSetting(phone: String, name: String, mail: String){
        userD.set(name, forKey: "Name")
        userD.set(mail, forKey: "Mail")
        userD.set(phone, forKey: "Phone")
        
        self.reference.child("accounts/" + phone + "/name").setValue(name)
        self.reference.child("accounts/" + phone + "/phone").setValue(phone)
        self.reference.child("accounts/" + phone + "/mail").setValue(mail)
       
        self.reference.child("accounts/" + phone + "/user_groups/").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary ?? [:]
            let keys = value.allKeys
            
            if keys.count == 0
            {
                self.createUserGroups(name: "Familia")
            }
        })
        
        self.notificationCenter.post(name: DataChangueNotification, object: self)
        
    }
    
    public func createUserGroups(name: String){

        var groupCode:String = randomAlphaNumericString(length: 6)
        
        let phone = userD.string(forKey: "Phone")!
        
        if phone.characters.count > 0
        {
            let userInfo = ["name" : userD.string(forKey: "Name")!,
                          "phone" : phone,
                          "rol" : "admin",
                          "visibility" : true] as [String : Any]
            
            self.reference.child("groups/" + groupCode).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary ?? [:]
                let keys = value.allKeys as! [String]
                
                if keys.count > 0 {
                    groupCode = self.checkCodeRepeat(array: keys, code: groupCode)
                }
            })
            
            self.reference.child("accounts/" + phone + "/user_groups/groups/" + groupCode).setValue(name)
            self.reference.child("accounts/" + phone + "/user_groups/groups/last_group").setValue(name)
            self.reference.child("groups/" + groupCode + "/group_info/group_code").setValue(groupCode)
            self.reference.child("groups/" + groupCode + "/group_info/group_name").setValue(name)
            self.reference.child("groups/" + groupCode + "/members/" + phone).setValue(userInfo)
        }
        
        var gruposAct = userD.dictionary(forKey: "Grupos") ?? [:]
        gruposAct[groupCode] = name
        
        userD.set(gruposAct, forKey: "Grupos")
        userD.set(groupCode, forKey: "CodeGrupoActual")
        userD.set(name, forKey: "NombreGrupoActual")

        
        self.notificationCenter.post(name: GroupsChangeNotification, object: self)
    }
    
    public func subscribeUserGroups(code: String){

        let phone = userD.string(forKey: "Phone")!
        var groupName = ""
        if phone.characters.count > 0
        {
            let userInfo = ["name" : userD.string(forKey: "Name")!,
                            "phone" : phone,
                            "rol" : "admin",
                            "visibility" : true] as [String : Any]
            
            self.reference.child("groups/" + code).observeSingleEvent(of: .value, with: {(snapshot) in
                let value = snapshot.value as? NSDictionary
                groupName = value?["group_name"] as! String
            })
            
            self.reference.child("groups/" + code + "/members/" + phone).setValue(userInfo)
            self.reference.child("accounts/" + phone + "/user_groups/groups/" + code).setValue(groupName)
            
            self.notificationCenter.post(name: GroupsChangeNotification, object: self)
        }
    }
    
    
    func checkCodeRepeat(array: [String], code: String) -> String {
        var codeWr = ""
        if array.contains(code)
        {
            codeWr = checkCodeRepeat(array: array, code: randomAlphaNumericString(length: 6))
        }else{
            codeWr = code
        }
        return codeWr
    }
    
    public func setUserRegToken(phone: String){
        
        guard let token = InstanceID.instanceID().token() else { return }
        self.reference.child("accounts/" + phone + "/FCMToken").setValue(token)
        
    }
    
    public func setUserPhoto (photo: UIImage, phone: String){
        
        let fileStorage = almacen.reference(forURL: "gs://camasacontigo.appspot.com/CAMUserPhotos/")
        let imageData: Data = UIImagePNGRepresentation(photo)!
        
        let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let imageUrl = docUrl.appendingPathComponent(phone + ".png")
        
        try! imageData.write(to: imageUrl)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        fileStorage.child(phone + ".png").putData(imageData, metadata: metadata) { (metadata, error) in
            guard metadata != nil else {
                return
            }
            self.urlDownload = (metadata?.downloadURL()?.path)!
            self.reference.child("accounts/" + phone + "/photo_url").setValue(self.urlDownload)
            
        }
        
        self.notificationCenter.post(name: PhotoChangueNotification, object: self)
    }
    
    public func saveMembersPhotos (photo: UIImage, phone: String){
        
        let imageData: Data = UIImagePNGRepresentation(photo)!
        let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let imageUrl = docUrl.appendingPathComponent(phone + ".png")
        try! imageData.write(to: imageUrl)
        let MemPhotoChangueNotification = NSNotification.Name("MemberPhotoChanged")
        self.notificationCenter.post(name: MemPhotoChangueNotification, object: self)
    
    }
    
//    get functions that use firebase methods
//    please pay atention about the notifications and error handling
//    created by kato
    
    public func getUserData(phone:String){
        
    }
    
    public func getMemberPhoto(phone: String) -> UIImage{
        let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let photoURl = docUrl.appendingPathComponent(phone + ".png")
        
        if (fileMan.fileExists(atPath: photoURl.path)){
            return UIImage(contentsOfFile: photoURl.path)!
        }else{
            return UIImage(named: "logo.png")!
        }
    }
    
    public func getMemberPhotoFB(phone: String) {
        let userPictureLocation = almacen.reference(forURL: "gs://camasacontigo.appspot.com/CAMUserPhotos/")
        let userPicture = userPictureLocation.child(phone)
        userPicture.getData(maxSize: 1 * 1024 * 1024) { (data, error) -> Void in
            if (error == nil) {
                let photo = UIImage(data: data!)
                let imageData: Data = UIImagePNGRepresentation(photo!)!
                let docUrl = try! self.fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let imageUrl = docUrl.appendingPathComponent(phone + ".png")
                try! imageData.write(to: imageUrl)
            }
        }
    }
    
    //// delete data functions
    //// Beware whit this
    //// Created by Kato
    
    public func deleteUserGroups(code: String){
        
    }
    
    public func unsuscribeGroups(code: String){
        
    }
    
    
    public func sendLocation (location: CLLocation, speed: CLLocationSpeed){
        
    }
    
    
    
}
