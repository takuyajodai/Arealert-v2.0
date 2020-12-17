//
//  ViewController.swift
//  Arealert
//
//  Created by Jodai Takuya on 2020/09/29.
//  Copyright © 2020 Jodai Takuya. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate, UNUserNotificationCenterDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var inputText: UITextField!

    var locationManager: CLLocationManager!
    
    //円を格納する変数(のちのち配列にしたい
    //var mkCircle = MKCircle(center:CLLocationCoordinate2DMake(0.0, 0.0), radius: 10
    
    //teratail
    var startPoint = CLLocationCoordinate2D()
    var circle: MKCircle?
    
    
    //----------セグエで受け渡しUserDefault------
    
    // 円の情報を保持する
    var circleFav: MKCircle!
    
    // ピンの情報を保持する
    var annotationFav: MKAnnotation!
    
    // お気に入りの情報を一つにまとめるリスト
    //var favoriteList:[favoriteStruct] = []
    
    // お気に入りの保存値を扱うキーを設定
    let key = "favorite_value"
    // UserDefaultsのインスタンスを生成
    let defaults = UserDefaults.standard
    
//    struct favoriteStruct {
//
//        var annotationStruct: MKAnnotation
//        var circleStruct: MKCircle
//        //構造体のイニシャライズ
//        init() {
//            annotationStruct = annotationFav
//            circleStruct = circleFav
//        }
//    }

    //-----------セグエで受け渡しUserDefault-----

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        //Text Fieldのdelegateの通知先を設定
        inputText.delegate = self
        
        //CLlocationManagerのインスタンス生成
        //現在地の情報取得などに使う
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        //MKMapViewのデリゲート
        mapView.delegate = self
        
        
        //位置情報の取得許可
        locationManager.requestWhenInUseAuthorization()
        
        //位置情報更新を指示
        locationManager.startUpdatingLocation()
        
        //地図の初期位置化
        initMap()
        
        // コンパスの表示
        let compass = MKCompassButton(mapView: mapView)
        compass.compassVisibility = .adaptive
        compass.frame = CGRect(x: 315, y: 160, width: 40, height: 40)
        self.view.addSubview(compass)
        // デフォルトのコンパスを非表示にする
        mapView.showsCompass = false
        
        // 通知許可の取得
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]){
            (granted, _) in
            if granted{
                UNUserNotificationCenter.current().delegate = self
            }
        }
        
        
        
    }
    
    


    
    
    //テキストフィールドのデリゲートメソッド
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let searchKey = textField.text {
            print(searchKey)
            
            //CLGeocoderのインスタンス生成
            let geocoder = CLGeocoder()
            
            //位置情報の取得
            geocoder.geocodeAddressString(searchKey, completionHandler: { (placemarks, error) in
                
                if let unwrapPlacemarks = placemarks {
                    if let firstPlacemark = unwrapPlacemarks.first {
                        if let location = firstPlacemark.location {
                            //緯度経度の位置情報
                            let targetCoordinate = location.coordinate
                            print(targetCoordinate)
                            
                            //ここからピンを置く作業(後で円を描画する時にピンを置く
                            //MKPointAnnotation(ピンを置くためのクラス)のインスタンス生成
                            let pin = MKPointAnnotation()
                            pin.coordinate = targetCoordinate
                            pin.title = searchKey
                            self.mapView.addAnnotation(pin)
                            self.mapView.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
                            
                            //ここまでピンを置く作業(後で円を描画する時にピンを置く
                        }
                    }
                }
            })
        }
        return true
    }
    
    
    //位置情報取得に失敗したときに呼び出されるメソッド
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error")
    }
    
    //GPSから値を取得した時に呼び出されるメソッド(デリゲート)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]) {

        //現在位置を更新すると中心を変更
        //mapView.userTrackingMode = .follow
        //updateCurrentLocation((locations.last?.coordinate)!)
        let location = locations.first
        
        //latitudeとlongitudeはアンラップ必要
        if let latitude = location?.coordinate.latitude {
            if let longitude = location?.coordinate.longitude {
                let center = CLLocationCoordinate2DMake(latitude, longitude)
                let inRange: Bool = contains(center)
                if(inRange == true) {
                    print("入った")
                    notification()
                }
            }
        }
        
    }
    
    
    //viewのロード時に地図を初期化
    func initMap() {
        var region:MKCoordinateRegion = mapView.region
        region.span.latitudeDelta = 0.01
        region.span.longitudeDelta = 0.01
        mapView.setRegion(region, animated: true)
        
        //ユーザの位置情報をマップ上に表示
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
//    //現在位置の更新のたび，中心位置を変更
//    func updateCurrentLocation(_ coordinate:CLLocationCoordinate2D) {
//        var region:MKCoordinateRegion = mapView.region
//        region.center = coordinate
//        mapView.setRegion(region, animated: true)
//    }
    
    
    //現在地に戻るボタン
    @IBAction func showCurrentLocation(_ sender: Any) {
        mapView.userTrackingMode = .follow
    }
    
    //円を作成するメソッド(MKMqpViewのデリゲートメソッド)
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circle : MKCircleRenderer = MKCircleRenderer(overlay: overlay)
        circle.strokeColor = UIColor(red:0.2, green: 0.3, blue: 0.4, alpha: 1.0)
        circle.fillColor = UIColor(red:0.2, green: 0.2, blue: 0.4, alpha: 0.5)
        circle.lineWidth = 1.0
        //print("円ができた")
        return circle
    }
    
    
  
    //tapジェスチャーは使用しない
    
//    @IBAction func mapTapped(_ sender: UITapGestureRecognizer) {
//        if sender.state == UIGestureRecognizer.State.ended {
//            print("タップされた")
//            mapView.removeOverlay(mkCircle) //すでにマップ上にある円を削除
//            //現在地取得(円の中心)
//            let userCoordinate = mapView.userLocation.coordinate
//            //タップした座標を取得
//            let tapPoint: CGPoint = sender.location(in: self.mapView)
//            //タップした座標を型変換
//            let tap: CLLocationCoordinate2D = self.mapView.convert(tapPoint, toCoordinateFrom: mapView)
//            //タップしたとこのx座標格納
//            let tapx = tap.latitude
//            //タップしたとこのy座標格納
//            let tapy = tap.longitude
//            //CLLocationに現在地を格納
//            let mylocation: CLLocation = CLLocation(latitude: userCoordinate.latitude, longitude: userCoordinate.longitude)
//            //CLLocationにタップしたとこを格納
//            let taplocation: CLLocation = CLLocation(latitude: CLLocationDegrees(tapx), longitude: CLLocationDegrees(tapy))
//            //円の半径(現在地とタップしたとこの距離)を測定
//            let distance = mylocation.distance(from: taplocation)
//            //distanceを型変換
//            let circleRadius = CLLocationDistance(distance)
//            //円の中心と半径を設定
//            mkCircle = MKCircle(center: userCoordinate, radius:circleRadius)
//            //円を描写
//            mapView.addOverlay(mkCircle)
//        }
//    }
    
    

    //ロングプレスからドラッグで範囲を指定しながら円を描く
    @IBAction func mapLongPressed(_ sender: UILongPressGestureRecognizer) {
//        //mapview内のタップした場所を取得
//        let location:CGPoint = sender.location(in: mapView)
//        if sender.state == UIGestureRecognizer.State.ended {
//            //タップした位置を緯度，経度の座標に変換
//            let mapPoint:CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
//            //ピンを刺す
//            let pin = MKPointAnnotation()
//            pin.coordinate = CLLocationCoordinate2DMake(mapPoint.latitude, mapPoint.longitude)
//            pin.title = "ピン"
//            self.mapView.addAnnotation(pin)
//            //self.mapView.region = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
//        }
//
        
        //https://teratail.com/questions/310568
        
        switch sender.state {
                case .began:
                    // ロングタップ開始
                    //print("start")

                    // すでに円が表示してあれば消す
                    // 複数範囲必要なため，消す必要なし
//                    if let _ = circle {
//                        mapView.removeOverlay(circle!)
//                    }

                    //　最初にタップしたところを初期位置とする
                    let tapPoint = sender.location(in: mapView)
                    startPoint = mapView.convert(tapPoint, toCoordinateFrom: mapView)
                    
                    // 中心値にpinを差す
                    let pin = MKPointAnnotation()
                    let mapPoint:CLLocationCoordinate2D = mapView.convert(tapPoint, toCoordinateFrom: mapView)
                    pin.coordinate = CLLocationCoordinate2DMake(mapPoint.latitude, mapPoint.longitude)
                    
                    pin.title = "ピン"
                    self.mapView.addAnnotation(pin)
                    
                    //pin情報をannotations[]に保存
                    annotationFav = pin
                    
                    // 緯度1度あたり 111km = 11100m
                    // mapView の表示緯度（mapView.region.span）の 1/10 の円を初期半径とする
                    let r = mapView.region.span.latitudeDelta * 1110
                    circle = MKCircle(center: startPoint, radius: r)
                    mapView.addOverlay(circle!)


                case .ended:
                    if let circle = circle {
                        //circle情報をcircles[]に保存
                        //circles.append(circle)
                        
                        circleFav = circle
                        //取り出せる情報
                        //print(circleFav.coordinate)
                        //print(circleFav.radius)
                        //print(annotationFav.coordinate)
                        //print(annotationFav.title)
                        //print(annotationFav.subtitle)
                        
                        //let favorite = init(annotationFav!, circleFav!)
                        //favoriteList.append(favorite)
                        //defaults.set(favoriteList, forKey: key)
                        //defaults.setEncoded(favoriteList, forKey: key)
                    }
                    // ロングタップ終了
                    print("end")

                case .changed:
                    // ドラッグ中
                    //print("changed")

                    // すでに円が表示してあれば消す
                    if let _ = circle {
                        mapView.removeOverlay(circle!)
                    }

                    let tapPoint = sender.location(in: mapView)

                    // ドラッグした距離を求める
                    let delta = mapView.convert(tapPoint, toCoordinateFrom: mapView)
                    let r = CLLocation.distance(from: startPoint, to: delta)

                    // ドラッグした長さに応じて円を描き直す
                    circle = MKCircle(center: startPoint, radius: r)
                    mapView.addOverlay(circle!)

                default:
                    print("それ以外")
                }
        
    }
    
    
    @IBAction func mapTapped(_ sender: UITapGestureRecognizer) {
        // タップした座標をマップ内の座標に変換
        let touchPoint = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let mapPoint = MKMapPoint(touchCoordinate)

        var deleteTarget:[MKOverlay] = []
        for overlay in mapView.overlays {
            let ovRect = overlay.boundingMapRect
            // タップした座標がオーバーレイに含まれている場合は削除対象に加える
            if ovRect.contains(mapPoint) {
                deleteTarget.append(overlay)
            }
        }
        // マップから対象を削除
        mapView.removeOverlays(deleteTarget)
    }
    
    //後でどうにかする
//アノテーションビューを返すメソッド
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let pin = view.annotation as? MKPointAnnotation {
            //キーボード入力したい
            //let inputTitle = becomeFirstResponder()
            //pin.title = inputTitle
            mapView.removeAnnotation(pin)
            mapView.removeOverlay(circle!)
        }
    }
    
    //フォアグラウンドでの通知(UNUserNotificationのデリゲートメソッド)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    var inRange: Bool = false
    
//    //円の範囲内にあるかを判定する
//    func inRangeDetect(_ location:CLLocationCoordinate2D) -> Bool {
//        //判定する範囲
//        let renderer = MKCircleRenderer(circle: circle)
//
//        // 緯度経度(CLLocationCoordinate2D)をマップ上のポイント(MKMapPoint)に変換する
//        let mapPoint = MKMapPoint(location)
//        // マップ上のポイントを MKCircleRenderer 領域内のポイントに変換する
//        let rendererPoint = renderer.point(for: mapPoint)
//        if renderer.path.contains(rendererPoint) {
//            // 含まれる
//            inRange = true
//        }
//        return inRange
//
//    }
    
    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        if let circle = circle {
            let renderer = MKCircleRenderer(circle: circle)
            let mapPoint = MKMapPoint(coordinate)
            let rendererPoint = renderer.point(for: mapPoint)
            return renderer.path.contains(rendererPoint)
        } else {
            return false
        }
        
    }
    
    func notification() {
        print("通知")
        //プッシュ通知のインスタンス生成
        let notification = UNMutableNotificationContent()
        notification.title = "Alert"
        notification.subtitle = "範囲に入りました"
        notification.body = "タップしてアプリを開いて下さい"
        notification.sound = UNNotificationSound.default
        
        //通知タイミングを指定
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        //通知のリクエスト
        let request = UNNotificationRequest(identifier: "ID", content: notification,trigger: trigger)
        //通知を実装
        UNUserNotificationCenter.current().add(request) { (error: Error?) in
            // エラーが存在しているかをif文で確認している
            if error != nil {
                print("通知でエラー")
            } else {
                print("")
            }
        }
    }
    
    
    //セグエ，お気に入り画面へ
    
    @IBAction func favoriteButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "showFavoriteView", sender:nil)
    }
    
    
    
}//class

// https://stackoverflow.com/questions/11077425/finding-distance-between-cllocationcoordinate2d-points
extension CLLocation {
    /// Get distance between two points
    ///
    /// - Parameters:
    ///   - from: first point
    ///   - to: second point
    /// - Returns: the distance in meters
    class func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
}

//extension MKCircle {
//
//    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
//        let renderer = MKCircleRenderer(circle: self)
//        let mapPoint = MKMapPoint(coordinate)
//        let rendererPoint = renderer.point(for: mapPoint)
//        return renderer.path.contains(rendererPoint)
//    }
//}

extension UserDefaults {
  func setEncoded<T: Encodable>(_ value: T, forKey key: String) {
    guard let data = try? JSONEncoder().encode(value) else {
       print("Can not Encode to JSON.")
       return
    }

    set(data, forKey: key)
  }

}
