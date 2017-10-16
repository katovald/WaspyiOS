//
//  Notifications.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 10/13/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import FirebaseMessaging

class Notifications: NSObject {

    func checkIn(topic:String, name: String, address: String){
        _ = "{\"to\":\"/topics/" + topic + "\",\"notification\":{\"title\":\"title\",\"body\":\"text\" }}"

        _ = URL(string: "https://fcm.googleapis.com/fcm/send")
        
//        let con =
//            (HttpURLConnection) url.openConnection();
//        con.setDoInput(true);
//        con.setDoOutput(true);
//        con.setInstanceFollowRedirects(true);
//        con.setRequestMethod("POST");
//
//        con.setRequestProperty("Content-Type","application/json");
//        con.setRequestProperty("Authorization","key=AIzaSyB70J***-z34q2_h*******qjZsM5zBIf8Y"); //I've added stars :-)
//        con.setRequestProperty("Content-Type","application/x-www-form-urlencoded");
//        con.setRequestProperty("Content-Type","charset=UTF-8");
//        con.setRequestProperty("Content-Length",Integer.toString(postDataLength));
//
//        con.setUseCaches(false);
//
//        DataOutputStream wr = new DataOutputStream(con.getOutputStream());
//        wr.write(postData);
//
//        InputStream inputStream= con.getInputStream();
//        BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));
//        String line = null;
//        String outPut = "";
//        while (((line = reader.readLine()) != null)){
//            outPut += line;
//        }
    }
}
