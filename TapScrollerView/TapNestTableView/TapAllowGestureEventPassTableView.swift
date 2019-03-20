//
//  TapAllowGestureEventPassTableView.swift
//  TapScrollerView
//
//  Created by Sun on 2019/3/19.
//  Copyright © 2019 夏宗斌. All rights reserved.
//

import UIKit
import WebKit

class TapAllowGestureEventPassTableView: UITableView {
    open var allowGestureEventPassViews: [UIView]?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        // 在某些情况下，contentView中的点击事件会被panGestureRecognizer拦截，导致不能响应，
        // 这里设置cancelsTouchesInView表示不拦截
        self.panGestureRecognizer.cancelsTouchesInView = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TapAllowGestureEventPassTableView: UIGestureRecognizerDelegate{
    // 返回YES表示可以继续传递触摸事件，这样两个嵌套的scrollView才能同时滚动
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
        guard allowGestureEventPassViews != nil else { return false }
        var view = otherGestureRecognizer.view
        if (view?.superview is WKWebView) {
            view = view?.superview
        }

        if allowGestureEventPassViews!.count >= 1 , allowGestureEventPassViews!.contains(where: { $0 == view }) {
            return true
        } else {
            return false
        }
    }
}
