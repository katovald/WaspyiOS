//
//  gruposSelectViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/17/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class gruposSelectViewController: UIViewController {
    
    let netReached = Reachability()
    
    let userD:UserDefaults = UserDefaults.standard
    @IBOutlet weak var ownerGroup: UILabel!
    @IBOutlet weak var create: UIButton!
    
    var grupos = [[String:String]]()
    
    @IBAction func closeMenu(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: "ExitGroup")
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func swipeClose(_ sender: Any) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: "ExitGroup")
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func create(_ sender: Any) {
        if (netReached?.isReachable)! {
            let alertController = UIAlertController(title: "Grupo Nuevo", message: "Introduce el nombre de tu grupo", preferredStyle: .alert)
            let confirmation = UIAlertAction(title: "Listo", style: .default, handler: {(_) in
                let field = alertController.textFields![0]
                if field.text! != ""
                {
                    self.dismiss(animated: false, completion: {
                        firebaseManager.init().createUserGroups(name: field.text!)
                    })
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
        }else{
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @IBOutlet weak var suscribirNuevo: Rounded!
    /*
})*/
    @IBAction func suscribe(_ sender: Any) {
        firebaseManager.init().subscribeUserGroups(code: codetext.text!)
        dismiss(animated: true) {
            NotificationCenter.default.post(notification: .groupsChanges)
        }
    }
    
    @IBOutlet weak var codetext: UITextField!
    @IBOutlet weak var visibleON: UISwitch!
    
    @IBAction func visibleONOFF(_ sender: Any) {
        firebaseManager.init().setMyVisibility(code: userD.string(forKey: "ActualGroup")!,
                                               tel: userD.string(forKey: "OwnerPhone")!,
                                               visible: visibleON.isOn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        suscribirNuevo.isEnabled = false
        codetext.delegate = self
        grupos=userD.array(forKey: "OwnerGroups") as? [[String : String]] ?? []
        
        visibleON.isOn = userD.bool(forKey: "VisibleInActualGroup")

        codetext.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func textChanged(_ textfield: UITextField){
        if (textfield.text?.count == 6){
            firebaseManager.init().isGroupExists(code: textfield.text!, completion: { (finded, owner) in
                if finded {
                    self.ownerGroup.text = "Te uniras al Grupo de\n" + owner
                    self.suscribirNuevo.isEnabled = true
                    self.view.endEditing(true)
                }else{
                    self.ownerGroup.text = "Grupo no encontrado o ya estas suscrito"
                }
            })
        }else{
            self.ownerGroup.text = ""
            self.suscribirNuevo.isEnabled = false
        }
    }
    
    func delay(segundos: Double, completion:@escaping()->()){
        let tiempoVista = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * segundos)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: tiempoVista, execute: {completion()
        })
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}

extension gruposSelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grupos.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let grupo =  grupos[indexPath.row]
        cell.textLabel?.text = grupo.first?.value
        cell.textLabel?.textColor = UIColor.init(hex: 0x3871B4)
        return cell
    }
}

extension gruposSelectViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (netReached?.isReachable)! {
            let transition = CATransition()
            transition.duration = 0.5
            transition.type = kCATransitionFade
            transition.subtype = kCATransitionFromRight
            view.window!.layer.add(transition, forKey: "ExitMenu")
            let grupoElegido = self.grupos[indexPath.row]
            self.userD.set(grupoElegido.first?.key, forKey: "ActualGroup")
            self.userD.set(grupoElegido.first?.value, forKey: "ActualGroupTitle")
            self.userD.set(nil, forKey: "ActualGroupPlaces")
            firebaseManager.init().getGroupMembersInfo(code: self.userD.string(forKey: "ActualGroup")!, completion: {(members) in
                self.userD.set(members, forKey: "MembersActiveGroup")
                firebaseManager.init().setLastGroup(name: (grupoElegido.first?.value)!)
            })
            firebaseManager.init().getPlaces(group: self.userD.string(forKey: "ActualGroup")!, completion: { (places) in
                self.userD.set(places, forKey: "ActualGroupPlaces")
            })
        
            self.dismiss(animated: false, completion:{
                NotificationCenter.default.post(notification: .groupsChanges)
            })
        }else{
            self.dismiss(animated: false, completion:nil)
        }
    }
}

extension gruposSelectViewController: UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 6
    }
}
