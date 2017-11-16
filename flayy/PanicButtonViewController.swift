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

class PanicButtonViewController: UIViewController, CNContactPickerDelegate, MFMessageComposeViewControllerDelegate {
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
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
    @IBOutlet weak var cancelAid: Rounded!
    
    @IBAction func setUnsetContact(_ sender: Any) {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        place = "coe_one"
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    var place:String!
    var activeBTN: UIButton? = nil
    var index:Int!
    var textMessageContact = [String]()
    var street:String!
    let sempahore = DispatchSemaphore(value: 0)
    
    @IBAction func setUnsetContact2(_ sender: Any) {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        place = "coe_two"
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    @IBAction func setUnsetContact3(_ sender: Any) {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        place = "coe_three"
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    @IBAction func salir(_ sender: Any) {
        dismiss(animated: true) {
            self.userD.set(self.contactos, forKey: "Contactos")
        }
    }
    
    @IBAction func panico(_ sender: Any) {
        sendHelpMsg()
    }
    
    @IBAction func cacel(_ sender: Any) {
       
    }
    
    let userD:UserDefaults = UserDefaults.standard
    var contactos:[String:String]!
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationServices.init().getAdress { (coord, speed, adreess, e) in
            if let a = adreess {
                let kilo = a["FormattedAddressLines"] as! [String]
                
                var direccion = ""
                
                for index in 0...(kilo.count - 1)
                {
                    direccion += kilo[index]
                    direccion += " "
                }
                
                self.street = direccion
            }
        }
        
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
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        print(contact)
        print(contact.givenName)
        let phone = (contact.phoneNumbers.first?.value)?.stringValue ?? ""
        if phone == ""
        {
            alert(message: "Ese contacto no tiene un telefono valido por favor selecciona otro")
        }else{
            firebaseManager.init().setEmergencyContacts(contact: [place: [contact.givenName:phone]])
            changeIcon(place: place, contactoName: contact.givenName, contactoPhone: phone)
        }
    }
    
    func changeIcon(place: String, contactoName: String, contactoPhone: String) {
        if place == "coe_one"{
            self.Contacto1.image = UIImage(named: "panico-avatar2.png")
            self.nombreC1.text = contactoName + "\r" + contactoPhone
        }
        if place == "coe_two"{
            self.Contacto2.image = UIImage(named: "panico-avatar2.png")
            self.nombreC2.text = contactoName + "\r" + contactoPhone
        }
        if place == "coe_three"{
            self.Contacto3.image = UIImage(named: "panico-avatar2.png")
            self.nombreC3.text = contactoName + "\r" + contactoPhone
        }
    }
    
    func sendHelpMsg(){
        if MFMessageComposeViewController.canSendText(){
            let messageCV = self.configuredMessageComposeViewController()
            present(messageCV, animated: true, completion: nil)
        }
        FCmNotifications.init().panicChechIn(address: street)
    }
}
