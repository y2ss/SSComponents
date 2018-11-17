//
//  SSPhotoAlbum.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/17.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import Photos

class SSPhotoAlbum {
    
    struct ConfigSetting {
        var thumbnailHieght: CGFloat//图像像素
    }
    
    private static var __instance = SSPhotoAlbum()
    var config: ConfigSetting
    class var shared: SSPhotoAlbum {
        return __instance
    }
    
    private init() {
        config = ConfigSetting(thumbnailHieght: 125)
    }

    //MARK: - 获取缩略图
    @discardableResult
    func requestDegraded(withPHAsset asset: PHAsset, completion: @escaping ((UIImage) -> Void)) -> PHImageRequestID {
        let size: CGSize
        /*PHImageManager中size是使用px单位，因此需要对传入的Size进行处理，宽高各自乘以ScreenScale，从而得到正确的图片*/
        size = CGSize(width: config.thumbnailHieght * UIScreen.main.scale, height: config.thumbnailHieght * UIScreen.main.scale)
        
        // 避免获取图片时出现的内存过高
        let option = PHImageRequestOptions()
        option.resizeMode = .fast
        option.isNetworkAccessAllowed = false//不从icloud上获取
        option.deliveryMode = .opportunistic
        option.isSynchronous = false
        /*PHImageManager 是通过请求的方式拉取图像，并可以控制请求得到的图像的尺寸、剪裁方式、质量*/
        /*resultHandler 在多次调用后，最终会返回高清的原图*/

        let imageRequestID = PHImageManager.default()
            .requestImage(for: asset,
                          targetSize: size,
                          contentMode: .aspectFit,
                          options: option,
                          resultHandler: { (image, info) in
                            if
                                let cancel = info?[PHImageCancelledKey] as? Bool,
                                let error = info?[PHImageErrorKey] as? Bool {
                                if error || cancel {
                                    return
                                }
                            }
                            guard let _image = image else { return }
                            completion(_image)
            })
        return imageRequestID
    }
    
    //MARK: - 获取高清图片
    @discardableResult
    func requestHD(withAsset asset: PHAsset, completion: @escaping (Data) -> Void) -> PHImageRequestID {
        let opt = PHImageRequestOptions()
        opt.resizeMode = .exact
        opt.isNetworkAccessAllowed = false
        opt.deliveryMode = .fastFormat
        opt.isSynchronous = true
        /*获取高清图时最好传输Data不直接传输UIImage避免内存过高卡顿*/
        let imageRequestID = PHImageManager.default().requestImageData(for: asset, options: opt) { (data, str, orientation, info) in
            print(str ?? "")
            print(orientation)
            print(info ?? [:])
            
            if
                let data = data,
                let cancel = info?[PHImageCancelledKey] as? Bool,
                let error = info?[PHImageErrorKey] as? Bool,
                let degrad = info?[PHImageResultIsDegradedKey] as? Bool {
                if !cancel && !error && !degrad {
                    completion(data)
                }
            }
        }
        return imageRequestID
    }
  
    
    //获取所有资源
    func requestAssets(withFetchResult result: PHFetchResult<AnyObject>, complection: @escaping (Array<SSPhotoAlbumModel>) -> Void) {
        var photos = [SSPhotoAlbumModel]()
        let fetch = result
        fetch.enumerateObjects { obj, idx, stop in
            print(obj)
            if let phasset = obj as? PHAsset {
                photos.append(SSPhotoAlbumModel.model(with: phasset))
            }
            if let avurlasset = obj as? AVURLAsset {
                photos.append(SSPhotoAlbumModel.model(with: avurlasset))
            }
            if fetch.count == photos.count {
                complection(photos)
            }
        }
    }
    
    
    enum FetchAlbumType {
        case photos
        case videos
        case all
    }
    
    enum PhotoAlbumError: Error {
        case authorizationError
        
        var localizedDescription: String {
            return "没有权限访问相册"
        }
    }
    
    func requestAlbumResoure(_ type: FetchAlbumType,
                             complection: @escaping (SSPhotoAlbumCache?, Error?) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .restricted || status == .denied {
            complection(nil, PhotoAlbumError.authorizationError)
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    print("加载中..")
                }
                
                let opt = PHFetchOptions()
                //排序
                opt.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                // 列出所有相册智能相册
                var subtype: PHAssetCollectionSubtype
                if type == .photos {
                    subtype = .smartAlbumUserLibrary
                } else if type == .videos {
                    subtype = .smartAlbumVideos
                } else {
                    subtype = .any
                }
                
                let albums: PHFetchResult = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: subtype, options: nil)
                albums.enumerateObjects({ (collection, idx, stop) in
                    print(collection)
                    let fetchResult = PHAsset.fetchAssets(in: collection, options: opt)
                    if fetchResult.count != 0 {
                        let _model = self.model(with: fetchResult as! PHFetchResult<AnyObject>)
                        DispatchQueue.main.async {
                            complection(_model, nil)
                        }
                    }
                })
            }
        }
    }
    
    private func model(with result: PHFetchResult<AnyObject>) -> SSPhotoAlbumCache {
        let model = SSPhotoAlbumCache()
        model.setResult(result: result)
        return model
    }
    
}
