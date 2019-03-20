//
//  TapPageView.swift
//  TapScrollerView
//
//  Created by Sun on 2019/3/19.
//  Copyright © 2019 夏宗斌. All rights reserved.
//

import UIKit

protocol TapPageViewDataSource: class {

    func numberOfPagesInPageView(pageView: TapPageView) -> Int
    
    func pageView(pageView: TapPageView, pageAtIndex index: Int) -> UIView
}

protocol TapPageViewDelegate: class {
    
    func pageView(pageView: TapPageView, didScrollToIndex index: Int)
}

let TapPageViewReuseIdentifier = "TapPageViewReuseIdentifier"

class TapPageView: UIView {

    weak var dataSource: TapPageViewDataSource?
    weak var delegate: TapPageViewDelegate?
    
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
        collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: TapPageViewReuseIdentifier)
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(collectionView)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = self.bounds
        collectionViewLayout.itemSize = CGSize(width: self.frame.size.width, height: self.frame.size.height)
        
        collectionView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func scrollToIndex(index: Int) {
        let pageCount = self.collectionView(collectionView, numberOfItemsInSection: 0)
        if index >= pageCount{ return }
        collectionView.scrollToItem(at: IndexPath.init(row: index, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
    }

}

extension TapPageView: UICollectionViewDelegate{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

extension TapPageView: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return dataSource?.numberOfPagesInPageView(pageView: self) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TapPageViewReuseIdentifier, for: indexPath)
        
        if let view = dataSource?.pageView(pageView: self, pageAtIndex: indexPath.row) {
            cell.contentView.addSubview(view)
            view.frame = cell.bounds
        }
      
        return cell
    }
    
    
}

extension TapPageView{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let offset = collectionView.contentOffset.x
        let pageNum = round(offset/self.frame.size.width)
        
        delegate?.pageView(pageView: self, didScrollToIndex: Int(pageNum))
    }
}


