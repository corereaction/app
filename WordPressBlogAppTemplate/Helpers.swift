import UIKit

// Replaces html entities
extension String {
    func htmlEncodedString() -> String?  {
        guard let encodedData = self.data(using: String.Encoding.utf8) else {
            return nil
        }
        
        let attributedOptions : [String: Any] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue
        ]
        
        var attributedString: NSAttributedString?
        do {
            attributedString = try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        } catch let error as NSError {
            print(error)
        }
        
        return attributedString?.string
    }
}

func toFormattedString(_ dateString:String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    
    if let date = dateFormatter.date(from: dateString) {
        dateFormatter.locale = Locale.current
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = .none
        let formattedDate = dateFormatter.string(from: date)
        
        return formattedDate

    }
    
    return ""
}
