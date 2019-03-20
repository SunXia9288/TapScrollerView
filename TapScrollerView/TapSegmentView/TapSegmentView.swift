//
//  TapSegmentView.swift
//  TapScrollerView
//
//  Created by Sun on 2019/3/19.
//  Copyright © 2019 夏宗斌. All rights reserved.
//

import UIKit

protocol TapSegmentViewDelegate: class {
    func segmentView(segmentView: TapSegmentView ,didScrollToIndex index:Int)
}

let TapSegmentViewReuseIdentifier = "TapSegmentViewReuseIdentifier"

class TapSegmentView: UIView {

    open lazy var itemWidth: CGFloat = 0
    
    open lazy var itemFont: UIFont = UIFont.systemFont(ofSize: 15)
    
    open lazy var itemNormalColor: UIColor = UIColor.white
    
    open lazy var itemSelectColor: UIColor = UIColor.red
    
    open lazy var bottomLineWidth: CGFloat = 80
    
    open lazy var bottomLineHeight: CGFloat = 40
    
    ///初始化title位置
    open lazy var selectIndex: Int = 0
    
    open lazy var itemList: [String] = {
        let itemList = [String]()
        return itemList
    }()
    
    weak var delegate: TapSegmentViewDelegate?
    
    private lazy var collectionViewLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout.init()
        //设置间距
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        //设置item尺寸
        let itemW = self.frame.size.width
        let itemH = self.frame.size.height
        flowLayout.itemSize = CGSize(width: itemW, height: itemH)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        //设置水平滚动方向
        flowLayout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        return flowLayout
    }()
    
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
//        collectionView.backgroundColor = UIColor.red
        collectionView.register(TapSegmentViewCell.classForCoder(), forCellWithReuseIdentifier: TapSegmentViewReuseIdentifier)
        return collectionView
    }()
    
    private var currentIndex: Int = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        UIConfig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func UIConfig()  {
        self.addSubview(collectionView)
        
        DispatchQueue.main.async {
            self.scrollToIndex(index: self.selectIndex)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = self.bounds
        collectionViewLayout.itemSize = CGSize(width: itemWidth, height: self.frame.size.height)
        collectionView.reloadData()
    }
    
    func selectIndex(indexPath: IndexPath) {
        currentIndex = indexPath.row
        collectionView.reloadData()
        collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
        
        delegate?.segmentView(segmentView: self, didScrollToIndex: indexPath.row)
    }
    
    open func scrollToIndex(index: Int){
        if currentIndex == index || index >= itemList.count{
            return
        }
        selectIndex(indexPath: IndexPath.init(row: index, section: 0))
    }
}

extension TapSegmentView: UICollectionViewDelegate{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
}

extension TapSegmentView: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: TapSegmentViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: TapSegmentViewReuseIdentifier, for: indexPath) as! TapSegmentViewCell
        let label = cell.titleLabel
        label.text = itemList[indexPath.row]
        label.font = itemFont
        label.textColor = (currentIndex == indexPath.row) ? itemSelectColor : itemNormalColor
        
        let bottomLine = cell.bottomLine
        if (currentIndex == indexPath.row){
            bottomLine.isHidden = false
            bottomLine.backgroundColor = itemSelectColor
            var frame = bottomLine.frame
            frame.size.width = bottomLineWidth
            frame.size.height = bottomLineHeight
            bottomLine.frame = frame
            
        }else{
            bottomLine.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectIndex(indexPath: indexPath)
    }
}
