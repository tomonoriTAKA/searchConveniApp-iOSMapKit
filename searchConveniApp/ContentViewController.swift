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
    
    var routeInfo = ViewController().route
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let routeDistance = routeInfo?.distance
        let routeExpectedTravelTime = routeInfo?.expectedTravelTime
        if (routeDistance != nil && routeExpectedTravelTime != nil){
//        routeInfoText.text = String("現在地から\(Int(routeDistance!/1000))km,所要時間(自動車で)\(Int(routeExpectedTravelTime!/60))分")
        }
    }


}
