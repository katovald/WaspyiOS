//
//  PlacesViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 7/19/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit

class PlacesViewController: UIViewController {
    
    @IBOutlet weak var titleBar: UINavigationBar!

    @IBAction func dismissView(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    let userD:UserDefaults = UserDefaults.standard

    var places = [[String:[String:Any]]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        places = userD.array(forKey: "ActualGroupPlaces") as? [[String:[String:Any]]] ?? []
        if places.count == 0
        {
            firebaseManager.init().getPlaces(group: userD.string(forKey: "ActualGroup")!, completion:{(lugares) in
                self.places = lugares
                self.userD.set(lugares, forKey: "ActualGroupPlaces")
            })
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension PlacesViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let name = places[indexPath.row].first?.value
        cell.textLabel?.textColor = UIColor.init(hex: 0x3871B4)
        cell.textLabel?.text = name!["place_name"] as? String
        return cell
    }
}

extension PlacesViewController: UITableViewDelegate{
    func  tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        userD.set(places[indexPath.row], forKey: "EditingPlace")
        NotificationCenter.default.post(name: NSNotification.Name("EditingPlace"), object: self)
        performSegue(withIdentifier: "configuracionLugares", sender: nil)
    }
}

