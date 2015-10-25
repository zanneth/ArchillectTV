//
//  NSDataAdditions.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/25/15.
//

import Foundation

extension NSData {
    func jsonDataByTrimmingBytes() -> NSData?
    {
        let bytesPtr = UnsafePointer<UInt8>(self.bytes)
        let bytesBuf = UnsafeBufferPointer(start: bytesPtr, count: self.length)
        var jsonPayloadBeginIdx = 0
        
        for (idx, byte) in bytesBuf.enumerate() {
            let chr = Character(UnicodeScalar(byte))
            
            if (chr == Character("{") || chr == Character("[")) {
                jsonPayloadBeginIdx = idx
                break
            }
        }
        
        return NSData(bytes: bytesBuf.baseAddress + jsonPayloadBeginIdx, length: self.length - jsonPayloadBeginIdx)
    }
}
