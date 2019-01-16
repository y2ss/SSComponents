//
//  GirdDragViewViewController.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/18.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

class GirdDragViewViewController: UIViewController, GridDragViewDataSource, GridDragViewDelegate, GridCellDelegate {
    
    private var collection: GridDragView! = nil
    private var data = [UIColor]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        
        let layout = UICollectionViewFlowLayout()
        let width: CGFloat = (self.view.width - 80) / 4
        
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 15
        
        let barH = 64 + UIApplication.shared.statusBarFrame.height
        let collection = GridDragView(frame: CGRect(x: 10, y: barH, width: self.view.width - 20, height: self.view.height - 64), collectionViewLayout: layout)
        collection.g_delegate = self
        collection.g_dataSource = self
        collection.register(GridCell.self, forCellWithReuseIdentifier: "GridCell")
        collection.backgroundColor = UIColor.black
        self.view.addSubview(collection)        
        self.collection = collection
    }
    
    func isDragToTrash(with collectionView: GridDragView, cellLocation: CGPoint) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath) as! GridCell
        if indexPath.row == data.count {
            cell.initAddCell()
        } else {
            cell.initCell(data[indexPath.row], isSelected: indexPath.item == collection.selectedItem)
        }
        cell.delegate = self
        cell.tag = indexPath.item
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count + 1
    }
    
    func dataSourceOfCollectionViewDataSource(with collectionView: GridDragView) -> Array<Any> {
        return data
    }
    
    func MoveTo(with collectionView: GridDragView, newDataSourceAfterMove dataSource: Array<Any>) {
        data = dataSource as! [UIColor]
    }
    
    func Delete(with collectionView: GridDragView, newDatasourceAfterDelete dataSource: Array<Any>) {
        data = dataSource as! [UIColor]
    }
    
    func didDragging(with collectionView: GridDragView, cellLocation: CGPoint) {
 
    }
    
    func willEndDragging(with collectionView: GridDragView) {

    }
    
    func willBeginDragging(with collectionView: GridDragView, soureIndexPath: IndexPath) {

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row != data.count {
            collection.selectedItem = indexPath.row
            collectionView.reloadData()
        }
    }
    
    func didSuccessDragging(with collectionView: GridDragView, soureIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if soureIndexPath.item == collection.selectedItem {
            collection.selectedItem = destinationIndexPath.item
        }
    }
    
    //CellDelegate
    func didAddNewColor() {
        data.append(UIColor(red: CGFloat(arc4random() % 255) / 255,
                            green: CGFloat(arc4random() % 255) / 255,
                            blue: CGFloat(arc4random() % 255) / 255,
                            alpha: 1))
        self.collection.reloadData()
    }

    func didChooseSomeColor(_ tag: Int) {

    }
}
