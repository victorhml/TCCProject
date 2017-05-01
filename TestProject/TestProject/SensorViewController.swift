//
//  SensorViewController.swift
//  TestProject
//
//  Created by Victor Hugo Martins Lisboa on 09/11/16.
//  Copyright © 2016 Victor Hugo Martins Lisboa. All rights reserved.
//

import UIKit
import Firebase

struct stateStruct {
    let state: String!
}

class SensorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    let sensores = ["Alarme", "Fogo", "Gás", "IP", "Presença", "Temperatura", "Umidade"]
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    var list = [stateStruct]()
    var arr = [String]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        // Do any additional setup after loading the view.
//        let i = 0;
//        while (i == 0) {
//            getData()
//        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        _ = Timer.init(timeInterval: 0.5, target: self, selector: #selector(time), userInfo: nil, repeats: true)
    }
    
    func time() {
        let i = 0
        while (i == 0) {
            getData()
        }
    }
    
    func getData() {
        ref = FIRDatabase.database().reference()

        ref.observe(.childAdded, with: {
            (snapshot: FIRDataSnapshot) in
            let dict = snapshot.value as! [String: AnyObject]
            let state = dict["state"] as! String
            self.list.insert(stateStruct(state: state), at: 0)
            self.arr.append(state)
            DispatchQueue.main.async(execute: { 
                self.tableView.reloadData()
            })
            print("VETOR")
            print(self.arr)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SensorTableViewCell
        cell.nomeSensor.text = sensores[indexPath.row]
        cell.textState.text = arr[indexPath.row]
        return cell
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
