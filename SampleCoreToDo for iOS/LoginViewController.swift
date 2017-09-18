//
//  LoginViewController.swift
//  SampleCoreToDo for iOS
//
//  Created by jabe0958 on 2017/09/17.
//  Copyright © 2017年 jabe0958. All rights reserved.
//

import UIKit
import CoreData
import LocalAuthentication
import os.log

class LoginViewController: UIViewController {

    // MARK: - Properties
    
    static let log = OSLog(subsystem: "jp.tatsudoya.macos..SampleCoreToDo-for-iOS", category: "UI")
    
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
            AlertUtil.alertOK(viewController: self, _title: "パスワードが不正です。", _message: "正しいパスワードを入力してください。")
            return
        }
        
        if CryptUtil.hashSHA256(value: inputtedPassword, salt: Constants.passwordSalt, stretching: Constants.passwordStretching) != getHashedPassword() {
            AlertUtil.alertOK(viewController: self, _title: "パスワードが不正です。", _message: "正しいパスワードを入力してください。")
            return
        }
        
        performSegue(withIdentifier: "SegueLoginSuccessViewController", sender: nil)
    }
    
    @IBAction func touchIdButtonTapped(_ sender: Any) {
        let _context = LAContext()
        let _localizedReason = "パスワード入力の代わりにTouchIDで認証します。"
        var authError: NSError?
        
        if #available(iOS 8.0, macOS 10.12.1, *) {
            if _context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                _context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: _localizedReason, reply: { success, evaluateError in
                    if success {
                        self.performSegue(withIdentifier: "SegueLoginSuccessViewController", sender: nil)
                    } else {
                        os_log("TouchIDエラー : %@", log: LoginViewController.log, type: .error, evaluateError.debugDescription)
                    }
                })
            } else {
                AlertUtil.alertOK(viewController: self, _title: "TouchID 非対応端末です。", _message: "パスワードによる認証を行なってください。")
            }
        } else {
            AlertUtil.alertOK(viewController: self, _title: "OSバージョンエラー", _message: "TouchIDによる認証が行えるのはiOS8.0以降あるいはmacOS10.12.1以降です。")
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
