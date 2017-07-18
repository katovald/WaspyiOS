//
//  dataHDLR.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/5/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import AVKit

class userDATA: NSObject {
    
    private var photo:String
    private var nombre:String
    private var grupo:NSDictionary
    private var ultimog:String
    private var userID: String
    
    init(photo: String, nombre: String, grupo: NSDictionary, ultimog: String, userID:String) {
        self.photo = photo
        self.nombre =  nombre
        self.grupo = grupo
        self.ultimog = ultimog
        self.userID = userID
    }
    
    public func getUltimog() -> String {
        return self.ultimog
    }
    
    public func setUltimog(last: String){
        self.ultimog = last
    }
    
    public func getGroups() -> NSDictionary {
        return self.grupo
    }

}
