//
//  SSPhotoAlbumModel.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/17.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Photos

class SSPhotoAlbumModel {

    var asset: AnyObject?//存储对象 PHAsset或AVURLAsset
    
    private init() {}
    
    class func model(with phAsset: PHAsset) -> SSPhotoAlbumModel {
        let model = SSPhotoAlbumModel()
        model.asset = phAsset
        return model
    }
    
    class func model(with avAsset: AVURLAsset) -> SSPhotoAlbumModel {
        let model = SSPhotoAlbumModel()
        model.asset = avAsset
        return model
    }

}
