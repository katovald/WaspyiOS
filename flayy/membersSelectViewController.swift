//
//  membersSelectViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/17/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class membersSelectViewController: UIViewController{

    @IBAction func closeMenu(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var miembros:[[String:[String:Any]]]!
    var menuActionDelegate: MenuActionDelegate? = nil
    var delegate: usingMap? = nil
    
    let userD:UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miembros = userD.array(forKey: "MembersActiveGroup") as! [[String:[String:Any]]]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func delay(segundos: Double, completion:@escaping()->()){
        let tiempoVista = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * segundos)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: tiempoVista, execute: {completion()
        })
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        dismiss(animated: true, completion: {
            self.delay(segundos: 0.5, completion: {
                self.menuActionDelegate?.reopenMenu()
            })
        })
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
        cell.membersInit(pic: imagenR, adress: memberdata?["current_place"] as? String ?? "Buscando direccion", nombre: memberdata?["name"] as! String, battery: memberdata?["battery_level"] as? Int ?? 0, speed: 0)
        return cell
    }
}

extension membersSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let phone = miembros[indexPath.row].first?.key
        dismiss(animated: true, completion: {
            self.delay(segundos: 0.5, completion: {
                    self.delegate?.centerMember(phone: phone!)
                })
            })
    }
}

