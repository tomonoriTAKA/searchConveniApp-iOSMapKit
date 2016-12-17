//
//  ViewController.swift
//  searchConveniApp
//
//  Created by 高橋知憲 on 2016/12/12.
//  Copyright © 2016年 高橋知憲. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

extension MKPlacemark {
    var address: String {
        let components = [self.administrativeArea, self.locality, self.thoroughfare, self.subThoroughfare]
        return components.flatMap { $0 }.joined(separator: "")
    }
}


// CLLocationManagerDelegateを継承しなければならない
class ViewController: UIViewController, UISearchBarDelegate,CLLocationManagerDelegate,MKMapViewDelegate {
    
    @IBOutlet weak var conveniMapView: MKMapView! = MKMapView() //マップ生成
    @IBOutlet weak var destSearchBar: UISearchBar! //検索バー
    @IBOutlet weak var trackingButton: UIBarButtonItem! // トラッキングのボタン
    @IBOutlet weak var userLocation: UITextField!
    
    
    // 現在地の位置情報の取得にはCLLocationManagerを使用
    var lm: CLLocationManager!
    
    // 取得した現在地の緯度を保持するインスタンス
    var userLatitude: CLLocationDegrees!
    // 取得した現在地の経度を保持するインスタンス
    var userLongitude: CLLocationDegrees!
    
    //任意のピンを刺した位置の緯度経度を保持するインスタンス
    var pinLatitude: CLLocationDegrees!
    var pinLongitude: CLLocationDegrees!
    
    //立てるピンのインスタンス
    
    //長押しで立てるピン
    var myPin: MKPointAnnotation!
    
    
    //ユーザーの現在地に立てるピン
    var userPin: MKPointAnnotation!
    
    var routeRenderer:MKPolylineRenderer?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // フィールドの初期化
        lm = CLLocationManager()
        userLatitude = CLLocationDegrees()
        userLongitude = CLLocationDegrees()
        
        //立てたピンの緯度経度の初期化
        pinLatitude = CLLocationDegrees()
        pinLongitude = CLLocationDegrees()
        
        
        
        conveniMapView.frame = self.view.frame
        
        
        //デリゲート先に自分を設定する。
        conveniMapView.delegate = self
        
        // CLLocationManagerをDelegateに指定
        lm.delegate = self
        
        //サーチバーのデリゲートを自分に設定
        destSearchBar.delegate = self
        
        // 位置情報取得の許可を求めるメッセージの表示．必須．
        lm.requestWhenInUseAuthorization()
        // 位置情報の精度を指定．任意，
        lm.desiredAccuracy = kCLLocationAccuracyKilometer
        // 位置情報取得間隔を指定．指定した値（メートル）移動したら位置情報を更新する．任意．
        lm.distanceFilter = 1000.0
        
        
        // GPSの使用を開始する
        lm.startUpdatingLocation()
        
        //スケールを表示する
        conveniMapView.showsScale = true
        
        // 長押しのUIGestureRecognizerを生成.
        let myLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer()
        myLongPress.addTarget(self, action: #selector(ViewController.recognizeLongPress(sender:)))
        
        // MapViewにUIGestureRecognizerを追加.
        conveniMapView.addGestureRecognizer(myLongPress)
        
    }
    
    
    
    /*
     長押しを感知した際に呼ばれるメソッド.
     */
    func recognizeLongPress(sender: UILongPressGestureRecognizer) {
        
        // 長押しの最中に何度もピンを生成しないようにする.
        if sender.state != UIGestureRecognizerState.began {
            return
        }
        
        // 長押しした地点の座標を取得.
        let location = sender.location(in: conveniMapView)
        
        // locationをCLLocationCoordinate2Dに変換.
        let myCoordinate: CLLocationCoordinate2D = conveniMapView.convert(location, toCoordinateFrom: conveniMapView)
        
        //長押しした地点＝ピンを刺す地点の緯度経度を変数に格納
        pinLatitude = myCoordinate.latitude
        pinLongitude = myCoordinate.longitude
        
        // ピンを生成.（長押し時のもの）
        myPin = MKPointAnnotation()
        
        // 座標を設定.
        myPin.coordinate = myCoordinate
        
        // MARK: - 日本語の文字列はplistや別クラスで定義管理するとなお良い
 
        
        // タイトルを設定.
        myPin.title = "国名"
        
        // サブタイトルを設定.（緯度経度を表示）
        myPin.subtitle = "latitude: \(pinLatitude!) , longitude: \(pinLongitude!)"
        
        //MapViewにピンを追加.
        conveniMapView.addAnnotation(myPin)
        
        //ピンの情報を取得
        self.reverseGeocord(latitude: pinLatitude, longitude: pinLongitude, myPin: myPin)
    }
    
    /*
     addAnnotationした際に呼ばれるデリゲートメソッド.
     */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation === mapView.userLocation {
            // 現在地を示すアノテーションの場合はデフォルトのまま
            
            //現在地のタイトルをnilにすることでコールアウトを非表示にする
            (annotation as? MKUserLocation)?.title = nil
            
            return nil
            
            
        } else {
    
            let identifier = "annotation"
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                // 再利用できる場合はそのまま返す
                
                return annotationView
            } else { // 再利用できるアノテーションが無い場合（初回など）は生成する
                let myPinIdentifier = "PinAnnotationIdentifier"
                //アノテーションビュー生成
                let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: myPinIdentifier)
                //                annotationView.image = UIImage(named: "pinFIlled") // ここで好きな画像を設定します
                
                //コールアウトの表示
                annotationView.canShowCallout = true
                
                //ピンの色を指定
                annotationView.pinTintColor = UIColor.green
                
                //ピンが降ってくるアニメーションをつける
                annotationView.animatesDrop = true
                
                return annotationView
            }
        }
    }
    
    /*
     * トラッキングボタンが押されたときのメソッド（トラッキングモード切り替え）
     */
    @IBAction func tapTrackingButton(_ sender: UIBarButtonItem) {
        
        // MARK: - ここのtrackingButton.image = UIImage(named: "trackingFollow")だけど共通化できひんかな？？？
        // できれば別クラスで定義するとなお良い！
        
        
        switch conveniMapView.userTrackingMode{
        case .none:
            //noneからfollowへ
            conveniMapView.setUserTrackingMode(.follow, animated: true)
            //トラッキングボタンの画像を変更する
            trackingButton.image = UIImage(named: "trackingFollow")
            
        case .follow:
            //followからfollowWithHeadingへ
            conveniMapView.setUserTrackingMode(.followWithHeading, animated: true)
            //トラッキングボタンの画像を変更する
            trackingButton.image = UIImage(named: "trackingHeading")
            
        case .followWithHeading:
            //followWithHeadingからnoneへ
            conveniMapView.setUserTrackingMode(.none, animated: true)
            //トラッキングボタンの画像を変更する
            trackingButton.image = UIImage(named: "trackingNone")
        }
    }
    
    /*
     * トラッキングが自動解除されたとき
     */
    @objc(mapView:didChangeUserTrackingMode:animated:) func mapView (_ mapView :MKMapView, didChange mode:MKUserTrackingMode, animated:Bool){
        trackingButton.image = UIImage(named: "trackingNone")
    }
    
    //位置情報利用許可のステータスが変わった
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status{
        //ロケーションの更新を開始する
        case .authorizedAlways, .authorizedWhenInUse:
            lm.startUpdatingLocation()
            
            //トラッキングボタンを有効にする
            trackingButton.isEnabled = true
            
        default:
            
            //ロケーションの更新を停止する
            lm.stopUpdatingLocation()
            
            //トラッキングモードをnoneにする
            conveniMapView.setUserTrackingMode(.none, animated: true)
            
            // トラッキングボタンを変更する
            trackingButton.image = UIImage(named: "trackingNone")
            
            //トラッキングボタンを無効にする
            trackingButton.isEnabled = false
        }
    }
    
    /* 現在の位置情報取得成功時に実行される関数 */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
        // 取得した緯度がnewLocation.coordinate.longitudeに格納されている
        userLatitude = newLocation!.coordinate.latitude
        // 取得した経度がnewLocation.coordinate.longitudeに格納されている
        userLongitude = newLocation!.coordinate.longitude
        
        let userLocation:CLLocationCoordinate2D  = CLLocationCoordinate2DMake(userLatitude,userLongitude)
        userPin = MKPointAnnotation()
        userPin.coordinate = userLocation
        
        conveniMapView.addAnnotation(userPin)
        
        // 取得した緯度・経度をLogに表示
        NSLog("latitude: \(userLatitude) , longitude: \(userLongitude)")
        // GPSの使用を停止する．停止しない限りGPSは実行され，指定間隔で更新され続ける．
        // lm.stopUpdatingLocation()
    }
    
    /* 位置情報取得失敗時に実行される関数 */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // この例ではLogにErrorと表示するだけ．
        NSLog("Error")
    }
    
    
    /*
     * 座標から情報を呼び出す関数
     */
    func reverseGeocord (latitude:CLLocationDegrees , longitude:CLLocationDegrees, myPin:MKPointAnnotation){
        
        // geocoderを作成.
        let myGeocorder = CLGeocoder()
        
        // locationを作成.
        let myLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        
        //逆ジオコーディングで座標から国名、住所、名称、郵便番号等を取得。
        myGeocorder.reverseGeocodeLocation(myLocation, completionHandler: { (placemarks, error) -> Void in
            
            
            for placemark in placemarks! {
                
                print("Name: \(placemark.name)")
                print("Country: \(placemark.country)")
                print("ISOcountryCode: \(placemark.isoCountryCode)")
                print("administrativeArea: \(placemark.administrativeArea)")
                print("subAdministrativeArea: \(placemark.subAdministrativeArea)")
                print("Locality: \(placemark.locality)")
                print("PostalCode: \(placemark.postalCode)")
                print("areaOfInterest: \(placemark.areasOfInterest)")
                print("Ocean: \(placemark.ocean)")
                
                // pinのタイトルとサブタイトルを国名と土地名称に変更する.
                
                
                self.myPin.subtitle? = "\(placemark.name!)"
                
                //oceanにピンを立てるとcountryがnilになるので
                //countryがnilかどうかで場合分け
                if placemark.country != nil{
                    
                    self.myPin.title? = "\(placemark.country!)"
                    self.userLocation.text? = "\(placemark.country!),\(placemark.name!)"
                    
                }else{
                    self.myPin.title? = "Ocean"
                    self.userLocation.text? = "\(placemark.name!)"
                    
                    
                }
                
            }
        })
        
    }
    
    
    /*
     * コールアウトにボタンを表示するメソッド
     */
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for view in views {
            view.rightCalloutAccessoryView = UIButton(type: UIButtonType.detailDisclosure)
        }
    }
    
    
    /*
     * コールアウトのボタンが押されたときのメソッド
     */
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        
        // UIAlertControllerを作成する.
        let myAlert: UIAlertController = UIAlertController(title: "ピンの削除", message: "Delete this pin?", preferredStyle: .alert)
        
        // OKが押されたらピンを削除するアラートアクションを作成.
        let myOkAction = UIAlertAction(title: "OK", style: .default) { action in
            mapView.removeAnnotation(view.annotation!)
        }
        
        //ピンの削除をキャンセルするアラートアクションを作成.
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        // OK,cancelのActionを追加する.
        myAlert.addAction(myOkAction)
        myAlert.addAction(cancelAction)
        
        // UIAlertを発動する.
        present(myAlert, animated: true, completion: nil)
        
    }
    
    
    /*
     * 検索ボタン押下時の呼び出しメソッド
     */
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //すべてのピンを削除
        conveniMapView.removeAnnotations(conveniMapView.annotations)
        
        //キーボードを閉じる。
        destSearchBar.resignFirstResponder()
        
        //検索条件を作成する。
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = destSearchBar.text! + " コンビニ"
        
        //検索範囲はマップビューと同じにする。
        request.region = conveniMapView.region
        
        //ローカル検索を実行する。
        let localSearch:MKLocalSearch = MKLocalSearch(request: request)
        localSearch.start(completionHandler: {(result, error) in
            
            //検索結果がnilじゃないとき（nilだとfor...inできない）
            if result?.mapItems != nil{
                
                for placemark in (result?.mapItems)! {
                    
                    //エラーなし
                    if(error == nil) {
                        
                        //検索された場所にピンを刺す。
                        
                        //ピン生成
                        let annotation = MKPointAnnotation()
                        
                        //ピンに座標を入れる
                        annotation.coordinate = CLLocationCoordinate2DMake(
                            placemark.placemark.coordinate.latitude, placemark.placemark.coordinate.longitude)
                        
                        //タイトル、サブタイトルをつける
                        annotation.title = placemark.placemark.name
                        annotation.subtitle = placemark.placemark.title
                        
                        //ピンを刺す
                        self.conveniMapView.addAnnotation(annotation)
                        
                        //検索が終了したアラートを出す
                        let title = "検索が完了しました"
                        let message = "OKを押して続けてください"
                        self.searhAlert(title: title, message: message)
                        
        
                    } else {
                        
                        
                        print(placemark.placemark.name!)
                        print(placemark.placemark.title!)
                        
                        //エラー
                        print("error!")
                    }
                }
            }else{
                
                //検索結果がnilのとき検索失敗のアラートを出す
                let title = "検索できませんでした"
                let message = "別の言葉で試してみてください"
                self.searhAlert(title: title, message: message)
                
                print("action OK")
                
            
            
            }
        })
    }
    
    //OKで確認をとるだけのアラートを出すメソッド
    
    // MARK: - UIAlertViewControllerをカスタムクラス作るとなお良い
    func searhAlert(title:String, message:String ) {
        
        //アラートコントローラー生成
        let searchAlertController:UIAlertController = UIAlertController(
            title:title, message:message , preferredStyle:.alert)
        
        //アラートのアクションを定義
        let OkAction:UIAlertAction = UIAlertAction(title: "OK", style: .default){action in
            
            print("action OK")
        }
        
        //アラートコントローラーにアクションを追加
        searchAlertController.addAction(OkAction)
        
        //アラートを表示
        self.present(searchAlertController,animated: true, completion: nil)
        
    }
    
    
    func getRoute(){
        
        // 現在地と目的地のMKPlacemarkを生成
        
        let userCoordinate = CLLocationCoordinate2DMake(userLatitude, userLongitude)
        let destLocation = CLLocationCoordinate2DMake(pinLatitude, pinLongitude)
        
        let fromPlacemark = MKPlacemark(coordinate:userCoordinate, addressDictionary:nil)
        let toPlacemark   = MKPlacemark(coordinate:destLocation, addressDictionary:nil)
        
        // MKPlacemark から MKMapItem を生成
        let fromItem = MKMapItem(placemark:fromPlacemark)
        let toItem   = MKMapItem(placemark:toPlacemark)
        
        // MKMapItem をセットして MKDirectionsRequest を生成
        let request = MKDirectionsRequest()
        
        request.source = fromItem
        request.destination = toItem
        request.requestsAlternateRoutes = false // 単独の経路を検索
        request.transportType = MKDirectionsTransportType.automobile
        
        let directions = MKDirections(request:request)
        // 経路探索.
        directions.calculate { (response, error) in
            
            // NSErrorを受け取ったか、ルートがない場合.
            if error != nil || response!.routes.isEmpty {
                return
            }
            
            let route: MKRoute = response!.routes[0] as MKRoute
            print("目的地まで \(Int(route.distance)/1000)km")
            print("所要時間 \(Int(route.expectedTravelTime/60))分")
            
            // mapViewにルートを描画.
            self.conveniMapView.add(route.polyline)
        }    }

    
    // MARK: - howUserAndDestinationOnMap()の計算ロジックもモデルクラスで処理するのもあり！
    
    // 地図の表示範囲を計算
    func showUserAndDestinationOnMap() {
        
        // 現在地と目的地を含む矩形を計算
        let maxLat:Double = fmax(userLatitude,  pinLatitude)
        let maxLon:Double = fmax(userLongitude, pinLongitude)
        let minLat:Double = fmin(userLatitude,  pinLatitude)
        let minLon:Double = fmin(userLongitude, pinLongitude)
        
        // 地図表示するときの緯度、経度の幅を計算
        let mapMargin:Double = 1.5;  // 経路が入る幅(1.0)＋余白(0.5)
        let leastCoordSpan:Double = 0.005;    // 拡大表示したときの最大値
        let span_x:Double = fmax(leastCoordSpan, fabs(maxLat - minLat) * mapMargin);
        let span_y:Double = fmax(leastCoordSpan, fabs(maxLon - minLon) * mapMargin);
        
        let span:MKCoordinateSpan = MKCoordinateSpanMake(span_x, span_y);
        
        // 現在地を目的地の中心を計算
        let center:CLLocationCoordinate2D = CLLocationCoordinate2DMake((maxLat + minLat) / 2, (maxLon + minLon) / 2);
        let region:MKCoordinateRegion = MKCoordinateRegionMake(center, span);
        
        conveniMapView.setRegion(conveniMapView.regionThatFits(region), animated:true);
    }
    
    // ルートの表示設定.
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let route: MKPolyline = overlay as! MKPolyline
        let routeRenderer: MKPolylineRenderer = MKPolylineRenderer(polyline: route)
        
        // ルートの線の太さ.
        routeRenderer.lineWidth = 4.0
        
        // ルートの線の色.
        routeRenderer.strokeColor = UIColor.magenta
        return routeRenderer
    }
    
    //ピンがタップされたときに起こるイベント
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // 描画済みの経路を削除
        self.conveniMapView.removeOverlays(self.conveniMapView.overlays)
        
        //タップされたピンの座標を入れる
        myPin = view.annotation as! MKPointAnnotation!
        pinLatitude = myPin.coordinate.latitude
        pinLongitude = myPin.coordinate.longitude
        
        //現在地からピンまでの経路を検索
        self.getRoute()
    }
    
    
}





