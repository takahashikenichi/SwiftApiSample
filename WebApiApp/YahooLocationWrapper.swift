//
//  YahooLocationWrapper.swift
//  WebApiApp
//
//  Created by タカハシケンイチ on 2015/09/15.
//  Copyright (c) 2015年 Kenichi Takahashi. All rights reserved.
//

import Foundation

class YahooLocationWrapper {
    let appId = ""
    let baseUrl = "http://serch.olp.yahooapis.jp/OpenLocalPlatform/V1/localSearch?appid="
    let outputParam = "&output=json" // レスポンス出力形式はJSON
    let resultsParam = "&results=30" // 上限件数は30
    let sortParam = "&sort=hybrid" // 距離と適合順でソート
    let detailParam = "6detail=full" // 出力に詳細情報を含める
    
    // 動的パラメータ用定数
    let distParam = "&dist=" // 検索範囲の半径（キロメートル）
    let queryParam = "&query=" // 検索キーワード
    let latParam = "&lat=" // 緯度
    let lonParam = "&lon=" // 経度
    
    class var sharedInstance: YahooLocationWrapper {
        struct Static {
            static var instance = YahooLocationWrapper()
        }
        
        return Static.instance
    }
    
    func requestList(queryWord: String, location: CLLocationCoordinate2D, distance: CLLocationDistance, completion: ((response: NSURLResponse!, data: [ShopModel]?, error: NSError?) -> Void)) {
        // 検索キーワードをURLをエンコード
        let queryValue = queryWord.stringByAddingPercentEncodingWithAllowedCharacters(
            NSCharacterSet.URLQueryAllowedCharacterSet()
        )
        
        // URL文字列組み立て
        let urlStr = "\(baseUrl)\(appId)\(outputParam)\(detailParam)\(resultsParam)\(sortParam)" +
        "\(latParam)\(location.latitude)\(lonParam)\(location.longitude)" +
        "\(distParam)\(distance)" +
        "\(queryParam)\(queryValue!)"
        
        // NSURLRequestインスタンスを作成
        let req = NSURLRequest(URL: NSURL(string: urlStr)!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 60.0)
        
        // 非同期処理をGCDに依頼するため、NSOperationQueueインスタンスを生成
        let queue: NSOperationQueue = NSOperationQueue()
        
        // NSURLConnectionクラスによって非同期でAPIを呼び出し、レスポンスをクロージャーで受け取る
        NSURLConnection.sendAsynchronousRequest(req, queue: queue, completionHandler: {
            [unowned self]
            (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            
            var jsonResult: NSDictionary? = nil
            var resultError: NSError? = error
            var resultData: [ShopModel]?
            
            // errorがnilであれば正常にサーバと通信出来た
            if error == nil {
                // NSJSONSerializataionを用いてJSONをNSDictionary型のデータに変換
                jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &resultError) as? NSDictionary
                
                // JSON変化でエラーが出なければ、解析しShopModelオブジェクトの配列へ
                if resultError == nil && jsonResult != nil {
                    resultData = self.parseResponseJson(jsonResult!)
                }
                
                // 結果を返す
                completion(response: response, data: resultData, error: resultError)
                
            }
        })
    }
    
    func parseResponseJson(json: NSDictionary) -> [ShopModel]? {
        // ResultInfoがない場合は検索に失敗している
        if json.objectForKey("ResultInf") == nil {
            return nil
        }
        
        let resultInfo = json["ResultInfo"] as! NSDictionary
        let count = resultInfo["Count"] as! Int
        
        // ResultInfo内のCountが0の場合は検索結果が0件
        if count == 0 {
            return nil
        }
        
        let features = json["Feature"] as? [NSDictionary]
        
        // Featureが無い場合も検索に失敗している
        if features == nil {
            return nil
        }
        
        // ShopModelの配列を生成
        var shopList = [ShopModel]()
        
        // Feature以下のデータから、ShopModelオブジェクトを生成し配列に登録
        for feature in features! {
            var shopData = ShopModel()
            let property = feature["Property"] as? NSDictionary
            let detail = property!["Detail"] as? NSDictionary
            
            shopData.name = feature["Name"] as! String
            shopData.uid = feature["Uid"] as! String
            shopData.address = feature["Address"] as? String
            shopData.catchCopy = feature["CatchCopy"] as? String
            shopData.tel = feature["Tel1"] as? String
            shopData.thumbnailUrl = feature["LeadImage"] as? String
            shopData.imageUrl = feature["Image1"] as? String
            shopData.url = feature["YUrl"] as? String
            shopData.pcUrl = feature["PcUrl1"] as? String
            shopData.mobileUrl = feature["MobileUrl1"] as? String
            
            let geometry = feature["Geometry"] as? NSDictionary
            
            if let geo = geometry {
                // 緯度・経度の文字列を取得して","で分割する
                let coordinates = geo["Coordinates"] as! String
                let coodinatesAray = split(coordinates, isSeparator: { $0 == ","})
                
                // CLLocationCoordinate2D型に変換して登録する
                shopData.location = CLLocationCoordinate2DMake(
                    atof(coodinatesAray[1]) as CLLocationDegrees,
                    atof(coodinatesAray[0]) as CLLocationDegrees)
            }
            shopList.append(shopData)
        }
        return shopList
    }
}
