//
//  FCMNotifications.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 10/19/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import Foundation
import UserNotifications

class FCmNotifications {
    private var fcmURL:URL!
    private var content:String!
    private var key:String!
    private let userD:UserDefaults = UserDefaults.standard
    private let session = URLSession.shared
    private var request:URLRequest!
    
    init() {
        fcmURL = URL(string: "https://fcm.googleapis.com/fcm/send")
        content = "application/json"
        key = "AAAA0ZmfTw0:APA91bH7ERfyAUXMLOXqh0AW1g0hyghk9yBLHwNu2ffozcKCVE4FgS4YrwPFn1e5w3QlxxSmOx_wAkEyllbcjuJ7IAwBxXCO1YpqYjet_wbsU3MlO_lr5Zn3wXWLY5nmkyc99WBxok-b"
        request = URLRequest(url: fcmURL)
        request.httpMethod = "POST"
        request.addValue(content, forHTTPHeaderField: "Content-Type")
        request.addValue("key=" + key, forHTTPHeaderField: "Authorization")
    }
    
    public func enterGEO(){
        let message = [ "to": "/topics/" + userD.string(forKey: "ActualGroup")! + "_enter",
                        "content_available": true,
                        "priority": "high",
                        "time_to_live": 60,
                        "data" : [
                                    "type" : "geofence",
                                    "title" : "Waspy",
                                    "body" : userD.string(forKey: "OwnerPhone")! + " ha llegado",
                                    "sender" : userD.string(forKey: "OwnerPhone")!
                                ]
            ] as [String : Any]
        
        self.send(message: message)
    }
    
    private func send(message: [String:Any])
    {
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: message, options: .prettyPrinted)
        }catch let error{
            print(error.localizedDescription)
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] {
                    print(json)
                    // handle json...
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
        
        task.resume()
    }
    
    public func exitGEO(){
        let message = [ "to": "/topics/" + userD.string(forKey: "ActualGroup")! + "_exit",
                        "content_available": true,
                        "priority": "high",
                        "time_to_live": 60,
                        "data" : [
                            "type" : "geofence",
                            "title" : "Waspy",
                            "body" : userD.string(forKey: "OwnerPhone")! + " ha salido",
                            "sender" : userD.string(forKey: "OwnerPhone")!
            ]
            ] as [String : Any]
        self.send(message: message)
    }
    
    public func doChecIn(telefono: String){
        firebaseManager.init().getMessageToken(phone: telefono) { (token) in
            let message = [ "to": token,
                            "content_available":true,
                            "data": [
                                "type":"check_in_request",
                                "body": [
                                    "title":"Haz CheckIn",
                                    "body":"Alguien en tu grupo Sistemas quiere saber cómo estas"
                                ]
                            ]
                        ] as [String : Any]
         
            self.send(message: message)
        }
    }
    
    public func chechIn(address: String){
        let message = [ "to": "/topics/" + userD.string(forKey: "ActualGroup")! + "_alert",
                        "content_available":true,
                        
                        "data" : [
                            "type" : "check_in",
                            "body" : [
                                "title" : userD.string(forKey: "OwnerName")!,
                                "body" : "Ha hecho un Check In",
                                "location" : address
                                ],
                             "sender": userD.string(forKey: "OwnerPhone")!
                                ]
            ] as [String : Any]
        firebaseManager.init().saveCheckIn()
       self.send(message: message)
    }
    
    public func panicChechIn(address: String){
        let message = [ "to": "/topics/" + userD.string(forKey: "ActualGroup")! + "_alert",
                        "content_available":true,
                        "data" : [
                            "type" : "panic_button",
                            "body" : [
                                "title" : userD.string(forKey: "OwnerName")!,
                                "body" : "Ha hecho un Check In",
                                "location" : address
                            ],
                            "sender": userD.string(forKey: "OwnerPhone")!
            ]
            ] as [String : Any]
        
        self.send(message: message)
    }
    
    public func unsuscribePLS(phone: String, code: String)
    {
        firebaseManager.init().getMessageToken(phone: phone) { (token) in
            let message = [ "to": token,
                            "content_available":true,
                            "data" : [
                                "type" : "kick_out",
                                "body" : ["kickout":code]
                ]
                ] as [String : Any]
            self.send(message: message)
        }
    }
    
    public func placesUpdated(){
        let message = [ "to": "/topics/" + userD.string(forKey: "ActualGroup")! + "_message",
                        "content_available":true,
                        "data" : [
                            "type" : "update_geofences"
            ]
            ] as [String : Any]
        
        self.send(message: message)
    }
    
    func messageReceiver(message: [AnyHashable: Any]){
        let msgType = message["type"] as! String
        if msgType == "check_in_request"{
            let msgBody = message["body"] as! String
            let dict = convertToDictionary(text: msgBody)
            notify(msg: dict!["body"]! as! String, titulo: dict!["title"]! as! String)
        }
        if msgType == "geofence"
        {
            let msg = message["body"] as! String
            let title = message["title"] as! String
            let name = message["sender"] as! String
            
            if name != userD.string(forKey: "OwnerName"){
                notify(msg: msg, titulo: title)
            }
        }
        if msgType == "check_in"
        {
            let name = message["sender"] as! String
            if name != userD.string(forKey: "OwnerName"){
                let msgBody = message["body"] as! String
                let dict = convertToDictionary(text: msgBody)
                notifyExtra(msg: dict!["location"] as! String,
                            titulo: dict!["title"] as! String,
                            subtitulo: dict!["body"] as! String)
            }
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func notify(msg : String, titulo: String) {
        let content = UNMutableNotificationContent()
        content.title = titulo
        content.body = msg
        let request = UNNotificationRequest(identifier: "WaspyHabla", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func notifyExtra(msg : String, titulo: String, subtitulo:String) {
        let content = UNMutableNotificationContent()
        content.title = titulo
        content.subtitle = subtitulo
        content.body = msg
        let request = UNNotificationRequest(identifier: "WaspyHabla", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
