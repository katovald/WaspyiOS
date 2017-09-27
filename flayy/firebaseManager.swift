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
  //  public let LocationChangeNotification = NSNotification.Name("UserLocationChanged")
//    public let PhotoChangueNotification = NSNotification.Name("UserPhotoChanged")
//    public let GroupsChangeNotification = NSNotification.Name("UserGroupsChanged")
    
    
    ///initiate class
    ///battery monitor and references firebase
    
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
        userD.set(name, forKey: "OwnerName")
        userD.set(phone, forKey: "OwnerPhone")
        
        self.reference.child("accounts/" + phone + "/name").setValue(name)
        self.reference.child("accounts/" + phone + "/phone").setValue(phone)
        self.reference.child("accounts/" + phone + "/mail").setValue(mail)
       
        self.reference.child("accounts/" + phone + "/user_groups/").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary ?? [:]
            let keys = value.allKeys
            
            if keys.count == 0
            {
                self.createUserGroups(name: "Mi Grupo")
            }
        })
        
        self.notificationCenter.post(name: DataChangueNotification, object: self)
        
    }
    
    public func createUserGroups(name: String){

        var groupCode:String = randomAlphaNumericString(length: 6)
        
        let phone = userD.string(forKey: "OwnerPhone")!
        
        if phone.characters.count > 0
        {
            let userInfo = ["name" : userD.string(forKey: "Name")!,
                          "phone" : phone,
                          "rol" : "admin",
                          "visibility" : true,
                          "photo_url": self.userD.string(forKey: "OwnerDownloadURL")!] as [String : Any]
            
            self.reference.child("groups/" + groupCode).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary ?? [:]
                let keys = value.allKeys as! [String]
                
                if keys.count > 0 {
                    groupCode = checkCodeRepeat(array: keys, code: groupCode)
                }
            })
            
            self.reference.child("accounts/" + phone + "/user_groups/groups/" + groupCode).setValue(name)
            self.reference.child("accounts/" + phone + "/user_groups/last_group").setValue(name)
            self.reference.child("groups/" + groupCode + "/group_info/group_code").setValue(groupCode)
            self.reference.child("groups/" + groupCode + "/group_info/group_name").setValue(name)
            self.reference.child("groups/" + groupCode + "/members/" + phone).setValue(userInfo)

        }
        
        var gruposAct = userD.dictionary(forKey: "OwnerGroups") ?? [:]
        gruposAct[groupCode] = name
        
        userD.set(gruposAct, forKey: "OwnerGroups")
        userD.set(groupCode, forKey: "ActualGroup")
        userD.set(name, forKey: "ActualGroupTitle")
        
        let memberInfo = [phone:["Nombre": self.userD.string(forKey: "OwnerName") ?? "",
                                             "Telefono": self.userD.string(forKey: "OwnerPhone") ?? "",
                                             "Descarga": self.userD.string(forKey: "OwnerDownloadURL") ?? "",
                                             "Rol": "Admin",
                                             "Geocercas": ["Enter":true, "Exit":true]]]
        
        userD.set(memberInfo, forKey: "ActiveGroupMembers")
        
        self.notificationCenter.post(name: GroupsChangeNotification, object: self)
    }
    
    public func subscribeUserGroups(code: String){

        let phone = userD.string(forKey: "OwnerPhone")!
        var groupName = ""
        var groupMembers = [String:Any]()
        
        if phone.characters.count > 0
        {
            let userInfo = ["name" : userD.string(forKey: "Name")!,
                            "phone" : phone,
                            "rol" : "admin",
                            "visibility" : true,
                            "photo_url": self.userD.string(forKey: "OwnerDownloadURL")!] as [String : Any]
            
            self.reference.child("groups/" + code).observeSingleEvent(of: .value, with: {(snapshot) in
                let value = snapshot.value as? NSDictionary
                let groupInfo = value?["group_info"] as! NSDictionary
                groupName = groupInfo["group_name"] as! String
                groupMembers = value?["members"] as! [String:AnyObject]
                
                self.reference.child("groups/" + code + "/members/" + phone).setValue(userInfo)
                self.reference.child("accounts/" + phone + "/user_groups/groups/" + code).setValue(groupName)
            })
        }
        var allGroupMembers = [String:Any]()
        let keys = groupMembers.keys
        for key in keys{
            let memberInfo = groupMembers[key] as! [String:Any]
            
            allGroupMembers[key] = ["Nombre": memberInfo["name"],
                                    "Telefono": memberInfo["phone"],
                                    "Descarga": memberInfo["photo_url"],
                                    "Rol": memberInfo["rol"],
                                    "Geocercas": memberInfo["geoFence_Notifications"]]
            
            self.getMemberPhotoFB(phone: key)
        }
        self.userD.set(allGroupMembers, forKey: "ActiveGroupMembers")
        self.notificationCenter.post(name: GroupsChangeNotification, object: self)
    }
    
    public func setUserRegToken(phone: String){
        
        guard let token = InstanceID.instanceID().token() else { return }
        self.reference.child("accounts/" + phone + "/FCMToken").setValue(token)
        
    }
    
    public func saveUserPhotoFB(photo: UIImage, phone: String){
        
        let fileStorage = almacen.reference(forURL: "gs://camasacontigo.appspot.com/Waspy/")
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
            self.reference.child("accounts/" + phone + "/photo_url").setValue(metadata?.downloadURL()?.absoluteString)
            self.userD.set(metadata?.downloadURL()?.absoluteString, forKey: "OwnerDownloadURL")
            
            var auxMembersInfo = self.userD.dictionary(forKey: "ActiveGroupMembers")
            var member = auxMembersInfo?[phone] as! [String:Any]
            member["Descarga"] = metadata?.downloadURL()?.absoluteString
            auxMembersInfo?[phone] = member
            self.userD.set(auxMembersInfo, forKey: "ActiveGroupMembers")
        }
        
        self.notificationCenter.post(name: PhotoChangueNotification, object: self)
    }
    
    public func saveOwnerPhoto(photo: UIImage, phone: String){
        
        let imageData: Data = UIImagePNGRepresentation(photo)!
        let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let imageUrl = docUrl.appendingPathComponent(phone + ".png")
        try! imageData.write(to: imageUrl)
        let MemPhotoChangueNotification = NSNotification.Name("MemberPhotoChanged")
        self.notificationCenter.post(name: MemPhotoChangueNotification, object: self)
    
    }
    
    @objc public func updateUserLocation()
    {
        let phone = self.userD.string(forKey: "Phone")!
        let name = self.userD.string(forKey: "Name")!
        
        if phone == "" || name == ""
        {
            return
        }
        
        LocationServices.init().getAdress(completion: {coordinades, speed, address, error in
            if let a = address {
                
                print(a)
                
                let kilo = a["FormattedAddressLines"] as! [String]
                
                var direccion = ""
                
                for index in 0...(kilo.count - 1)
                {
                    direccion += kilo[index] 
                    direccion += " "
                }
                
                let codeGroups = self.userD.array(forKey: "Groupkeys") as! [String]
                
                for code in codeGroups{
                    self.reference.child("groups/" + code + "/members/" + phone + "/battery_level").setValue(batteryLevel())
                    self.reference.child("groups/" + code + "/members/" + phone + "/current_place").setValue(direccion)
                    self.reference.child("groups/" + code + "/members/" + phone + "/location/latitude").setValue(coordinades.latitude)
                    self.reference.child("groups/" + code + "/members/" + phone + "/location/longitude").setValue(coordinades.longitude)
                    self.reference.child("groups/" + code + "/members/" + phone + "/location/speed").setValue(speed.magnitude)
                }
            }
        })
        
        
        
    }
//    get functions that use firebase methods
//    please pay atention about the notifications and error handling
//    created by kato
    
    public func getOwnerData(phone:String){
        reference.child("accounts/" + phone).observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary
            if (value?.count)! > 0
            {
                self.userD.set(value?["name"] as! String, forKey: "OwnerName")
                self.userD.set(value?["phone"] as! String, forKey: "OwnerPhone")
                self.userD.set(value?["photo_url"] as! String, forKey: "OwnerDownloadURL")
                let usergroupsinfo = value?["user_groups"] as! NSDictionary
                let usergroups = usergroupsinfo["groups"] as! [String:String]
                var gruposAux = [[String:String]]()
                for key in usergroups.keys{
                    gruposAux.append([key:usergroups[key]!])
                }
                self.userD.set(gruposAux, forKey: "OwnerGroups")
                let actualgroupc = usergroups.first?.key
                let actualgroupn = usergroups.first?.value
                self.userD.set(actualgroupc, forKey: "ActualGroup")
                self.userD.set(actualgroupn, forKey: "ActualGroupTitle")
                self.getGroupMembersInfo()
            }
        })
    }
    
    public func getPhoneOwnerGroups(){
        let phone = self.userD.string(forKey: "Phone")
        self.reference.child("accounts/" + phone! + "/user_groups/").observeSingleEvent(of: .value, with: {(snapshot) in
            guard let value = snapshot.value as? NSDictionary else {return}
            self.userD.set(value["groups"], forKey: "OwnerGroups")
        })
        
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
        let userPictureLocation = almacen.reference(forURL: "gs://camasacontigo.appspot.com/Waspy/")
        let userPicture = userPictureLocation.child(phone + ".png")
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
    
    public func getGroupMembersInfo()
    {
        let id = userD.string(forKey: "ActualGroup")!
        var membersGroup = [[String:[String:Any]]]()
        
        self.reference.child("groups/" + id + "/members").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String:[String:Any]] ?? [:]
            let keys = value.keys
            
            for key in keys
            {
                self.getMemberPhotoFB(phone: key)
                membersGroup.append([key:value[key]!])
            }
            
            self.userD.set(membersGroup, forKey: "MembersActiveGroup")
        })
    }
    
    public func getNotifications()
    {
        var Alerts = [[String:[String:Any]]]()
        
        self.reference.child("alerts_geo/").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as! [String:[String:Any]]
            let keys = value.keys
            
            for key in keys
            {
                self.getMemberPhotoFB(phone: key)
                Alerts.append([key:value[key]!])
            }
        })
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
