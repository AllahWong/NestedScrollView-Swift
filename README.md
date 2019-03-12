---
# NestedScrollView-Swift
---

# NestedScrollView-Swift
---
类似今日头条多个滚动试图嵌套
---
 主要功能：
    将标题和滚动的内容封装起来，组合成一个新的组件。
----
 预览
---
 ![image](https://github.com/AllahWong/NestedScrollView/blob/master/preview.png)
----
基本使用：
----
        let titleHeight: CGFloat = 50
        let nestedView: ALNScrollView = ALNScrollView(contentViews: tableViews as [UIScrollView & ALNContentProtocol])
        nestedView.frame = self.view.bounds
        nestedView.delegate = self
        nestedView.defaultSelectedIndex = 5
        nestedView.titleSwitchAnimated = true
        nestedView.contentSwitchAnimated = true
        nestedView.titleViewFrame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: titleHeight)
        nestedView.contentViewFrame = CGRect.init(x: 0, y: titleHeight, width: self.view.frame.width, height: self.view.frame.height - titleHeight)
        nestedView.canSwitchWhenScrolling = true
        nestedView.titleMinimumLineSpacing = 3
        nestedView.titleMinimumInteritemSpacing = 3
        nestedView.titleSectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        nestedView.titleItemSize = CGSize.init(width: 100, height: titleHeight)
        nestedView.contentMinimumLineSpacing = 0
        nestedView.contentItemSize = CGSize.init(width: nestedView.contentViewFrame.width, height: nestedView.contentViewFrame.height)
        self.view.addSubview(nestedView)
        
