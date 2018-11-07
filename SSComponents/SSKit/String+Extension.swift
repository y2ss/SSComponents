//
//  String+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/10/30.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit
import ObjectiveC

extension String {
    func trim() -> String {
        var str = self
        str = str.trimmingCharacters(in: CharacterSet.controlCharacters)
        str = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        return str
    }
    
    func midlleSpace() -> String {
        var str = self
        str = str.replacingOccurrences(of: " ", with: "")
        return str
    }
    
    func toHex() -> UInt32 {
        var result:UInt32 = 0
        Scanner(string: self).scanHexInt32(&result)
        return result
    }
    
    func sha11() -> String {
        guard let data = self.data(using: String.Encoding.utf8) else {
            log.error("字符串初始失敗")
            return ""
        }
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CC_SHA1(data.bytes, CC_LONG(data.count), &digest)
        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        for byte in digest {
            output.appendFormat("%02x", byte)
        }
        return output as String
    }
}
