//
//  ArchillectError.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/25/15.
//

import Foundation

struct ArchillectError : LocalizedError {
    enum ErrorCode {
        case unknown
        case connectionError
        case invalidSession
        case serverError
    }
    
    let code: ErrorCode
    var debugDescription: String? = nil
    
    init(_ code: ErrorCode)
    {
        self.code = code
    }
    
    public var errorDescription: String?
    {
        switch self.code {
        case .unknown:
            return "Unknown"
        case .connectionError:
            return "ConnectionError"
        case .invalidSession:
            return "InvalidSession"
        case .serverError:
            return "ServerError"
        }
    }
}
