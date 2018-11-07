//
//  FileManager+Extension.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/7.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Foundation

extension FileManager {
    
    private class func url(for directory: SearchPathDirectory) -> URL? {
        return self.default.urls(for: directory, in: .userDomainMask).last
    }

    private class func path(for directory: SearchPathDirectory) -> String? {
        return NSSearchPathForDirectoriesInDomains(directory, .userDomainMask, true).first
    }
    
    class var documents: URL? {
        return self.url(for: .userDirectory)
    }
    
    class var documentsPath: String? {
        return self.path(for: .documentDirectory)
    }
    
    class var libaray: URL? {
        return self.url(for: .libraryDirectory)
    }
    
    class var libarayPath: String? {
        return self.path(for: .libraryDirectory)
    }
    
    class var caches: URL? {
        return self.url(for: .cachesDirectory)
    }
    
    class var cachesPath: String? {
        return self.path(for: .cachesDirectory)
    }
    
    class func skipBackup(for filePath: String) -> Bool {
        var url = URL(fileURLWithPath: filePath)
        do {
            var urlResource = URLResourceValues()
            urlResource.isExcludedFromBackup = true
            try url.setResourceValues(urlResource)
            return true
        } catch {
            log.debug(error)
            return false
        }
    }
}

