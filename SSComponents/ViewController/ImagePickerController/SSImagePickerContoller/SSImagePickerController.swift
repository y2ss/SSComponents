//
//  SSImagePickerController.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/17.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class SSImagePickerController: UIViewController {
    
    private let identifier: String = "SSPickerImageControllerCell"
    private var collectionView: UICollectionView!
    private var photos = [SSPhotoAlbumModel]()//资源合集

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 20, width: 40, height: 40)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backBtn.setTitle("返回", for: .normal)
        backBtn.setTitleColor(UIColor.black, for: .normal)
        backBtn.setTitleColor(UIColor.black, for: .normal)
        self.view.addSubview(backBtn)
        initCollection()
        getAlbum()
    }
    
    @objc private func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //获取所有相片数据
    private func getAlbum() {
        photos.removeAll()
        
        SSPhotoAlbum.shared.requestAlbumResoure(.all) { model, error in
            guard let cache = model else {
                if let _error = error {
                    print(_error)
                }
                return
            }
            self.photos = cache.models
            self.collectionView.reloadData()
        }
    }
    
    private func initCollection() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 2
        flowLayout.minimumInteritemSpacing = 2
        let width = (self.view.frame.size.width - 12) / 4
        flowLayout.itemSize = CGSize(width: width, height: width)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 80, width: self.view.frame.size.width, height: self.view.frame.size.height - 80), collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        self.view.addSubview(collectionView)
        collectionView.register(SSPhotoCell.self, forCellWithReuseIdentifier: identifier)
    }
}

extension SSImagePickerController: UICollectionViewDelegate, UICollectionViewDataSource {
    //MARK: CollectionDelegate&DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! SSPhotoCell
        cell.contentView.backgroundColor = UIColor.gray
        cell.delegate = self
        if indexPath.item == 0 {
            cell.initRigidCell()
        } else {
            cell.initCell(photos[indexPath.item - 1])
        }
        return cell
    }
}

extension SSImagePickerController: SSPhotoCellDelegate {
    func albumDidChoosePhoto() {
        
    }
}
