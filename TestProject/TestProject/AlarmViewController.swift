//
//  AlarmViewController.swift
//  TestProject
//
//  Created by Victor Hugo Martins Lisboa on 11/11/16.
//  Copyright © 2016 Victor Hugo Martins Lisboa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class AlarmViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var ref: FIRDatabaseReference!
    @IBOutlet weak var imageView: UIImageView!

    @IBAction func onViewTapped(_ sender: UITapGestureRecognizer) {
        if imageView.image == UIImage(named: "desativado") {
            al(state: "ON")
            imageView.image = UIImage(named: "ativado")
        }
        else {
            al(state: "OFF")
            imageView.image = UIImage(named: "desativado")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        ref = FIRDatabase.database().reference()
        
        ref.child("alarme").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as! [String : AnyObject]
            let state = dict["state"] as! String
            if state == "OFF" {
                self.imageView.image = UIImage(named: "desativado")
            }
            else {
                self.imageView.image = UIImage(named: "ativado")
            }
        })
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func al(state: String) {
        let ref = FIRDatabase.database().reference()
        let post: [String: AnyObject] = ["state": state as AnyObject]
        ref.child("alarme").setValue(post)
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

