//
//  LoginViewController.swift
//  TestProject
//
//  Created by Victor Hugo Martins Lisboa on 31/10/16.
//  Copyright © 2016 Victor Hugo Martins Lisboa. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import LocalAuthentication
import SCLAlertView
import MessageUI
import CoreData

struct loginSt {
    static var em = String()
    static var se = String()
}

class LoginViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var x = 0
    let i = 1
    
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var senhaText: UITextField!
    
    @IBOutlet weak var logoImg: UIImageView!
    
    @IBOutlet weak var digitalButton: UIButton!
    
    @IBAction func cadastro(_ sender: UIButton) {
        
        getAlertCadastro()
    }
    
    func getAlertCadastro() {
        let alert = SCLAlertView()
        alert.addButton("Cadastrar", target: self, selector: #selector(LoginViewController.sendEmail))
        alert.addButton("Cancelar", target: self, selector: #selector(LoginViewController.hide))
        alert.showWarning("Cadastro", subTitle: "À princípio o cadastro está limitado, mande o seu email para nós, caso já possua, clique em Cancelar")
    }
    
    func sendEmail() {
        let emailIOT = "iot.sec2@gmail.com"
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([emailIOT])
            mail.setSubject("Cadastro")
            mail.setMessageBody("<p>Olá, eu gostaria de me cadastrar no IOT Security</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    func hide() {
        //        self.authenticateUser()
    }
    
    @IBAction func forgotPass(_ sender: UIButton) {
        let alert = SCLAlertView()
        let recEm = alert.addTextField("Digite seu email")
        alert.addButton("Enviar") {
            FIRAuth.auth()?.sendPasswordReset(withEmail: recEm.text!, completion: { (error) in
                if error != nil {
//                    print("Não foi possível")
                    let alert2 = SCLAlertView()
                    alert2.addButton("OK", action: {
                    })
                    alert2.showWarning("Não foi possível", subTitle: "")
                }
                else {
                    let alert3 = SCLAlertView()
                    alert3.addButton("OK", action: {
                    })
                    alert3.showWarning("1º Passo concluído", subTitle: "Um email foi enviado para você")
                }
            })
            
        }
        alert.addButton("Cancelar") { 
        }
        alert.showWarning("Recuperar senha", subTitle: "")
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func touchIDAvailable() -> Bool {
        let context = LAContext()
        var error: NSError? = nil
        
        if (context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)) {
            return true
        }
        else {
            return false
        }
    }
    
    @IBAction func digital(_ sender: UIButton) {
        self.authenticateUser()
    }
    
    func changeColor() {
        if (emailText.text == loginSt.em && senhaText.text == loginSt.se) {
            emailText.backgroundColor = UIColor(red: 250/255, green: 254/255, blue: 192/255, alpha: 1)
            senhaText.backgroundColor = UIColor(red: 250/255, green: 254/255, blue: 192/255, alpha: 1)
            
        }
        if (emailText.text != loginSt.em || senhaText.text != loginSt.se || emailText.text == "" || senhaText.text == "") {
            emailText.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            senhaText.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //        self.authenticateUser()
        
        loadData()
//        senhaText.text = ""
        _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(LoginViewController.changeColor), userInfo: nil, repeats: true)
        
        if !touchIDAvailable() || (loginSt.em == "" && loginSt.se == "") {
            self.digitalButton.isHidden = true
        }
            
        else {
//            self.authenticateUser()
            self.digitalButton.isHidden = false
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        setLoad()
        login()
    }
    
    func setLoad() {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Login", in: managedObjectContext)
        
        let login = Login(entity: entityDescription!, insertInto: managedObjectContext)
        
        login.email = emailText.text!
        login.password = senhaText.text!
        
        let request: NSFetchRequest<Login> = Login.fetchRequest()
        request.entity = entityDescription
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request as! NSFetchRequest<NSFetchRequestResult>)
        
        do {
            try managedObjectContext.execute(deleteRequest)
            try managedObjectContext.save()
//            emailText.text = ""
//            senhaText.text = ""
        }
        catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    func loadData() {
        
        let entityDescription = NSEntityDescription.entity(forEntityName: "Login", in: managedObjectContext)
        
        let request: NSFetchRequest<Login> = Login.fetchRequest()
        request.entity = entityDescription
        
        //        let pred = NSPredicate(format: "(name = %@)", name.text!)
        //        request.predicate = pred
        
        do {
            var results = try managedObjectContext.fetch(request as! NSFetchRequest<NSFetchRequestResult>)
            
            if results.count > 0 {
                let match = results[results.count-1] as! NSManagedObject
                emailText.text = match.value(forKey: "email") as? String
                senhaText.text = match.value(forKey: "password") as? String
                loginSt.em = emailText.text!
                loginSt.se = senhaText.text!
                //                loginSt.init(em: emailText.text!, se: senhaText.text!)
                x = 1
                //                print(match.value(forKey: "name")!)
            }
            else {
                print("No Match")
            }
            
        }
        catch let error {
            print(error.localizedDescription)
        }
        
    }
    
    func login() {
        
        if self.emailText.text == "" || self.senhaText.text == "" {
            let alert = SCLAlertView()
            alert.addButton("OK", target: self, selector: #selector(LoginViewController.hide))
            alert.showWarning("Oops!", subTitle: "Por favor insira um email e senha válidos")
        }
        else {
            FIRAuth.auth()?.signIn(withEmail: self.emailText.text!, password: self.senhaText.text!, completion: { (user, error) in
                if error == nil {
                    //                    self.emailText.text = self.em
                    //                    self.senhaText.text = self.se
                    //                    print("Sucesso")
                    self.performSegue(withIdentifier: "segue", sender: nil)
                }
                else {
                    let alert = SCLAlertView()
                    alert.addButton("OK", target: self, selector: #selector(LoginViewController.hide))
                    alert.showWarning("Oops!", subTitle: "Usuário e/ou senha inválido(s)")
                }
            })
            
        }
    }
    func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        let reasonString = "Você precisa se logar ao app"
        
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success, policyError) in
                if success {
                    //                    print("Sucesso")
                    FIRAuth.auth()?.signIn(withEmail: loginSt.em, password: loginSt.se, completion: { (user, error) in
                        if error == nil {
                            //                    self.emailText.text = self.em
                            //                    self.senhaText.text = self.se
                            //                    print("Sucesso")
                            self.performSegue(withIdentifier: "segue", sender: nil)
                        }
                        else {
                            let alert = SCLAlertView()
                            alert.addButton("OK", target: self, selector: #selector(LoginViewController.hide))
                            alert.showWarning("Oops!", subTitle: "Usuário e/ou senha inválido(s)")
                        }
                    })
                    //                    self.performSegue(withIdentifier: "segue", sender: nil)
                }
                else {
                    let pe = policyError! as NSError
                    switch pe.code {
                    case LAError.systemCancel.rawValue:
                        print("Sistema cancelou")
                    case LAError.userCancel.rawValue:
                        print("Usuario cancelou")
                    case LAError.userFallback.rawValue:
                        print("Usuario prefere senha")
                        OperationQueue.main.addOperation({
                            //                                self.dismiss(animated: true, completion: nil)
                        })
                    default:
                        print("Falhou")
                        OperationQueue.main.addOperation({
                            //                            self.dismiss(animated: true, completion: nil)
                        })
                    }
                }
            })
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
