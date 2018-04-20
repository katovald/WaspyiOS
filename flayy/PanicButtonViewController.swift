//
//  PanicButtonViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 10/16/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import MessageUI
import ContactsUI
import MapKit

class PanicButtonViewController: UIViewController, CNContactPickerDelegate, MFMessageComposeViewControllerDelegate {
    
    var place:String!
    var index:Int!
    var textMessageContact = [String]()
    var street:String!
    let reachNet = Reachability()
    let userD:UserDefaults = UserDefaults.standard
    var contactos:[String:String]!
    var count = 0

    @IBOutlet weak var Contacto1: UIImageView!
    @IBOutlet weak var Contacto2: UIImageView!
    @IBOutlet weak var Contacto3: UIImageView!
    
    @IBOutlet weak var plusLess: UIImageView!
    @IBOutlet weak var plusLess2: UIImageView!
    @IBOutlet weak var plussLes3: UIImageView!
    
    @IBOutlet weak var nombreC1: UILabel!
    @IBOutlet weak var nombreC2: UILabel!
    @IBOutlet weak var nombreC3: UILabel!
    
    @IBOutlet weak var panicBtn: Rounded!
    
    @IBAction func setUnsetContact(_ sender: Any) {
        getContacts()
        if contactos["coe_one"] != nil{
            Contacto1.image = UIImage(named: "panico-avatar1.png")
            plusLess.image = UIImage(named: "panico-avatar1+.png")
            nombreC1.text = ""
            contactos["coe_one"] = nil
            if (reachNet?.isReachable)! {
                firebaseManager.init().setEmergencyContacts(contact: ["coe_one": contactos["coe_one"] as Any])
            }
        } else {
            let cnPicker = CNContactPickerViewController()
            cnPicker.delegate = self
            place = "coe_one"
            self.present(cnPicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func setUnsetContact2(_ sender: Any) {
        getContacts()
        if contactos["coe_two"] != nil {
            Contacto2.image = UIImage(named: "panico-avatar1.png")
            plusLess2.image = UIImage(named: "panico-avatar1+.png")
            contactos["coe_two"] = nil
            nombreC2.text = ""
            if (reachNet?.isReachable)! {
                firebaseManager.init().setEmergencyContacts(contact: ["coe_two": contactos["coe_two"] as Any])
            }
        } else {
            let cnPicker = CNContactPickerViewController()
            cnPicker.delegate = self
            place = "coe_two"
            self.present(cnPicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func setUnsetContact3(_ sender: Any) {
        getContacts()
        if contactos["coe_three"] != nil {
            Contacto3.image = UIImage(named: "panico-avatar1.png")
            plussLes3.image = UIImage(named: "panico-avatar1+.png")
            contactos["coe_three"] = nil
            nombreC3.text = ""
            if (reachNet?.isReachable)! {
                firebaseManager.init().setEmergencyContacts(contact: ["coe_three": contactos["coe_three"] as Any])
            }
        } else {
            let cnPicker = CNContactPickerViewController()
            cnPicker.delegate = self
            place = "coe_three"
            self.present(cnPicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func salir(_ sender: Any) {
        dismiss(animated: true) {
            self.userD.set(self.contactos, forKey: "Contactos")
        }
    }
    
    @IBAction func panico(_ sender: Any) {
        sendHelpMsg()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationServices.init().getAdress(location: CLLocationManager.init().location!) { (adreess, e) in
            if e == nil {
                self.street = adreess
            }
        }
        getContacts()
        // Do any additional setup after loading the view.
    }

    func getContacts(){
        contactos = userD.dictionary(forKey: "EmergencyContacts") as? [String : String] ?? [:]
        let keys = contactos.keys
        for key in keys {
            if key == "coe_one"{
                changeIcon(place: key, contactoName: contactos[key]!, contactoPhone: contactos[key + "_p"]!)
                textMessageContact.append(contactos[key + "_p"]!)
            }
            if key == "coe_two"{
                changeIcon(place: key, contactoName: contactos[key]!, contactoPhone: contactos[key + "_p"]!)
                textMessageContact.append(contactos[key + "_p"]!)
            }
            if key == "coe_three"{
                changeIcon(place: key, contactoName: contactos[key]!, contactoPhone: contactos[key + "_p"]!)
                textMessageContact.append(contactos[key + "_p"]!)
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let phone = (contact.phoneNumbers.first?.value)?.stringValue ?? ""
        if phone == ""
        {
            alert(message: "Ese contacto no tiene un telefono valido por favor selecciona otro")
        }else{
            if (reachNet?.isReachable)! {
                firebaseManager.init().setEmergencyContacts(contact: [place: [contact.givenName:phone]])
            }
            changeIcon(place: place, contactoName: contact.givenName, contactoPhone: phone)
        }
    }
    
    func changeIcon(place: String, contactoName: String, contactoPhone: String) {
        if place == "coe_one"{
            self.Contacto1.image = UIImage(named: "panico-avatar2.png")
            self.plusLess.image = UIImage(named: "panico-avatar2-.png")
            self.nombreC1.text = contactoName + "\r" + contactoPhone
        }
        if place == "coe_two"{
            self.Contacto2.image = UIImage(named: "panico-avatar2.png")
            self.plusLess2.image = UIImage(named: "panico-avatar2-.png")
            self.nombreC2.text = contactoName + "\r" + contactoPhone
        }
        if place == "coe_three"{
            self.Contacto3.image = UIImage(named: "panico-avatar2.png")
            self.plussLes3.image = UIImage(named: "panico-avatar2-.png")
            self.nombreC3.text = contactoName + "\r" + contactoPhone
        }
    }
    
    func sendHelpMsg(){
        if MFMessageComposeViewController.canSendText(){
            let messageCV = self.configuredMessageComposeViewController()
            present(messageCV, animated: true, completion: nil)
        }else{
            showToast(message: "No tienes habilitado el servicio de mensajes SMS")
        }
        if (reachNet?.isReachable)!
        {
            FCmNotifications.init().send(type: .panicChechIn, point: CLLocationManager.init().location!, name: nil)
        }
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        textMessageContact.removeAll()
        getContacts()
        messageComposeVC.recipients = textMessageContact
        if street != nil {
            messageComposeVC.body =  "Boton de Panico activado por " +
                self.userD.string(forKey: "OwnerName")! +
                ", cerca de " + street +
            "\r Comunicate Pronto."
        } else {
            messageComposeVC.body =  "Boton de Panico activado por " +
                self.userD.string(forKey: "OwnerName")! +
            "\r Comunicate Pronto."
        }
        return messageComposeVC
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}

extension UIViewController {
    
    func showToast(message : String) {
        
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - self.view.frame.size.width/4,
                                               y: self.view.frame.size.height-self.view.frame.size.height/5,
                                               width: self.view.frame.size.width/2,
                                               height: 35))
        toastLabel.backgroundColor = UIColor.clear
        toastLabel.textColor = UIColor.red
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        toastLabel.adjustsFontSizeToFitWidth = true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
