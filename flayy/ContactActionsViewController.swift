//
//  ContactActionsViewController.swift
//  flayy
//
//  Created by Jose Katzuo Valdez Carmona on 12/14/17.
//  Copyright © 2017 CAMSA. All rights reserved.
//

import UIKit
import MessageUI

class ContactActionsViewController: UIViewController, MFMessageComposeViewControllerDelegate {

    var contactPhone:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func call(_ sender: Any) {
        guard let number = URL(string: "tel://" + contactPhone) else { return }
        UIApplication.shared.open(number)
        self.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func sms(_ sender: Any) {
        if MFMessageComposeViewController.canSendText(){
            let messageCV = self.configuredMessageComposeViewController()
            present(messageCV, animated: true, completion: nil)
        }else{
            showToast(message: "No tienes habilitado el servicio de mensageria SMS")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func touchOutside(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        messageComposeVC.recipients = [contactPhone]
        return messageComposeVC
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: {
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    @IBAction func checkIN(_ sender: Any) {
        FCmNotifications.init(phone: contactPhone, kickOutCode: "").send(type: .doCheckIn, point: nil)
        self.dismiss(animated: false, completion: nil)
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
