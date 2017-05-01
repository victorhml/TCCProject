//
//  EmergenciaViewController.swift
//  TestProject
//
//  Created by Victor Hugo Martins Lisboa on 09/11/16.
//  Copyright © 2016 Victor Hugo Martins Lisboa. All rights reserved.
//

import UIKit

class EmergenciaViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    let images = [UIImage(named: "police"), UIImage(named: "samu"), UIImage(named: "bomb")]
    
    let nomes = ["Polícia", "Paramédicos", "Bombeiros"]
    
    let numeros = ["190", "192", "193"]
    
    let fake = "989004350"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EmergenciaTableViewCell
        cell.imgPick.image = images[indexPath.row]
        cell.nome.text = nomes[indexPath.row]
        cell.numero.text = numeros[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let url = URL(string: "tel://\(numeros[indexPath.row])"), UIApplication.shared.canOpenURL(url) {
        if let url = URL(string: "tel://\(fake)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
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
