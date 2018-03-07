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

struct Section {
    var name: ParamTypes
    var items: [Params]
    var collapsed: Bool
    
    init(name: ParamTypes, items: [Params], collapsed: Bool = true) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }
}

enum Params: String {
    case link = "Link Value"
    case source = "Source"
    case medium = "Medium"
    case content = "Content"
    case bundleID = "App Bundle ID"
    case fallbackURL = "Fallback URL"
    case minimumAppVersion = "Minimum App Version"
    case customScheme = "Custom Scheme"
    case appStoreID = "AppStore ID"
    case affiliateToken = "Affiliate Token"
    case campaignToken = "Campaign Token"
    case providerToken = "Provider Token"
    case packageName = "Package Name"
    case androidFallbackURL = "Android Fallback URL"
    case minimumVersion = "Minimum Version"
    case title = "Title"
    case descriptionText = "Description Text"
    case imageURL = "Image URL"
    case otherFallbackURL = "Other Platform Fallback URL"
}

enum ParamTypes: String {
    case iOS = "iOS"
    case iTunes = "iTunes Connect Analytics"
    case android = "Android"
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
        //https://s2ek9.app.goo.gl/
        let code = self.userD.string(forKey: "ActualGroup")!
        let domain = "s2ek9.app.goo.gl"
        let bundleID = "com.camsa.waspy"
        let minVersion = "1.0"
        guard let deepLink = URL(string: "https://waspy.com/?groupID=" + code) else { return }

        print(deepLink)
        
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
            let textMSG = "Unete a mi grupo \(self.userD.string(forKey: "ActualGroupTitle") ?? "") en Waspy \n"
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
    
    var miembros:[[String:[String:Any]]]!
    
    let userD:UserDefaults = UserDefaults.standard
    var checkIn:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        miembros = userD.array(forKey: "MembersActiveGroup") as? [[String:[String:Any]]] ?? []
        firebaseManager.init().getLastCheckIN { (texto, location) in
            print(texto)
        }
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
                NotificationCenter.default.post(notification: .findUser)
            })
        }else{
            self.dismiss(animated: true, completion: {
                self.alert(message: "El usuario no esta comparitendo su ubicacion, solicitale un check in")
            })
        }
    }
}


