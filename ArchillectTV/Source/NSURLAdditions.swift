//
//  NSURLAdditions.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/25/15.
//

import Foundation

extension URL {
    var requestParameters: [String : String]?
    {
        get
        {
            let urlComponents = self.absoluteString.components(separatedBy: "/")
            let paramsString = urlComponents[urlComponents.count - 1]
            let parameterComponents = paramsString.components(separatedBy: CharacterSet(charactersIn: "&?"))
            var dict: Dictionary<String, String> = Dictionary()
            
            for paramPair in parameterComponents {
                let kvPair = paramPair.components(separatedBy: "=")
                if (kvPair.count == 2 && kvPair[0].characters.count > 0) {
                    let key = kvPair[0].removingPercentEncoding!
                    let value = kvPair[1].removingPercentEncoding!
                    dict[key] = value
                }
            }
            
            return dict
        }
    }
    
    func URLByAppendingRequestParameters(_ params: [String : String]) -> URL?
    {
        var paramsString = ""
        
        for (key, value) in params {
            var delim = ""
            if (paramsString.characters.count == 0) {
                delim = "?"
            } else {
                delim = "&"
            }
            
            let keyParam = key.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            let valueParam = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            paramsString += "\(delim)\(keyParam!)=\(valueParam!)"
        }
    
        var absoluteString = self.absoluteString
        absoluteString += paramsString
        
        return URL(string: absoluteString)
    }
}
