//
//  AppDelegate.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 6/30/17.
//  Copyright © 2017 Jose Katzuo Valdez Carmona. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        //npi que va aqui
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Messaging.messaging().delegate = self as MessagingDelegate
        
        if #available(iOS 10.0, *)
        {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions,
                                                                    completionHandler: {_,_ in})
            Messaging.messaging().delegate = self
        }else {
            let settings = UIUserNotificationSettings(types:[.alert,.badge,.sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()

        GMSServices.provideAPIKey("AIzaSyCsKticH0eEpIsY-iB07Py0RFQt8nRQ1Gk")
        GMSPlacesClient.provideAPIKey("AIzaSyDRB6xIV_O1rX_bvc_3BzWfUp0yooLwSD0")
        
        if (Auth.auth().currentUser == nil){
            let aux = UIStoryboard(name: "Main", bundle: nil)
            let view = aux.instantiateViewController(withIdentifier: "inicioWOLogin") as UIViewController
            window?.rootViewController = view
        }else{
            let aux = UIStoryboard(name: "Main", bundle: nil)
            let view = aux.instantiateViewController(withIdentifier: "inicioWLogin") as UIViewController
            window?.rootViewController = view
        }
        return true
    }
    
    //[INICIO DE SERVICIO]
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        //if let messageID = userInfo[gcmMessageIDKey] {
          //  print("Message ID: \(messageID)")
        //}
        
        // Print full message.
        //print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        //if let messageID = userInfo[gcmMessageIDKey] {
          //  print("Message ID: \(messageID)")
        //}
        
        // Print full message.
        //print(userInfo)
        
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(UIBackgroundFetchResult.noData)
            return
        }
    }
    // [END receive_message]
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //print("APNs token retrieved: \(deviceToken)")
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("updated")
    }
}
