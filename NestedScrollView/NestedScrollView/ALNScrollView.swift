//
//  ALNScrollView.swift
//  NestedScrollView
//
//  Created by Allah on 2019/3/9.
//  Copyright © 2019年 Allah. All rights reserved.
//

import Foundation
import UIKit

protocol ALNScrollViewStyle: class {
    var titleViewFrame: CGRect{ get }
    var contentViewFrame: CGRect{ get }
    
    
    ///  titleSwitchAnimated :when YES,switch the item can see scrolling animation.default is YES.
    var titleSwitchAnimated: Bool{ get }
    
    ///  contentSwitchAnimated :when YES,switch the item can see scrolling animation.default is YES.
    var contentSwitchAnimated: Bool{ get }

    
    ///  style of titles
    var titleMinimumLineSpacing: CGFloat{ get }
    var titleMinimumInteritemSpacing: CGFloat{ get }
    var titleSectionInset: UIEdgeInsets{ get }
    var titleItemSize: CGSize{ get }
    
    
    ///  style of contents
    var contentMinimumLineSpacing: CGFloat{ get }
    var contentMinimumInteritemSpacing: CGFloat{ get }
    var contentSectionInset: UIEdgeInsets{ get }
    var contentItemSize: CGSize{ get }
    
    var titleBackgroundColor: UIColor{ get }
    var contentBackgroundColor: UIColor{ get }
}

protocol ALNScrollViewDelegate: class{
    func numberOfItemsInScrollView(scrollView:ALNScrollView) -> Int
    
    ///  title item must be subclass of UICollectionViewCell,and implement ALNTitleProtocol.
    ///
    /// - Returns: the class of title item
    func titleCellClass() -> AnyClass
    
    ///  callback when the method cellForItemAtIndexPath in titleView is excuted,you can update title item here.
    ///
    /// - Parameters:
    ///   - scrollView: self
    ///   - titleCell: currentcell returned by cellForItemAtIndexPath
    ///   - index: indexPath.row in cellForItemAtIndexPath
    func configTitleCell(scrollView: ALNScrollView,titleCell:UICollectionViewCell & ALNTitleProtocol,index: Int)
    
    func didSelectItemAtIndex(scrollView: ALNScrollView,selectedIndex: Int)
    func didUnselectItemAtIndex(scrollView: ALNScrollView,unselectedIndex: Int)
    
    /// - Parameters:
    ///   - index: the index will select
    ///   - fromIndex: the index current selected
    ///   - ratio: (the width which the will show item showed) / (the width of the item)
    func willSelectItem(scrollView: ALNScrollView,item: (UICollectionViewCell & ALNTitleProtocol)?,index: Int,fromItem: (UICollectionViewCell & ALNTitleProtocol)?,fromIndex: Int,ratio: CGFloat)

}

class ALNScrollView: UIView{
    private var _countOfItems: Int = 0
    private weak var _delegate: ALNScrollViewDelegate?
    private var _currentSelectedIndex: Int = 0
    private var _contentViews = [UIScrollView & ALNContentProtocol]()
    private var _titleSwitchAnimated: Bool = true
    private var _contentSwitchAnimated: Bool = true
    
    private var _titleViewFrame: CGRect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50)
    private var _contentViewFrame: CGRect = CGRect(x: 0, y: 50, width: UIScreen.main.bounds.size.width, height: 300)
    private var _defaultSelectedIndex: Int = 0
    
    private var _canSwitchWhenScrolling: Bool = true
    private var _titleMinimumLineSpacing: CGFloat = 0
    private var _titleMinimumInteritemSpacing: CGFloat = 0
    private var _titleSectionInset: UIEdgeInsets = UIEdgeInsets.zero
    private var _titleItemSize: CGSize = CGSize.zero
    
    private var _contentMinimumLineSpacing: CGFloat = 0
    private var _contentMinimumInteritemSpacing: CGFloat = 0
    private var _contentSectionInset: UIEdgeInsets = UIEdgeInsets.zero
    private var _contentItemSize: CGSize = CGSize.zero
    
    private var _titleBackgroundColor: UIColor = UIColor.white
    private var _contentBackgroundColor: UIColor = UIColor.white
    
    //MARK: setter getter
    ///  delegate:  need to be set first
    weak var delegate: ALNScrollViewDelegate?{
        set{
            _delegate = newValue
            guard let del = _delegate else {
                return
            }
            _countOfItems = min(del.numberOfItemsInScrollView(scrollView: self), _contentViews.count)
            configTitleView()
            configContentView()
        }
        get{
            return _delegate
        }
    }
    var currentSelectedIndex: Int{
        set{
            _currentSelectedIndex = newValue
        }
        get{
            return _currentSelectedIndex
        }
    }
    
    ///  defaultSelectedIndex: default selectedIndex when first load,default 0
    var defaultSelectedIndex: Int{
        set{
            _defaultSelectedIndex = newValue
            titleView.defaultSelectedIndex = _defaultSelectedIndex
            contentView.defaultSelectedIndex = _defaultSelectedIndex
        }
        get{
            return _defaultSelectedIndex
        }
    }

    //MARK: lazy var
    lazy var canSwitchWhenScrollingGestures = {
        return [UISwipeGestureRecognizer]()
        }()
    lazy var titleView: ALNTitleView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        let titleV = ALNTitleView.init(frame: CGRect.zero, collectionViewLayout: layout)
        titleV.titleViewDelegate = self
        self.addSubview(titleV)
        return titleV
    }()
    lazy var contentView: ALNContentView = {
        let contentV = ALNContentView.init(contentViews: _contentViews)
       contentV.contentViewDelegate = self
        self.addSubview(contentV)
        return contentV
    }()
    
    
    //MARK: init deinit
    ///  init with contentViews
    ///
    /// - Parameter contentViews: contentViews the view in which is subclass of UIScrollView,and implement ALNContentProtocol Protocol
    init(contentViews: [UIScrollView & ALNContentProtocol]) {
        super.init(frame: CGRect.zero)
        _contentViews = contentViews
        self.backgroundColor = UIColor.white
        if _canSwitchWhenScrolling {
            addSwipeGesures()
        }
    }
    func selectItemAtIndex(index: Int)  {
        guard let _ = delegate, isIndexAvaliable(index: index) else {
            return
        }
        titleView.selectItemAtIndex(index: index)
        contentView.selectItemAtIndex(index: index)
        if index != _currentSelectedIndex {
            titleView .unselectItemAtIndex(index: _currentSelectedIndex)
        }
        _currentSelectedIndex = index
    }
    
    //MARK - Private
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("\(#function)in\(#file)")
    }
    
    deinit {
        print("\(#function)in\(#file)")
    }
    
    //MARK: check index bounds
    func isIndexAvaliable(index: Int) -> Bool {
        return index < _countOfItems
    }
    
    
    //MARK: view Config
    func configTitleView()  {
        updateTitleViewFrame()
    }
    
    func configContentView()  {
        updateContentViewFrame()
    }
    
    //MARK: view update
    func updateTitleViewFrame()  {
        titleView.frame = _titleViewFrame
    }
    
    func updateContentViewFrame()  {
        contentView.frame = _contentViewFrame
    }
}


extension ALNScrollView: ALNTitleViewDelegate{
    //MARK:ALNTitleViewDelegate
    func numberOfItemsInTitleView(titleView: ALNTitleView) -> Int{
        return _countOfItems
    }
    func titleCellClass() -> AnyClass{
        guard let del = delegate else {
            return UICollectionViewCell.self
        }
        return del.titleCellClass()
    }
    func configTitleCell(titleView: ALNTitleView,titleCell: UICollectionViewCell & ALNTitleProtocol,index: Int){
        guard let del = delegate else {
            return
        }
        del.configTitleCell(scrollView: self, titleCell: titleCell, index: index)
    }
    func didSelectItemAtIndex(titleView: ALNTitleView,selectedIndex: Int){
        contentView.selectItemAtIndex(index: selectedIndex)
        currentSelectedIndex = selectedIndex
        guard let del = delegate else {
            return
        }
        del.didSelectItemAtIndex(scrollView: self, selectedIndex: selectedIndex)
    }
    func didUnselectItemAtIndex(titleView: ALNTitleView,unselectedIndex: Int){
        guard let del = delegate else {
            return
        }
        del .didUnselectItemAtIndex(scrollView: self, unselectedIndex: unselectedIndex)
    }
}


extension ALNScrollView: ALNContentViewDelegate{
    //MARK:ALNContentViewDelegate

    func numberOfItemsInContentView(contentView: ALNContentView) -> Int{
        return _countOfItems
    }
    func didSelectItemAtIndex(contentView: ALNContentView,selectedIndex:Int){
        titleView.selectItemAtIndex(index: selectedIndex)
        currentSelectedIndex = selectedIndex
        guard let del = delegate else {
            return
        }
        del.didSelectItemAtIndex(scrollView: self, selectedIndex: selectedIndex)
    }
    func didUnselectItemAtIndex(contentView: ALNContentView,unselectedIndex: Int){
        titleView.unselectItemAtIndex(index: unselectedIndex)
        guard let del = delegate else {
            return
        }
        del.didUnselectItemAtIndex(scrollView: self, unselectedIndex: unselectedIndex)
    }
    func willSelectItemAtIndex(contentView: ALNContentView,index: Int,fromIndex: Int,ratio: CGFloat){
        guard let del = delegate else{
            return
        }
        del.willSelectItem(scrollView: self, item: titleView.titleCellAtIndex(index: index), index: index, fromItem: titleView.titleCellAtIndex(index: fromIndex), fromIndex: fromIndex, ratio: ratio)
    }
}

extension ALNScrollView: UIGestureRecognizerDelegate{
    //MARK:UIGestureRecognizerDelegate

    
    ///  canSwitchWhenScrolling:when YES,when the sub scrollView in the contentView isScrolling ,you still can switch item by swipe. default YES
    var canSwitchWhenScrolling: Bool{
        get{
        return _canSwitchWhenScrolling
        }
        set{
            if _canSwitchWhenScrolling != newValue{
                if !canSwitchWhenScrolling{
                    for gesture in canSwitchWhenScrollingGestures{
                        self.removeGestureRecognizer(gesture)
                    }
                    canSwitchWhenScrollingGestures .removeAll()
                }
              
                self.addSwipeGesures()
            }
            _canSwitchWhenScrolling = newValue
        }
        
    }
    
    func addSwipeGesures() {
        let sLeft: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
        sLeft.direction = UISwipeGestureRecognizer.Direction.left
        sLeft.addTarget(self, action: #selector(swipeLeft(gesture:)))
        sLeft.delegate = self
        self.addGestureRecognizer(sLeft)
        
        let sRight: UISwipeGestureRecognizer = UISwipeGestureRecognizer()
        sRight.direction = UISwipeGestureRecognizer.Direction.right
        sRight.addTarget(self, action: #selector(swipeRight(gesture:)))
        sRight.delegate = self
        self.addGestureRecognizer(sRight)
        
        canSwitchWhenScrollingGestures += [sLeft,sRight]
    }

    @objc func swipeLeft(gesture: UISwipeGestureRecognizer) {
        guard _currentSelectedIndex < _contentViews.count - 1 else {
            return
        }
        let currentScrollView: UIScrollView = _contentViews[_currentSelectedIndex]
        if currentScrollView.isDecelerating || currentScrollView.isDragging {
            currentScrollView.isScrollEnabled = false
            selectItemAtIndex(index: _currentSelectedIndex + 1)
            currentScrollView.isScrollEnabled = true
        }
    }
    
    @objc func swipeRight(gesture: UISwipeGestureRecognizer) {
        guard _currentSelectedIndex > 0 else {
            return
        }
        let currentScrollView: UIScrollView = _contentViews[_currentSelectedIndex]
        if currentScrollView.isDecelerating || currentScrollView.isDragging {
            currentScrollView.isScrollEnabled = false
            selectItemAtIndex(index: _currentSelectedIndex - 1)
            currentScrollView.isScrollEnabled = true
        }
    }
  
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


extension ALNScrollView: ALNScrollViewStyle{
    //MARK:Styles
    var titleViewFrame: CGRect{
        set{
            _titleViewFrame = newValue
            updateTitleViewFrame()
        }
        get{
            return _titleViewFrame
        }
    }
    var contentViewFrame: CGRect{
        set{
            _contentViewFrame = newValue
            updateContentViewFrame()
        }
        get{
            return _contentViewFrame
        }
    }
    var contentSwitchAnimated: Bool{
        set{
            _contentSwitchAnimated = newValue
            contentView.contentSwitchAnimated = newValue
        }
        get{
            return _contentSwitchAnimated
        }
    }
    var titleSwitchAnimated: Bool{
        set{
            _titleSwitchAnimated = newValue
            titleView.titleSwitchAnimated = newValue
        }
        get{
            return _titleSwitchAnimated
        }
    }
  
    var titleMinimumLineSpacing: CGFloat{
        get{
            return _titleMinimumLineSpacing
        }
        set{
            _titleMinimumLineSpacing = newValue
            titleView.minimumLineSpacing = _titleMinimumLineSpacing
        }
    }
    var titleMinimumInteritemSpacing: CGFloat{
        get{
            return _titleMinimumLineSpacing
        }
        set{
            _titleMinimumLineSpacing = newValue
            titleView.minimumLineSpacing = _titleMinimumLineSpacing
        }
    }
    var titleSectionInset: UIEdgeInsets{
        get{
            return _titleSectionInset
        }
        set{
            _titleSectionInset = newValue
            titleView.sectionInset = _titleSectionInset
        }
    }
    var titleItemSize: CGSize{
        get{
            return _titleItemSize
        }
        set{
            _titleItemSize = newValue
            titleView.itemSize = _titleItemSize
        }
    }
    
    var contentMinimumLineSpacing: CGFloat{
        get{
            return _contentMinimumLineSpacing
        }
        set{
            _contentMinimumLineSpacing = newValue
            contentView.minimumLineSpacing = _contentMinimumLineSpacing
        }
    }
    var contentMinimumInteritemSpacing: CGFloat{
        get{
            return _contentMinimumInteritemSpacing
        }
        set{
            _contentMinimumInteritemSpacing = newValue
            contentView.minimumInteritemSpacing = _contentMinimumInteritemSpacing
        }
    }
    var contentSectionInset: UIEdgeInsets{
        get{
            return _contentSectionInset
        }
        set{
            _contentSectionInset = newValue
            contentView.sectionInset = _contentSectionInset
        }
    }
    var contentItemSize: CGSize{
        get{
            return _contentItemSize
        }
        set{
            _contentItemSize = newValue
            contentView.itemSize = _contentItemSize
        }
    }
    
    var titleBackgroundColor: UIColor{
        get{
            return _titleBackgroundColor
        }
        set{
            _titleBackgroundColor = newValue
            titleView.backgroundColor = _titleBackgroundColor
        }
    }
    
    var contentBackgroundColor: UIColor{
        get{
            return _contentBackgroundColor
        }
        set{
            _contentBackgroundColor = newValue
            contentView.backgroundColor = _contentBackgroundColor
        }
    }
}
