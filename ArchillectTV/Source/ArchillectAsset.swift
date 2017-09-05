//
//  ArchillectAsset.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/25/15.
//

import Foundation

struct ArchillectAsset {
    enum AssetType {
        case unknown
        case gif
    }
    
    var type:   AssetType   = .unknown
    var url:    URL?
    var index:  UInt        = 0
    
    init()
    {}
    
    init(_ responseData: Data)
    {
        let jsonData = responseData.jsonDataByTrimmingBytes()
        if let objs = (try? JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions())) as? NSArray {
            if (objs.count >= 2) {
                // first object is the type. second object is our payload
                if let typeStr = objs[0] as? NSString {
                    switch (typeStr) {
                    case "gif":
                        self.type = .gif
                    default:
                        self.type = .unknown
                    }
                }
                
                if let dict = objs[1] as? NSDictionary {
                    if let indexNum = dict["index"] as? NSNumber {
                        self.index = indexNum.uintValue
                    }
                    
                    var assetKey: String? = nil
                    switch (self.type) {
                    case .gif:
                        assetKey = "gif"
                    default:
                        assetKey = nil
                    }
                    
                    if (assetKey != nil) {
                        if let assetURLString = dict[assetKey!] as? NSString {
                            self.url = URL(string: assetURLString as String)!
                        }
                    }
                }
            }
        }
    }
}
