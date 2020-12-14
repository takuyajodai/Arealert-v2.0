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
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization() //位置情報の取得許可
        locationManager.startUpdatingLocation() //位置情報更新を指示
        
        mapView.showsUserLocation = true
        

        
        
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
                            
                            //ここまでピンを置く作業(後で円を描画する時にピンを置く
                        }
                    }
                }
            })
        }
        return true
    }
}//class
    //GPSから値を取得した時に呼び出されるメソッド
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations:[CLLocation]) {
//
//        //現在座標を取得
//        let longitude = (locations.last?.coordinate.longitude.description)!
//        let latitude = (locations.last?.coordinate.latitude.description)!
//        print("[DBG]longitude : " + longitude)
//        print("[DBG]latitude : " + latitude)
//
        //常に現在位置を表示する
        //mapView.setCenter((locations.last?.coordinate)!, animated: true)

   
        
        //CLGeocoderインスタンス
        //let geocoder = CLGeocoder()
        
        //入力された文字から位置情報を取得
//        geocoder.geocodeAddressString(searchKeyword!,completionHandler:{_,_ in (placemarks:[CLPlacemark]?,error:Error?,.self,}in
//
//        //位置情報が存在する場合1軒目の位置情報をplacemarkに取り出す
//            if let placemark = placemarks?[0] {
//                //位置情報から緯度経度が存在する場合，緯度経度をtargetCoordinateに取り出す
//                if let targetCoodinate = placemark.location?.coordinate {
//                    print(targetCoodinate)
//                }
//            }
//        }
//   }
        


