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

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var inputText: UITextField!

    

    
    var locationManager: CLLocationManager!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        //Text Fieldのdelegateの通知先を設定
        inputText.delegate = self
        
        //CLlocationManagerのインスタンス生成
        //現在地の情報取得などに使う
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        
        
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
    
}//class



