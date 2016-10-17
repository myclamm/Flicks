//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by Mike Lam on 10/15/16.
//  Copyright © 2016 CodePath Tumblr. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var networkErrorView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    var movies : [NSDictionary]?
    var endpoint : String?
    let refreshControl = UIRefreshControl()
    
    override func viewWillAppear(_ animated: Bool) {
        if Reachability.isConnectedToNetwork() {
            if networkErrorView.isHidden == false {
                refreshData()
            }
            // Network connection available
            networkErrorView.isHidden = true
        } else {
            // Network connectino unavailable
            networkErrorView.isHidden = false
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        refreshData()
        refreshControl.addTarget(self, action: #selector(MoviesViewController.refreshData), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = movies {
            return movies.count
        } else {
            return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        let movie = self.movies![indexPath.row]
        let title = movie["title"] as! String
        let overview = movie["overview"] as! String
        
        let baseUrl = "http://image.tmdb.org/t/p/w500"
        
        if let posterPath = movie["poster_path"] as? String {
            let urlString = baseUrl + posterPath
            let url = URL(string:urlString)! as URL
            cell.posterView.setImageWith(url)
        }
        
        cell.titleLabel.text = title
        cell.overviewLabel.text = overview
        
        
        print("image \(cell.posterView.image)")
        return cell
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        
        let indexPath = tableView.indexPath(for: cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destination as! DetailViewController
        
        detailViewController.movie = movie
        
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func refreshData () {
        //Start loading spinner
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        // Check for internet connection
        if Reachability.isConnectedToNetwork() {
            // Network connection available
            networkErrorView.isHidden = true
            
            if let endpoint = endpoint {
                let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
                let url = URL(string:"https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
                
                let request = URLRequest(url: url!)
                let session = URLSession(
                    configuration: URLSessionConfiguration.default,
                    delegate:nil,
                    delegateQueue:OperationQueue.main
                )
                
                let task : URLSessionDataTask? = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    
                    //Handle error
                    if let error = error {
                        print("error \(error)")
                    }
                    
                    if let data = dataOrNil {
                        if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                            self.movies = responseDictionary["results"] as? [NSDictionary]
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                    }
                });
                
                if let task = task {
                    task.resume()
                } else {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
            }
            
            
        } else {
            // Network connection unavailable
            networkErrorView.isHidden = false
            MBProgressHUD.hide(for: self.view, animated: true)
        }
        
    }
    

}


