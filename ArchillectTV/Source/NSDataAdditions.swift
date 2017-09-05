//
//  NSDataAdditions.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/25/15.
//

import Foundation

extension Data {
    func jsonDataByTrimmingBytes() -> Data?
    {
        let bytesPtr = (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: self.count)
        let bytesBuf = UnsafeBufferPointer(start: bytesPtr, count: self.count)
        var jsonPayloadBeginIdx = 0
        
        for (idx, byte) in bytesBuf.enumerated() {
            let chr = Character(UnicodeScalar(byte))
            
            if (chr == Character("{") || chr == Character("[")) {
                jsonPayloadBeginIdx = idx
                break
            }
        }
        
        return Data(bytes: UnsafePointer<UInt8>(bytesBuf.baseAddress! + jsonPayloadBeginIdx), count: self.count - jsonPayloadBeginIdx)
    }
}
