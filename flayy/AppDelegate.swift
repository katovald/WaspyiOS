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
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var timer:Timer!
    var timer1:Timer!
    var userD:UserDefaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        FirebaseApp.configure()
        
        GMSServices.provideAPIKey("AIzaSyCsKticH0eEpIsY-iB07Py0RFQt8nRQ1Gk")
        GMSPlacesClient.provideAPIKey("AIzaSyAwV7hbQZlFyOytB36ad81YAhlKxEw_34A")
        
        Messaging.messaging().delegate = self
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        NotificationCenter.default.addObserver(self, selector: #selector(stopMonitoring), name: NSNotification.Name("LogOut"), object: nil)
        
        if (Auth.auth().currentUser == nil){
            let aux = UIStoryboard(name: "Main", bundle: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(startMonitoring), name: NSNotification.Name("CorrectLogIn"), object: nil)
            let view = aux.instantiateViewController(withIdentifier: "inicioWOLogin") as UIViewController
            window?.rootViewController = view
        }else{
            let aux = UIStoryboard(name: "Main", bundle: nil)
            let view = aux.instantiateViewController(withIdentifier: "inicioWLogin") as UIViewController
            window?.rootViewController = view
            startMonitoring()
        }
        
        return true
    }
    
    //[INICIO DE SERVICIO]
    @objc func startMonitoring()
    {
        timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
        timer1 = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)
    }
    
    @objc func startTimer()
    {
        firebaseManager.init().updateUserLocation()
    }
    
    @objc func updateData()
    {
        let groupCode = self.userD.string(forKey: "ActualGroup") ?? ""
        if groupCode != ""{
            firebaseManager.init().getGroupMembersInfo(code: groupCode, completion: {(members) in
                self.userD.set(members, forKey: "MembersActiveGroup")
            })
        }
    }
    
    @objc func stopMonitoring()
    {
        timer.invalidate()
        timer1.invalidate()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        FCmNotifications.init().messageReceiver(message: userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage)
    }
    // This function is added here only for debugging purposes, and can be removed if swizzling is enabled.
    // If swizzling is disabled then this function must be implemented so that the APNs token can be paired to
    // the FCM registration token.
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNs token retrieved: \(deviceToken)")
        // With swizzling disabled you must set the APNs token here.
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        print("url \(url)")
        print("url host :\(url.host!)")
        print("url path :\(url.path)")
        
        
        let urlPath : String = url.path as String!
        let urlHost : String = url.host as String!
        let _: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        if(urlHost != "swiftdeveloperblog.com")
        {
            print("Host is not correct")
            return false
        }
        
        if(urlPath == "/inner"){
            
        } else if (urlPath == "/about"){
            
        }
        self.window?.makeKeyAndVisible()
        return true
    }
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler()
    }
}
// [END ios_10_message_handling]

extension AppDelegate : MessagingDelegate {
    // [START refresh_token]
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        firebaseManager.init().setUserRegToken()
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    
    // [END ios_10_data_message]
}
