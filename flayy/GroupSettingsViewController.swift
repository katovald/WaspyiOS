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
    @IBAction func dissmisConfig(_ sender: Any) {
        self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var miembros: UITableView!
    
    var membersArray = [[String:[String:Any]]]()
    
    let userD:UserDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        membersArray = userD.array(forKey: "MembersActiveGroup") as! [[String:[String:Any]]]
        
        // Dispose of any resources that can be recreated.
    }
    

   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
extension GroupSettingsViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return membersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! PicMemberTableViewCell
        let aux = membersArray[indexPath.row]
        let imagenR = firebaseManager.init().getMemberPhoto(phone: (aux.first?.key)!)
        let member = aux.first?.key
        let memberdata = aux[member!]
        cell.membersInit(pic: imagenR, adress: memberdata?["current_place"] as? String ?? "Buscando direccion", nombre: memberdata?["name"] as! String, battery: memberdata?["battery_level"] as? Int ?? 0, speed: 0)
        return cell
    }
}

extension GroupSettingsViewController: UITableViewDelegate{
    
}


