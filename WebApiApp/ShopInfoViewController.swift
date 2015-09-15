//
//  ShopInfoViewController.swift
//  WebApiApp
//
//  Created by タカハシケンイチ on 2015/09/09.
//  Copyright (c) 2015年 Kenichi Takahashi. All rights reserved.
//

import UIKit

class ShopInfoViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var shopNameLabel: UILabel!
    @IBOutlet var catchCopyLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var browserButton: UIButton!
    @IBOutlet var telButton: UIButton!
    
    var shopInfo: ShopModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if shopInfo == nil {
            return
        }
        
        // ラベルへのテキストの設定
        shopNameLabel.text = shopInfo.name
        catchCopyLabel.text = shopInfo.catchCopy
        addressLabel.text = shopInfo.address
        
        // ボタンの設定（URL・電話番号があれば遊興、無ければ向こうにする）
        browserButton.enabled = shopInfo.url != nil || shopInfo.mobileUrl != nil || shopInfo.pcUrl != nil
        telButton.enabled = shopInfo.tel != nil
        
        // 画像表示
        // shopInfo.imageUrlがある場合はそちらを優先して表示する
        // ない場合はshopInfo.thumbnailUrlを表示する
        var imageUrlStr: String!
        if shopInfo.imageUrl != nil && shopInfo.imageUrl! != "" {
            imageUrlStr = shopInfo.imageUrl
        } else if shopInfo.thumbnailUrl != nil && shopInfo.thumbnailUrl! != "" {
            imageUrlStr = shopInfo.thumbnailUrl
        }
        
        // どちらもない場合は、imageViewの背景色を黒にする
        if imageUrlStr == nil {
            imageView.backgroundColor = UIColor.blackColor()
            return
        }
        
        imageView.image = nil
        
        // 画像を非同期に読み込み、読み込み完了後に表示する
        let imageUrl = NSURL(string: imageUrlStr!)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            [unowned self] in
            let data = NSData(contentsOfURL: imageUrl!)
            
            if data != nil {
                let image = UIImage(data: data!)
                
                dispatch_async(dispatch_get_main_queue(), {self.imageView.image = image})
            }
        })
    }
    
    // Webボタンが押された時、対策のページをSafariで開く
    @IBAction func browserButtonClicked(sender: UIButton) {
        if shopInfo == nil {
            return
        }
        
        // url、mobileUrl、pcUrlの優先度で開くURLを決定する
        let urlStr = shopInfo.url ?? shopInfo.mobileUrl ?? shopInfo.pcUrl
        
        let url = NSURL(string: urlStr!)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    // 電話ボタンが押された時、電話番号
    @IBAction func telButtonClicked(sender: UIButton) {
        if shopInfo == nil || shopInfo.tel == nil {
            return
        }
        
        let url = NSURL(string: "tel:" + shopInfo.tel!)
        UIApplication.sharedApplication().openURL(url!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
        
    class func createInstance() -> ShopInfoViewController {
        // "Shop.storyboard"を読み込み、UIStoryboardのインスタンスを生成する
        let storyboard = UIStoryboard(name: "ShopInfo", bundle: NSBundle.mainBundle())
        
        // storyboardにて指定された初期ビューコントローラーをインスタンス化する
        let viewController = storyboard.instantiateInitialViewController() as! ShopInfoViewController
        
        // インスタンス化されたビューコントローラーを返す
        return viewController
    }
    
    func setShopInfo(shopInfo: ShopModel) {
        self.shopInfo = shopInfo
    }
    

}
