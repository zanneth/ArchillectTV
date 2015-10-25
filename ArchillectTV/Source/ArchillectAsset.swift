//
//  ArchillectAsset.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/25/15.
//

import Foundation

struct ArchillectAsset {
    enum Type {
        case Unknown
        case GIF
    }
    
    var type:   Type    = .Unknown
    var url:    NSURL   = NSURL()
    var index:  UInt    = 0
    
    init()
    {}
    
    init(_ responseData: NSData)
    {
        let jsonData = responseData.jsonDataByTrimmingBytes()
        if let objs = (try? NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions())) as? NSArray {
            if (objs.count >= 2) {
                // first object is the type. second object is our payload
                if let typeStr = objs[0] as? NSString {
                    switch (typeStr) {
                    case "gif":
                        self.type = .GIF
                    default:
                        self.type = .Unknown
                    }
                }
                
                if let dict = objs[1] as? NSDictionary {
                    if let indexNum = dict["index"] as? NSNumber {
                        self.index = indexNum.unsignedIntegerValue
                    }
                    
                    var assetKey: String? = nil
                    switch (self.type) {
                    case .GIF:
                        assetKey = "gif"
                    default:
                        assetKey = nil
                    }
                    
                    if (assetKey != nil) {
                        if let assetURLString = dict[assetKey!] as? NSString {
                            self.url = NSURL(string: assetURLString as String)!
                        }
                    }
                }
            }
        }
    }
}
