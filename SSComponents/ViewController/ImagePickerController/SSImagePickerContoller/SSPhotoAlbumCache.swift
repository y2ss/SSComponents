//
//  SSPhotoAlbumCache.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/17.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Photos

class SSPhotoAlbumCache {
    
    var result = PHFetchResult<AnyObject>()//存储PHFetchResult对象 PHAsset和AVURLAsset
    var models = [SSPhotoAlbumModel]()//存储模型数组
    
    //从fetchResult抓取PHAsset
    func setResult(result: PHFetchResult<AnyObject>) {
        self.result = result
        
        SSPhotoAlbum.shared.requestAssets(withFetchResult: result) { models in
            print(models)
            self.models = models
        }
    }
}



