//
//  PortaViewController.swift
//  TestProject
//
//  Created by Victor Hugo Martins Lisboa on 09/11/16.
//  Copyright © 2016 Victor Hugo Martins Lisboa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class PortaViewController: UIViewController {
    
    @IBOutlet weak var banSwitch: UISwitch!
    @IBOutlet weak var cozSwitch: UISwitch!
    @IBOutlet weak var quaSwitch: UISwitch!
    @IBOutlet weak var salaSwitch: UISwitch!
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        banSwitch.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        cozSwitch.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        quaSwitch.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        salaSwitch.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        getBan()
        getCoz()
        getQua()
        getSala()
        
        // Do any additional setup after loading the view.
    }
    
    func getBan() {
        ref = FIRDatabase.database().reference()
        ref.child("portas").child("banheiro").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? [String : AnyObject]
            
            let porta = dict!["state"] as! String
            
            if (porta == "ON") {
                self.banSwitch.isOn = true
            }
            else {
                self.banSwitch.isOn = false
            }
        })
    }
    
    func getCoz() {
        ref = FIRDatabase.database().reference()
        ref.child("portas").child("cozinha").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? [String : AnyObject]
            
            let porta = dict!["state"] as! String
            
            if (porta == "ON") {
                self.cozSwitch.isOn = true
            }
            else {
                self.cozSwitch.isOn = false
            }
        })
    }

    func getQua() {
        ref = FIRDatabase.database().reference()
        ref.child("portas").child("quarto").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? [String : AnyObject]
            
            let porta = dict!["state"] as! String
            
            if (porta == "ON") {
                self.quaSwitch.isOn = true
            }
            else {
                self.quaSwitch.isOn = false
            }
        })
    }
    
    func getSala() {
        ref = FIRDatabase.database().reference()
        ref.child("portas").child("sala").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? [String : AnyObject]
            
            let porta = dict!["state"] as! String
            
            if (porta == "ON") {
                self.salaSwitch.isOn = true
            }
            else {
                self.salaSwitch.isOn = false
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func banSwitch(_ sender: UIButton) {
        if banSwitch.isOn == false {
            ban(state: "ON")
            banSwitch.isOn = true
        }
        else {
            ban(state: "OFF")
            banSwitch.isOn = true
        }
    }
    
    @IBAction func cozSwitch(_ sender: UIButton) {
        if cozSwitch.isOn == false {
            coz(state: "ON")
            cozSwitch.isOn = true
        }
        else {
            coz(state: "OFF")
            cozSwitch.isOn = true
        }
    }
    
    @IBAction func quaSwitch(_ sender: UIButton) {
        if quaSwitch.isOn == false {
            qua(state: "ON")
            quaSwitch.isOn = true
        }
        else {
            qua(state: "OFF")
            quaSwitch.isOn = true
        }
    }
    
    @IBAction func salaSwitch(_ sender: UIButton) {
        if salaSwitch.isOn == false {
            sala(state: "ON")
            salaSwitch.isOn = true
        }
        else {
            sala(state: "OFF")
            salaSwitch.isOn = true
        }
    }
    
    func ban(state: String) {
        let ref = FIRDatabase.database().reference()
        let post: [String: AnyObject] = ["state": state as AnyObject]
        ref.child("portas").child("banheiro").setValue(post)
    }
    
    func coz(state: String) {
        let ref = FIRDatabase.database().reference()
        let post: [String: AnyObject] = ["state": state as AnyObject]
        ref.child("portas").child("cozinha").setValue(post)
    }
    
    func qua(state: String) {
        let ref = FIRDatabase.database().reference()
        let post: [String: AnyObject] = ["state": state as AnyObject]
        ref.child("portas").child("quarto").setValue(post)
    }
    
    func sala(state: String) {
        let ref = FIRDatabase.database().reference()
        let post: [String: AnyObject] = ["state": state as AnyObject]
        ref.child("portas").child("sala").setValue(post)
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
