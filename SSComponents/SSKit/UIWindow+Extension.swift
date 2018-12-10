//
//  UIWindow+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/5.
//  Copyright © 2018年 y2ss. All rights reserved.
//


extension UIWindow {
    class var mainView: UIView? {
        if let window = UIApplication.shared.keyWindow {
            return window
        } else {
            return UIApplication.shared.delegate?.window ?? nil
        }
    }
}
