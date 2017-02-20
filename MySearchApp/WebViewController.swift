//
//  WebViewController.swift
//  MySearchApp
//
//  Created by Shintaro Takemura on 2017/02/19.
//  Copyright © 2017年 Shintaro Takemura. All rights reserved.
//

import UIKit
import WebKit


class WebViewController: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var itemUrl: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let webView = WKWebView(frame: self.view.frame)
        webView.navigationDelegate = self
        view.addSubview(webView)

        guard let url = itemUrl else { return }
        let urlRequest = URLRequest(url: URL(string: url)!)
        webView.load(urlRequest)
        
        webView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
    }
    

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
