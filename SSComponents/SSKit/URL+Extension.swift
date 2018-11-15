//
//  URL.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/7.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

extension URL {
    
    //MARK: - url 参数
    var params: [String: Any]? {
        set {}
        get {
            if let query = self.query {
                var dict = [String: Any]()
                let qc = query.components(separatedBy: "&")
                for value in qc {
                    if
                        let key = value.components(separatedBy: "=").first,
                        let value = value.components(separatedBy: "=").last {
                        dict[key] = value
                    }
                }
                return dict
            }
            return nil
        }
    }
}
