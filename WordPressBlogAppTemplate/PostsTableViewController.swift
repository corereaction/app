import UIKit
//import iAd

class PostsTableViewController: UITableViewController {
    
    @IBOutlet var footerLoadingView:FooterLoadingView!
    @IBOutlet var footerLabel: UILabel!
    
    var postsArray: [Posts] = Array()
    var currentPage: Int = 1
    var totalPosts: Int = 0
    var totalPages: Int = 0
    //var adView: ADBannerView?
    var didAnimateCell:[IndexPath: Bool] = [:]
    
    //search alien
    var filteredPosts = [Posts]()
    
    
    //search alien
    let searchController = UISearchController(searchResultsController: nil)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(PostsTableViewController.getLatestPosts(_:)), for: UIControlEvents.valueChanged)
        self.refreshControl?.beginRefreshing()
      
        getBlogPosts(currentPage)
        
        footerLoadingView.isHidden = true
        
        // Set preferences
        self.title = Settings.Strings.siteName
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.tintColor = Settings.Colors.postTableViewControllerNavigationBarTintColor
        navigationController?.navigationBar.barTintColor = Settings.Colors.postTableViewControllerNavigationBarBackgroundColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: Settings.Colors.postTableViewControllerNavigationTitleColor]
        navigationController?.navigationBar.isTranslucent = true

        // Removing iAd since Apple shut it down
//        if Settings.Bools.showAds {
//            // Set up ads
//            adView = ADBannerView(adType: ADAdType.Banner)
//            if (adView != nil) {
//                adView!.delegate = self
//                self.tableView.tableHeaderView = adView
//            }
//        }
        
        //search alien
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar

    }

    func getLatestPosts(_ sender:AnyObject) {
        
//         postsArray.removeAll()
         getBlogPosts(1)
    }
    func getBlogPosts(_ page:Int) {
        
        let baseURL = URL(string: Settings.Strings.website)
        guard let getPostsURL = URL(string: "wp-json/wp/v2/posts?_embed&page=\(page)", relativeTo: baseURL) else { return }
        let sessionConfig = URLSessionConfiguration.default
        let sharedSession = URLSession(configuration: sessionConfig)
        
        let downloadPosts: URLSessionDownloadTask = sharedSession.downloadTask(with: getPostsURL) { (location, response, error) -> Void in
        
            if (error == nil) {
                
                guard let url = location else {  self.refreshControl?.endRefreshing(); self.showErrorMessage(); return }
                guard let dataObject = try? Data(contentsOf: url) else {  self.refreshControl?.endRefreshing(); self.showErrorMessage(); return }
                guard let httpHeaders = response as? HTTPURLResponse else {  self.refreshControl?.endRefreshing(); self.showErrorMessage(); return }
                guard let headerDict = httpHeaders.allHeaderFields as Any as? NSDictionary else {  self.refreshControl?.endRefreshing(); self.showErrorMessage(); return }
                guard let myTotalPostsString: String = headerDict["X-WP-Total"] as? String else {  self.refreshControl?.endRefreshing(); self.showErrorMessage(); return }
                guard let myTotalPagesString: String = headerDict["X-WP-TotalPages"] as? String else {  self.refreshControl?.endRefreshing(); self.showErrorMessage(); return }
               
                self.totalPosts = Int(myTotalPostsString) ?? 0
                self.totalPages = Int(myTotalPagesString) ?? 0
                
                guard let blogPostArray: NSArray = (try! JSONSerialization.jsonObject(with: dataObject, options: [])) as? NSArray else { return }
                
                if (blogPostArray.count > 0) {
                    self.postsArray.removeAll()
                    for blogPost in blogPostArray as! [NSDictionary] {
                    
                        let newPost = Posts(post: blogPost)
                        self.postsArray.append(newPost)
                    
                    }
                
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        self.tableView.reloadData()
                        if ((self.refreshControl) != nil) {
                            self.refreshControl?.endRefreshing()
                         }
                        self.footerLoadingView.isHidden = true
                  
                    })
                } else {
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.refreshControl?.endRefreshing()
                        self.footerLoadingView.activityIndicator.isHidden = true
                        self.footerLabel.text = Settings.Strings.noMorePostsText
                        
                    })
                }
            }
            else {
                
                self.refreshControl?.endRefreshing()
                self.showErrorMessage()
                
            }
            
        } 
        
        downloadPosts.resume()
        
    }

    func showErrorMessage() {
        
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            messageLabel.text = Settings.Strings.noConnectionText
            messageLabel.textColor = Settings.Colors.errorMessageColor
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font.withSize(20)
            messageLabel.sizeToFit()
            
            DispatchQueue.main.async(execute: { () -> Void in
                self.tableView.backgroundView = messageLabel
            })

    }

    
    func loadMorePosts() {
        
        self.footerLoadingView.isHidden = false
        self.footerLabel.text = Settings.Strings.loadingPostsText
        
        if currentPage < totalPages {
            
            currentPage = currentPage + 1
            getBlogPosts(currentPage)
        
        } else {
           
            DispatchQueue.main.async(execute: { () -> Void in
                self.refreshControl?.endRefreshing()
                self.footerLoadingView.activityIndicator.isHidden = true
                self.footerLabel.text = Settings.Strings.noMorePostsText
            
            })

        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - TableView

    override func numberOfSections(in tableView: UITableView) -> Int {
    
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text!  == "" {
            return filteredPosts.count
        }
        return self.postsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.postCell.rawValue , for: indexPath) as! PostTableViewCell
        
        let posts: Posts
        if searchController.isActive && searchController.searchBar.text != "" {
            posts = filteredPosts[indexPath.row]
        }
        else {
            posts = postsArray[indexPath.row]
            
        }
        if ((indexPath as NSIndexPath).row == self.postsArray.count - 1) {

            loadMorePosts()
            
        }
        
        return cell
        
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        
        if didAnimateCell[indexPath] == nil || didAnimateCell[indexPath]! == false {
            didAnimateCell[indexPath] = true
            let view = cell.contentView
        
            view.layer.opacity = 0.6
        
            UIView.animate(withDuration: 0.4, animations: {
            view.layer.transform = CATransform3DIdentity
            view.layer.opacity = 1

        }) 
      }
        
        let post: Posts = self.postsArray[(indexPath as NSIndexPath).row]
        
        if let postCell = cell as? PostTableViewCell {
            postCell.setPost(post)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifiers.showPostDetails.rawValue {
            if let row = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                let destinationController = segue.destination as! PostDetailTableViewController
                destinationController.post = self.postsArray[row]
                
            }
        }
    }

   
    func filterContentForSearchText(searchText: String, scope: String = "All"){
        filteredPosts = postsArray.filter { postsArray in
            return (postsArray.postTitle?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
    }
    
    
}

extension PostsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
