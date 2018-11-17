//
//  BitManager.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/16.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

struct BitManager {
    // MARK: - 取低4位
    static func lowFourBit(_ num: Int) -> Int {
        return num & 0x0F
    }
    
    // MARK: - 取低八位
    static func lowEightBit(_ num: Int) -> Int {
        return num & 0xFF
    }
    
    // MARK: - 右移八位
    static func rightShiftEightBit(_ num: Int) -> Int {
        return num >> 8
    }
    
    // MARK: - 右移十六位
    static func rightShiftDoubleEightBit(_ num: Int) -> Int {
        return rightShiftEightBit(rightShiftEightBit(num))
    }
    
    // MARK: - 左移八位 0补齐
    static func leftShiftEightBit(_ num: Int) -> Int {
        return num << 8
    }
    
    // MARK: - 左移动十六位
    static func leftShiftDoubleEightBit(_ num: Int) -> Int {
        return leftShiftEightBit(leftShiftEightBit(num))
    }
    
    // MARK: - 按位或OR
    // 对于每一个比特位，当两个操作数相应的比特位至少有一个1时，结果为1，否则为0。
    static func bitWiseOr(_ num1: Int, num2: Int) -> Int {
        return num1 | num2
    }
    
    // MARK: - 取任意位
    static func lowAnyBit(_ num: Int, bit: Int) -> Int {
        return num & bit
    }
    
    // MARK: - 右移任意位
    static func rightShiftAnyBit(_ num: Int, bit: Int) -> Int {
        return num >> bit
    }
    
    // MARK: - 左移任意位
    static func leftShiftAnyBit(_ num: Int, bit: Int) -> Int {
        return num << bit
    }
    
    static func getBitValue(_ bit: Int, num: Int) -> Int {
        
        var bitValue = 0
        switch bit {
        case 4:
            bitValue = lowFourBit(num)
            break
        case 8:
            bitValue = lowEightBit(num)
            break
        case 16:
            bitValue = lowEightBit(rightShiftEightBit(num))
            break
        case 24:
            bitValue = lowEightBit(rightShiftDoubleEightBit(num))
            break
        default: break
        }
        return bitValue
    }
    
    static func setBitValue(_ bit: Int, num: Int) -> Int {
        
        var bitValue = 0
        switch bit {
        case 8:
            bitValue = leftShiftEightBit(num)
            break
        case 16:
            bitValue = leftShiftDoubleEightBit(num)
            break
        default: break
        }
        return bitValue
    }
}
