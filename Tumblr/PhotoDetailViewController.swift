//
//  PhotoDetailViewController.swift
//  Tumblr
//
//  Created by Mei-Ling Laures on 6/22/17.
//  Copyright © 2017 Dominique Adapon. All rights reserved.
//

import UIKit

class PhotoDetailViewController: UIViewController {

    // need the linked image that we will display it in
    @IBOutlet weak var imageView: UIImageView!
    
    // make a dictionary of all of the post's information
    var dict: [String: Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // find the image that will be displayed in the detail view
    override func viewWillAppear(_ animated: Bool) {
        if let photos = dict["photos"] as? [[String: Any]] {
            let photo = photos[0]
            let originalSize = photo["original_size"] as! [String: Any]
            let urlString = originalSize["url"] as! String
            let url = URL(string: urlString)
            
            // display the image using Alamofire
            imageView.af_setImage(withURL: url!)
            
        }
    }

}
