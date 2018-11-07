//
//  Notification+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/7.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

extension NotificationCenter {
    
    func postOnMainThread(_ notification: Notification) {
        self.performSelector(onMainThread: #selector(post(_:)), with: notification, waitUntilDone: true)
    }
    
    /*
     @param object 通知携带的对象
     @param userInfo 通知携带的用户信息
     */
    func postOnMainThread(_ name: Notification.Name, object: Any? = nil, userInfo:[AnyHashable: Any]? = nil) {
        let notification = Notification(name: name, object: object, userInfo: userInfo)
        self .postOnMainThread(notification)
    }
}


