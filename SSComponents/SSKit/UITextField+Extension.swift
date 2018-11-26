//
//  UITextField+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/15.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

extension UITextField {
    
    //当前选中的字符串范围
    var selectedRange: NSRange? {
        if let selectedRange = self.selectedTextRange {
            let selectedStart = selectedRange.start
            let selectedEnd = selectedRange.end
            let location = self.offset(from: beginningOfDocument, to: selectedStart)
            let length = self.offset(from: selectedStart, to: selectedEnd)
            return NSRange.init(location: location, length: length)
        }
        return nil
    }
    
    //选中所有文字
    func selectAllText() {
        let range = self.textRange(from: beginningOfDocument, to: endOfDocument)
        self.selectedTextRange = range
    }
    
    //选中指定范围的文字
    func selectedRange(_ range: NSRange) {
        if
            let start = self.position(from: beginningOfDocument, offset: range.location),
            let end = self.position(from: beginningOfDocument, offset: NSMaxRange(range)) {
            let selectedRange = self.textRange(from: start, to: end)
            self.selectedTextRange = selectedRange
        }
    }
}

//MARK: - input number 格式化
extension UITextField {
    enum NumberFormatType {
        case idCard//身份证号
        case phone//手机号
        case bankCard//银行卡
    }
    
    private struct Constant {
        static let phoneLength = 11
        //手机号334格式空格处光标所处位置:3，8
        static let phone1st = 3
        static let phone2nd = 8
        
        static let idCardLength = 18
        //身份证号684格式空格处光标所处位置:6，15
        static let idCard1st = 6
        static let idCard2nd = 15
        
        static let bankCardLength = 24
        //银行卡证号684格式空格处光标所处位置:4，9，14，19，24
        static let bankCard1st = 4
        static let bankCard2nd = 9
        static let bankCard3rd = 14
        static let bankCard4th = 19
        static let bankCard5th = 24
    }
    
    /*
     eg:
     func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textfield.formatting(shouldChangeCharactersin: range, replaceString: string, type: .bankCard)
     }
     */
    func formatting(shouldChangeCharactersin range: NSRange, replaceString: String, type: NumberFormatType) -> Bool {
        guard let text = self.text else { return false }
        //delete
        if replaceString == "" {
            if range.length == 1 {//最后一位
                if range.location == text.count - 1 {
                    return true
                } else {
                    var offset = range.location
                    if range.location < text.count && text[range.location] == " " {
                        if let _range = self.selectedTextRange {
                            if _range.isEmpty {
                                self.deleteBackward()
                                offset -= 1
                            }
                        }
                    }
                    self.deleteBackward()
                    self.text = insert(text, type: type)
                    if let newPos = self.position(from: self.beginningOfDocument, offset: offset) {
                        self.selectedTextRange = self.textRange(from: newPos, to: newPos)
                    }
                    return false
                }
            } else if range.length > 1 {
                var isLast = false
                if range.location + range.length == text.count {
                    isLast = true
                }
                self.deleteBackward()
                self.text = insert(text, type: type)
                var offset = range.location
                changeCharacters(in: range, type: type, offset: &offset)
                if !isLast {
                    if let newPos = self.position(from: self.beginningOfDocument, offset: offset) {
                        self.selectedTextRange = self.textRange(from: newPos, to: newPos)
                    }
                }
                return false
            } else {
                return true
            }
        } else if replaceString.count > 0 {
            switch type {
            case .idCard:
                if text.middleSpace().count + replaceString.count - range.length > Constant.idCardLength {
                    return false
                }
                break
            case .phone:
                if text.middleSpace().count + replaceString.count - range.length > Constant.phoneLength {
                    return false
                }
                break
            case .bankCard:
                if text.middleSpace().count + replaceString.count - range.length > Constant.bankCardLength {
                    return false
                }
                break
            }
            
            insertText(replaceString)
            self.text = insert(text, type: type)
            var offset = range.location + replaceString.count
            changeCharacters(in: range, type: type, offset: &offset)
            switch type {
            case .idCard:
                if range.location == Constant.idCard1st || range.location == Constant.idCard2nd {
                    offset += 1
                }
                break
            case .phone:
                if range.location == Constant.phone1st || range.location == Constant.phone2nd {
                    offset += 1
                }
                break
            case .bankCard:
                if range.location == Constant.bankCard1st ||
                    range.location == Constant.bankCard2nd ||
                    range.location == Constant.bankCard3rd ||
                    range.location == Constant.bankCard4th ||
                    range.location == Constant.bankCard5th {
                    offset += 1
                }
                break
            }
            if let newPos = self.position(from: self.beginningOfDocument, offset: offset) {
                self.selectedTextRange = self.textRange(from: newPos, to: newPos)
            }
            return true
        } else {
            return true
        }
    }
    
    private func insert(_ str: String, type: NumberFormatType) -> String {
        var _str = str.middleSpace()
        switch type {
        case .idCard:
            if _str.count > Constant.idCard1st {
                _str.insert(" ", at: _str.index(_str.startIndex, offsetBy: Constant.idCard1st))
            }
            if _str.count > Constant.idCard2nd {
                _str.insert(" ", at: _str.index(_str.startIndex, offsetBy: Constant.idCard2nd))
            }
            break
        case .phone:
            if _str.count > Constant.phone1st {
                _str.insert(" ", at: _str.index(_str.startIndex, offsetBy: Constant.phone1st))
            }
            if _str.count > Constant.phone2nd {
                _str.insert(" ", at: _str.index(_str.startIndex, offsetBy: Constant.phone2nd))
            }
            break
        case .bankCard:
            if _str.count > Constant.bankCard1st {
                _str.insert(" ", at: _str.index(_str.startIndex, offsetBy: Constant.bankCard1st))
            }
            if _str.count > Constant.bankCard2nd {
                _str.insert(" ", at: _str.index(_str.startIndex, offsetBy: Constant.bankCard2nd))
            }
            if _str.count > Constant.bankCard3rd {
                _str.insert(" ", at: _str.index(_str.startIndex, offsetBy: Constant.bankCard3rd))
            }
            if _str.count > Constant.bankCard4th {
                _str.insert(" ", at: _str.index(_str.startIndex, offsetBy: Constant.bankCard4th))
            }
            if _str.count > Constant.bankCard5th {
                _str.insert(" ", at: _str.index(_str.startIndex, offsetBy: Constant.bankCard5th))
            }
            break
        }
        return _str
    }

    //set光标位置
    private func changeCharacters(in range: NSRange, type: NumberFormatType, offset:inout Int) {
        if type == .idCard {
            if range.location == Constant.idCard1st || range.location == Constant.idCard2nd {
                offset += 1
            }
        } else if type == .phone {
            if range.location == Constant.phone1st || range.location == Constant.phone2nd {
                offset += 1
            }
        } else {
            if range.location == Constant.bankCard1st ||
                range.location == Constant.bankCard2nd ||
                range.location == Constant.bankCard3rd ||
                range.location == Constant.bankCard4th ||
                range.location == Constant.bankCard5th {
                offset += 1
            }
        }
    }
}
