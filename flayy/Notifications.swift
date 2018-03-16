//
//  Notifications.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 3/6/18.
//  Copyright © 2018 CAMSA. All rights reserved.
//

import Foundation


enum notificationType: String {
    case userDataChange
    case groupsChanges
    case placesChanges
    case logIn
    case groupCreated
    case reachability
    case findUser
    case getPlaceData
    case findAddress
    case editPlace
    case fxCameraMap
    case alert
    case pushAlert
    case tryToPush
    case focusLost
    case helpMe
    case turnOnPush
    case placeConfig
    case finishTask
    case dataLoaded
    case deleted
}

extension NotificationCenter {
    func add(observer: Any, selector: Selector,
             notification: notificationType, object: Any? = nil) {
        addObserver(observer, selector: selector,
                    name: Notification.Name(notification.rawValue),
                    object: object)
    }
    func post(notification: notificationType,
              object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) {
        post(name: NSNotification.Name(rawValue: notification.rawValue),
             object: object, userInfo: userInfo)
    }
    func remove(observer: Any, notification: notificationType, object: Any? = nil){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(notification.rawValue), object: object)
    }
}
