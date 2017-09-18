//
//  AlertUtil.swift
//  SampleCoreToDo for iOS
//
//  Created by jabe0958 on 2017/09/18.
//  Copyright © 2017年 jabe0958. All rights reserved.
//

import Foundation
import UIKit

final class AlertUtil {
    
    // MARK: - Properties
    
    // none
    
    // MARK: - Constructor
    
    private init() {}
    
    // MARK: - Functions
    
    // 与えられたUIViewController上に与えあれたタイトルとメッセージでOKボタンのみの警告ダイアログを表示します。
    static public func alertOK(viewController: UIViewController, _title: String, _message: String) {
        let alertController = UIAlertController(title: _title, message: _message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            // FixMe : 何か処理を書かないと自動的にダイアログが閉じられてしまう。。。
            print("OK")
        }
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }

}
