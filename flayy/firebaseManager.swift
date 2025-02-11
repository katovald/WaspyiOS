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
    return Int(UIDevice.current.batteryLevel * 100)
}

enum dataType {
    case group
    case user
}

public class firebaseManager {
    private var reference: DatabaseReference!
    private var userD:UserDefaults = UserDefaults.standard
    private var almacen = Storage.storage()
    private var urlDownload:String!
    private let fileMan = FileManager.default

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
    
    public func clearUserDefaults()
    {
        self.userD.set(nil, forKey: "OwnerName")
        self.userD.set(nil, forKey: "OwnerMail")
        self.userD.set(nil, forKey: "OwnerGroups")
        self.userD.set(nil, forKey: "ActualGroup")
        self.userD.set(nil, forKey: "ActualGroupTitle")
        self.userD.set(nil, forKey: "MembersActiveGroup")
        self.userD.set(nil, forKey: "ActualGroupPlaces")
        self.userD.set(nil, forKey: "VisibleInActualGroup")
    }
    
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
    
    public func isGroupExists(code: String, completion: @escaping (Bool, String) -> Void) {
        self.reference.child("groups/" + code).observeSingleEvent(of: .value) { (snap) in
            let value = snap.value as? NSDictionary ?? nil
            let group_info = value!["group_info"] as! NSDictionary
            let childexist:Bool = (value != nil)
            var owner:String = ""
            if childexist {
                let data = snap.value as? [String:[String:Any]] ?? [:]
                let members = data["members"] as? [String:[String:Any]] ?? [:]
                let memberNumbers = members.keys
                let ownerPhone = self.userD.string(forKey: "OwnerPhone")!
                for member in memberNumbers {
                    if member == ownerPhone{
                        let reference = [code:group_info["group_name"] as! String]
                        self.reference.child("accounts/\(ownerPhone)/user_groups/groups/").updateChildValues(reference)
                        self.getOwnerData(phone: ownerPhone)
                        completion(false, "")
                        return
                    }
                }
                for member in memberNumbers {
                    let memberData = members[member]
                    if memberData!["rol"] as? String == "admin"{
                        owner = memberData!["name"] as? String ?? ""
                        break
                    }
                }
            }
            completion(childexist,owner)
        }
    }
    
    public func changeGroupName(code: String, name: String){
        let telefono = userD.string(forKey: "OwnerPhone")!
        self.reference.child("accounts/" + telefono + "/user_groups/groups/" + code).setValue(name)
        self.reference.child("groups/" + code + "/group_info/group_name").setValue(name)
    }
    
    public func setUserSetting(){
        guard let phone = userD.string(forKey: "OwnerPhone") else {return}
        guard let mail = userD.string(forKey: "OwnerMail") else {return}
        let name = userD.string(forKey: "OwnerName") ?? ""
        self.reference.child("accounts/" + phone + "/name").setValue(name)
        self.reference.child("accounts/" + phone + "/phone").setValue(phone)
        self.reference.child("accounts/" + phone + "/mail").setValue(mail)
        self.reference.child("accounts/" + phone + "/user_groups/groups/").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String:String] ?? [:]
            let keys = value.keys
            if keys.count == 0
            {
                self.createUserGroups(name: "Mi Grupo")
            }else{
                for key in keys {
                    self.reference.child("groups/\(key)/members/\(phone)/name/").setValue(name)
                }
            }
        })
        
        self.reference.child("accounts/" + phone + "/account_level/").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? String ?? ""
            
            if value == ""
            {
                self.reference.child("accounts/" + phone + "/account_level").setValue("freemium")
                self.userD.set("freemium", forKey: "OwnerAccountType")
            }else{
                self.userD.set(value, forKey: "OwnerAccountType")
            }
        })
        
        if userD.string(forKey: "OwnerName") != nil{
            NotificationCenter.default.post(notification: .userDataChange)
        }
    }
    
    public func setEmergencyContacts(contact: [String:Any]){
        let telefono = self.userD.string(forKey: "OwnerPhone")!
        let place = contact.first?.key
        let contactNew = contact.first?.value as? [String:String] ?? nil
        self.reference.child("accounts/" + telefono + "/contacts_of_emergency/" + place!).setValue(contactNew?.first?.key)
        self.reference.child("accounts/" + telefono + "/contacts_of_emergency/" + place! + "_p").setValue(contactNew?.first?.value)
        var contactos = self.userD.dictionary(forKey: "EmergencyContacts") as? [String:String] ?? [:]
        
        contactos[place!] = contactNew?.first?.key
        contactos[place! + "_p"] = contactNew?.first?.value
        
        self.userD.set(contactos, forKey: "EmergencyContacts")
    }
    
    public func createAlertGeo(key: String, coment: String){
        let tipo = userD.integer(forKey: "AlertType")
        var title:String!
        switch tipo {
        case 1:
            title = "Agresion"
        case 2:
            title = "Acoso"
        case 3:
            title = "Asalto"
        case 4:
            title = "Motoatraco"
        case 5:
            title = "Robos"
        default:
            title = "Alerta"
        }
        let date = Date()    /////18-Oct-2017 10:51:47
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)

        let hour = components.hour
        let min = components.minute
        let sec = components.second
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        let result = formatter.string(from: date) + " " +
                        String(describing: hour ?? 0) + ":" +
                        String(describing: min ?? 0) + ":" +
                        String(describing: sec ?? 0)
        
        let alertBody = ["comments":coment,
                        "date":result,
                        "type":tipo,
                        "title": title] as [String : Any]
        self.reference.child("alerts_geo/" + key).updateChildValues(alertBody)
    }
    
    public func createUserGroups(name: String){
        
        var gruposAct = userD.array(forKey: "OwnerGroups") ?? []
        
        var groupCode = randomAlphaNumericString(length: 6)
        
        guard let phone = userD.string(forKey: "OwnerPhone")
            else { return }

        if phone.count > 0
        {
            let userInfo = ["name" : userD.string(forKey: "OwnerName") ?? "",
                          "phone" : phone,
                          "rol" : "admin",
                          "visibility" : true,
                          "photo_url": self.userD.string(forKey: "OwnerDownloadURL") ?? "",
                          "geoFence_Notifications": ["geoFence_enter":true,
                                                     "geoFence_exit":true]] as [String : Any]
            
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
            gruposAct.append(newGroup)
            
            userD.set(gruposAct, forKey: "OwnerGroups")
            userD.set(groupCode, forKey: "ActualGroup")
            userD.set(name, forKey: "ActualGroupTitle")
            userD.set(true, forKey: "VisibleInActualGroup")
            userD.set(nil, forKey: "ActualGroupPlaces")
            
            var banderas = [String:[String:Bool]]()
            
            banderas["geoFence_Notifications"] = ["geoFence_enter":true, "geoFence_exit":true]
            var memberInfo = Array<Any>()
            memberInfo.append([phone:["name": self.userD.string(forKey: "OwnerName") ?? "",
                                     "phone": self.userD.string(forKey: "OwnerPhone") ?? "",
                                     "photo_url": self.userD.string(forKey: "OwnerDownloadURL") ?? "",
                                     "rol": "Admin",
                                     "geoFence_Notifications": ["geoFence_enter":true, "geoFence_exit":true]]])
            
            userD.set(memberInfo, forKey: "MembersActiveGroup")
            userD.set(banderas, forKey: "NotificationFlags")
            
            Messaging.messaging().subscribe(toTopic: groupCode + "_enter")
            Messaging.messaging().subscribe(toTopic: groupCode + "_exit")
            Messaging.messaging().subscribe(toTopic: groupCode + "_alert")
            NotificationCenter.default.post(notification: .groupCreated)
        }
    }
    
    public func subscribeUserGroups(code: String){
        let phone = userD.string(forKey: "OwnerPhone")!
        var groupName = ""
        var groupMembers = [String:Any]()
        userD.set(nil, forKey: "ActualGroupPlaces")
        if phone.count > 0
        {
            let userInfo = ["name" : userD.string(forKey: "OwnerName") ?? "",
                            "phone" : phone,
                            "rol" : "guest",
                            "visibility" : true,
                            "photo_url": self.userD.string(forKey: "OwnerDownloadURL") ?? ""] as [String : Any]
            
            self.reference.child("groups/" + code).observeSingleEvent(of: .value, with: {(snapshot) in
                guard let value = snapshot.value as? NSDictionary else {return}
                let groupInfo = value["group_info"] as! NSDictionary
                groupName = groupInfo["group_name"] as! String
                groupMembers = value["members"] as! [String:AnyObject]
                
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
            let memberInfo = groupMembers[key] as? [String:Any] ?? [:]
            
            allGroupMembers[key] = ["name": memberInfo["name"],
                                    "phone": memberInfo["phone"],
                                    "photo_url": memberInfo["photo_url"],
                                    "rol": memberInfo["rol"],
                                    "photo_url": memberInfo["geoFence_Notifications"]]
            
            self.getMemberPhotoFB(phone: key)
        }
        self.getPlaces(group: code, completion: {(places) in
            self.userD.set(places, forKey: "ActualGroupPlaces")
            NotificationCenter.default.post(notification: .placesChanges)
        })
        self.userD.set(allGroupMembers, forKey: "MembersActiveGroup")
        Messaging.messaging().subscribe(toTopic: code + "_enter")
        Messaging.messaging().subscribe(toTopic: code + "_exit")
        Messaging.messaging().subscribe(toTopic: code + "_alert")
        NotificationCenter.default.post(notification: .groupsChanges)
    }
    
    public func setUserRegToken(){
        let phone = self.userD.string(forKey: "OwnerPhone") ?? ""
        if phone != ""{
            guard let token = InstanceID.instanceID().token() else { return }
            self.reference.child("accounts/" + phone + "/FCMToken").setValue(token)
        }
    }
    
    public func turnEnterNotification(code: String, OnOff: Bool){
        self.reference.child("groups/" + code + "/members/" + userD.string(forKey: "OwnerPhone")! + "/geoFence_Notifications/geoFence_enter").setValue(OnOff)
    }
    
    public func turnExitNotification(code: String, OnOff: Bool){
         self.reference.child("groups/" + code + "/members/" + userD.string(forKey: "OwnerPhone")! + "/geoFence_Notifications/geoFence_exit").setValue(OnOff)
    }
    
    public func setLastGroup(name: String){
        let phone = userD.string(forKey: "OwnerPhone")
        self.reference.child("accounts/" + phone! + "/user_groups/last_group").setValue(name)
    }
    
    public func setUserAdminGroup(phone: String, group: String, admin: Bool){
        if admin{
            self.reference.child("groups/" + group + "/members/" + phone + "/rol").setValue("admin")
        }else{
            self.reference.child("groups/" + group + "/members/" + phone + "/rol").setValue("guest")
        }
    }
    
    public func saveGroupPlace(code: String, address: String, icon: Int, l: [Double], place_name:String, radio: Int){
        var placeData = [String:Any]()
        placeData["address"] = address
        placeData["icon"] = icon
        placeData["l"] = l
        placeData["place_name"] = place_name
        placeData["radio"] = radio
        
        self.reference.child("groups/" + code + "/group_places").childByAutoId().setValue(placeData)
    }
    
    public func saveCheckIn(point: CLLocation?){
        guard let locat = point else {
            return
        }
        
        let code = self.userD.string(forKey: "ActualGroup")
        let name = self.userD.string(forKey: "OwnerName")
        let date = Date()    /////18-Oct-2017 10:51:47
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let hour = components.hour
        let min = components.minute
        let sec = components.second
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.string(from: date) + " " +
            String(describing: hour ?? 0) + ":" +
            String(describing: min ?? 0) + ":" +
            String(describing: sec ?? 0)
        formatter.dateFormat = "dd-MMM-yyyy"
        let time = formatter.string(from: date) + " " +
            String(describing: hour ?? 0) + ":" +
            String(describing: min ?? 0) + ":" +
            String(describing: sec ?? 0)
        LocationServices.init().getAdress(location: locat) { (address, e) in
             if e == nil {
                let checkIn =  ["address":address!,
                                "location": ["latitude":locat.coordinate.latitude,
                                             "longitude":locat.coordinate.longitude,
                                             "speed":locat.speed.magnitude],
                                "time":time,
                                "type":"check_in",
                                "user":name ?? ""] as [String : Any]
                
                self.reference.child("groups/" + code! + "/group_check_in/").child(result).setValue(checkIn)
            }
        }
    }
    
    public func savePanicCall(point: CLLocation?){

        guard let locat = point else {
            return
        }
        
        let code = self.userD.string(forKey: "ActualGroup")
        let name = self.userD.string(forKey: "OwnerName")
        let date = Date()    /////18-Oct-2017 10:51:47
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let hour = components.hour
        let min = components.minute
        let sec = components.second
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let result = formatter.string(from: date) + " " +
            String(describing: hour ?? 0) + ":" +
            String(describing: min ?? 0) + ":" +
            String(describing: sec ?? 0)
        formatter.dateFormat = "dd-MMM-yyyy"
        let time = formatter.string(from: date) + " " +
            String(describing: hour ?? 0) + ":" +
            String(describing: min ?? 0) + ":" +
            String(describing: sec ?? 0)
        LocationServices.init().getAdress(location: locat) { (address, e) in
            if e == nil {
                let panic =  ["address":address!,
                                "location": ["latitude":locat.coordinate.latitude,
                                             "longitude":locat.coordinate.longitude,
                                             "speed":locat.speed.magnitude],
                                "time":time,
                                "type":"check_in",
                                "user":name ?? ""] as [String : Any]
                
                self.reference.child("groups/" + code! + "/group_check_in/").child(result).setValue(panic)
            }
        }
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
    
    public func saveUserPhotoFB(photo: UIImage, phone: String, completion: @escaping () -> Void){
        
        let fileStorage = almacen.reference(forURL: "gs://camasacontigo.appspot.com/Waspy/")
        let imageData: Data = UIImagePNGRepresentation(photo)!
        self.saveOwnerPhoto(photo: photo, phone: phone)
        let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let imageUrl = docUrl.appendingPathComponent(phone + ".png")
        
        try! imageData.write(to: imageUrl)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        fileStorage.child(phone + ".png").putData(imageData,
                                                  metadata: metadata,
                                                  completion: { (metadataFB, error) in
            if metadataFB != nil {
                self.reference.child("accounts/" + phone + "/photo_url").setValue(metadataFB?.downloadURL()?.absoluteString)
                self.userD.set(metadataFB?.downloadURL()?.absoluteString, forKey: "OwnerDownloadURL")
                
                var auxMembersInfo = self.userD.array(forKey: "MembersActiveGroup") ?? []
                if (auxMembersInfo.count == 0)
                {
                    
                }else{
                    for key in 0...auxMembersInfo.count - 1
                    {
                        let member = auxMembersInfo[key] as! [String:[String:Any]]
                        if member.first?.key == phone
                        {
                            var data = member.first?.value
                            data!["photo_url"] = metadataFB?.downloadURL()?.absoluteString
                            auxMembersInfo[key] = [phone:data]
                            self.userD.set(auxMembersInfo, forKey: "MembersActiveGroup")
                        }
                    }
                    
                }
                NotificationCenter.default.post(notification: .userDataChange)
                completion()
            } else {
                self.reference.child("accounts/" + phone + "/photo_url").setValue("")
                
                completion()
            }
        })
            
    }
    
    public func saveOwnerPhoto(photo: UIImage, phone: String){
        let imageData: Data = UIImagePNGRepresentation(photo)!
        let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let imageUrl = docUrl.appendingPathComponent(phone + ".png")
        try! imageData.write(to: imageUrl)
    }
    
    public func setMyVisibility(code: String, tel: String, visible: Bool)
    {
        reference.child("groups/" + code + "/members/" + tel + "/visibility").setValue(visible)
        userD.set(visible, forKey: "VisibleInActualGroup")
    }
    
    public func updateUserLocation(location: CLLocation)
    {
        guard let phone = self.userD.string(forKey: "OwnerPhone")
            else {return}
        guard self.userD.string(forKey: "OwnerName") != nil
            else { return }
        
        LocationServices.init().getAdress(location: location, completion: {address, error in
                let ownerGroups = self.userD.array(forKey: "OwnerGroups") as? [[String:String]] ?? []
                for code in ownerGroups {
                    self.dataExistence(search: (code.first?.key)!, type: .group , completion: { (response) in
                        if response{
                            self.reference.child("groups/" + (code.first?.key)! + "/members/" + phone + "/battery_level").setValue(batteryLevel())
                            self.reference.child("groups/" + (code.first?.key)! + "/members/" + phone + "/current_place").setValue(address)
                            self.reference.child("groups/" + (code.first?.key)! + "/members/" + phone + "/location/latitude").setValue(location.coordinate.latitude)
                            self.reference.child("groups/" + (code.first?.key)! + "/members/" + phone + "/location/longitude").setValue(location.coordinate.longitude)
                            self.reference.child("groups/" + (code.first?.key)! + "/members/" + phone + "/location/speed").setValue(location.speed.magnitude)
                        }
                    })
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
    
    public func getEmergencyContacts(){
        let telefono = self.userD.string(forKey: "OwnerPhone")!
        self.reference.child("accounts/" + telefono + "/contacts_of_emergency/").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [String:String] else { return }
            self.userD.set(value, forKey: "EmergencyContacts")
        }
    }
    
    public func getUserMail(phone: String, completion: @escaping (String) -> Void){
        self.reference.child("accounts/" + phone + "/mail").observeSingleEvent(of: .value) { (mail) in
            completion(mail.value as? String ?? "")
        }
    }
    
    public func getOwnerData(phone:String){
        reference.child("accounts/" + phone).observeSingleEvent(of: .value, with: {(snapshot) in
            let value = snapshot.value as? NSDictionary ?? [:]
            if (value.count) > 0
            {
                self.userD.set(value["name"] as! String, forKey: "OwnerName")
                self.userD.set(value["phone"] as! String, forKey: "OwnerPhone")
                let urlDownload = value["photo_url"] as? String ?? ""
                if urlDownload != ""{
                    self.getMemberPhotoFB(phone: phone)
                    self.userD.set(value["photo_url"] as! String, forKey: "OwnerDownloadURL")
                }
                let usergroupsinfo = value["user_groups"] as? NSDictionary ?? [:]
                let usergroups = usergroupsinfo["groups"] as? [String:String] ?? [:]
                var gruposAux = [[String:String]]()
                if usergroups.keys.count == 0 {
                    self.createUserGroups(name: "Mi Grupo")
                } else {
                    for key in usergroups.keys{
                        gruposAux.append([key:usergroups[key]!])
                    }
                    
                    self.userD.set(gruposAux, forKey: "OwnerGroups")
                    if self.userD.string(forKey: "ActualGroup") == nil{
                        let actualgroupc = usergroups.first?.key
                        let actualgroupn = usergroups.first?.value
                        self.userD.set(actualgroupc, forKey: "ActualGroup")
                        self.userD.set(actualgroupn, forKey: "ActualGroupTitle")
                    }
                    
                    self.getGroupMembersInfo(code: self.userD.string(forKey: "ActualGroup")!, completion: { (members) in
                        self.userD.set(members, forKey: "MembersActiveGroup")
                        self.getPlaces(group: self.userD.string(forKey: "ActualGroup")!, completion: {(list) in
                            self.userD.set(list, forKey: "ActualGroupPlaces")
                            NotificationCenter.default.post(notification: .logIn)
                            NotificationCenter.default.post(notification: .groupsChanges)
                        })
                    })
                }
            }
        })
    }
    
    private func dataExistence(search: String, type: dataType,  completion: @escaping (Bool) -> Void) {
        switch type {
        case .group:
            self.reference.child("groups/\(search)/").observeSingleEvent(of: .value, with: { (data) in
                completion(((data.value as? NSDictionary) != nil))
            })
        case .user:
            self.reference.child("acoounts/\(search)/").observeSingleEvent(of: .value, with: { (data) in
                completion(((data.value as? NSDictionary) != nil))
            })
        }
    }
    
    public func getMessageToken(phone: String, completion: @escaping (String) -> Void){
        self.reference.child("accounts/" + phone + "/FCMToken/").observeSingleEvent(of: .value, with: {(snapshot) in
            guard let value = snapshot.value as? String else {return}
            completion(value)
        })
    }
    
    public func getLastCheckIN(completion: @escaping (String, [String:Double]) -> Void){
        guard let grupo:String = self.userD.string(forKey: "ActualGroup") else {return}
        self.reference.child("groups/" + grupo + "/group_check_in/").queryLimited(toLast: 1).observeSingleEvent(of: .value, with: {(snapshot) in
            guard let value = snapshot.value as? [String:Any] else {return}
            let keys = value.keys
            let data = value[keys.first!] as! [String:Any]
            let location = data["location"] as! [String:Double]
            let checkINMSG = "\(data["user"] as! String) ha hecho checkIn en: \n \(data["address"] as! String) \n \(data["time"] as! String)"
            print(checkINMSG)
            completion(checkINMSG, location)
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
            return UIImage(named: "default.png")!
        }
    }
    
    public func getMemberPhotoFB(phone: String) {
        let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let photoURl = docUrl.appendingPathComponent(phone + ".png")
        
        if (fileMan.fileExists(atPath: photoURl.path)){
            return
        }else{
            let userPictureLocation = almacen.reference(forURL: "gs://camasacontigo.appspot.com/Waspy/")
            let userPicture = userPictureLocation.child(phone + ".png")
            
            let docUrl = try! fileMan.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let photoURl = docUrl.appendingPathComponent(phone + ".png")
            
            let atrib = try? fileMan.attributesOfFileSystem(forPath: photoURl.path)
            
            print(atrib ?? "none")
            
            userPicture.getMetadata { (metadata, error) in
                if error == nil || atrib == nil {
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
            }
        }
    }
    
    public func getAlertData(key: String, completion: @escaping ([String:Any]) -> Void){
        self.reference.child("alerts_geo/" + key).observeSingleEvent(of: .value, with: { (snapshot) in
            completion(snapshot.value as! [String:Any])
        })
    }
    
    public func getGroupMembersInfo(code: String, completion: @escaping ([[String:[String:Any]]]) ->  Void)
    {
        let id = code
        var membersGroup = [[String:[String:Any]]]()
        
        self.reference.child("groups/" + id + "/members").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? [String:[String:Any]] ?? [:]
            
            for key in value.keys
            {
                if self.userD.string(forKey: "OwnerPhone") ?? "" == key
                {
                    var banderas = [String:[String:Bool]]()
                    banderas["geoFence_Notifications"] = value[key]?["geoFence_Notifications"] as? [String : Bool]
                    self.userD.set(banderas, forKey: "NotificationFlags")
                }else{
                    self.getMemberPhotoFB(phone: key)
                }
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
        var groups = userD.array(forKey: "OwnerGroups") as! [[String:Any]]
        if kill
        {
            self.reference.child("groups/" + code).setValue(nil)
        }else{
            if groups.count == 1 {
                self.userD.set(nil, forKey: "OwnerGroups")
                self.userD.set(nil, forKey: "ActualGroupPlaces")
                self.createUserGroups(name: "Mi grupo")
            }else{
                var index = 0
                for grupo in groups
                {
                    if grupo.first?.key == code{
                        groups.remove(at: index)
                        break
                    }
                    index += 1
                }
                let newGroup = groups.first
                self.userD.set(groups, forKey: "OwnerGroups")
                self.userD.set(newGroup?.first?.key, forKey: "ActualGroup")
                self.userD.set(newGroup?.first?.value, forKey: "ActualGroupTitle")
                self.userD.set(nil, forKey: "ActualGroupPlaces")
                NotificationCenter.default.post(notification: .groupsChanges)
                self.getGroupMembersInfo(code: self.userD.string(forKey: "ActualGroup")!, completion: {(members) in
                    self.userD.set(members, forKey: "MembersActiveGroup")
                    self.setLastGroup(name: (newGroup?.first?.value)! as! String)
                })
                self.getPlaces(group: self.userD.string(forKey: "ActualGroup")!, completion: { (places) in
                    self.userD.set(places, forKey: "ActualGroupPlaces")
                })
            }
            self.reference.child("groups/" + code + "/members/" + phone).setValue(nil)
        }
        Messaging.messaging().unsubscribe(fromTopic: code + "_enter")
        Messaging.messaging().unsubscribe(fromTopic: code + "_exit")
        Messaging.messaging().unsubscribe(fromTopic: code + "_alert")
    }
}
