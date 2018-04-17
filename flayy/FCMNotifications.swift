//
//  FCMNotifications.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 10/19/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import Foundation
import UserNotifications
import MapKit

enum messageType {
    case enterGeo
    case exitGeo
    case doCheckIn
    case locationPLS
    case checkIn
    case panicChechIn
    case unsuscribePLS
    case placesUpdated
}

class FCmNotifications {
    private var fcmURL:URL!
    private var content:String!
    private var key:String!
    private let userD:UserDefaults = UserDefaults.standard
    private let session = URLSession.shared
    private var request:URLRequest!
    private var actualGroup:String {
        return userD.string(forKey: "ActualGroup") ?? ""
    }
    private var ownerName:String {
        return userD.string(forKey: "OwnerName") ?? ""
    }
    private var ownerPhone:String {
        return userD.string(forKey: "OwnerPhone") ?? ""
    }
    private var to:String!
    private var kickOutGroup:String!
    
    init() {
        fcmURL = URL(string: "https://fcm.googleapis.com/fcm/send")
        content = "application/json"
        key = "AAAA0ZmfTw0:APA91bH7ERfyAUXMLOXqh0AW1g0hyghk9yBLHwNu2ffozcKCVE4FgS4YrwPFn1e5w3QlxxSmOx_wAkEyllbcjuJ7IAwBxXCO1YpqYjet_wbsU3MlO_lr5Zn3wXWLY5nmkyc99WBxok-b"
        request = URLRequest(url: fcmURL)
        request.httpMethod = "POST"
        request.addValue(content, forHTTPHeaderField: "Content-Type")
        request.addValue("key=" + key, forHTTPHeaderField: "Authorization")
    }
    
    init(phone: String, kickOutCode: String) {
        fcmURL = URL(string: "https://fcm.googleapis.com/fcm/send")
        content = "application/json"
        key = "AAAA0ZmfTw0:APA91bH7ERfyAUXMLOXqh0AW1g0hyghk9yBLHwNu2ffozcKCVE4FgS4YrwPFn1e5w3QlxxSmOx_wAkEyllbcjuJ7IAwBxXCO1YpqYjet_wbsU3MlO_lr5Zn3wXWLY5nmkyc99WBxok-b"
        request = URLRequest(url: fcmURL)
        request.httpMethod = "POST"
        request.addValue(content, forHTTPHeaderField: "Content-Type")
        request.addValue("key=" + key, forHTTPHeaderField: "Authorization")
        to = phone
        kickOutGroup = kickOutCode
    }
    
    public func send(type: messageType, point: CLLocation?)
    {
        self.message(type: type, point: point) { (data) in
            do {
                self.request.httpBody = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
                }catch let error{
                    print(error.localizedDescription)
                }
            
                let task = self.session.dataTask(with: self.request) { (dataSession, response, error) in
                    guard error == nil else {
                        return
                    }
                
                guard let dataResponse = dataSession else {
                    return
                }
                
                do {
                    //create json object from data
                    if let json = try JSONSerialization.jsonObject(with: dataResponse, options: .mutableContainers) as? [String: AnyObject] {
                        print(json)
                        // handle json...
                    }
                    
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            
            task.resume()
        }
    }
    
    public func messageReceiver(message: [AnyHashable: Any]){
        
        guard let msgType = message["type"] as? String else {return}
        
        if msgType == "check_in_request"{
            let msgBody = message["body"] as? String ?? ""
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
            let msgBody = message["body"] as! String
            let dict = convertToDictionary(text: msgBody)
            notifyExtra(msg: dict!["location"] as! String,
                        titulo: dict!["title"] as! String,
                        subtitulo: dict!["body"] as! String)
        }
        
        if msgType == "kick_out"
        {
            print(message["body"] ?? "")
            let group = message["body"] as! String
            let dic = convertToDictionary(text: group)
            let code = dic!["kickout"] as! String
            firebaseManager.init().unsuscribeGroups(code: code,
                                                    phone: self.userD.string(forKey: "OwnerPhone")!,
                                                    kill: true)
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
        let request = UNNotificationRequest(identifier: "Waspy", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func notifyExtra(msg : String, titulo: String, subtitulo:String) {
        let content = UNMutableNotificationContent()
        content.title = titulo
        content.subtitle = subtitulo
        content.body = msg
        let request = UNNotificationRequest(identifier: "Waspy", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    private func message(type: messageType, point: CLLocation?, completion: @escaping ([String:Any]) -> Void){
        switch type {
        case .checkIn:
            LocationServices.init().getAdress(location: point!, completion: { (address, e) in
                if e == nil {
                    firebaseManager.init().saveCheckIn(point: point!)
                    completion([ "to": "/topics/\(self.actualGroup)_alert",
                        "content_available":true,
                        "data" : [
                            "type" : "check_in",
                            "body" : [
                                "title" : self.ownerName,
                                "body" : "Ha hecho un Check In",
                                "location" : address
                            ],
                            "sender": self.ownerPhone
                        ]
                        ] as [String : Any])
                }})
        case .doCheckIn:
            firebaseManager.init().getMessageToken(phone: to) { (token) in
                completion([ "to": token,
                             "content_available":true,
                             "data": [
                                "type":"check_in_request",
                                "body": [
                                    "title":"Haz CheckIn",
                                    "body":"Alguien en tu grupo Sistemas quiere saber cómo estas"
                                ]
                    ]
                    ] as [String : Any])
            }
        case .enterGeo:
            completion(["to": "/topics/\(actualGroup)_enter",
                        "content_available": true,
                        "priority": "high",
                        "time_to_live": 60,
                        "notification":[
                            "title" : "Waspy",
                            "body" : "\(ownerName) ha llegado"
                        ],
                        "data" : [
                            "type" : "geofence",
                            "title" : "Waspy",
                            "body" : "\(ownerName) ha llegado",
                            "sender" : ownerPhone
                        ]
                    ] as [String : Any])
        case .exitGeo:
            completion([ "to": "/topics/\(actualGroup)_exit",
                         "content_available": true,
                         "priority": "high",
                         "time_to_live": 60,
                         "notification":[
                            "title" : "Waspy",
                            "body" : "\(ownerName) ha llegado"
                         ],
                         "data" : [
                            "type" : "geofence",
                            "title" : "Waspy",
                            "body" : "\(ownerName) ha salido",
                            "sender" : ownerPhone
                ]
                ] as [String : Any])
        case .locationPLS:
            firebaseManager.init().getMessageToken(phone: to) { (token) in
                completion([ "to": token,
                             "content_available":true,
                             "data": [
                                "type":"whereAreYou"
                    ]
                    ]
                    as [String : Any])
            }
        case .panicChechIn:
            LocationServices.init().getAdress(location: point!, completion: { (address, e) in
                if e == nil {
                    firebaseManager.init().savePanicCall(point: point!)
                    completion([ "to": "/topics/\(self.actualGroup)_alert",
                        "content_available":true,
                        "data" : [
                            "type" : "panic_button",
                            "body" : [
                                "title" : self.ownerName,
                                "body" : "Ha pedido Ayuda",
                                "location" : address
                            ],
                            "sender": self.ownerPhone
                        ]
                        ] as [String : Any])
                }})
        case .placesUpdated:
            completion([ "to": "/topics/\(actualGroup)_message",
                         "content_available":true,
                         "data" : [
                            "type" : "update_geofences"
                ]
                ] as [String : Any])
        case .unsuscribePLS:
            firebaseManager.init().getMessageToken(phone: to) { (token) in
                completion([ "to": token,
                             "content_available":true,
                             "data" : [
                                "type" : "kick_out",
                                "body" : ["kickout":self.kickOutGroup]
                    ]
                    ] as [String : Any])
            }
        }
    }
}
