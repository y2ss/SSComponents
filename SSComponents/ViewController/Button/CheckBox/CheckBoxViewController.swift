//
//  CheckBoxViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/26.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class CheckBoxViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SSCheckBoxDelegate {

    private var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize.init(width: UIScreen.width * 0.5, height: (UIScreen.height - navigationController!.navigationBar.height) / 3)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView = UICollectionView(frame:  CGRect(x: 0, y: 0, width: UIScreen.width, height: UIScreen.height), collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        self.view.addSubview(collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let box = SSCheckBox.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 80))
        box.delegate = self
        if indexPath.row == 0 {
            box.type = .circle
            box.onAnimateType = .stroke
            box.offAnimateType = .stroke
            box.animationDuration = 0.3
        } else if indexPath.row == 1 {
            box.type = .circle
            box.onAnimateType = .oneStroke
            box.offAnimateType = .oneStroke
            box.animationDuration = 0.4
        } else if indexPath.row == 2 {
            box.type = .circle
            box.onAnimateType = .bounce
            box.offAnimateType = .bounce
        } else if indexPath.row == 3 {
            box.type = .square
            box.onAnimateType = .fade
            box.offAnimateType = .fade
            box.animationDuration = 0.2
        } else if indexPath.row == 4 {
            box.type = .square
            box.onAnimateType = .fill
            box.offAnimateType = .fill
            box.animationDuration = 0.6
        } else if indexPath.row == 5 {
            box.type = .square
            box.onAnimateType = .flat
            box.offAnimateType = .flat
            box.animationDuration = 0.7
        }
        if indexPath.row % 2 == 0 {
            box.tintColor = UIColor.lightGray
            box.onTintColor = UIColor.init(red: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)
            box.onFillColor = UIColor.clear
            box.onCheckColor = UIColor.init(red: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)
        } else {
            box.tintColor = UIColor.lightGray
            box.onTintColor = UIColor.init(red: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)
            box.onFillColor =  UIColor.init(red: 0, green: 122.0 / 255.0, blue: 1, alpha: 1)
            box.onCheckColor = UIColor.white
        }
        cell.contentView.addSubview(box)
        box.center = cell.contentView.center
        return cell
    }
    
    deinit {
        print("---")
    }
    
    func checkBoxDidTap(_ checkBox: SSCheckBox) {
        
    }
    
    func animationDidStop(_ checkBox: SSCheckBox) {
        
    }
}
