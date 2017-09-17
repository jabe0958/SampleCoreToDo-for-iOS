//
//  ViewController.swift
//  SampleCoreToDo for iOS
//
//  Created by jabe0958 on 2017/09/13.
//  Copyright © 2017年 jabe0958. All rights reserved.
//

import UIKit
import CoreData
import os.log

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Properties
    
    static let log = OSLog(subsystem: "jp.tatsudoya.macos..SampleCoreToDo-for-iOS", category: "UI")
    
    @IBOutlet weak var taskTableView: UITableView!
    
    private let segueEditTaskViewController = "SegueEditTaskViewController"
    
    // MARK: - Properties for table view
    
    var tasks:[Task] = []
    var tasksToShow:[String:[String]] = ["ToDo":[], "Shopping":[], "Assignment":[]]
    let taskCategories:[String] = ["ToDo", "Shopping", "Assignment"]
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskTableView.dataSource = self
        taskTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
        
        taskTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View Data Source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return taskCategories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return taskCategories[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksToShow[taskCategories[section]]!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = taskTableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.reuseIdentifier, for: indexPath) as? TaskTableViewCell else {
            fatalError("Unexpected Index Path")
        }
        
        let sectionData = tasksToShow[taskCategories[indexPath.section]]
        let cellData = sectionData?[indexPath.row]
        
        cell.textLabel?.text = "\(cellData!)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let deletedCategory = taskCategories[indexPath.section]
            let deletedName = tasksToShow[deletedCategory]?[indexPath.row]
            
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name =%@ and category = %@", deletedName!, deletedCategory)
            
            do {
                let task = try _context.fetch(fetchRequest)
                _context.delete(task[0])
            } catch {
                print("Fething Failed.")
            }
            
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            getData()
        }
        
        taskTableView.reloadData()
    }
    
    // MARK: - Method of Getting data from Core Data
    
    func getData() {
        os_log("getData() start.", log: ViewController.log, type: .debug)
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        do {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            tasks = try _context.fetch(fetchRequest)
            
            for key in tasksToShow.keys {
                tasksToShow[key] = []
            }
            
            for task in tasks {
                tasksToShow[task.category!]?.append(task.name!)
                let key = "testkey"
                os_log("[plain    ] ★%@★", log: ViewController.log, type: .debug, task.name!)
                let cipherText = CryptUtil.encryptAES256CBC(key: key, plainText: task.name!)
                os_log("[encrypted] ★%@★", log: ViewController.log, type: .debug, cipherText)
                os_log("[decrypted] ★%@★", log: ViewController.log, type: .debug, CryptUtil.decryptAES256CBC(key: key, cipherText: cipherText))
                os_log("", log: ViewController.log, type: .debug)
            }
        } catch {
            print("Fetching Failed.")
        }
        os_log("[hash     ] ★%@★ -> ★%@★", log: ViewController.log, type: .debug, "p@ssword!", CryptUtil.hashSHA256(value: "p@ssword!", salt: "ssaalltt", stretching: 1000))
        os_log("getData() end.", log: ViewController.log, type: .debug)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination as? AddTaskViewController else {return}
        
        let _context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if let indexPath = taskTableView.indexPathForSelectedRow, segue.identifier == segueEditTaskViewController {
            let editedCategory = taskCategories[indexPath.section]
            let editedName = tasksToShow[editedCategory]?[indexPath.row]
            
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "name = %@ and category = %@", editedName!, editedCategory)
            
            do {
                let task = try _context.fetch(fetchRequest)
                destinationViewController.task = task[0]
            } catch {
                print("Fething Failed.")
            }
        }
    }
}

