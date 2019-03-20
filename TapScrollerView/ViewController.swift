//
//  ViewController.swift
//  TapScrollerView
//
//  Created by Sun on 2019/3/19.
//  Copyright © 2019 夏宗斌. All rights reserved.
//

import UIKit
class ViewController: UIViewController {

    private lazy var nestTableView: TapNestTableView = {
        let nestTableView = TapNestTableView.init(frame: CGRect(x: 0, y: 88, width:view.bounds.width, height: view.bounds.height - 64 - 88))
        nestTableView.headerView = headerView
        nestTableView.segmentView = segmentView
        nestTableView.contentView = contentView
        nestTableView.allowGestureEventPassViews = viewList
        nestTableView.delegate = self
        nestTableView.dataSource = self
        return nestTableView
    }()
    
    private lazy var headerView: UIView = {
        let headerView = UIView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 300))
        headerView.backgroundColor = UIColor.orange
        return headerView
    }()
    
    private lazy var segmentView: TapSegmentView = {
        let segmentView = TapSegmentView.init(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 40))
        segmentView.delegate = self
        segmentView.itemWidth = 80
        segmentView.itemFont = UIFont.systemFont(ofSize: 15)
        segmentView.itemNormalColor = UIColor(red: 155.0 / 255, green: 155.0 / 255, blue: 155.0 / 255, alpha: 1)
        segmentView.itemSelectColor = UIColor(red: 244.0 / 255, green: 67.0 / 255, blue: 54.0 / 255, alpha: 1)
        segmentView.bottomLineWidth = 60
        segmentView.bottomLineHeight = 2
        segmentView.itemList = ["列表1","列表2","列表3","列表4","图片"]
        segmentView.selectIndex = 4 //默认选中最后一个tab
//        segmentView.backgroundColor = UIColor.red
        return segmentView
    }()
    
    private lazy var contentView: TapPageView = {
        let contentView = TapPageView.init(frame: view.bounds)
        contentView.delegate = self
        contentView.dataSource = self
        return contentView
    }()
    
    
    private lazy var viewList: [UIView] = {
        var viewList = [UIView]()
        let titleArr = ["","","",""]
        for (index,_) in titleArr.enumerated(){
            let tableView = UITableView.init(frame: view.bounds, style: UITableView.Style.plain)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.separatorStyle = .none
            tableView.tag = index + 200
            viewList.append(tableView)
        }
        
        let scrollerView = UIScrollView.init(frame: CGRect.zero)
        scrollerView.backgroundColor = UIColor.white
        let image = UIImage.init(named: "img1.jpg")
        let imageView = UIImageView.init(image: image)
        imageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.width * image!.size.height / image!.size.width)
        scrollerView.contentSize = imageView.frame.size
        scrollerView.alwaysBounceVertical = true
        scrollerView.addSubview(imageView)
        scrollerView.delegate = self
        viewList.append(scrollerView)
        return viewList
    }()

    private var canContentScroll: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        initDataSource()
        view.addSubview(nestTableView)
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    func initDataSource() {
       
    }

}

extension ViewController: TapSegmentViewDelegate{
    func segmentView(segmentView: TapSegmentView, didScrollToIndex index: Int) {
        contentView.scrollToIndex(index: index)
    }
}

extension ViewController: TapPageViewDelegate{
    func pageView(pageView: TapPageView, didScrollToIndex index: Int) {
        segmentView .scrollToIndex(index: index)
    }
}

extension ViewController: TapPageViewDataSource{
    func numberOfPagesInPageView(pageView: TapPageView) -> Int {
        return viewList.count
    }
    
    func pageView(pageView: TapPageView, pageAtIndex index: Int) -> UIView {
        return viewList[index]
    }
}

extension ViewController: UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}


extension ViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 200 {
            return 3
        }else{
            return 20
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "你好新世界"
        return cell
    }
    
    
}

extension ViewController: TapNestTableViewDelegate{
    func nestTableViewHeaderView() -> UIView {
         return headerView
    }
    
    func nestTableViewContentCanScroll(nestTableView: TapNestTableView) {
        canContentScroll = true
    }
    
    func nestTableViewContainerCanScroll(nestTableView: TapNestTableView) {
        for view in self.viewList{
            var scrollerView: UIScrollView?
            if view is UIScrollView{
                scrollerView = view as? UIScrollView
            }
            if scrollerView != nil{
                scrollerView?.contentOffset = CGPoint.zero
            }
            
        }
    }
    
    func nestTableViewDidScroll(scrollView: UIScrollView) {
        // 监听容器的滚动，来设置NavigationBar的透明度
//        let offset = scrollView.contentOffset.y
//        let canScrollHeight = nestTableView.heightForContainerCanScroll()
        
    }
    
}

extension ViewController: TapNestTableViewDataSource{
  
    
    func nestTableViewContentInsetTop(nestTableView: TapNestTableView) -> CGFloat {
        return 0
    }
    
    func nestTableViewContentInsetBottom(nestTableView: TapNestTableView) -> CGFloat {
        return 0
    }
    
    
}

extension ViewController{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !canContentScroll {
            scrollView.contentOffset = CGPoint.zero
        }else if scrollView.contentOffset.y <= 0{
            canContentScroll = false
            nestTableView.canScroll = true
        }
        scrollView.showsVerticalScrollIndicator = canContentScroll
    }
}
