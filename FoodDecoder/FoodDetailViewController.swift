//
//  FoodDetailViewController.swift
//  FoodDecoder
//
//  Created by Boris Conforty on 10/02/16.
//  Copyright © 2016 Boris Conforty. All rights reserved.
//

import UIKit

class FoodDetailViewController: UIViewController {
    
    @IBOutlet weak var _webView: UIWebView?
    @IBOutlet weak var _doneButton: UIButton?
    
    var _url: NSURL?
        
    @IBAction func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil);
    }
    
    func prepareURLForDetails(detail: String) {
        var url: NSURL?
        if detail.hasPrefix("http") {
            url = NSURL(string: detail.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        } else {
            url = NSURL(string: "https://codecheck.info/m/product.search?q=\(detail)&OK=Suchen".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!)
        }

        _url = url;
    }
    
    override func viewWillAppear(animated: Bool) {
        showUrl(_url!)
        
        self.preferredContentSize = CGSizeMake(800, 800)
    }
    
    private func showUrl(url: NSURL) {
        if _url != nil {
            _webView?.loadRequest(NSURLRequest(URL: url))
        }
    }
}
