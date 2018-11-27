//
//  PictureSwipeVC1.swift
//  SSComponents
//
//  Created by y2ss on 2018/11/26.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class PictureSwipeVC1: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UINavigationControllerDelegate {

    @IBOutlet weak var collection: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    var selectedCell: SSPictureSwipeCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout.itemSize = CGSize(width: UIScreen.width * 0.5 - 20, height: (UIScreen.width * 0.5 - 20) * 2 / 3)
        collection.delegate = self
        collection.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationController?.delegate = self
    }
    
    @IBAction func onBackAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedCell = collectionView.cellForItem(at: indexPath) as? SSPictureSwipeCell
        let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PictureSwipeVC2") as! PictureSwipeVC2
        vc.image = selectedCell.imgview.image!
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == .push {
            return SSPictureSwiper(type: .push)
        }
        return nil
    }
}

class SSPictureSwipeCell: UICollectionViewCell {
    @IBOutlet weak var imgview: UIImageView!
}
