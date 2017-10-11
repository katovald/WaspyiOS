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
import GeoFire
import FirebaseMessaging

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
    public let LocationChangeNotification = NSNotification.Name("GroupPlacesUpdated")
    public let PlacesChangedNotification = NSNotification.Name("PlacesAdded")
    public let LogInNotification = NSNotification.Name("CorrectLogIn")
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
    
    public func userExist(phone:String, completion: @escaping (Bool) -> Void)
    {
        self.reference.child("accounts/" + phone).observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary ?? nil
            
            if value == nil
            {
                self.userD.set(nil, forKey: "OwnerName")
                self.userD.set(phone, forKey: "OwnerPhone")
                self.userD.set(nil, forKey: "OwnerMail")
                self.userD.set(nil, forKey: "OwnerGroups")
                self.userD.set(nil, forKey: "ActualGroup")
                self.userD.set(nil, forKey: "ActualGroupTitle")
                self.userD.set(nil, forKey: "MembersActiveGroup")
                self.userD.set(nil, forKey: "ActualGroupPlaces")
                self.userD.set(nil, forKey: "VisibleInActualGroup")
                completion(false)
            }else{
                completion(true)
            }
            
        })
    }
    
    public func changeGroupName(code: String, name: String){
        let telefono = userD.string(forKey: "OwnerPhone")!
        self.reference.child("accounts/" + telefono + "/user_groups/groups/" + code).setValue(name)
        self.reference.child("groups/" + code + "/group_info/group_name").setValue(name)
    }
    
    public func setUserSetting(phone: String, name: String, mail: String){
        userD.set(name, forKey: "OwnerName")
        userD.set(phone, forKey: "OwnerPhone")
        userD.set(mail, forKey: "OwnerMail")
        
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

        var gruposAct = userD.array(forKey: "OwnerGroups")
        
        var groupCode:String = randomAlphaNumericString(length: 6)
        
        let phone = userD.string(forKey: "OwnerPhone")!
        
        if phone.characters.count > 0
        {
            let userInfo = ["name" : userD.string(forKey: "OwnerName")!,
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
            
            let newGroup = [groupCode:name]
            gruposAct?.append(newGroup)
            
            userD.set(gruposAct, forKey: "OwnerGroups")
            userD.set(groupCode, forKey: "ActualGroup")
            userD.set(name, forKey: "ActualGroupTitle")
            userD.set(true, forKey: "VisibleInActualGroup")
            
            let memberInfo = [phone:["Nombre": self.userD.string(forKey: "OwnerName") ?? "",
                                     "Telefono": self.userD.string(forKey: "OwnerPhone") ?? "",
                                     "Descarga": self.userD.string(forKey: "OwnerDownloadURL") ?? "",
                                     "Rol": "Admin",
                                     "Geocercas": ["Enter":true, "Exit":true]]]
            
            userD.set(memberInfo, forKey: "MembersActiveGroup")
            
            self.notificationCenter.post(name: GroupsChangeNotification, object: self)
        }
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
                
                var gruposAct = self.userD.array(forKey: "OwnerGroups")
                gruposAct?.append([code:groupName])
                self.userD.set(gruposAct, forKey: "OwnerGroups")
                self.userD.set(code, forKey: "ActualGroup")
                self.userD.set(groupName, forKey: "ActualGroupTitle")
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
        self.getPlaces(group: code, completion: {(places) in
            self.userD.set(places, forKey: "ActualGroupPlaces")
            self.notificationCenter.post(name: self.PlacesChangedNotification, object: self)
        })
        self.userD.set(allGroupMembers, forKey: "MembersActiveGroup")
        self.notificationCenter.post(name: GroupsChangeNotification, object: self)
    }
    
    public func setUserRegToken(phone: String){
        
        guard let token = InstanceID.instanceID().token() else { return }
        self.reference.child("accounts/" + phone + "/FCMToken").setValue(token)
        
    }
    
    public func setLastGroup(name: String){
        let phone = userD.string(forKey: "OwnerPhone")
        self.reference.child("accounts/" + phone! + "/user_groups/last_groups").setValue(name)
    }
    
    public func setUserAdminGroup(phone: String, group: String, admin: Bool){
        if admin{
            self.reference.child("groups/" + group + "/members/" + phone + "/rol").setValue("admin")
        }else{
            self.reference.child("groups/" + group + "/members/" + phone + "/rol").setValue("guest")
        }
    }
    
    public func saveGroupPlace(code: String, address: String, icon: Int, l: [String:Double], place_name:String, radio: Int){
        var placeData = [String:Any]()
        placeData["address"] = address
        placeData["icon"] = icon
        placeData["l"] = l
        placeData["place_name"] = place_name
        placeData["radio"] = radio
        
        self.reference.child("groups/" + code + "/group_places").childByAutoId().setValue(placeData)
        
        Messaging.messaging().subscribe(toTopic: "D8hfeS_enter")
        Messaging.messaging().subscribe(toTopic: "D8hfeS_exit")
        Messaging.messaging().subscribe(toTopic: "D8hfeS_alert")
    }
    
    public func editGroupPlace(code: String, key: String, address: String, icon: Int, l: [String:Double], place_name:String, radio: Int){
        var placeData = [String:Any]()
        placeData["address"] = address
        placeData["icon"] = icon
        placeData["l"] = l
        placeData["place_name"] = place_name
        placeData["radio"] = radio
        self.reference.child("groups/" + code + "/group_places/" + key).setValue(placeData)
    }
    
    public func saveUserPhotoFB(photo: UIImage, phone: String){
        
        let fileStorage = almacen.reference(forURL: "gs://camasacontigo.appspot.com/Waspy/")
        let imageData: Data = UIImagePNGRepresentation(photo)!
        
        let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let imageUrl = docUrl.appendingPathComponent(phone + ".png")
        
        try! imageData.write(to: imageUrl)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        fileStorage.child(phone + ".png").putData(imageData,
                                                  metadata: metadata,
                                                  completion: { (metadataFB, error) in
            guard metadataFB != nil else {
                return
            }
            self.reference.child("accounts/" + phone + "/photo_url").setValue(metadataFB?.downloadURL()?.absoluteString)
            self.userD.set(metadataFB?.downloadURL()?.absoluteString, forKey: "OwnerDownloadURL")
            
            var auxMembersInfo = self.userD.dictionary(forKey: "MembersActiveGroup")
            if (auxMembersInfo == nil)
            {
                
            }else{
                var member = auxMembersInfo?[phone] as! [String:Any]
                member["Descarga"] = metadataFB?.downloadURL()?.absoluteString
                auxMembersInfo?[phone] = member
                self.userD.set(auxMembersInfo, forKey: "MembersActiveGroup")
            }
        })
        
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
    
    public func setMyVisibility(code: String, tel: String, visible: Bool)
    {
        reference.child("groups/" + code + "/members/" + tel + "/visibility").setValue(visible)
        userD.set(visible, forKey: "VisibleInActualGroup")
    }
    
    public func updateUserLocation()
    {
        guard let phone = self.userD.string(forKey: "OwnerPhone")
            else {return}
        let name = self.userD.string(forKey: "OwnerName")!
        
        if phone == "" || name == ""
        {
            return
        }
        
        LocationServices.init().getAdress(completion: {coordinades, speed, address, error in
            if let a = address {
                let kilo = a["FormattedAddressLines"] as! [String]
                
                var direccion = ""
                
                for index in 0...(kilo.count - 1)
                {
                    direccion += kilo[index]
                    direccion += " "
                }
                
                let ownerGroups = self.userD.array(forKey: "OwnerGroups") as! [[String:String]]
                
                for code in ownerGroups{
                    self.reference.child("groups/" + (code.first?.key)! + "/members/" + phone + "/battery_level").setValue(batteryLevel())
                    self.reference.child("groups/" + (code.first?.key)! + "/members/" + phone + "/current_place").setValue(direccion)
                    self.reference.child("groups/" + (code.first?.key)! + "/members/" + phone + "/location/latitude").setValue(coordinades.latitude)
                    self.reference.child("groups/" + (code.first?.key)! + "/members/" + phone + "/location/longitude").setValue(coordinades.longitude)
                    self.reference.child("groups/" + (code.first?.key)! + "/members/" + phone + "/location/speed").setValue(speed.magnitude)
                }
            }
        })
    }
    
    public func updatePlace (code: String, key: String, data: [String:Any])
    {
        self.reference.child("groups/" + code + "/group_places/" + key).setValue(data)
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
                self.getGroupMembersInfo(code: self.userD.string(forKey: "ActualGroup")!, completion: { (members) in
                    self.userD.set(members, forKey: "MembersActiveGroup")
                    self.getPlaces(group: actualgroupc!, completion: {(list) in
                        self.userD.set(list, forKey: "ActualGroupPlaces")
                        self.notificationCenter.post(name: self.LogInNotification, object: self)
                    })
                })
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
            return UIImage(named: "map-eye.png")!
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
    
    public func getGroupMembersInfo(code: String, completion: @escaping ([[String:[String:Any]]]) ->  Void)
    {
        let id = code
        var membersGroup = [[String:[String:Any]]]()
        
        self.reference.child("groups/" + id + "/members").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String:[String:Any]] ?? [:]
            let keys = value.keys
            
            for key in keys
            {
                self.getMemberPhotoFB(phone: key)
                membersGroup.append([key:value[key]!])
            }
            
            completion(membersGroup)
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
    
    public func getPlaces(group: String, completion: @escaping ([[String:[String:Any]]]) ->  Void){
        var places = [[String:[String:Any]]]()
        self.reference.child("groups/" + group + "/group_places").observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? [String:Any] ?? [:]
            let keys = value.keys
            
            for key in keys{
                let place = value[key] as! [String:Any]
                var aux = [String:Any]()
                aux["address"] = place["address"] as! String
                aux["icon"] = place["icon"] as! Int
                aux["place_name"] = place["place_name"] as! String
                
                let location = place["l"]

                aux["l"] = location
                aux["radio"] = place["radio"]
                
                let infoPlace = [key:aux]
                
                places.append(infoPlace)
            }
            completion(places)
        })
    }
    //// delete data functions
    //// Beware whit this
    //// Created by Kato
    
    public func deletePlace(code: String, key: String){
        self.reference.child("groups/" + code + "/group_places/" + key).setValue(nil)
    }

    public func unsuscribeGroups(code: String, phone: String, kill: Bool){
        self.reference.child("accounts/" + phone + "/user_groups/groups/" + code).setValue(nil)
        if kill
        {
            self.reference.child("groups/" + code).setValue(nil)
        }else{
            self.reference.child("groups/" + code + "/members/" + phone).setValue(nil)
        }
    }
}
