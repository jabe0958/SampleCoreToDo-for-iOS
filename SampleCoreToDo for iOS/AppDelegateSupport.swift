//
//  AppDelegateSupport.swift
//  SampleCoreToDo for iOS
//
//  Created by jabe0958 on 2017/09/18.
//  Copyright © 2017年 jabe0958. All rights reserved.
//

import Foundation
import UIKit

final class AppDelegateSupport {
    
    static private var loginViewController: UIViewController? = nil
    
    static private var beforeEnterBackgroundRootViewController: UIViewController? = nil
    
    static private var instatiatedLoginViewController = false
    
    static private var logined = false
    
    static func viewDidEnterBackground(_ window: UIWindow?) {
        loginViewController = window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "LoginViewController")
        beforeEnterBackgroundRootViewController = window?.rootViewController
        window?.rootViewController = loginViewController
        window?.makeKeyAndVisible()
    }
    
    static func getBeforeEnterBackgroundRootViewController() -> UIViewController? {
        return beforeEnterBackgroundRootViewController
    }
    
    static func login() {
        logined = true
    }
    
    static func isLogined() -> Bool {
        return logined
    }
}
