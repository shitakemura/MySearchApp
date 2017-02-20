//
//  SearchItemTableViewCell.swift
//  MySearchApp
//
//  Created by Shintaro Takemura on 2017/02/19.
//  Copyright © 2017年 Shintaro Takemura. All rights reserved.
//

import UIKit

class SearchItemTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemTitleLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!
    
    var itemUrl: String?
    
    var imageCache = NSCache<AnyObject, UIImage>()
    let priceFormat = NumberFormatter()
    
    var itemData = ItemData() {
        didSet {
            
            itemTitleLabel.text = itemData.itemTitle
            
            let number = NSNumber(integerLiteral: Int(itemData.itemPrice!)!)
            priceFormat.numberStyle = .currency
            priceFormat.currencyCode = "JPY"
            itemPriceLabel.text = priceFormat.string(from: number)
            
            itemUrl = itemData.itemUrl
            
            guard let itemImageUrl = itemData.itemImageUrl else {
                return
            }
            
            if let cacheImage = imageCache.object(forKey: itemImageUrl as AnyObject) {
                itemImageView.image = cacheImage
                return
            }
            
            guard let url = URL(string: itemImageUrl) else {
                return
            }
            
            let request = URLRequest(url: url)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request) { (data: Data?, reqponse: URLResponse?, error: Error?) in
                
                guard error == nil else { return }
                guard let data = data else { return }
                guard let image = UIImage(data: data) else { return }
                
                // add image to cache
                self.imageCache.setObject(image, forKey: itemImageUrl as AnyObject)
                
                DispatchQueue.main.async {
                    self.itemImageView.image = image
                }
            }
            
            task.resume()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    override func prepareForReuse() {
        itemImageView.image = nil
    }
    
}
