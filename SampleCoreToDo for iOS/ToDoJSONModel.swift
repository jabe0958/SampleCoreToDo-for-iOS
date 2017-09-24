//
//  ToDoJSONModel.swift
//  SampleCoreToDo for iOS
//
//  Created by jabe0958 on 2017/09/23.
//  Copyright © 2017年 jabe0958. All rights reserved.
//

import Foundation
import SwiftyDropbox

class ToDoJSONModel {
    
    // MARK: - Properties
    
    // MARK: - Constructors
    
    public init() {
    }
    
    // MARK: - Model Functions
    
    public func getToDos() -> [String:[String]] {
        var tasksToShow:[String:[String]] = ["ToDo":[], "Shopping":[], "Assignment":[]]
        
        var jsonData: Data
        var jsonObjects: NSArray
        
        var jsonString: String = ""
        do {
            if AppDelegateSupport.isSaveDropbox() {
                readJsonFromDropbox()
            }
            jsonString = try String(contentsOf: getJsonFilePath()!, encoding: .utf8)
        } catch {
            print("Reading JSON file is Failed.")
            return tasksToShow
        }
        let decryptedJsonString = CryptUtil.decryptAES256CBC(key: AppDelegateSupport.getHashedLoginPassword(), cipherText: jsonString)
        jsonData = decryptedJsonString.data(using: .utf8)!
        
        do {
            jsonObjects = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! NSArray
        } catch {
            print("Parsing JSON is Failed.")
            return tasksToShow
        }
        
        for key in tasksToShow.keys {
            tasksToShow[key] = []
        }
        
        for jsonObject in jsonObjects {
            let taskJson = jsonObject as! Dictionary<String, String>
            tasksToShow[taskJson["category"]!]?.append(taskJson["name"]!)
        }
        
        return tasksToShow
    }
    
    public func readJsonFromDropbox() {
        let destURL = getJsonFilePath()
        let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
            return destURL!
        }
        let client = DropboxClientsManager.authorizedClient
        client!.files.download(path: "/" + Constants.jsonFileName, overwrite: true, destination: destination)
            .response { response, error in
                //                        if let response = response {
                //                            print(response)
                //                        } else if let error = error {
                //                            print(error)
                //                        }
            }
            .progress { progressData in
                //                        print(progressData)
        }
    }
    
    public func getToDo(category: String, name: String) throws -> Task? {
        
        let tasksToShow = getToDos()
        
        for taskName in tasksToShow[category]! {
            if taskName == name {
                let task:Task = Task()
                task.category = category
                task.name = name
                return task
            }
        }
        
        return nil
    }
    
    public func updateToDo(editedCategory: String, editedName: String, originalName: String?) throws {

        var tasksToShow = getToDos()
        
        if originalName != nil {
            if tasksToShow[editedCategory]!.contains(originalName!) {
                let index = tasksToShow[editedCategory]!.index(of: originalName!)
                tasksToShow[editedCategory]![index!] = editedName
            }
        } else {
            tasksToShow[editedCategory]!.append(editedName)
        }
        
        let jsonTaskArray = convertDictionaryArray(fromNextedArray: tasksToShow)
        
        try saveJson(jsonObject: jsonTaskArray)
    }
    
    public func deleteToDo(deletedCategory: String, deletedName: String) throws {
        
        var tasksToShow = getToDos()
        
        if tasksToShow.keys.contains(deletedCategory) {
            if (tasksToShow[deletedCategory]?.contains(deletedName))! {
                let index = tasksToShow[deletedCategory]!.index(of: deletedName)
                tasksToShow[deletedCategory]!.remove(at: index!)
                let jsonTaskArray = convertDictionaryArray(fromNextedArray: tasksToShow)
                try saveJson(jsonObject: jsonTaskArray)
            }
        }
    }
    
    public func reencrypt(newPassword: String) throws {
        let jsonTaskArray = convertDictionaryArray(fromNextedArray: getToDos())
        try saveJson(jsonObject: jsonTaskArray, password: newPassword)
    }
    
    private func saveJson(jsonObject: Array<Any>) throws {
        try saveJson(jsonObject: jsonObject, password: AppDelegateSupport.getHashedLoginPassword())
    }
    
    private func saveJson(jsonObject: Array<Any>, password: String) throws {
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        let jsonStr = String(bytes: jsonData, encoding: .utf8)
        let encryptedJsonStr = CryptUtil.encryptAES256CBC(key: password, plainText: jsonStr!)
        let path_file_name = getJsonFilePath()!
        do {
            try encryptedJsonStr.write(to: path_file_name, atomically: false, encoding: .utf8)
        } catch {
            print("Write Failed.")
        }
        if AppDelegateSupport.isSaveDropbox() {
            saveJsonToDropbox(encryptedJsonStr: encryptedJsonStr)
        }
        
    }
    
    private func saveJsonToDropbox(encryptedJsonStr: String) {
        let client = DropboxClientsManager.authorizedClient
        let encryptedJsonData = encryptedJsonStr.data(using: .utf8, allowLossyConversion: false)!
        client!.files.upload(path: "/" + Constants.jsonFileName, mode: .overwrite, input: encryptedJsonData)
            .response { response, error in
//                if let response = response {
//                    print(response)
//                } else if let error = error {
//                    print(error)
//                }
            }
            .progress { progressData in
//                print(progressData)
        }
    }
    
    private func getJsonFilePath() -> URL? {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let jsonFilePath = dir.appendingPathComponent(Constants.jsonFileName)
            print(jsonFilePath)
            return jsonFilePath
        }
        return nil
    }
    
    private func convertDictionaryArray(fromNextedArray: [String:[String]]) -> Array<Any> {
        var dictionaryArray = Array<Any>()
        
        for category in fromNextedArray.keys {
            for name in fromNextedArray[category]! {
                var task = Dictionary<String, String>()
                task["category"] = category
                task["name"] = name
                dictionaryArray.append(task)
            }
        }
        
        return dictionaryArray
    }
}
