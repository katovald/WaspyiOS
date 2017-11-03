//
//  PanicButtonViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 10/16/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import ContactsUI

class PanicButtonViewController: UIViewController, CNContactPickerDelegate {

    @IBOutlet weak var Contacto1: UIImageView!
    @IBOutlet weak var Contacto2: UIImageView!
    @IBOutlet weak var Contacto3: UIImageView!
    
    @IBOutlet weak var nombreC1: UILabel!
    @IBOutlet weak var nombreC2: UILabel!
    @IBOutlet weak var nombreC3: UILabel!
    
    @IBAction func setUnsetContact(_ sender: Any) {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        self.index = 0
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    var activeBTN: UIButton? = nil
    var index:Int!
    
    @IBAction func setUnsetContact2(_ sender: Any) {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    @IBAction func setUnsetContact3(_ sender: Any) {
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    @IBAction func salir(_ sender: Any) {
        dismiss(animated: true) {
            self.userD.set(self.contactos, forKey: "Contactos")
        }
    }
    
    let userD:UserDefaults = UserDefaults.standard
    var contactos = [[String:String](),[String:String](),[String:String]()]
    var count = 0
    var contacto = [String:String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let contactos = userD.array(forKey: "Contactos") ?? []

        for _ in contactos
        {
            if count == 0
            {
                self.Contacto1.image = UIImage(named: "panico-avatar2.png")
            }
            if count == 1
            {
                self.Contacto2.image = UIImage(named: "panico-avatar2.png")
            }
            if count == 2
            {
                self.Contacto2.image = UIImage(named: "panico-avatar2.png")
            }
            count = 0
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
            alert(message: "Ese contato no tiene un telefono valido por favor selecciona otro")
        }else{
            self.contacto[contact.givenName] = phone
            if self.index == 0{
                self.nombreC1.text = (self.contacto.first?.key)! + "\r" + (self.contacto.first?.value)!
                self.contactos[0] = self.contacto
            }
            if self.index == 1{
                self.nombreC2.text = (self.contacto.first?.key)! + "\r" + (self.contacto.first?.value)!
                self.contactos[1] = self.contacto
                    //            let pic = contacto.imageData
                    //            if pic == nil {
                    //
                    //            }
            }
            if self.index == 2{
                self.nombreC2.text = (self.contacto.first?.key)! + "\r" + (self.contacto.first?.value)!
                self.contactos[1] = self.contacto
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
