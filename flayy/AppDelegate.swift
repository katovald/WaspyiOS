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
import CoreLocation
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        //npi que va aqui
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
    }
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var timer:Timer!
    var background: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
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
        
        if (Auth.auth().currentUser == nil){
            let aux = UIStoryboard(name: "Main", bundle: nil)
            let view = aux.instantiateViewController(withIdentifier: "inicioWOLogin") as UIViewController
            window?.rootViewController = view
        }else{
            let aux = UIStoryboard(name: "Main", bundle: nil)
            let view = aux.instantiateViewController(withIdentifier: "inicioWLogin") as UIViewController
            window?.rootViewController = view
        }
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
        
        return true
    }
    
    //[INICIO DE SERVICIO]
    
    @objc func startTimer()
    {
        firebaseManager.init().updateUserLocation()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
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
        //print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Auth.auth().setAPNSToken(deviceToken, type: .unknown)
        // With swizzling disabled you must set the APNs token here.
        // Messaging.messaging().apnsToken = deviceToken
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        
    }
    
    func handleEvent(forRegion region: CLRegion!){
        print("Geofence Triggered!")
    }
}

extension AppDelegate: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion{
            handleEvent(forRegion: region)
        }
    }
}
