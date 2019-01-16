//
//  GridView.swift
//  SSComponents
//
//  Created by y2ss on 2018/12/18.
//  Copyright © 2018年 y2ss. All rights reserved.
//

import UIKit

@objc protocol GridDragViewDelegate: UICollectionViewDelegate {
    //移动后更新数据源
    func MoveTo(with collectionView: GridDragView, newDataSourceAfterMove dataSource: Array<Any>)
    //删除后更新数据源
    func Delete(with collectionView: GridDragView, newDatasourceAfterDelete dataSource: Array<Any>)
    //忽略某些不需要拖动的Cell
    @objc optional func IgnoreIndexPaths(with collectionView: GridDragView) -> [IndexPath]
    //将要开始移动
    @objc optional func willBeginDragging(with collectionView: GridDragView, soureIndexPath: IndexPath)
    //正在移动
    @objc optional func didDragging(with collectionView: GridDragView, cellLocation: CGPoint)
    //移动完毕
    @objc optional func willEndDragging(with collectionView: GridDragView)
    //成功交换位置
    @objc optional func didSuccessDragging(with collectionView: GridDragView, soureIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    //是否在垃圾桶上
    @objc optional func isDragToTrash(with collectionView: GridDragView, cellLocation: CGPoint) -> Bool
}

protocol GridDragViewDataSource: UICollectionViewDataSource {
    //数据源
    func dataSourceOfCollectionViewDataSource(with collectionView: GridDragView) -> Array<Any>
}


class GridDragView: UICollectionView {
    
    enum GridViewScrollDirection {
        case none
        case up
        case down
    }
    
    weak var g_dataSource : GridDragViewDataSource? {
        set {
            self.dataSource = newValue
        }
        get {
            return self.dataSource as? GridDragViewDataSource
        }
    }
    weak var g_delegate : GridDragViewDelegate? {
        set {
            self.delegate = newValue
        }
        get {
            return self.delegate as? GridDragViewDelegate
        }
    }
    
    var minimumPressDuration: TimeInterval {
        set {
            longPress.minimumPressDuration = newValue
        }
        get {
            return longPress.minimumPressDuration
        }
    }
    
    var edgeScrollEnable = true
    var isShake = true//是否振动
    var shakeLevel: Float = 2
    var isEditing = false//是否编辑
    var selectedItem = -1
    
    private var movingIndexPath: IndexPath?
    private var scrollDirection: GridViewScrollDirection = .none
    private var originalIndexPath: IndexPath?
    private lazy var longPress: UILongPressGestureRecognizer = {
        let lp = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(sender:)))
        lp.minimumPressDuration = 0.5
        self.addGestureRecognizer(lp)
        return lp
    }()
    private var isPanning = true
    private var movingCell: UICollectionViewCell?
    private var movingCenter: CGPoint?
    private var tempMoveCell: UIView?
    private var edgeTime: CADisplayLink?
    private var lastPoint: CGPoint?
    private var observering = false
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setupObserver()
    }
    
    private func setupConfi() {
        minimumPressDuration = 1
    }

    @objc private func longPressAction(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            gestureBegan(sender)
        } else if sender.state == .changed {
            gestureChanged(sender)
        } else if sender.state == .ended || sender.state == .cancelled {
            gestureEnded(sender)
        }
    }
    
    private func gestureBegan(_ sender: UILongPressGestureRecognizer) {
        guard let indexPath = self.indexPathForItem(at: sender.location(in: sender.view)) else { return }
        if shouldBeIngnored(indexPath) { return }
        isPanning = true
        guard let cell = self.cellForItem(at: indexPath) else { return }
        guard let snapshot = snapshot(cell) else { return }
        originalIndexPath = indexPath
        let tempMoveCell = UIView()
        tempMoveCell.layer.contents = snapshot.cgImage
        cell.isHidden = true
        movingCell = cell
        movingCenter = cell.center
        self.tempMoveCell = tempMoveCell
        self.tempMoveCell?.frame = cell.frame
        self.addSubview(self.tempMoveCell!)
        startTimer()
        if !isEditing { startShake() }
        lastPoint = sender.location(in: sender.view)
        g_delegate?.willBeginDragging?(with: self, soureIndexPath: originalIndexPath ?? IndexPath())
    }
    
    private func gestureChanged(_ sender: UILongPressGestureRecognizer) {
        let tp = sender.location(in: sender.view)
        g_delegate?.didDragging?(with: self, cellLocation: tp)
        tempMoveCell?.center = tp
        lastPoint = tp
        moveCell()
    }
    
    private func gestureEnded(_ sender: UILongPressGestureRecognizer) {
        guard let _oip = originalIndexPath, let mc = movingCenter else { return }
        if
            let isDrag = g_delegate?.isDragToTrash?(with: self, cellLocation: sender.location(in: self)) {
            if isDrag {
                let cell = self.cellForItem(at: _oip)
                cell?.isHidden = false
                deleteCell()
                isPanning = false
                stopTimer()
                g_delegate?.willEndDragging?(with: self)
                stopShake()
                movingCell?.isHidden = false
                self.isUserInteractionEnabled = true
                self.tempMoveCell?.removeFromSuperview()
                self.originalIndexPath = nil
                self.reloadData()
            } else {
                if originalIndexPath == nil { return }
                let cell = self.cellForItem(at: _oip)
                self.isUserInteractionEnabled = false
                isPanning = false
                stopTimer()
                g_delegate?.willEndDragging?(with: self)
                
                UIView.animate(withDuration: 0.25,
                               animations: {
                                self.tempMoveCell?.center = mc
                }) { (flag) in
                    self.stopShake()
                    self.movingCell?.isHidden = false
                    self.isUserInteractionEnabled = true
                    cell?.isHidden = false
                    self.tempMoveCell?.removeFromSuperview()
                    self.originalIndexPath = nil
                }
            }
        }
    }
    
    
    private func deleteCell() {
        guard let oip = originalIndexPath else { return }
        var temp = g_dataSource?.dataSourceOfCollectionViewDataSource(with: self) ?? []
        temp.remove(at: oip.item)
        g_delegate?.Delete(with: self, newDatasourceAfterDelete: temp)
    }
    
    private func moveCell() {
        guard let tempMoveCell = tempMoveCell else { return }
        for cell in self.visibleCells {
            if let indexPath = self.indexPath(for: cell) {
                if originalIndexPath == nil { return }
                if indexPath == originalIndexPath || shouldBeIngnored(indexPath) {
                    continue
                }
                let x: CGFloat = CGFloat(fabsf(Float(tempMoveCell.x - cell.x)))
                let y: CGFloat = CGFloat(fabsf(Float(tempMoveCell.y - cell.y)))
                if x <= tempMoveCell.width / 2 && y <= tempMoveCell.height / 2 {
                    movingIndexPath = indexPath
                    movingCell = cell
                    movingCenter = cell.center
                    updateDataSource()
                    CATransaction.begin()
                    self.moveItem(at: originalIndexPath!, to: movingIndexPath!)
                    CATransaction.setCompletionBlock({
                        print("动画完成")
                    })
                    CATransaction.commit()
                    g_delegate?.didSuccessDragging?(with: self, soureIndexPath: originalIndexPath!, to: movingIndexPath!)
                    originalIndexPath = movingIndexPath
                    break
                }
            }
        }
    }
    
    private func updateDataSource() {
        guard let oig = originalIndexPath, let mip = movingIndexPath else { return }
        var temp = [Any]()
        temp = g_dataSource?.dataSourceOfCollectionViewDataSource(with: self) ?? []
        if mip.item > oig.item {
            for i in oig.item ..< mip.item {
                temp.swapAt(i, i + 1)
            }
        } else {
            for i in stride(from: oig.item, to: mip.item, by: -1) {
                temp.swapAt(i, i - 1)
            }
        }
        g_delegate?.MoveTo(with: self, newDataSourceAfterMove: temp)
    }
    
    private func shouldBeIngnored(_ indexPath: IndexPath) -> Bool {
        if g_delegate == nil {
            return false
        }
        if let indexPaths = g_delegate?.IgnoreIndexPaths?(with: self) {
            for _indexPath in indexPaths {
                if _indexPath.item == indexPath.item && _indexPath.section == indexPath.section {
                    return true
                }
            }
        }
        return false
    }
    
    private func snapshot(_ cell: UICollectionViewCell) -> UIImage? {
        UIGraphicsBeginImageContext(cell.bounds.size)
        let ctx = UIGraphicsGetCurrentContext()
        cell.layer.render(in: ctx!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
    
    private func startTimer() {
        if edgeTime == nil && edgeScrollEnable {
            edgeTime = CADisplayLink(target: self, selector: #selector(timerAction))
            edgeTime?.add(to: RunLoop.main, forMode: .common)
        }
    }
    
    @objc private func timerAction() {
        guard let _ = lastPoint else { return }
        setScrollDirection()
        switch scrollDirection {
        case .up:
            self.setContentOffset(CGPoint(x: self.contentOffset.x, y: self.contentOffset.y - 4), animated: false)
            lastPoint!.y -= 4
            break
        case .down:
            self.setContentOffset(CGPoint(x: self.contentOffset.x, y: self.contentOffset.y + 4), animated: false)
            lastPoint!.y += 4
            break
        default:
            break
        }
    }
    
    private func setScrollDirection() {
        guard let tempMoveCell = tempMoveCell else { return }
        scrollDirection = .none
        if self.height + self.contentOffset.y - tempMoveCell.y < tempMoveCell.height / 2 && self.height + self.contentOffset.y < self.contentSize.height {
            scrollDirection = .down
        }
        if tempMoveCell.y - self.contentOffset.y < tempMoveCell.height / 2 && self.contentOffset.y > 0 {
            scrollDirection = .up
        }
    }
    
    private func stopTimer() {
        if let edgeTime = edgeTime {
            edgeTime.invalidate()
            self.edgeTime = nil
        }
    }
    
    private func startShake() {
        if !isShake {
            let cells = self.visibleCells
            for cell in cells {
                if let oig = originalIndexPath {
                    cell.isHidden = self.indexPath(for: cell)?.item == oig.item && self.indexPath(for: cell)?.section == oig.section
                } else {
                    cell.isHidden = false
                }
            }
            return
        }
        let keyAni = CAKeyframeAnimation()
        keyAni.keyPath = "transform.translation.x"
        keyAni.values = [NSNumber(value: -shakeLevel),
                         NSNumber(value: shakeLevel),
                         NSNumber(value: -shakeLevel)]
        keyAni.repeatCount = MAXFLOAT
        keyAni.duration = 0.2
        let cells = self.visibleCells
        for cell in cells {
            if self.shouldBeIngnored(self.indexPath(for: cell)!) { continue }
            if cell.layer.animation(forKey: "shake") == nil {
                cell.layer.add(keyAni, forKey: "shake")
            }
            if let oig = originalIndexPath {
                cell.isHidden = self.indexPath(for: cell)?.item == oig.item && self.indexPath(for: cell)?.section == oig.section
            } else {
                cell.isHidden = false
            }
        }
        if let tempMoveCell = tempMoveCell {
            if tempMoveCell.layer.animation(forKey: "shake") == nil {
                tempMoveCell.layer.add(keyAni, forKey: "shake")
            }
        }
    }
    
    private func stopShake() {
        if !isShake { return }
        let cells = self.visibleCells
        for cell in cells {
            cell.layer.removeAllAnimations()
        }
        tempMoveCell?.layer.removeAllAnimations()
    }
    
    private func angleToRad(_ x: CGFloat) -> Double {
        return Double(x) / 180.0 * .pi
    }
    
    private func setupObserver() {
        if observering { return }
        self.addObserver(self, forKeyPath: "contentOffset", options: .new, context: nil)
        observering = true
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        longPress.isEnabled = (self.indexPathForItem(at: point) != nil)
        return super.hitTest(point, with: event)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if isEditing || isPanning {
                startShake()
            } else if !isEditing && !isPanning {
                stopShake()
            }
        }
    }
    
    deinit {
        if observering {
            self.removeObserver(self, forKeyPath: "contentOffset")
            observering = false
        }
    }
}


protocol GridCellDelegate: class {
    func didAddNewColor()
    func didChooseSomeColor(_ tag: Int)
}

class GridCell: UICollectionViewCell {
    
    weak var delegate: GridCellDelegate?
    
    private var btn: UIButton! = nil
    private var shadowView: UIView! = nil
    private var colorBtn: UIButton! = nil
    private var selectedView: UIView! = nil
    
    override var isSelected: Bool {
        didSet(new) {
            if new {
                delegate?.didChooseSomeColor(self.tag)
            }
        }
    }
    
    func initCell(_ color: UIColor, isSelected: Bool) {
        
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
        
        if btn != nil {
            btn.removeFromSuperview()
        }
        if shadowView != nil {
            shadowView.removeFromSuperview()
        }
        if colorBtn != nil {
            colorBtn.removeFromSuperview()
        }
        if selectedView != nil {
            selectedView.removeFromSuperview()
        }
        
        let _ = UIView().then {
            $0.frame = self.contentView.bounds
            $0.backgroundColor = UIColor(hex: 0xff343434)
            $0.isHidden = !isSelected
            self.selectedView = $0
            self.contentView.addSubview($0)
        }
        
        let w = self.bounds.width - 8
        
        let _ = UIView().then {
            $0.frame = CGRect(x: 0, y: 0, width: w, height: w)
            $0.backgroundColor = color
            $0.layer.cornerRadius = w / 2
            $0.layer.masksToBounds = true
            $0.center = self.contentView.center
            self.contentView.addSubview($0)
            self.shadowView = $0
        }
        
        let _ = UIButton(type: .custom).then {
            $0.frame = CGRect(x: 0, y: 0, width: w, height: w)
            $0.center = self.contentView.center
            $0.isUserInteractionEnabled = isSelected
            $0.backgroundColor = UIColor.clear
            $0.addTarget(self, action: #selector(colorAction), for: .touchUpInside)
            self.contentView.addSubview($0)
            self.colorBtn = $0
        }
    }
    
    func initAddCell() {
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = self.width / 2
        self.layer.masksToBounds = true
        
        if colorBtn != nil {
            colorBtn.removeFromSuperview()
        }
        if shadowView != nil {
            shadowView.removeFromSuperview()
        }
        if selectedView != nil {
            selectedView.removeFromSuperview()
        }
        if btn == nil {
            let btn = UIButton(type: .custom)
            btn.frame = CGRect(x: 0, y: 0, width: 38, height: 38)
            btn.center = self.contentView.center
            btn.setImage(UIImage(named: "cvc_collection_add_btn"), for: .normal)
            btn.addTarget(self, action: #selector(addAction), for: .touchUpInside)
            
            self.btn = btn
        }
        self.contentView.addSubview(btn)
    }
    
    @objc private func colorAction() {
    }
    
    @objc private func addAction() {
        delegate?.didAddNewColor()
    }
}
