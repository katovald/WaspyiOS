//
//  membersSelectViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/17/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import FirebaseDynamicLinks

protocol ActionMenuDelegate {
    func presentActions(phoneNumber: String)
}

class membersSelectViewController: UIViewController{

    @IBAction func closeMenu(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBAction func CloseBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var lastCheck: UILabel!
    @IBOutlet weak var membersTable: UITableView!
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBAction func sharing(_ sender: Any) {
        //https://app_code.app.goo.gl/apple-app-site-association
        //https://s2ek9.app.goo.gl/ 
    }
    
    var miembros:[[String:[String:Any]]]!
    
    let userD:UserDefaults = UserDefaults.standard
    var checkIn:String = ""
    
    let notificationObserver = NotificationCenter.default
    let solicitudUsuarios = Notification.Name("UserAsked")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miembros = userD.array(forKey: "MembersActiveGroup") as? [[String:[String:Any]]] ?? []
        checkIn = userD.string(forKey: "LastCheckIn") ?? ""
        if checkIn == "" {
            lastCheck.isHidden = true
        }
        shareBtn.layer.cornerRadius = 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func updateTableData()
    {
        //TODO search for real time view
        //
    }
    
    func delay(segundos: Double, completion:@escaping()->()){
        let tiempoVista = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * segundos)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: tiempoVista, execute: {completion()
        })
    }
    
    @IBAction func actionMenu(_ sender: UIButton) {
        let member = miembros[sender.tag]
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ContactsActions") as! ContactActionsViewController
        vc.contactPhone = member.first?.key
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil)
    }
    
}

extension membersSelectViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return miembros.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PicMemberTableViewCell
        let aux = miembros[indexPath.row]
        let imagenR = firebaseManager.init().getMemberPhoto(phone: (aux.first?.key)!)
        let member = aux.first?.key
        let memberdata = aux[member!]
        cell.membersInit(pic: imagenR, adress: memberdata?["current_place"] as? String ?? "Buscando direccion", nombre: memberdata?["name"] as? String ?? "", battery: memberdata?["battery_level"] as? Int ?? 0, speed: 0, visible: memberdata?["visibility"] as? Bool ?? true, telefono: (aux.first?.key)!)
        cell.plusBtn.tag = indexPath.row
        cell.plusBtn.addTarget(self, action: #selector(actionMenu(_:)), for: .touchUpInside)
        return cell
    }
}

extension membersSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = miembros[indexPath.row].first?.value
        let visibility = data!["visibility"] as? Bool ?? true
        if visibility{
            self.userD.set(data, forKey: "UserAsked")
            self.dismiss(animated: true, completion: {
                self.notificationObserver.post(name: self.solicitudUsuarios, object: self)
            })
        }else{
            self.dismiss(animated: true, completion: {
                self.alert(message: "El usuario no esta comparitendo su ubicacion, solicitale un check in")
            })
        }
    }
}


