//
//  App.swift
//  MySearchApp
//
//  Created by Shintaro Takemura on 2017/02/23.
//  Copyright © 2017年 Shintaro Takemura. All rights reserved.
//

import Foundation
import UIKit


final class App {

    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let navigationController: UINavigationController
    
    init(window: UIWindow) {

        navigationController = window.rootViewController as! UINavigationController
        let searchItemVC = navigationController.viewControllers[0] as! SearchItemViewController
        
        searchItemVC.didSelect = show
    }
    
    func show(itemData: ItemData) {
        let webVC = storyboard.instantiateViewController(withIdentifier: "WebVC") as! WebViewController
        webVC.itemUrl = itemData.itemUrl
        navigationController.pushViewController(webVC, animated: true)
    }
    
}
