//
//  ShopModel.swift
//  WebApiApp
//
//  Created by タカハシケンイチ on 2015/09/09.
//  Copyright (c) 2015年 Kenichi Takahashi. All rights reserved.
//

import Foundation

class ShopModel {
    // 店舗のユニークID
    var uid: String!
    // 店舗名
    var name: String!
    // 住所
    var address: String?
    // 電話番号
    var tel: String?
    // キャッチコピー
    var catchCopy: String?
    // 緯度・経度
    var location: CLLocationCoordinate2D?
    // サムネール画像URL
    var thumbnailUrl: String?
    // 画像URL
    var imageUrl: String?
    // Yahoo! JapanロゴのURL
    var url: String?
    // データ提供元のPC向けURL
    var pcUrl: String?
    // データ提供元のモバイル向けURL
    var mobileUrl: String?
    
    init() {
        
    }
}