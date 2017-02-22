//
//  SearchItemViewController.swift
//  MySearchApp
//
//  Created by Shintaro Takemura on 2017/02/19.
//  Copyright © 2017年 Shintaro Takemura. All rights reserved.
//

import UIKit

class SearchItemViewController: UIViewController {

    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var button: UIButton!
    
    var itemDataArray = [ItemData]()

    let appid = ""
    let entryUrl = "https:shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        
        activityIndicator.hidesWhenStopped = true
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 70
        tableView.register(UINib(nibName: "SearchItemTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func buttonTapped(sender: UIButton) {
        print("button tapped")
    }

}


extension SearchItemViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        activityIndicator.startAnimating()
        
        guard let inputText = searchBar.text else { return }
        
        guard inputText.lengthOfBytes(using: String.Encoding.utf8) > 0 else { return }
        
        itemDataArray.removeAll()
        
        let parameter = ["appid": appid, "query": inputText]
        let requestUrl = createRequestUrl(parameter: parameter)
        
        print("requestUrl: \(requestUrl)")
        
        // Web API Request
        request(requestUrl: requestUrl)
        
        searchBar.resignFirstResponder()
    }

    func createRequestUrl(parameter: [String: String]) -> String {
        var parameterString = ""
        
        for key in parameter.keys {
        
            print("key: \(key)")
            
            guard let value = parameter[key] else { continue }
            
            print("value: \(value)")
            
            if parameterString.lengthOfBytes(using: String.Encoding.utf8) > 0 {
                parameterString += "&"
            }
            
            guard let encodeValue = encodeParameter(key: key, value: value) else { continue }
            
            parameterString += encodeValue
        }
        
        let requestUrl = entryUrl + "?" + parameterString
        return requestUrl
    }
    
    
    func encodeParameter(key: String, value: String) -> String? {
        
        guard let escapedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            return nil
        }
        
        return "\(key)=\(escapedValue)"
    }
    
    
    func request(requestUrl: String) {
        
        guard let url = URL(string: requestUrl) else { return }
        
        let request = URLRequest(url: url)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) in
            
            guard error == nil else {
                
                let alert = UIAlertController(title: "エラー", message: error?.localizedDescription, preferredStyle: .alert)
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.present(alert, animated: true, completion: nil)
                }
                
                return
            }
            
            guard let data = data else { return }
            
            guard let jsonData = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else {
                
                return
            }
            
            guard let resultSet = jsonData["ResultSet"] as? [String: Any] else { return }
            
            self.parseData(resultSet: resultSet)
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
        
        task.resume()
    }
    
    
    func parseData(resultSet: [String: Any]) {
        
        guard let firstObject = resultSet["0"] as? [String: Any] else { return }
        
        guard let results = firstObject["Result"] as? [String: Any] else { return }
        
        for key in results.keys.sorted() {
            
            
            if key == "Request" { continue }
            
            guard let result = results[key] as? [String: Any] else { continue }
            
            var itemImageUrl: String?
            if let itemImageDic = result["Image"] as? [String: Any] {
                itemImageUrl = itemImageDic["Medium"] as? String
            }
            
            let itemTitle = result["Name"] as? String
            
            var itemPrice: String?
            if let itemPriceDic = result["Price"] as? [String: Any] {
                itemPrice = itemPriceDic["_value"] as? String
            }
            
            let itemUrl = result["Url"] as? String
            
            let itemData = ItemData(itemImageUrl: itemImageUrl, itemTitle: itemTitle, itemPrice: itemPrice, itemUrl: itemUrl)

            itemDataArray.append(itemData)
        }
    }
}


extension SearchItemViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // go to nextview
        let storyboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "WebVC") as! WebViewController
        
        nextView.itemUrl = itemDataArray[indexPath.row].itemUrl
        
        navigationController?.pushViewController(nextView, animated: true)
    }
}


extension SearchItemViewController: UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemDataArray.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as? SearchItemTableViewCell else {
            return UITableViewCell()
        }
        
        cell.itemData = itemDataArray[indexPath.row]
        return cell
    }
}



