//
//  CameraViewController.swift
//  TestProject
//
//  Created by Victor Hugo Martins Lisboa on 09/11/16.
//  Copyright © 2016 Victor Hugo Martins Lisboa. All rights reserved.
//

import UIKit
import Firebase
import AVKit
import AVFoundation
import MjpegStreamingKit
import SCLAlertView

class CameraViewController: UIViewController {
    
    var ref: FIRDatabaseReference!
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var imageView: UIImageView!
    var playing = false
    
    var streamingController: MjpegStreamingController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.tintColor = UIColor.white
//        imageView.backgroundColor = UIColor.black
//        imageView.backgroundColor = UIColor(red: 227/255, green: 187/255, blue: 187/255, alpha: 1)
//        getData()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
    }
    
    func getData() {
        ref = FIRDatabase.database().reference()
        ref.child("ip").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? [String : AnyObject]
            
            let ip = dict!["value"] as! String
//            let ip = "192.168.2.2"
            self.streamingController = MjpegStreamingController(imageView: self.imageView)
            
            self.streamingController.didStartLoading = { [unowned self] in
                self.loadingIndicator.startAnimating()
            }
            self.streamingController.didFinishLoading = { [unowned self] in
                self.loadingIndicator.stopAnimating()
            }
        
            let urlString = "http://\(ip):9090/stream/video.mjpeg"
//            let urlString = "http://camera1.mairie-brest.fr/mjpg/video.mjpg?resolution=320x240"
            let url = URL(string: urlString)
//            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            
//            if !self.verifyUrl(urlString: urlString) {
                self.streamingController.contentURL = url
                self.loadingIndicator.isHidden = true
                self.streamingController.play()
//            }
//            else {
//                let alert = SCLAlertView()
//                alert.addButton("OK", target: self, selector: #selector(CameraViewController.error))
//                alert.showError("ERRO⚠️", subTitle: "A câmera não pôde ser carregada")
//            }
            
        })
    }
    
    func verifyUrl (urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    func error() {
        _ = navigationController?.popViewController(animated: true)
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
