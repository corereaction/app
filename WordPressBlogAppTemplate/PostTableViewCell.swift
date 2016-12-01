import UIKit
import Kingfisher

class PostTableViewCell: UITableViewCell {

    @IBOutlet var mainView: UIView!
    @IBOutlet var postTitleLabel: UILabel!
    @IBOutlet var featuredImage: UIImageView!
    
    func setPost(_ post:Posts) {
       
        mainView.layer.cornerRadius = 10
        mainView.layer.masksToBounds = true

        postTitleLabel.text = post.postTitle?.htmlEncodedString()

        if let stringURL = post.postFeaturedImageURL {
            if let url = URL(string: stringURL)  {
                self.featuredImage.kf_setImage(with: url, placeholder: #imageLiteral(resourceName: "Placeholder"), options: [], progressBlock: nil, completionHandler: nil)
            }
        } else {
            self.featuredImage.image = UIImage(named:"Placeholder")

        }

    }
}
