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
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        
    }
    
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    var timer:Timer!
    var timer1:Timer!
    var background: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var userD:UserDefaults = UserDefaults.standard
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey("AIzaSyCsKticH0eEpIsY-iB07Py0RFQt8nRQ1Gk")
        GMSPlacesClient.provideAPIKey("AIzaSyAwV7hbQZlFyOytB36ad81YAhlKxEw_34A")
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        FirebaseApp.configure()

        NotificationCenter.default.addObserver(self, selector: #selector(startMonitoring), name: NSNotification.Name("CorrectLogIn"), object: nil)
        
        if (Auth.auth().currentUser == nil){
            let aux = UIStoryboard(name: "Main", bundle: nil)
            let view = aux.instantiateViewController(withIdentifier: "inicioWOLogin") as UIViewController
            window?.rootViewController = view
        }else{
            let aux = UIStoryboard(name: "Main", bundle: nil)
            let view = aux.instantiateViewController(withIdentifier: "inicioWLogin") as UIViewController
            window?.rootViewController = view
        }
        
        let token = Messaging.messaging().fcmToken
        print("FCM token: \(token ?? "")")
        return true
    }
    
    //[INICIO DE SERVICIO]
    @objc func startMonitoring()
    {
        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(startTimer), userInfo: nil, repeats: true)
        timer1 = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)
    }
    
    @objc func startTimer()
    {
        firebaseManager.init().updateUserLocation()
    }
    
    @objc func updateData()
    {
        firebaseManager.init().getGroupMembersInfo(code: self.userD.string(forKey: "ActualGroup")!, completion: {(members) in
            self.userD.set(members, forKey: "MembersActiveGroup")
        })
    }
    
    func BGtask(_ block: @escaping () -> Void){
        DispatchQueue.global(qos: .default).async(execute: block)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        BGtask {
            firebaseManager.init().updateUserLocation()
        }
    }
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
}

extension AppDelegate: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {

    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
    }
}
