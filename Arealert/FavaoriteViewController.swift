//
//  FavaoriteViewController.swift
//  Arealert
//
//  Created by Jodai Takuya on 2020/12/17.
//  Copyright © 2020 Jodai Takuya. All rights reserved.
//

import UIKit
import MapKit

class FavaoriteViewController: UIViewController /*,UITableViewDataSource*/ {

    
    
    // お気に入りの保存値を扱うキーを設定
    let key = "favorite_value"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // TableViewのdataSourceを設定
        //tableView.dataSource = self
        
        // UserDefaultsの取得
        //let defaults = UserDefaults.standard
        
        // UserDefaultsから取り出し
        //var favoriteList:[(annotationFav:MKAnnotation, circleFav:MKCircle)] = defaults.array(forKey: key)!
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    @IBOutlet weak var tableView: UITableView!
    
    
    
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // Cellの総数を返すdataSourceメソッド(必記述)
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return favoriteList.count
//    }
    
    // Cellに値を設定するdatasourceメソッド(必記述)
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath)
//        return cell
//    }
    
}
