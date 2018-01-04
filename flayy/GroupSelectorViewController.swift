//
//  GroupSelectorViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/18/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class GroupSelectorViewController: UIViewController {

    @IBAction func create(_ sender: Any) {
        let alertController = UIAlertController(title: "Grupo Nuevo", message: "Introduce el nombre de tu grupo", preferredStyle: .alert)
        let confirmation = UIAlertAction(title: "Listo", style: .default, handler: {(_) in
            let field = alertController.textFields![0]
            if field.text! != ""
            {
                firebaseManager.init().createUserGroups(name: field.text!)
                self.dismissSelector(self)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler:{(_) in
        })
        alertController.addTextField(configurationHandler: {(textfield) in
            textfield.placeholder = "Nombre"
        })
        
        alertController.addAction(confirmation)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBOutlet weak var newGroup: UIBarButtonItem!
    let userD: UserDefaults = UserDefaults.standard
    
    @IBOutlet weak var titulo: UINavigationItem!
    
    @IBAction func dismissSelector(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var gruposLista: [[String:String]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gruposLista = userD.array(forKey: "OwnerGroups") as! [[String:String]]
        titulo.title = userD.string(forKey: "ActualGroupTitle") ?? ""
        NotificationCenter.default.addObserver(self, selector: #selector(dataChanged), name: NSNotification.Name("UserGroupsChanged"), object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func dataChanged(){
        self.dismiss(animated: false, completion: nil)
    }
}

extension GroupSelectorViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gruposLista.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.textColor = UIColor.init(hex: 0x3871B4)
        cell.textLabel?.text = gruposLista[indexPath.row].first?.value
        return cell
    }
}

extension GroupSelectorViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //"detalleGrupo"
        let selectedGroup = gruposLista[indexPath.row].first?.key
        
        firebaseManager.init().getGroupMembersInfo(code: selectedGroup!, completion: {(members) in
            self.userD.set(members, forKey: "MiembrosAuxiliares")
            self.userD.set(selectedGroup, forKey: "CodigoGrupoAuxiliar")
            self.userD.set(self.gruposLista[indexPath.row].first?.value, forKey: "NombreAuxiliar")
            self.performSegue(withIdentifier: "detalleGrupo", sender: self)
        })
    }
}
