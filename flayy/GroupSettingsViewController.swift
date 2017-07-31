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
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var miembros: UITableView!
    
    var membersArray = ["Juan", "Pepe", "Kato", "Kinich", "Rodrigo", "Haza"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func resizeImage(image: UIImage, newSize: CGSize) -> UIImage {
    
    let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
    let context = UIGraphicsGetCurrentContext()
    
    // Set the quality level to use when rescaling
    context!.interpolationQuality = CGInterpolationQuality.default
    let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: newSize.height)
    
    context!.concatenate(flipVertical)
    // Draw into the context; this scales the image
    context?.draw(image.cgImage!, in: CGRect(x: 0.0,y: 0.0, width: newRect.width, height: newRect.height))
    
    let newImageRef = context!.makeImage()! as CGImage
    let newImage = UIImage(cgImage: newImageRef)
    
    // Get the resized image from the context and a UIImage
    UIGraphicsEndImageContext()
    
    return newImage
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return membersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "members")! as! MemberDataTableViewCell
        var imagenR = UIImage()
        imagenR = resizeImage(image: UIImage(named: "foto")!, newSize: CGSize(width: 70, height: 70))
        print(membersArray[indexPath.row])
        cell.membersInit(pic: imagenR, datos: membersArray[indexPath.row], admin: true)
        return cell
    }
}


