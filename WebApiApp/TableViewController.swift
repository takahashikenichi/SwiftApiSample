//
//  TableViewController.swift
//  WebApiApp
//
//  Created by タカハシケンイチ on 2015/09/09.
//  Copyright (c) 2015年 Kenichi Takahashi. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView?
    
    var shopInfoList: [ShopModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView = UITableView()
        tableView!.backgroundColor = UIColor.whiteColor()
        tableView!.delegate = self
        tableView!.dataSource = self
        
        self.view.addSubview(tableView!)
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView!.frame = self.view.bounds
        
        self.view.layoutIfNeeded()
    }
    
    func setShopList(shopList: [ShopModel]!) {
        self.shopInfoList = shopList
        tableView?.reloadData() // ? がOptional Chaining
    }
    
    // セクション数を返す（今回セクション分けしないので1を返す）
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    // セクション毎の項目数を返す
    // 今回はセクションわけがないのでshopListに含まれる要素数を返す
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shopInfoList == nil {
            return 0
        } else {
            return shopInfoList.count
        }
    }
    
    // indexPathで指定された一男の行を示すUITableViewCellのオブジェクト（セル）を返す
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // "Cell"というIndetifierの再利用可能なセルを探す
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
            
        // 無ければ新規に作成する
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        }
            
        // indexPath.row番目のデータをshopListから取り出す
        let shopData = shopInfoList[indexPath.row]
        
        // セルに店名と住所を設定する
        cell!.textLabel!.text = shopData.name
        cell!.detailTextLabel!.text = shopData.address
        // セルの右端に表示する画像を設定する
        cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        return cell!
    }
    
    // セルの高さの見積もり高さを返す
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0 as CGFloat
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44.0 as CGFloat
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // セルが選択上他のままにならないように、表示を元に戻す
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        // 親ビューコントローラに店舗情報表示を依頼する
        let parentViewController = self.parentViewController as! ViewController
        parentViewController.presentShopViewController(indexPath.row)
    }

}
