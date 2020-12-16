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

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var inputText: UITextField!

    

    
    var locationManager: CLLocationManager!
    
    //円を格納する変数(のちのち配列にしたい
    var mkCircle = MKCircle(center:CLLocationCoordinate2DMake(0.0, 0.0), radius: 10)
    
    //teratailで頂いた回答用
    var startPoint = CLLocationCoordinate2D()
    var circle: MKCircle?
    

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
        circle.strokeColor = UIColor.red
        circle.fillColor = UIColor(red:0.5, green: 0.0, blue: 0.0, alpha: 0.5)
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
                    print("start")

                    // すでに円が表示してあれば消す
                    if let _ = circle {
                        mapView.removeOverlay(circle!)
                    }

                    //　最初にタップしたところを初期位置とする
                    let tapPoint = sender.location(in: mapView)
                    startPoint = mapView.convert(tapPoint, toCoordinateFrom: mapView)

                    // 緯度1度あたり 111km = 11100m
                    // mapView の表示緯度（mapView.region.span）の 1/10 の円を初期半径とする
                    // このあたりは適当
                    let r = mapView.region.span.latitudeDelta * 1110
                    circle = MKCircle(center: startPoint, radius: r)
                    mapView.addOverlay(circle!)


                case .ended:
                    // ロングタップ終了
                    print("end")

                case .changed:
                    // ドラッグ中
                    print("changed")

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


