//
//  PasswordViewController.swift
//  SampleCoreToDo for iOS
//
//  Created by jabe0958 on 2017/09/17.
//  Copyright © 2017年 jabe0958. All rights reserved.
//

import UIKit
import CoreData

class PasswordViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var repeatNewPasswordTextField: UITextField!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("[PasswordViewController] viewDidLoad() end.")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions of Buttons

    @IBAction func registButtonTapped(_ sender: Any) {
        let newPassword = newPasswordTextField.text!
        let repeatNewPassword = repeatNewPasswordTextField.text!
        if !validatePassword(newPassword: newPassword, repeatNewPassword: repeatNewPassword) {
            return
        }
        
        do {
            let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<Config> = Config.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "key = %@", Constants.configKeyPassword)
            let configPasswords = try _context.fetch(fetchRequest)
            
            var configPassword: Config? = nil
            if configPasswords.count == 0 {
                configPassword = Config(context: _context)
                configPassword?.key = Constants.configKeyPassword
            } else {
                configPassword = configPasswords[0]
            }
            configPassword?.value = CryptUtil.hashSHA256(value: newPassword, salt: Constants.passwordSalt, stretching: Constants.passwordStretching)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        } catch {
            print("Fetching Failed.")
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Methods for Validation

    // 新しいパスワードの検証を行います。
    private func validatePassword(newPassword: String, repeatNewPassword: String) -> Bool {
        if newPassword == "" {
            alertValidated(message: "新しいパスワードが入力されていません。")
            return false
        }
        if repeatNewPassword == "" {
            alertValidated(message: "確認用パスワードが入力されていません。")
            return false
        }
        if newPassword != repeatNewPassword {
            alertValidated(message: "新しいパスワードと確認用パスワードが一致していません。")
            return false
        }
        if newPassword.utf8.count < Constants.passwordMinimumLength {
            alertValidated(message: "新しいパスワードは " +  "\(Constants.passwordMinimumLength)" + " 文字以上である必要があります。")
            return false
        }
        
        return true
    }
    
    // 検証エラーの警告ダイアログを表示します。
    private func alertValidated(message: String) {
        let alertController = UIAlertController(title: "入力したパスワードに誤りがあります", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            // FixMe : 何か処理を書かないと自動的にダイアログが閉じられてしまう。。。
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
