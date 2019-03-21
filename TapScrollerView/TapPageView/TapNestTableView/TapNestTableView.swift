//
//  TapNestTableView.swift
//  TapScrollerView
//
//  Created by Sun on 2019/3/19.
//  Copyright © 2019 夏宗斌. All rights reserved.
//

import UIKit

protocol TapNestTableViewDelegate: class {
    // 当内容可以滚动时会调用
    func nestTableViewContentCanScroll(nestTableView: TapNestTableView)
    // 当容器可以滚动时会调用
    func nestTableViewContainerCanScroll(nestTableView: TapNestTableView)
    // 当容器正在滚动时调用，参数scrollView就是充当容器的tableView
    func nestTableViewDidScroll(scrollView: UIScrollView)
    
    //获取headView
    func nestTableViewHeaderView() -> UIView
    
    //获取segmentView
    func nestTableViewSegmentView() -> TapSegmentView
}

protocol TapNestTableViewDataSource: class {
    // 根据 navigationBar 是否透明，返回不同的值
    // 1. 当设置 navigationBar.translucent = NO 时，
    //    普通机型 InsetTop = 0， iPhoneX InsetTop = 0 （默认情况）
    // 2. 当设置 navigationBar.translucent = YES 时，
    //    普通机型 InsetTop = 64， iPhoneX InsetTop = 88
    func nestTableViewContentInsetTop(nestTableView: TapNestTableView) ->CGFloat
 
    
    // 一般不需要实现
    // 普通机型 InsetBottom = 0， iPhoneX InsetBottom = 34 （默认情况）
    func nestTableViewContentInsetBottom(nestTableView: TapNestTableView) ->CGFloat
    
    // 获取viewList
    func nestTableViewViewList() -> [UIView]
}

class TapNestTableView: UIView {
    
    // 头部
    open var headerView: UIView?
    // 分类导航
    open var segmentView: TapSegmentView?

    // 内容
    open var contentView: TapPageView?{
        didSet{
            resizeContentHeight()
        }
    }
   
    // 设置容器是否可以滚动
    open var canScroll: Bool?{
        didSet{
            guard canScroll != nil else {return}
            if canScroll! {
                delegate?.nestTableViewContainerCanScroll(nestTableView: self)
            }
        }
    }
    // 允许手势传递的view列表
    open var allowGestureEventPassViews: [UIView]? {
        didSet{
            guard allowGestureEventPassViews != nil else {return}
            tableView.allowGestureEventPassViews = allowGestureEventPassViews
        }
    }
    
    weak var delegate: TapNestTableViewDelegate?{
        didSet{
            tableView.tableHeaderView = delegate?.nestTableViewHeaderView()
            segmentView = delegate?.nestTableViewSegmentView()
            segmentView?.delegate = self
            self.addSubview(segmentView!)
        }
    }
    weak var dataSource: TapNestTableViewDataSource?{
        didSet{
            self.allowGestureEventPassViews = dataSource?.nestTableViewViewList()
            resizeContentHeight()
            tableView.reloadData()
        }
    }
    
    private lazy var tableView:TapAllowGestureEventPassTableView = {
        let tableView = TapAllowGestureEventPassTableView.init(frame: self.bounds, style: UITableView.Style.grouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        return tableView
    }()
    
    private var isFooterViewHidden = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView = TapPageView.init(frame: self.bounds)
        contentView!.delegate = self
        contentView!.dataSource = self
        self.addSubview(tableView)
      
        
        canScroll = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        resizeTableView()
    }
    
    func resizeTableView() {
        tableView.frame = self.bounds
    }
    
    func resizeContentHeight() {
        let contentHeight = self.bounds.height - (segmentView?.bounds.height ?? 0) - self.contentInsetTop() - self.contentInsetBottom()
        contentView?.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: contentHeight)
        tableView.reloadData()

    }

    func contentInsetTop() -> CGFloat {
        //TODO 默认值需要考虑iphoneX及以上机型
        return dataSource?.nestTableViewContentInsetTop(nestTableView: self) ?? 0
    }
    
    func contentInsetBottom() -> CGFloat {
        return dataSource?.nestTableViewContentInsetBottom(nestTableView: self) ?? 0
        
    }
    
    open func heightForContainerCanScroll() -> CGFloat{
        if ((tableView.tableHeaderView?.frame.size.height) != nil) {
            return (tableView.tableHeaderView?.frame.size.height)! - contentInsetTop()
        }else{
            return 0
        }
    }
}

extension TapNestTableView: UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return segmentView?.bounds.height ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return segmentView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return contentView?.bounds.height ?? 0
    }
}

extension TapNestTableView: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        if contentView != nil {
            cell.selectionStyle = .none
            cell.contentView.addSubview(contentView!)
        }
        return cell
    }
}

extension TapNestTableView{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let contentOffset = heightForContainerCanScroll()

        if !(canScroll ?? true) {
            // 这里通过固定contentOffset的值，来实现不滚动
            scrollView.contentOffset = CGPoint(x: 0, y: contentOffset)
        } else if scrollView.contentOffset.y >= contentOffset {
            scrollView.contentOffset = CGPoint(x: 0, y: contentOffset)
            canScroll = false

            // 通知delegate内容开始可以滚动
           delegate?.nestTableViewContentCanScroll(nestTableView: self)
        }
        scrollView.showsVerticalScrollIndicator = canScroll ?? false
        
        delegate?.nestTableViewDidScroll(scrollView: tableView)
    }
}

extension TapNestTableView: TapSegmentViewDelegate{
    func segmentView(segmentView: TapSegmentView, didScrollToIndex index: Int) {
        contentView?.scrollToIndex(index: index)
    }
}

extension TapNestTableView: TapPageViewDelegate{
    func pageView(pageView: TapPageView, didScrollToIndex index: Int) {
        segmentView?.scrollToIndex(index: index)
        
    }
}

extension TapNestTableView: TapPageViewDataSource{
    func numberOfPagesInPageView(pageView: TapPageView) -> Int {
        return dataSource?.nestTableViewViewList().count ?? 0
    }
    
    func pageView(pageView: TapPageView, pageAtIndex index: Int) -> UIView {
        return dataSource?.nestTableViewViewList()[index] ?? UIView()
    }
}
