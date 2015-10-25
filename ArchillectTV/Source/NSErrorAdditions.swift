//
//  NSErrorAdditions.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/25/15.
//

import Foundation

enum ArchillectErrorCode : Int {
    case Unknown
    case ConnectionError
    case InvalidSession
    case ServerError
}

extension NSError {
    private static let ArchillectErrorDomain = "com.zanneth.archillect.tv"
    
    class func archillectError(code: ArchillectErrorCode) -> NSError
    {
        return self.archillectError(code, underlying: nil)
    }
    
    class func archillectError(code: ArchillectErrorCode, underlying: NSError?) -> NSError
    {
        var userInfo: [NSObject : AnyObject]? = nil
        if (underlying != nil) {
            userInfo = [
                NSUnderlyingErrorKey : underlying!
            ]
        }
        
        return self.archillectError(code, userInfo: userInfo)
    }
    
    class func archillectError(code: ArchillectErrorCode, userInfo: [NSObject : AnyObject]?) -> NSError
    {
        return NSError(domain: ArchillectErrorDomain, code: code.rawValue, userInfo: userInfo)
    }
}
