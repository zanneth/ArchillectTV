//
//  NSURLAdditions.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/25/15.
//

import Foundation

extension NSURL {
    var requestParameters: [String : String]? {
        get
        {
            let urlComponents = self.absoluteString.componentsSeparatedByString("/")
            let paramsString = urlComponents[urlComponents.count - 1]
            let parameterComponents = paramsString.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "&?"))
            var dict: Dictionary<String, String> = Dictionary()
            
            for paramPair in parameterComponents {
                let kvPair = paramPair.componentsSeparatedByString("=")
                if (kvPair.count == 2 && kvPair[0].characters.count > 0) {
                    let key = kvPair[0].stringByRemovingPercentEncoding!
                    let value = kvPair[1].stringByRemovingPercentEncoding!
                    dict[key] = value
                }
            }
            
            return dict
        }
    }
    
    func URLByAppendingRequestParameters(params: [String : String]) -> NSURL?
    {
        var paramsString = ""
        
        for (key, value) in params {
            var delim = ""
            if (paramsString.characters.count == 0) {
                delim = "?"
            } else {
                delim = "&"
            }
            
            let keyParam = key.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            let valueParam = value.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            paramsString += "\(delim)\(keyParam!)=\(valueParam!)"
        }
    
        var absoluteString = self.absoluteString
        absoluteString += paramsString
        
        return NSURL(string: absoluteString)
    }
}
