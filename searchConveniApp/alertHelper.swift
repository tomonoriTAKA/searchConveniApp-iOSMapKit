//
//  alertHelper.swift
//  searchConveniApp
//
//  Created by 高橋知憲 on 2016/12/21.
//  Copyright © 2016年 高橋知憲. All rights reserved.
//

import Foundation
import UIKit

class AlertHelper {
    func showAlert(fromController controller: UIViewController ,title:String, message: String) {
        var searchAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //アラートのアクションを定義
        let OkAction:UIAlertAction = UIAlertAction(title: "OK", style: .default){action in
            
            print("action OK")
        }
        
        //アラートコントローラーにアクションを追加
        searchAlertController.addAction(OkAction)

        
        
        controller.present(searchAlertController, animated: true, completion: nil)
    }
}

