//
//  GroupSettingsViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/18/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class GroupSettingsViewController: UIViewController {
    @IBAction func inicioReturn(_ sender: Any) {
        
    }
    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var codigo: UILabel!
    @IBAction func dissmisConfig(_ sender: Any) {
        self.userD.set(nil, forKey: "MiembrosAuxiliares")
        self.userD.set(nil, forKey: "CodigoGrupoAuxiliar")
        self.userD.set(nil, forKey: "NombreAuxiliar")
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    var membersArray = [[String:[String:Any]]]()
    
    let userD:UserDefaults = UserDefaults.standard
    
    var code:String!
    var textName:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        membersArray = userD.array(forKey: "MiembrosAuxiliares") as! [[String : [String : Any]]]
        code = userD.string(forKey: "CodigoGrupoAuxiliar")
        textName = userD.string(forKey: "NombreAuxiliar")
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
        cell.membersInit(pic: imagenR, datos: memberdata!["name"] as! String,phone: memberdata!["phone"] as! String, admin: memberdata!["rol"] as! String == "admin")
        return cell
    }
}

extension GroupSettingsViewController: UITableViewDelegate{
    
}


