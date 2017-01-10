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
     
     ピンがタップされる→現在地からピンまでの経路情報(MKRoute)を取得→詳細ボタン押したときに所要時間と経路距離を出したい
     
     ↓↓↓
     
     VCのroute:MKRouteの値を一度AppDelegateに保存→ContentVCにて取得→ラベルに出力！
     
     
     
     */
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //ViewControllerから経路情報(route:MKRoute)を取得
        let routeInfo = ViewController().route
        
        //距離情報だけを取り出して格納
        let routeDistance = routeInfo?.distance
        
        //推定所要時間だけを取り出して格納
        let routeExpectedTravelTime = routeInfo?.expectedTravelTime
        
        //ラベルに文字として出力
        routeInfoLabel.text = "\(routeDistance),\(routeExpectedTravelTime)"

    }
    
}
