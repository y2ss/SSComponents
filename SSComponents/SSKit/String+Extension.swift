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
    
    subscript (r: Range<Int>) -> String {
        if r.lowerBound > count || r.upperBound > count {
            fatalError("string substring error")
        }
        let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
        return String(self[startIndex ..< endIndex])
    }
    
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }
    
    func trim() -> String {
        var str = self
        str = str.trimmingCharacters(in: CharacterSet.controlCharacters)
        str = str.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return str
    }
    
    func middleSpace() -> String {
        var str = self
        str = str.replacingOccurrences(of: " ", with: "")
        return str
    }
    
    func toHex() -> UInt32 {
        var result:UInt32 = 0
        Scanner(string: self).scanHexInt32(&result)
        return result
    }
    
    func hexStringToData() -> Data? {
        guard let bytes = self.toBytes() else { return nil }
        return Data(bytes: bytes)
    }
    
    //16进制字符串转化为 [UInt8]
    func toBytes() -> [UInt8]? {
        if self.count % 2 != 0 { return nil }
        var bytes = [UInt8]()
        var sum = 0
        let intRange = 48 ... 57
        let lowercaseRange = 97 ... 102
        let uppercaseRange = 65 ... 70
        for (index,c ) in self.utf8CString.enumerated() {
            var intC = Int(c.byteSwapped)
            if intC == 0 {
                break
            } else if intRange.contains(intC) {
                intC -= 48
            } else if lowercaseRange.contains(intC) {
                intC -= 87
            } else if uppercaseRange.contains(intC) {
                intC -= 55
            } else {
                return nil
            }
            sum = sum * 16 + intC
            if index % 2 != 0 {
                bytes.append(UInt8(sum))
                sum = 0
            }
        }
        return bytes
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
    
    
    //计算文字高度
    func height(with font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize), constrainedWidth: CGFloat) -> CGFloat {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
       
        let attrs = [
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.paragraphStyle: paragraph
        ]
        let textSize = (self as NSString)
            .boundingRect(with: CGSize(width: constrainedWidth, height: 9999),
                          options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                          attributes: attrs,
                          context: nil)
            .size
    
        return textSize.height
    }

    
    //计算文字宽度
    func width(with font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize), constrainedHeight: CGFloat) -> CGFloat {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .byWordWrapping
        
        let attrs = [
            NSAttributedString.Key.font : font,
            NSAttributedString.Key.paragraphStyle: paragraph
        ]
        let textSize = (self as NSString)
            .boundingRect(with: CGSize(width: 9999, height: constrainedHeight),
                          options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
                          attributes: attrs,
                          context: nil)
            .size
        return textSize.width
    }
    
    //json string to dictionary
    var jsonStringToDictnary: Dictionary<String, Any>? {
        if let _data = self.data(using: .utf8) {
            do {
                let jsonDict = try JSONSerialization.jsonObject(with: _data, options: .allowFragments)
                return jsonDict as? Dictionary<String, Any>
            } catch {
                log.debug(error)
            }
        }
        return nil
    }
    
    func jsonStringToModel<T>(_ model: T.Type) -> T? where T : Decodable {
        if let _data = self.data(using: .utf8) {
            do {
                let model = try JSONDecoder().decode(T.self, from: _data)
                return model
            } catch {
                log.debug(error)
            }
        }
        return nil
    }

    var isContainChinese: Bool {
        let length = self.count
        for i in 0 ..< length {
            let subStr = self[i ..< i + 1]
            let cStr = subStr.utf8
            if cStr.count == 3 {
                return true
            }
        }
        return false
    }
    
}


