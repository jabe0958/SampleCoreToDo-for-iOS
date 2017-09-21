//
//  ToDoModel.swift
//  SampleCoreToDo for iOS
//
//  Created by jabe0958 on 2017/09/21.
//  Copyright © 2017年 jabe0958. All rights reserved.
//

import Foundation
import CoreData

class ToDoModel {
    
    // MARK: - Properties
    
    private var _context: NSManagedObjectContext
    
    // MARK: - Constructors
    
    public init(context: NSManagedObjectContext) {
        _context = context
    }
    
    // MARK: - Model Functions
    
    public func getToDos() -> [String:[String]] {
        var tasks:[Task] = []
        var tasksToShow:[String:[String]] = ["ToDo":[], "Shopping":[], "Assignment":[]]
        
        do {
            let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
            tasks = try _context.fetch(fetchRequest)
            
            for key in tasksToShow.keys {
                tasksToShow[key] = []
            }
            
            for task in tasks {
                tasksToShow[task.category!]?.append(task.name!)
            }
        } catch {
            print("Fetching Failed.")
        }
        return tasksToShow
    }
    
    public func getToDo(category: String, name: String) throws -> Task? {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name = %@ and category = %@", name, category)
        
        let task = try _context.fetch(fetchRequest)
        if task.count > 0 {
            return task[0]
        } else {
            return nil
            
        }
    }
    
    public func updateToDo(task: Task?, editedCategory: String, editedName: String) throws {
        var _task: Task
        if task == nil {
            _task = Task(context: _context)
        } else {
            _task = task!
        }
        
        _task.name = editedName
        _task.category = editedCategory

        try _context.save()
    }
    
    public func deleteToDo(deletedCategory: String, deletedName: String) throws {
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "name =%@ and category = %@", deletedName, deletedCategory)
        
        let task = try _context.fetch(fetchRequest)
        _context.delete(task[0])
        
        try _context.save()
    }
}
