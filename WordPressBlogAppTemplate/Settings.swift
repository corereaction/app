import UIKit

struct Settings {
    
    struct Strings {
        static let website = "http://cop13.mx/"
        static let siteName = "COP 13"
        static let featuredImageSize = "large"
        static let noMorePostsText = "No hay nada más que leer."
        static let noConnectionText = "No hay conexión, por favor vuelva a intentarlo."
        static let loadingPostsText = "Cargando..."
    }
    struct Colors {
        // Custom Colors
        static let myBlueColor = UIColor(red: 78.0/255.0, green: 178.0/255.0, blue: 207.0/255.0, alpha: 1.0)
        
        // Elements
        static let caption = UIColor.black.withAlphaComponent(0.8)
        static let title = UIColor.black
        static let errorMessageColor = UIColor.black
        static let postTableViewControllerNavigationBarTintColor = UIColor.black
        static let postTableViewControllerNavigationBarBackgroundColor = UIColor.white
        static let postTableViewControllerNavigationTitleColor = Colors.title
        static let postDetailTableViewCellTitleColor = Colors.title
        static let postDetailTableViewCellMetaColor = Colors.caption
        
    }
    struct Bools {
        static let showAds = false
    }
    
}
enum CellIdentifiers: String {
    case postCell
}
enum SegueIdentifiers: String {
    case showPostDetails
}

enum Errors : Error {
    case couldNotConnect, unknown
}
