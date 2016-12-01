import UIKit

class FooterLoadingView: UIView {

    @IBOutlet var activityIndicator:UIActivityIndicatorView!

    override var isHidden:Bool {
        get {
            return super.isHidden
        }
        set(hidden) {
            super.isHidden = hidden
            if (activityIndicator != nil) {
                if hidden {
                    self.activityIndicator.stopAnimating()
                } else {
                    self.activityIndicator.startAnimating()
                }
            }
        }
    }

}

