//
//  SaveConfigViewController.swift
//  SampleCoreToDo for iOS
//
//  Created by jabe0958 on 2017/09/24.
//  Copyright © 2017年 jabe0958. All rights reserved.
//

import UIKit
import CoreData
import SwiftyDropbox

class SaveConfigViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var dropboxSwitch: UISwitch!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AppDelegateSupport.isSaveDropbox() {
            dropboxSwitch.setOn(true, animated: false)
        } else {
            dropboxSwitch.setOn(false, animated: false)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions of Buttons
    
    @IBAction func dropboxSwitchValueChanged(_ sender: Any) {
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Config> = Config.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "key = %@", Constants.configKeyDropboxSet)
        var configDropboxSets: [Config]
        var configDropboxSet: Config
        do {
            configDropboxSets = try _context.fetch(fetchRequest)
        } catch {
            print("Fetching Failed.")
            return
        }
        if configDropboxSets.count == 0 {
            configDropboxSet = Config(context: _context)
        } else {
            configDropboxSet = configDropboxSets[0]
        }
        configDropboxSet.key = Constants.configKeyDropboxSet
        
        if dropboxSwitch.isOn {
            DropboxClientsManager.authorizeFromController(UIApplication.shared,
                                                          controller: self,
                                                          openURL: { (url: URL) -> Void in
                                                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            })
            if DropboxClientsManager.authorizedClient == nil {
                dropboxSwitch.setOn(false, animated: true)
                configDropboxSet.value = "0"
            } else {
                dropboxSwitch.setOn(true, animated: true)
                configDropboxSet.value = "1"
                let todoModel = ToDoJSONModel()
                todoModel.readJsonFromDropbox()
            }
        } else {
            configDropboxSet.value = "0"
        }
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    @IBAction func BackButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
