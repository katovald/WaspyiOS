//
//  MemberDataTableViewCell.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/18/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class MemberDataTableViewCell: UITableViewCell {
    @IBOutlet weak var admin: UISwitch!
    @IBOutlet weak var Data: UILabel!
    @IBOutlet weak var roundedPic: UIImageView!
    @IBOutlet weak var phone: UILabel!
    
    @IBOutlet weak var expelBTN: UIButton!
    
    var code:String!
    
    @IBAction func giveAdmin(_ sender: Any) {
        firebaseManager.init().setUserAdminGroup(phone: phone.text!, group: code, admin: admin.isOn)
    }
    
    @IBAction func goAway(_ sender: Any) {
        firebaseManager.init().unsuscribeGroups(code: code, phone: phone.text!, kill: false)
        let aux = UserDefaults.standard.array(forKey: "MiembrosAuxiliares") as! [[String:[String:Any]]]
        var aux2 = [[String:[String:Any]]]()
        for member in aux
        {
            if member.first?.key != phone.text!
            {
                aux2.append(member)
            }
        }
        UserDefaults.standard.set(aux2, forKey: "MiembrosAuxiliares")
        self.removeFromSuperview()
        superview?.reloadInputViews()
    }
    
    func membersInit (pic: UIImage, datos: String, phone: String, ad: Bool, adminGroup: Bool, group: String)
    {
        self.admin.transform = CGAffineTransform.init(scaleX: 0.75, y: 0.75)
        self.admin.isOn = ad
        self.Data.text = datos
        self.phone.text = phone
        self.roundedPic.image = pic
        roundedPic.layer.borderWidth = 1
        roundedPic.layer.masksToBounds = false
        roundedPic.backgroundColor = UIColor.blue
        roundedPic.layer.cornerRadius = roundedPic.frame.height/2
        roundedPic.clipsToBounds = true
        
        if !adminGroup{
            expelBTN.isHidden = true
            admin.isEnabled = false
        }
        
        if phone == UserDefaults.init().string(forKey: "OwnerPhone")
        {
            expelBTN.isHidden = true
        }
        
        code = group
    }

}
