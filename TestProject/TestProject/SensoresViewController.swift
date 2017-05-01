//
//  SensoresViewController.swift
//  TestProject
//
//  Created by Victor Hugo Martins Lisboa on 17/11/16.
//  Copyright © 2016 Victor Hugo Martins Lisboa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class SensoresViewController: UIViewController {

    @IBOutlet weak var ipTxt: UILabel!
    @IBOutlet weak var temperaturaTxt: UILabel!
    @IBOutlet weak var umidadeTxt: UILabel!
    @IBOutlet weak var alarmSwitch: UISwitch!
    @IBOutlet weak var fogoSwitch: UISwitch!
    @IBOutlet weak var fogoNvl: UILabel!
    @IBOutlet weak var gasSwitch: UISwitch!
    @IBOutlet weak var gasNvl: UILabel!
    @IBOutlet weak var presencaSwitch: UISwitch!
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        alarmView.layer.cornerRadius = alarmView.frame.size.width/2
//        fogoView.layer.cornerRadius = fogoView.frame.size.width/2
//        gasView.layer.cornerRadius = gasView.frame.size.width/2
//        presencaView.layer.cornerRadius = presencaView.frame.size.width/2
        self.navigationController?.navigationBar.tintColor = UIColor.white
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getData() {
        ref = FIRDatabase.database().reference()
        
        ref.child("alarme").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as! [String : AnyObject]
            let state = dict["state"] as! String
            if state == "OFF" {
                self.alarmSwitch.isOn = false
                self.alarmSwitch.isEnabled = false
            }
            else {
                self.alarmSwitch.isOn = true
                self.alarmSwitch.isEnabled = false
            }
        })
        ref.child("fogo").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as! [String : AnyObject]
            let state = dict["state"] as! String
            self.fogoNvl.text = dict["nivel"] as? String
            if state == "OFF" {
                self.fogoSwitch.isOn = false
                self.fogoSwitch.isEnabled = false
            }
            else {
                self.fogoSwitch.isOn = true
                self.fogoSwitch.isEnabled = false
            }
        })
        ref.child("gas").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as! [String : AnyObject]
            let state = dict["state"] as! String
            self.gasNvl.text = dict["nivel"] as? String
            if state == "OFF" {
                self.gasSwitch.isOn = false
                self.gasSwitch.isEnabled = false
            }
            else {
                self.gasSwitch.isOn = true
                self.gasSwitch.isEnabled = false
            }
        })
        ref.child("presenca").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as! [String : AnyObject]
            let state = dict["state"] as! String
            if state == "OFF" {
                self.presencaSwitch.isOn = false
                self.presencaSwitch.isEnabled = false
            }
            else {
                self.presencaSwitch.isOn = true
                self.presencaSwitch.isEnabled = false
            }
        })
        
        ref.child("ip").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as! [String : AnyObject]
            let value = dict["value"] as! String
            self.ipTxt.text = value
        })
        
        ref.child("temperatura").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as! [String : AnyObject]
            let value = dict["value"] as! String
            self.temperaturaTxt.text = value
        })
        
        ref.child("umidade").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as! [String : AnyObject]
            let value = dict["value"] as! String
            self.umidadeTxt.text = value
        })

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
