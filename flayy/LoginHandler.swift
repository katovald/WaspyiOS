//
//  LoginHandler.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 2/27/18.
//  Copyright © 2018 CAMSA. All rights reserved.
//

import Foundation
import LocalAuthentication
import FirebaseAuth
import Security

struct KeychainConfiguration {
    static let serviceName = "Waspy"
    
    /*
     Specifying an access group to use with `KeychainPasswordItem` instances
     will create items shared accross both apps.
     
     For information on App ID prefixes, see:
     https://developer.apple.com/library/ios/documentation/General/Conceptual/DevPedia-CocoaCore/AppID.html
     and:
     https://developer.apple.com/library/ios/technotes/tn2311/_index.html
     */
    //    static let accessGroup = "[YOUR APP ID PREFIX].com.example.apple-samplecode.GenericKeychainShared"
    
    /*
     Not specifying an access group to use with `KeychainPasswordItem` instances
     will create items specific to each app.
     */
    static let accessGroup: String? = nil
}

public class LogingAttemps {
    private var password:String?
    private var email:String?
    private var errorCode:String?
    private var phone:String?
    
    let userD:UserDefaults = UserDefaults.standard
    
    init(contra: String, correo: String, telefono: String) {
        password = contra
        email = correo
        phone = telefono
    }
    
    init() {
        if UserDefaults.standard.string(forKey: "OwnerPhone") != nil {
            self.phone = UserDefaults.standard.string(forKey: "OwnerPhone")
        }
    }

    public func passwordAttempt(completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email!, password: password!) { (user, e) in
            if e == nil {
                self.storeKeys(completion: { (_) in
                    
                })
                completion(true)
            }else{
                self.message(error: AuthErrorCode(rawValue: e!._code)! , completion: { (message) in
                    self.errorCode = message
                    completion(false)
                })
            }
        }
    }
    
    public func fingerPrintAttempt(completion: @escaping (Bool) -> Void) {
        getKeys { (gotIt) in
            if gotIt {
                self.userD.set(self.phone, forKey: "OwnerPhone")
                self.userD.set(self.email, forKey:"OwnerMail")
                Auth.auth().signIn(withEmail: self.email!, password: self.password!) { (user, e) in
                    if e == nil {
                        completion(true)
                    }else{
                        self.message(error: AuthErrorCode(rawValue: e!._code)! , completion: { (message) in
                            self.errorCode = message
                        })
                        completion(false)
                    }
                }
            }else{
                self.errorCode = "Aun no has iniciado sesion en este telefono tienes que usar tu telefono y contraseña"
                completion(false)
            }
        }
    }
    
    public func registerAttempt(completion: @escaping (Bool) -> Void){
        Auth.auth().createUser(withEmail: email!, password: password!) { (user, e) in
            if e == nil {
                self.storeKeys(completion: { (_) in
                    
                })
                completion(true)
            }else{
                self.message(error: AuthErrorCode(rawValue: e!._code)! , completion: { (message) in
                    self.errorCode = message
                    completion(false)
                })
            }
        }
    }
    
    public func changeMail(completion: @escaping (Bool) -> Void) {
        Auth.auth().currentUser?.updateEmail(to: email!, completion: { (e) in
            self.userD.set(self.email, forKey:"OwnerMail")
        })
    }
    
    public func tell() -> String {
        return errorCode!
    }
    
    private func storeKeys(completion: @escaping (Bool) -> Void) {
        // Check that text has been entered into both the account and password fields.
        if (self.phone?.isEmpty)! && (self.password?.isEmpty)!
        {
            completion(false)
        }

        // This is a new account, create a new keychain item with the account name.
        let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName, account: self.phone!, accessGroup: KeychainConfiguration.accessGroup)
                
                // Save the password for the new item.
        do {
            try passwordItem.savePassword(self.password!)
        }
        catch {
            completion(false)
        }
        completion(true)
    }
    
    private func getKeys(completion: @escaping (Bool) -> Void) {
        if let account = self.phone {
            do {
                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                        account: account,
                                                        accessGroup: KeychainConfiguration.accessGroup)
                self.phone = passwordItem.account
                self.password = try passwordItem.readPassword()
                firebaseManager.init().getUserMail(phone: self.phone!, completion: { (mail) in
                    self.email = mail
                    completion(true)
                })
            }
            catch {
                completion(false)
            }
        }else{
            completion(false)
        }
    }
    
    private func message(error: AuthErrorCode,completion: @escaping (String) -> Void){
        switch error {
        case .invalidEmail:
            completion("Por favor puedes revisar tu correo, creemos que puede tener un error")
        case .operationNotAllowed:
            completion("Hubo un error, por favor comunicate a soporte")
        case .userDisabled:
            completion("Tu cuenta se encuentra dada de baja, por favor comunicate con soporte")
        case .wrongPassword:
            completion("Revisa tu contraseña, creemos que tiene un error")
        case .emailAlreadyInUse:
            completion("Este correo ya dispone de una cuenta en Waspy")
        case .weakPassword:
            completion("Por favor intenta crear una contraseña mas robusta")
        case .keychainError:
            completion("Existe un error en tu telefono")
        case .requiresRecentLogin:
            completion("Por favor vuelve a iniciar sesion")
        case .userNotFound:
            completion("No hemos localizado el correo proporcionado")
        default:
            completion("Algo fallo...")
        }
    }
}
