//
//  PhotosViewController.swift
//  Tumblr
//
//  Created by Dominique Adapon on 6/21/17.
//  Copyright © 2017 Dominique Adapon. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    // link the table view to the controller
    @IBOutlet weak var photoTable: UITableView!
    
    // make a list for all the posts that it will be going to
    var posts: [[String: Any]] = []

    var refreshControl: UIRefreshControl!
    var loadingData: Bool = false
    
    let limit = 10
    var pageCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // enable refresh control for the table view
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PhotosViewController.didPullToRefresh(_:)), for: .valueChanged)
        
        // to actually see the loading symbol
        photoTable.insertSubview(refreshControl, at: 0)
        
        // make this view controller control and be the source for the table view data
        photoTable.delegate = self
        photoTable.dataSource = self
        
        loadingData = true
        fetchPosts()
        
    }
    
    // calls the fetch function whenever the refresh control is called
    func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        loadingData = true
        fetchPosts()
    }
    
    // function to call the network for new information
    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV&limit=\(limit)&offset=" + String(pageCount * limit))!
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        session.configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        // make the task that finds the data
        let task = session.dataTask(with: url) { (data,response, error) in
            if let error = error {
                print (error.localizedDescription)
            } else if let data = data,
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                
                // this is what we got from the API call to the network
                let responseDictionary = dataDictionary["response"] as! [String:Any]
                
                // put the posts that we got into the controller variable
                self.posts += responseDictionary["posts"] as! [[String: Any]]
                
                // reload the table's data after we actually have the data
                self.photoTable.reloadData()
                
                // the network has finished fetching data, so if table is refreshing, end the loading signal
                self.refreshControl.endRefreshing()
                
                // data is no longer loading
                self.loadingData = false
            }
            
        }
        
        // make sure the task actually runs
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    // the table should have as many rows as there are posts
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    // this function shows what should be in each post
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // for each cell, it is a copy of the reusable cell that we have made
        let cell = photoTable.dequeueReusableCell(withIdentifier: "PhotoCell") as! PhotoCell
        // find the post that we actually need
        let post = posts[indexPath.row]
        
        // find the image that we are going to display in the app
        if let photos = post["photos"] as? [[String: Any]] {
            let photo = photos[0]
            let originalSize = photo["original_size"] as! [String: Any]
            let urlString = originalSize["url"] as! String
            let url = URL(string: urlString)
            
            // display the image in the cell using AlamofireImage pod
            cell.imageDisplay.af_setImage(withURL: url!)

        }
        
        return cell
    }
    
    // get rid of the gray selection animation
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    // in the case that a photo is chosen to be gone into
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // set the view that is going to, the cell that is has come from to find the row
        let control = segue.destination as! PhotoDetailViewController
        let cell = sender as! PhotoCell
        let indexPath = photoTable.indexPath(for: cell)!
        
        // pass the information from the particular post to the new view so it can deal with the information
        control.dict = posts[indexPath.row]
        
    }
    

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // only if no data is being loaded should we be calling the network
        if (!loadingData) {
            let scrollViewContentHeight = photoTable.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - photoTable.bounds.size.height
            
            if scrollView.contentOffset.y > scrollOffsetThreshold, photoTable.isDragging {
                loadingData = true
                pageCount += 1
                fetchPosts()
                
            }
        }
    }
}
