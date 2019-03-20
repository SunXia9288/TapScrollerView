//
//  TapSegmentViewCell.swift
//  TapScrollerView
//
//  Created by Sun on 2019/3/19.
//  Copyright © 2019 夏宗斌. All rights reserved.
//

import UIKit

let TapSegmentViewCellBottomLineHeight = 2

class TapSegmentViewCell: UICollectionViewCell {
    open lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    open lazy var bottomLine: UIView = {
        let bottomLine = UIView.init(frame: CGRect(x: 0, y: CGFloat(bounds.height - CGFloat(TapSegmentViewCellBottomLineHeight)), width: 0, height: CGFloat(TapSegmentViewCellBottomLineHeight)))
        bottomLine.clipsToBounds = true
//        bottomLine.backgroundColor = UIColor.red
        return bottomLine
    }()
    
    
  
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        
        addSubview(titleLabel)
        addSubview(bottomLine)
        
    }

    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        titleLabel.frame = bounds
        
        var bottomLineFrame: CGRect = bottomLine.frame
        bottomLineFrame.origin.x = (bounds.width - bottomLineFrame.width) / 2
        bottomLineFrame.origin.y = bounds.height - bottomLineFrame.height
        bottomLine.frame = bottomLineFrame
        
    }
}
