//
//  gruposSelectViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/17/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class gruposSelectViewController: UIViewController {
    
    let GroupsChangeNotification = NSNotification.Name("UserGroupsChanged")
    
    let userD:UserDefaults = UserDefaults.standard
    
    var grupos = [[String:String]]()
    
    var menuActionDelegate: MenuActionDelegate? = nil
    
    var notificationCenter:NotificationCenter = NotificationCenter.default
    
    @IBAction func closeMenu(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        grupos=userD.array(forKey: "OwnerGroups") as! [[String : String]]
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

extension gruposSelectViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grupos.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let grupo =  grupos[indexPath.row]
        cell.textLabel?.text = grupo.first?.value
        return cell
    }
}

extension gruposSelectViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion:{
            let grupoElegido = self.grupos[indexPath.row]
            self.userD.set(grupoElegido.first?.key, forKey: "ActualGroup")
            self.userD.set(grupoElegido.first?.value, forKey: "ActualGroupTitle")
            firebaseManager.init().getGroupMembersInfo()
            self.notificationCenter.post(name: self.GroupsChangeNotification, object: self)
        })
    }
}
