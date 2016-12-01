import UIKit
import WebKit
//import iAd

class PostDetailTableViewController: UITableViewController, WKNavigationDelegate {

    var post:Posts?
    var footerView = WKWebView()
    var contentString = "Could not load content"
    //var adView: ADBannerView?
    var shareBarButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup navigation buttons
        shareBarButton =  UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(PostDetailTableViewController.presentShareSheet))
        navigationItem.rightBarButtonItems = [shareBarButton]

        // Load CSS to style post content
        if let cssPath = Bundle.main.url(forResource: "default", withExtension: "css") {
            do {
                let cssString = try NSString(contentsOf: cssPath, encoding: String.Encoding.utf8.rawValue)
                if let content = post?.postContent {
                    contentString = (cssString as String) + content
                }
                
            } catch _ as NSError {
                
            }
        }

        footerView.loadHTMLString(contentString, baseURL: nil)
        footerView.navigationDelegate = self
        footerView.scrollView.isScrollEnabled = false
        footerView.frame.size.height = view.frame.size.height
        
        tableView.tableFooterView = footerView
        tableView.estimatedRowHeight = 100.0
        
//        if Settings.Bools.showAds {
//            // Set up ads
//            adView = ADBannerView(adType: ADAdType.Banner)
//            if (adView != nil) {
//                adView!.delegate = self
//                self.tableView.tableHeaderView = adView
//            }
//        }

        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: WebKit
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        webView.evaluateJavaScript("document.documentElement.scrollHeight", completionHandler: { (contentHeight, Error) -> Void in
            if let calculatedHeight = contentHeight as? CGFloat {
                self.footerView.frame.size.height = calculatedHeight
            } else {
                self.footerView.frame.size.height = 1500
            }
            self.tableView.tableFooterView = self.footerView
        })
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            guard let url = navigationAction.request.url else {
                 decisionHandler(.cancel)
                return
            }
            UIApplication.shared.openURL(url)
             decisionHandler(.cancel)
            return
        }
            decisionHandler(.allow)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 0
        case 1: return 1
        default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: if let _ = post?.postFeaturedImageURL {
                    return 200
                } else {
                    return 0
                }
        default: return 0
        }
        
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
       
        case 0:
            let reuseIdentifier = "header"
            if let stringURL = post?.postFeaturedImageURL {
                let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! PostDetailHeaderTableViewCell
                if let url = URL(string: stringURL)  {
                    cell.featuredImage.kf_setImage(with: url, placeholder: #imageLiteral(resourceName: "Placeholder"), options: [], progressBlock: nil, completionHandler: nil)
                    cell.featuredImage.contentMode = UIViewContentMode.scaleAspectFill
                    return cell
                }
            }
            // There is no Image
            return nil
            
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "meta", for: indexPath) as! PostDetailMetaTableViewCell
        
        cell.postTitleLabel.textColor = Settings.Colors.postDetailTableViewCellTitleColor
        cell.postDetailsLabel.textColor = Settings.Colors.postDetailTableViewCellMetaColor
        cell.postTitleLabel.text = post?.postTitle?.htmlEncodedString()

        guard let date = post?.postDate else {
            cell.postDetailsLabel.text = ""
            return cell
        }
        guard let author = post?.postAuthor else {
            cell.postDetailsLabel.text = ""
            return cell
        }
        cell.postDetailsLabel.text = "\(author) - \(toFormattedString(date))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
  
   // Share sheet

    func presentShareSheet() {

        var objectsToShare = [AnyObject]()

        // Set Post title
        if let textToShare = post?.postTitle?.htmlEncodedString() {

            objectsToShare.append(textToShare as AnyObject)

        }

        // Set URL
        if let urlString = post?.postURL {
            if let url = URL(string: urlString) {
                objectsToShare.append(url as AnyObject)
            }
        }

        // Set image
        if let stringURL = post?.postFeaturedImageURL {
            if let url = URL(string: stringURL)  {
                let imageView = UIImageView()
                imageView.kf_setImage(with: url, placeholder: nil, options: [], progressBlock: nil, completionHandler: nil)
                if let image = imageView.image {
                    objectsToShare.append(image)
                }

            }
        }

        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

        activityVC.excludedActivityTypes = [UIActivityType.assignToContact, UIActivityType.postToVimeo]
        activityVC.popoverPresentationController?.barButtonItem = shareBarButton
        activityVC.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.up

        present(activityVC, animated: true, completion: nil)

    }
  
}
