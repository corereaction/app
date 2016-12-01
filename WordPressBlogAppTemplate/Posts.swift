import Foundation
import UIKit

struct Posts {
     var postID: Int?
     var postContent: String?
     var postDate: String?
     var postFeaturedImageURL: String?
     var postLink: String?
     var postModified: String?
     var postTitle: String?
     var postAuthor: String?
     var postURL: String?
    
    init(post:NSDictionary) {
        
        postID = post["id"] as? Int
        postDate = post["date_gmt"] as? String
        postLink = post["link"] as? String
        postModified = post["modified"] as? String
        postURL = post["link"] as? String
        
        if let contentDictionary: NSDictionary = post["content"] as? NSDictionary {
            if let content = getRenderedContent(contentDictionary) {
                postContent = content
            }
        }
        
        if let titleDictionary: NSDictionary = post["title"] as? NSDictionary {
            if let title = getRenderedContent(titleDictionary) {
                postTitle = title
            }
        }
        
        if let embeddedContent = post["_embedded"] as? NSDictionary {
            // Author
            if let authorInfo = embeddedContent["author"] as? NSArray {
                if let authorDict = authorInfo[0] as? NSDictionary {
                    postAuthor = authorDict["name"] as? String
                }

            }
            // Featured Image
            // Pre beta 13
            if let preBeta13 = embeddedContent["https://api.w.org/featuredmedia"] as? NSArray {
                postFeaturedImageURL = getFeaturedImage(mediaArray: preBeta13)
            }

            // Support CURIE change in beta 13+
            if let curieFM = embeddedContent["wp:featuredmedia"] as? NSArray {
                postFeaturedImageURL = getFeaturedImage(mediaArray: curieFM)
            }

        }
        
    }
    
    func getFeaturedImage(mediaArray: NSArray) -> String? {
        if let mediaArray = mediaArray[0] as? NSDictionary {
            if let mediaDetails = mediaArray["media_details"] as? NSDictionary {
                if let sizes = mediaDetails["sizes"] as? NSDictionary {
                    if let featuredMedia = sizes["\(Settings.Strings.featuredImageSize)"] as? NSDictionary {
                        if let mediaURL = featuredMedia["source_url"] as? String {
                            return mediaURL
                        }
                    }
                }
            }
        }
        return nil
    }
    func getRenderedContent(_ renderedDict:NSDictionary) -> String? {
       
        if let renderedValue = renderedDict["rendered"] as? String {
            return renderedValue
        }
        return nil
    }
    
}
