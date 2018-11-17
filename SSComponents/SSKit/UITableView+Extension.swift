//
//  UITableView+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/16.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

extension UITableView {
    
    /*
     tableView 开启动画事务
     cellForRow 方法调用次数：reloadData 会为当前显示的所有cell调用这个方法，updates 只会为新增的cell调用这个方法
     cellForRow 方法调用时间：reloadData 会在 numberOfRows 方法调用后的某一时间异步调用 cellForRow 方法，updates 会在 numberOfRows 方法调用后马上调用 cellForRow 方法
     
     reloadData 方法缺陷：带来额外的不必要开销，缺乏动画
     updates 方法缺陷：deleteRows 不会调用 cellForRow 方法，可能导致显示结果与数据源不一致；需要手动保证 insertRows、deleteRows 之后，row 的数量与 numberOfRows 的结果一致，否则会运行时崩溃
     */
    func updates(_ action: (UITableView) -> ()) {
        self.beginUpdates()
        action(self)
        self.endUpdates()
    }
    
    
}
