//
//  SSPhotoCell.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/17.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit
import Photos

protocol SSPhotoCellDelegate: class {
    func albumDidChoosePhoto()
}

class SSPhotoCell: UICollectionViewCell {
    
    private var imageView: UIImageView!
    private var selectBtn: UIButton!
    
    weak var delegate: SSPhotoCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        imageView = UIImageView(frame: self.bounds)
        self.contentView.addSubview(imageView)
        
        selectBtn = UIButton(type: .custom)
        selectBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        selectBtn.center = CGPoint(x: self.contentView.bounds.size.width * 0.85, y: self.contentView.bounds.size.height * 0.2)
        selectBtn.isOpaque = true
        selectBtn.addTarget(self, action: #selector(onSelectedAction(sender:)), for: .touchUpInside)
        selectBtn.setImage(UIImage(named: "tick"), for: .normal)
        selectBtn.setImage(UIImage(named: "tick_select"), for: .selected)
        self.contentView.addSubview(selectBtn)
    }
    
    @objc private func onSelectedAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.albumDidChoosePhoto()
    }
    
    func initCell(_ model: SSPhotoAlbumModel) {
        if let asset = model.asset as? PHAsset {
            SSPhotoAlbum.shared.requestDegraded(withPHAsset: asset) { image in
                print(image)
                self.imageView.image = image
            }
        }
    }
    
    func initRigidCell() {
        self.selectBtn.isHidden = true
        self.imageView.contentMode = .center
        self.imageView.image = UIImage(named: "photo")
    }
}
