//
//  ControlViewController.swift
//  TestProject
//
//  Created by Victor Hugo Martins Lisboa on 31/10/16.
//  Copyright © 2016 Victor Hugo Martins Lisboa. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications
import SCLAlertView
import CoreData

class ControlViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var oldE = String()
    var newE = String()
    var newER = String()
    var oldP = String()
    var newP = String()
    var newPR = String()
    
    var e = loginSt.em
    var s = loginSt.se
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    @IBAction func change(_ sender: UIBarButtonItem) {
        let alertx = SCLAlertView()
        
        alertx.addButton("Mudar senha") { 
            let alert = SCLAlertView()
            let oldS = alert.addTextField("Senha antiga")
            oldS.isSecureTextEntry = true
            let newS = alert.addTextField("Senha nova")
            newS.isSecureTextEntry = true
            let newSR = alert.addTextField("Repita senha nova")
            newSR.isSecureTextEntry = true
            
            
            
            alert.addButton("Trocar Senha") {
                if oldS.text != self.s && oldS.text!.characters.count != 0 {
                    //                print("senha inicial errada")
                    let alert2 = SCLAlertView()
                    alert2.addButton("OK", action: {
                    })
                    alert2.showWarning("ERRO ⚠️", subTitle: "Senha antiga incorreta\nDigite novamente")
                }
                
                if newS.text != newSR.text {
                    //                print("valores diferentes")
                    let alert2 = SCLAlertView()
                    alert2.addButton("OK", action: {
                    })
                    alert2.showWarning("ERRO ⚠️", subTitle: "Senhas novas diferentes\nDigite novamente")
                }
                if oldS.text!.characters.count == 0 || newS.text!.characters.count == 0 || newSR.text!.characters.count == 0 {
                    //                print("insira algo")
                    loginSt.se = self.s
                    let alert2 = SCLAlertView()
                    alert2.addButton("OK", action: {
                    })
                    alert2.showWarning("ERRO ⚠️", subTitle: "Campo vazio\nDigite novamente")
                }
                if (newS.text!.characters.count < 6 && newS.text!.characters.count > 0) || (newSR.text!.characters.count < 6 && newSR.text!.characters.count > 0) {
                    //                print("6 digitos")
                    let alert2 = SCLAlertView()
                    alert2.addButton("OK", action: {
                    })
                    alert2.showWarning("ERRO ⚠️", subTitle: "Senha deve ter 6 digitos\nDigite novamente")
                }
                else {
                    let entityDescription = NSEntityDescription.entity(forEntityName: "Login", in: self.managedObjectContext)
                    
                    let login = Login(entity: entityDescription!, insertInto: self.managedObjectContext)
                    
                    login.email = loginSt.em
                    login.password = newS.text
                    
                    let request: NSFetchRequest<Login> = Login.fetchRequest()
                    request.entity = entityDescription
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
                    
                    do {
                        try self.managedObjectContext.execute(deleteRequest)
                        try self.managedObjectContext.save()
                        loginSt.em = ""
                        loginSt.se = ""
                    }
                    catch let error {
                        print(error.localizedDescription)
                    }
                    let user = FIRAuth.auth()?.currentUser
                    user?.updatePassword(newS.text!, completion: { (error) in
                        if (error != nil) {
                            print(error!.localizedDescription)
                        }
                        else {
                            //                        print("sucesso")
                            let alert2 = SCLAlertView()
                            alert2.addButton("OK", action: {
                            })
                            alert2.showWarning("Pronto", subTitle: "Senha trocada com sucesso")
                        }
                    })
                }
                
            }
            alert.addButton("Cancelar") {
                
            }
            alert.showWarning("Mudar senha", subTitle: "")
        }
        
        alertx.addButton("Apagar conta do dispositivo") {
            let alerty = SCLAlertView()
            alerty.addButton("Sim", action: {
                let entityDescription = NSEntityDescription.entity(forEntityName: "Login", in: self.managedObjectContext)
                
                let login = Login(entity: entityDescription!, insertInto: self.managedObjectContext)
                
                login.email = loginSt.em
                login.password = loginSt.se
                
                let request: NSFetchRequest<Login> = Login.fetchRequest()
                request.entity = entityDescription
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
                
                do {
                    try self.managedObjectContext.execute(deleteRequest)
//                    loginSt.em = ""
//                    loginSt.se = ""
                    login.email = ""
                    login.password = ""
                }
                catch let error {
                    print(error.localizedDescription)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.handleLogout()
                })
            })
            alerty.addButton("Não", action: { 
                
            })
            alerty.showWarning("Apagar Conta", subTitle: "Tem certeza disso?")
//            _ = Timer(timeInterval: 0.5, target: self, selector: #selector(ControlViewController.handleLogout), userInfo: nil, repeats: true)
        }
    
        
    
        alertx.addButton("Cancelar") {
            
        }
        
        alertx.showWarning("Configurações", subTitle: "Segurança")
//        butDel.backgroundColor = UIColor.red
    }
    
    var images = [UIImage(named: "camera"), UIImage(named: "sensor"), UIImage(named: "emergencia"), UIImage(named: "porta"), UIImage(named: "ativado")]
    
    var nomes = ["Câmera", "Status", "Emergência", "Portas", "Alarme"]
    
    var ref: FIRDatabaseReference!
    var refHandle: UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        getDataFlame()
        getDataGas()
        getDataPres()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        getData()
        //        print("email: \(loginSt.em)")
        //        print("senha: \(loginSt.se)")
        //        print(loginSt.em)
        //        print(loginSt.se)
    }
    
    func acionaAl() {
        al(state: "ON")
    }
    
    func al(state: String) {
        let ref = FIRDatabase.database().reference()
        let post: [String: AnyObject] = ["state": state as AnyObject]
        ref.child("alarme").setValue(post)
    }
    
    func bomb() {
        if let url = URL(string: "tel://989004350"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func pol() {
        if let url = URL(string: "tel://989004350"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func abreCam() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "cameraView") as! CameraViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func getDataFlame() {
        ref = FIRDatabase.database().reference()
        ref.child("fogo").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            let state = dict!["state"] as! String
            if (state == "ON") {
                //                self.getNotifFlame()
                self.getAlertFlame()
                print("FOGO!!")
            }
        })
    }
    
    func getDataGas() {
        ref = FIRDatabase.database().reference()
        ref.child("gas").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            let state = dict!["state"] as! String
            if (state == "ON") {
                //                self.getNotifGas()
                self.getAlertGas()
            }
        })
    }
    
    func getDataPres() {
        ref = FIRDatabase.database().reference()
        ref.child("presenca").observe(.value, with: { (snapshot) in
            let dict = snapshot.value as? NSDictionary
            let state = dict!["state"] as! String
            if (state == "ON") {
                //                self.getNotifPres()
                self.getAlertPres()
            }
        })
    }
    
    func getNotifFlame() {
        let content = UNMutableNotificationContent()
        content.title = "Foco de chama detectado"
        content.body = "O que deseja fazer?"
        //        content.badge = 1
        content.categoryIdentifier = "flameCat"
        content.sound = UNNotificationSound.default()
        let url = Bundle.main.url(forResource: "Images/faustao", withExtension: "gif")
        if let attachment = try? UNNotificationAttachment(identifier: "chamaQuiz", url: url!, options: nil) {
            content.attachments = [attachment]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let requestIdentifier = "chamaQuiz"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
        }
        
    }
    
    func getAlertFlame() {
        let alert = SCLAlertView()
        alert.addButton("Acionar Alarme", target: self, selector: #selector(ControlViewController.acionaAl))
        alert.addButton("Ligar Câmera", target: self, selector: #selector(ControlViewController.abreCam))
        alert.addButton("Chamar bombeiros", target: self, selector: #selector(ControlViewController.bomb))
        alert.addButton("OK", target: self, selector: #selector(ControlViewController.hide))
        alert.showWarning("Foco de incêndio", subTitle: "O que deseja fazer?")
    }
    
    
    func getNotifGas() {
        let content = UNMutableNotificationContent()
        content.title = "Nível de gás alto"
        content.body = "O que deseja fazer?"
        //        content.badge = 1
        content.categoryIdentifier = "gasCat"
        content.sound = UNNotificationSound.default()
        let url = Bundle.main.url(forResource: "Images/gas", withExtension: "gif")
        if let attachment = try? UNNotificationAttachment(identifier: "gasQuiz", url: url!, options: nil) {
            content.attachments = [attachment]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let requestIdentifier = "gasQuiz"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
        }
    }
    
    func getAlertGas() {
        let alert = SCLAlertView()
        alert.addButton("Acionar Alarme", target: self, selector: #selector(ControlViewController.acionaAl))
        alert.addButton("Ligar Câmera", target: self, selector: #selector(ControlViewController.abreCam))
        alert.addButton("Chamar bombeiros", target: self, selector: #selector(ControlViewController.bomb))
        alert.addButton("OK", target: self, selector: #selector(ControlViewController.hide))
        alert.showWarning("Vazamento de Gas", subTitle: "O que deseja fazer?")
    }
    
    func getNotifPres() {
        let content = UNMutableNotificationContent()
        content.title = "Intruso detectado"
        content.body = "O que deseja fazer?"
        //        content.badge = 1
        content.categoryIdentifier = "intruderCat"
        content.sound = UNNotificationSound.default()
        let url = Bundle.main.url(forResource: "Images/mabel", withExtension: "gif")
        if let attachment = try? UNNotificationAttachment(identifier: "intrusoQuiz", url: url!, options: nil) {
            content.attachments = [attachment]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let requestIdentifier = "intrusoQuiz"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
        }
        
    }
    
    func getAlertPres() {
        let alert = SCLAlertView()
        alert.addButton("Acionar Alarme", target: self, selector: #selector(ControlViewController.acionaAl))
        alert.addButton("Ligar Câmera", target: self, selector: #selector(ControlViewController.abreCam))
        alert.addButton("Chamar Polícia", target: self, selector: #selector(ControlViewController.pol))
        alert.addButton("OK", target: self, selector: #selector(ControlViewController.hide))
        alert.showWarning("Intruso Detectado", subTitle: "O que deseja fazer?")
    }
    
    @IBAction func Logoff(_ sender: AnyObject) {
        handleLogout()
    }
    
    func hide() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MenuCollectionViewCell
        
        cell.imgPick.image = images[indexPath.row]
        cell.lblTxt.text = nomes[indexPath.row]
        
        return cell
    }
    
    func checkIfUserIsLoggedIn() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
            handleLogout()
        }
        else {
            let uid = FIRAuth.auth()?.currentUser?.uid
            FIRDatabase.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = dictionary["name"] as? String
                }
                
            }, withCancel: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: "cam", sender: self)
        }
        else if indexPath.row == 1 {
            performSegue(withIdentifier: "sens", sender: self)
        }
        else if indexPath.row == 2 {
            performSegue(withIdentifier: "emer", sender: self)
        }
        else if indexPath.row == 3 {
            performSegue(withIdentifier: "port", sender: self)
        }
        else {
            performSegue(withIdentifier: "alar", sender: self)
        }
        
    }
    
    func handleLogout() {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch let logoutError {
            print(logoutError)
        }
        self.dismiss(animated: true, completion: nil)
        //        let loginController = LoginViewController()
        //        present(loginController, animated: true, completion: nil)
        
    }
    
    
}

//extension ControlViewController: UNUserNotificationCenterDelegate {
//
//    func flame(state: String) {
//        let ref = FIRDatabase.database().reference()
//        let post: [String: AnyObject] = ["state": state as AnyObject]
//        ref.child("fogo").setValue(post)
//    }
//
//    func gas(state: String) {
//        let ref = FIRDatabase.database().reference()
//        let post: [String: AnyObject] = ["state": state as AnyObject]
//        ref.child("gas").setValue(post)
//    }
//
//    func pres(state: String) {
//        let ref = FIRDatabase.database().reference()
//        let post: [String: AnyObject] = ["state": state as AnyObject]
//        ref.child("presenca").setValue(post)
//    }
//
//    func al(state: String) {
//        let ref = FIRDatabase.database().reference()
//        let post: [String: AnyObject] = ["state": state as AnyObject]
//        ref.child("alarme").setValue(post)
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//        print("User Info: \(notification.request.content.userInfo)")
//        completionHandler([.sound, .alert, .badge])
//
//    }
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        print("User Info: \(response.notification.request.content.userInfo)")
//        completionHandler()
//
//        switch response.actionIdentifier {
//        case "alarme":
//            al(state: "ON")
//        case "camera":
//            print("camera")
//        case "policia":
//            let url = URL(string: "tel://989004350")
//            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//        case "bombeiro":
//            let url = URL(string: "tel://989004350")
//            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
//        default:
//            break
//        }
//    }
//}

extension UIView
{
    func searchVisualEffectsSubview() -> UIVisualEffectView?
    {
        if let visualEffectView = self as? UIVisualEffectView
        {
            return visualEffectView
        }
        else
        {
            for subview in subviews
            {
                if let found = subview.searchVisualEffectsSubview()
                {
                    return found
                }
            }
        }
        
        return nil
    }
}
