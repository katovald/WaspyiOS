//
//  GroupSettingsViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/18/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import FirebaseMessaging
import FirebaseDynamicLinks

class GroupSettingsViewController: UIViewController {

    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var codigo: UILabel!
    
    @IBOutlet weak var visible: UISwitch!
    @IBOutlet weak var salida: UISwitch!
    @IBOutlet weak var share: UIButton!
    
    @IBAction func coompartir(_ sender: Any) {
        //https://s2ek9.app.goo.gl/
        let domain = "s2ek9.app.goo.gl"
        let bundleID = "com.camsa.waspy"
        let minVersion = "1.0"
        guard let deepLink = URL(string: "https://waspy.com/?groupID=" + codigo.text!) else { return }
        
        let components = DynamicLinkComponents(link: deepLink, domain: domain)
        
        let androidPKG = "com.dev.camsa.waspy"
        
        let iOSParams = DynamicLinkIOSParameters(bundleID: bundleID)
        iOSParams.minimumAppVersion = minVersion
        components.iOSParameters = iOSParams
        
        let androidParams = DynamicLinkAndroidParameters(packageName: androidPKG)
        androidParams.minimumVersion = 1
        components.androidParameters = androidParams
        
        // Or create a shortened dynamic link
        components.shorten { (shortURL, warnings, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            // TODO: Handle shortURL.
            let textMSG = "Unete a mi grupo \(self.nombre.text!) en Waspy \n"
            let textMSG1 = "\n Waspy v1.0 \nCAMSA development"
            let obj2Share = [textMSG, shortURL!, textMSG1] as [Any]
            let activity = UIActivityViewController(activityItems: obj2Share, applicationActivities: nil)
            activity.completionWithItemsHandler = { activity, success, items, error in
                if error == nil {
                    super.dismiss(animated: true, completion: nil)
                }
            }
            self.present(activity, animated: true, completion: nil)
        }
    }
    
    @IBAction func editar(_ sender: Any) {
        if edicion
        {
            editaGuarda.tintColor = UIColor.yellow
            editaGuarda.title = "Edicion"
            edicion = false
            nombre.isEnabled = false
            firebaseManager.init().changeGroupName(code: code, name: nombre.text!)
            self.dismiss(animated: true, completion: {
                firebaseManager.init().getOwnerData(phone: self.userD.string(forKey: "OwnerPhone")!)
            })
        }else{
            editaGuarda.tintColor = UIColor.init(hex: 0xEEC61B)
            editaGuarda.title = "Guardar"
            edicion = true
            nombre.isEnabled = true
        }
    }
    @IBOutlet weak var editaGuarda: UIBarButtonItem!
    
    @IBAction func getOut(_ sender: Any) {
        let grupos = userD.array(forKey: "OwnerGroups")
        let miembros = userD.array(forKey: "MiembrosAuxiliares")!
        if grupos?.count == 1 {
            alert(message: "Necesitas crear otro grupo, debes tener al menos uno")
            return
        } else {
            if adminOfGroup && admins == 1 && miembros.count > 1
            {
                alert(message: "Por favor necesitas dejar a alguien como administrador")
                return
            }else{
                if miembros.count == 1
                {
                    firebaseManager.init().unsuscribeGroups(code: code,
                                                            phone: userD.string(forKey: "OwnerPhone")!,
                                                            kill: true)
                }else{
                    firebaseManager.init().unsuscribeGroups(code: code,
                                                            phone: userD.string(forKey: "OwnerPhone")!,
                                                            kill: false)
                }
                self.dismiss(animated: true, completion:{
                    NotificationCenter.default.post(notification: .deleted)
                    let newGroup = grupos![0] as! [String:String]
                    self.userD.set(newGroup.first?.key, forKey: "ActualGroup")
                    self.userD.set(newGroup.first?.value, forKey: "ActualGroupTitle")
                    firebaseManager.init().getGroupMembersInfo(code: self.userD.string(forKey: "ActualGroup")!, completion: {(members) in
                        self.userD.set(members, forKey: "MembersActiveGroup")
                        firebaseManager.init().setLastGroup(name: (newGroup.first?.value)!)
                        firebaseManager.init().getOwnerData(phone: self.userD.string(forKey: "OwnerPhone")!)
                    })
                })
            }
        }
    }
    @IBAction func dissmisConfig(_ sender: Any) {
        self.userD.set(nil, forKey: "MiembrosAuxiliares")
        self.userD.set(nil, forKey: "CodigoGrupoAuxiliar")
        self.userD.set(nil, forKey: "NombreAuxiliar")
        self.userD.set(banderas, forKey: "NotificationFlags")
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func visibleONOFF(_ sender: UISwitch) {
        if visible.isOn
        {
            Messaging.messaging().subscribe(toTopic: code + "_enter")
        }else{
            Messaging.messaging().unsubscribe(fromTopic: code + "_enter")
        }
        
        firebaseManager.init().turnEnterNotification(code: code, OnOff: visible.isOn)
        var switches = banderas.first?.value as! [String:Bool]
        switches["geoFence_enter"] = visible.isOn
        banderas["geoFence_Notifications"] = switches
    }
    
    @IBAction func sucribeONOFF(_ sender: Any) {
        if salida.isOn
        {
            Messaging.messaging().subscribe(toTopic: code + "_exit")
        }else{
            Messaging.messaging().unsubscribe(fromTopic: code + "_exit")
        }
        firebaseManager.init().turnExitNotification(code: code, OnOff: visible.isOn)
        var switches = banderas["geoFence_Notifications"]! as! [String:Bool]
        switches["geoFence_exit"] = salida.isOn
        banderas["geoFence_Notifications"] = switches
    }
    var membersArray = [[String:[String:Any]]]()
    
    let userD:UserDefaults = UserDefaults.standard
    
    var code:String!
    var textName:String!
    var adminOfGroup:Bool!
    var admins:Int = 0
    var edicion:Bool = false
    var banderas:[String:Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        membersArray = userD.array(forKey: "MiembrosAuxiliares") as! [[String : [String : Any]]]
        for member in membersArray{
            if member.first?.key == userD.string(forKey: "OwnerPhone"){
                if member.first?.value["rol"] as? String == "admin" {
                    adminOfGroup = true
                }else{
                    adminOfGroup = false
                }
                visible.isOn = member.first?.value["visibility"] as? Bool ?? true
            }
            
            if member.first?.value["rol"] as? String == "admin"
            {
                admins += 1
            }
        }
        code = userD.string(forKey: "CodigoGrupoAuxiliar")
        textName = userD.string(forKey: "NombreAuxiliar")
        
        banderas = userD.dictionary(forKey: "NotificationFlags") ?? [:]
        if banderas.count == 0 {
            banderas = ["geoFence_Notifications" : ["geoFence_enter":true, "geoFence_exit":true]]
        }
        
        let switches = banderas.first?.value as! [String:Bool]

        self.visible.isOn = switches["geoFence_enter"] ?? true
        self.salida.isOn = switches["geoFence_exit"] ?? true
        self.codigo.text = code
        self.nombre.text = textName
        self.nombre.isEnabled = false
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
extension GroupSettingsViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return membersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "members") as! MemberDataTableViewCell
        let aux = membersArray[indexPath.row]
        let imagenR = firebaseManager.init().getMemberPhoto(phone: (aux.first?.key)!)
        let member = aux.first?.key
        let memberdata = aux[member!]
        cell.membersInit(pic: imagenR, datos: memberdata!["name"] as! String,phone: memberdata!["phone"] as! String, ad: memberdata!["rol"] as! String == "admin", adminGroup: adminOfGroup, group: code)
        return cell
    }
}
