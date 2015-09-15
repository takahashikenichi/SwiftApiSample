//
//  ViewController.swift
//  WebApiApp
//
//  Created by タカハシケンイチ on 2015/09/09.
//  Copyright (c) 2015年 Kenichi Takahashi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    enum ViewMode {
        case Map // 地図モード
        case Table // 一覧表示モード
    }
    
    @IBOutlet var searchBox: UITextField!
    @IBOutlet var container: UIView!
    @IBOutlet var currentPosButton: UIBarButtonItem!
    @IBOutlet var switchViewButton: UIBarButtonItem!
    @IBOutlet var clearButton: UIBarButtonItem!
    
    var mapViewController: MapViewController!
    var tableViewController: TableViewController!
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
    var shopList: [ShopModel]!

    var mode = ViewMode.Map
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 地図表示、一覧表示のビューコントローラーを生成
        mapViewController = MapViewController()
        tableViewController = TableViewController()
        
        // 生成したビューコントローラーをこのビューコントローラーの
        // 子ビューコントローラーとして登録する
        self.addChildViewController(mapViewController)
        self.addChildViewController(tableViewController)
        mapViewController.didMoveToParentViewController(self)
        tableViewController.didMoveToParentViewController(self)
        
        // containerのサブビューとして一覧表示、地図表示のルートビューを登録
        // （後から登録した地図表示が前面に表示される）
        container.addSubview(tableViewController.view)
        container.addSubview(mapViewController.view)
        
        // 地図表示が前面に出ているため、現在の表示モードを地図に設定
        mode = .Map
        
        // 位置情報取得開始
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        searchBox.delegate = self
    }
    
    // レイアウト完了時の処理
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mapViewController.view.frame = container.bounds
        tableViewController.view.frame = container.bounds
        
        self.view.layoutIfNeeded()
    }

    // View表示時の処理
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // トップページはナビゲーションバー非表示
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    // View非表示時の処理
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // ナビゲーションバー表示状態に戻す
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if locations.count > 0 {
            currentLocation = locations[0] as? CLLocation
            mapViewController.setLocation(currentLocation!.coordinate)
            
            locationManager.stopUpdatingLocation()
        }
    }

    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        NSLog("%@", error)
    }

    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .NotDetermined:
            if locationManager.respondsToSelector("requestWhenInUseAuthorization") {
                locationManager.requestWhenInUseAuthorization()
            }
        case .Restricted, .Denied:
            showAlertDialog(nil, message: "位置情報の取得が許可されていません。設定を変更してください。")
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            break
        default:
            break
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // キーボードを隠す
        textField.resignFirstResponder()
        
        // 文字列をtextFieldから取得
        let searchText = textField.text
        
        // 検索ラッパーオブジェクト取得
        let yahooLocationWrapper = YahooLocationWrapper.sharedInstance
        
        // 位置情報取得済なら検索実行
        if let location = currentLocation {
            yahooLocationWrapper.requestList(searchText,
                location: location.coordinate,
                distance: 1.0 as CLLocationDistance,
                completion: {
                    [unowned self]
                    (response: NSURLResponse!,
                    data: [ShopModel]?,
                    error: NSError?) in
                    
                    var errorMessage: String?
                    
                    // エラーの場合、エラーを表示してreturn
                    if error != nil {
                        self.showAlertDialog(nil, message: error!.localizedDescription)
                        return
                    }
                    
                    // 検索結果が空の場合、その旨をアラート表示してreturn
                    if data == nil || data!.count == 0 {
                        self.showAlertDialog(nil, message: "見つかりませんでした")
                        return
                    }
                    
                    // 検索結果を反映する
                    self.shopList = data
                    
                    self.showShopList()
            })
        }
        
        return true
    }
    
    func showShopList() {
        // 結果がなければ何もせずにreturn
        if shopList == nil || shopList.count == 0 {
            return
        }
    
        // 地図上のマーカー表示用のアノテーション配列を作成
        var annotations: [AnyObject] = []
        var count = 0
        for shopData in shopList {
            annotations.append(MyAnnotation(locationCoordinate: shopData.location!, title: shopData.name, subtitle: shopData.address, index: count))
            count++
        }
    
        // 検索結果を地図と一覧に反映する
        dispatch_async(dispatch_get_main_queue(), {
            [unowned self] in
            // 地図への反映
            self.mapViewController.setAnnotations(annotations)
    
            // 一覧表示への反映
            self.tableViewController.setShopList(self.shopList)
        })
    }
    
    
    func presentShopViewController(index: Int) {
        // shopListがない、指定のindexがshopListに含まれる要素数を超える場合は何もしない
        if shopList == nil || index >= shopList.count {
            return
        }
        
        // indexで指定されたShopModelのインスタンスを取得
        let shopInfo = shopList[index]
        
        // ShopInfoViewControllerのインスタンスを生成し、ShopModelのインスタンスを設定する
        let shopInfoViewController = ShopInfoViewController.createInstance()
        shopInfoViewController.setShopInfo(shopInfo)
        
        // ナビゲーションコントローラーを用いて、店舗情報画面に推移するf
        self.navigationController?.pushViewController(shopInfoViewController, animated: true)
    }
    
    
    func showAlertDialog(title: String?, message: String?) {
        // iOS8のUIArertControllerが有るかを確認する
        if objc_getClass("UIAlertController") != nil {
            let closeAction = UIAlertAction(title: "Close", style: .Default,
                handler: {
                    (action: UIAlertAction!) -> Void in
            })
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(closeAction)
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            let alertView = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "Close")
            alertView.show()
        }
    }
    
    @IBAction func currentPosButtonClicked(sender: UIBarButtonItem) {
        if mode == .Map {
            locationManager.startUpdatingLocation()
        }
    }
    
    @IBAction func switchButtonClicked(sender: UIBarButtonItem) {
        var fromView: UIView!
        var toView: UIView!
        
        if mode == .Map {
            mode = .Table
            currentPosButton.enabled = false
            locationManager.stopUpdatingLocation()
            
            fromView = mapViewController.view
            toView = tableViewController.view
        } else {
            mode = .Map
            currentPosButton.enabled = true
            
            fromView = tableViewController.view
            toView = mapViewController.view
        }
        
        UIView.transitionFromView(fromView, toView: toView, duration: 0.5, options: .TransitionFlipFromTop | .ShowHideTransitionViews, completion: nil)
    }
    
    @IBAction func clearButtonClicked(sender: UIBarButtonItem) {
        shopList = nil
        
        mapViewController.setAnnotations(nil)
        tableViewController.setShopList(nil)
    }
}

