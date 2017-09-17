//
//  LoginViewController.swift
//  SampleCoreToDo for iOS
//
//  Created by jabe0958 on 2017/09/17.
//  Copyright © 2017年 jabe0958. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - View Life Cycle
    
    override func viewDidAppear(_ animated: Bool) {
        let hashedPassword = getHashedPassword()
        
        if hashedPassword == nil {
            print("HashedPassword is nil")
            performSegue(withIdentifier: "SegueEditPasswordViewController", sender: nil)
            return
        }
        print("HashedPassword : ★" + (hashedPassword)! + "★")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions of Buttons
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        let inputtedPassword = passwordTextField.text!
        
        if inputtedPassword == "" {
            alertLoginFailed()
            return
        }
        
        if CryptUtil.hashSHA256(value: inputtedPassword, salt: Constants.passwordSalt, stretching: Constants.passwordStretching) != getHashedPassword() {
            alertLoginFailed()
            return
        }
        
        performSegue(withIdentifier: "SegueLoginSuccessViewController", sender: nil)
    }
    
    // MARK: - Login Functions
    
    private func getHashedPassword() -> String? {
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        var hashedPassword: String = ""
        
        do {
            let fetchRequest: NSFetchRequest<Config> = Config.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "key = %@", Constants.configKeyPassword)
            let configPassword = try _context.fetch(fetchRequest)
            if configPassword.count == 0 {
                return nil
            }
            hashedPassword = configPassword[0].value!
        } catch {
            print("Fetch Failed.")
        }
        return hashedPassword
    }

    private func alertLoginFailed() {
        let alertController = UIAlertController(title: "パスワードが不正です。", message: "正しいパスワードを入力してください。", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            print("OK")
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
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
