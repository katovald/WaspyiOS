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
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFromLeft
        view.window!.layer.add(transition, forKey: "ExitGroup")
        dismiss(animated: false, completion: nil)
    }
    
    @IBOutlet weak var suscribirNuevo: Rounded!
    
    @IBAction func suscribe(_ sender: Any) {
        firebaseManager.init().subscribeUserGroups(code: codetext.text!)
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
        grupos=userD.array(forKey: "OwnerGroups") as? [[String : String]] ?? []
        
        visibleON.isOn = userD.bool(forKey: "VisibleInActualGroup")

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
        let transition = CATransition()
        transition.duration = 0.5
        transition.type = kCATransitionFade
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: "ExitMenu")
        self.dismiss(animated: false, completion:{
            let grupoElegido = self.grupos[indexPath.row]
            self.userD.set(grupoElegido.first?.key, forKey: "ActualGroup")
            self.userD.set(grupoElegido.first?.value, forKey: "ActualGroupTitle")
            firebaseManager.init().getGroupMembersInfo(code: self.userD.string(forKey: "ActualGroup")!, completion: {(members) in
                self.userD.set(members, forKey: "MembersActiveGroup")
                firebaseManager.init().setLastGroup(name: (grupoElegido.first?.value)!)
            })
            firebaseManager.init().getPlaces(group: self.userD.string(forKey: "ActualGroup")!, completion: { (places) in
                self.userD.set(places, forKey: "ActualGroupPlaces")
            })
            self.notificationCenter.post(name: self.GroupsChangeNotification, object: self)
        })
    }
}
