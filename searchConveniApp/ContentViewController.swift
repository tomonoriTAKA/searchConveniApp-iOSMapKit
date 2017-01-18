//
//  ContentViewController.swift
//  searchConveniApp
//
//  Created by 高橋知憲 on 2017/01/04.
//  Copyright © 2017年 高橋知憲. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ContentViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var routeInfoLabel: UILabel!
    
    
    /*
     
     ピンがタップされる
     →現在地からピンまでの経路情報(MKRoute)を取得
     →詳細ボタン押したときに所要時間と経路距離を出したい
    
     */
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //ContentViewControllerが表示されるたびによばれる（表示の直前に処理）
    override func viewWillAppear(_ animated: Bool) {
        //AppDelegateを読み込む
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        //AppDelegateからrouteInfoを呼び出し経路情報をラベルに表示
        routeInfoLabel.text = "目的地まで\((appDelegate.routeInfo?.distance)!/1000.0)km\n自動車で\(Int((appDelegate.routeInfo?.expectedTravelTime)!/60))分"
    }
    
    
    
    
}
