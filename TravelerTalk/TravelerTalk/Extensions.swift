//
//  Extensions.swift
//  everybodyChats
//
//  Created by seokhyun kim on 2017-08-11.
//  Copyright © 2017 seokhyun kim. All rights reserved.
//

import UIKit

let imageCache = NSCache<NSString, UIImage>()

extension UIImageView {
    
    
    func loadImageUsingCacheWithString(urlString: String) {
        self.image = nil
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, responese, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error ?? String())
                return
            }
            DispatchQueue.main.async{
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as NSString)
                    self.image = downloadedImage
                }
            }
            //                cell.imageView?.image = UIImage(data: data!)
        }).resume()
    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
