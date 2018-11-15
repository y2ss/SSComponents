//
//  UIDevice+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/15.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

extension UIDevice {
    
 
    
    func blankof<T>(type: T.Type) -> T {
        let ptr = UnsafeMutablePointer<T>.allocate(capacity: MemoryLayout<T>.size)
        let val = ptr.pointee
        ptr.deinitialize(count: MemoryLayout<T>.size)
        return val
    }

    
    //获取手机硬盘总空间
    var totalDiskSize: Int64 {
        var fs = blankof(type: statfs.self)
        if statfs("/var", &fs) >= 0 {
            return Int64(UInt64(fs.f_bsize) * fs.f_blocks)
        }
        return 0
    }
    
    // 磁盘可用大小
    var availableDiskSize: Int64 {
        var fs = blankof(type: statfs.self)
        if statfs("/var", &fs) >= 0 {
            return Int64(UInt64(fs.f_bsize) * fs.f_bavail)
        }
        return 0
    }
    
    func fileSizeToString(_ fileSize: Int64) -> String {
        let fileSize1 = CGFloat(fileSize)
        let KB: CGFloat = 1024
        let MB = KB * KB
        let GB = MB * MB
        if fileSize1 < 10 {
            return "0 B"
        } else if fileSize1 < KB {
            return "< 1 KB"
        } else if fileSize1 < MB {
            return String(format: "%.1f KB", CGFloat(fileSize1) / KB)
        } else if fileSize1 < GB {
            return String(format: "%.1f MB", CGFloat(fileSize1) / MB)
        } else {
            return String(format: "%.1f GB", CGFloat(fileSize1) / GB)
        }
    }
 
}
