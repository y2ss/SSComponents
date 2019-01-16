//
//  Utils.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/17.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

func synced(_ lock: AnyObject, closure: () -> (Void))  {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    closure()
}

func toJSON(_ obj: AnyObject) throws -> String? {
    let json = try JSONSerialization.data(withJSONObject: obj, options: [])
    return NSString.init(data: json, encoding: String.Encoding.utf8.rawValue) as String?
}

func fromJSON(_ str: String) throws -> AnyObject? {
    if let json = str.data(using: .utf8, allowLossyConversion: false) {
        let obj: AnyObject = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as AnyObject
        return obj
    }
    return nil
}

func arrayMax<T: Comparable>(_ array: [T]) -> T? {
    guard let first = array.first else { return nil }
    return array.reduce(first, { return $0 > $1 ? $0 : $1 })
}

func findIndex<T: Equatable>(_ array: [T], valueToFind: T) -> Int? {
    for (index, value) in array.enumerated() {
        if value == valueToFind {
            return index
        }
    }
    return nil
}

func += <KeyType, ValueType> (left: inout Dictionary<KeyType, ValueType>, right: Dictionary<KeyType, ValueType>) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}
