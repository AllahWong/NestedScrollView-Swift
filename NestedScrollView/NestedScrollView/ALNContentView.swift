//
//  ALNContentView.swift
//  NestedScrollView
//
//  Created by Allah on 2019/3/9.
//  Copyright © 2019年 Allah. All rights reserved.
//

import Foundation
import UIKit

protocol ALNContentViewDelegate : class {
    func numberOfItemsInContentView(contentView: ALNContentView) -> Int
    func didSelectItemAtIndex(contentView: ALNContentView,selectedIndex:Int)
    func didUnselectItemAtIndex(contentView: ALNContentView,unselectedIndex: Int)
    
    /// executed when draging contentView from one item to another
    ///
    /// - Parameters:
    ///   - contentView: self
    ///   - index: the index will select
    ///   - fromIndex: the index current selected
    ///   - ratio: (the width which the will show item showed) / (the width of the item)
    func willSelectItemAtIndex(contentView: ALNContentView,index: Int,fromIndex: Int,ratio: CGFloat)
}

class ALNContentView: UICollectionView {
    
    private var _currentSelectedIndex: Int = 0
    private var _countOfItems: Int = 0
    private var _contentViews = [UIScrollView & ALNContentProtocol]()
    private weak var _contentViewDelegate: (AnyObject & ALNContentViewDelegate)?
    ///  defaultSelectedIndex: default selectedIndex when first load,default 0
    private var _defaultSelectedIndex = 0
    
    weak var contentViewDelegate: (AnyObject & ALNContentViewDelegate)?
    ///  contentSwitchAnimated :when YES,switch the item can see scrolling animation.default is YES.
    var contentSwitchAnimated: Bool = true
    
    ///  style of titles
    var minimumLineSpacing: CGFloat = 0
    var minimumInteritemSpacing: CGFloat = 0
    var sectionInset: UIEdgeInsets = UIEdgeInsets.zero
    var itemSize: CGSize = CGSize.zero
    
    //MARK: getter setter
    var currentSelectedIndex: Int{
        get{
            return _currentSelectedIndex
        }
    }
    var defaultSelectedIndex: Int{
        set{
            _defaultSelectedIndex = newValue
            selectItemAtIndex(index: newValue, animated: false)
        }
        get{
            return _defaultSelectedIndex
        }
    }
    
    //MARK: init deinit
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(contentViews: [UIScrollView & ALNContentProtocol]) {
        print("\(#function)in\(#file)")

        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionView.ScrollDirection.horizontal
        
        super.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: 0, height: 0)), collectionViewLayout:layout)
        backgroundColor = UIColor.clear
        _contentViews = contentViews
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *){
            contentInsetAdjustmentBehavior = .never
        }
     
        delegate = self;
        dataSource = self
        register(UICollectionViewCell.self, forCellWithReuseIdentifier: (type(of: self).description()))
        isPagingEnabled = true
        addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
        contentSwitchAnimated = true
    }

    deinit {
        print("\(#function)in\(#file)")
    }
    
    //MARK: select one item
    func selectItemAtIndex(index: Int) {
        selectItemAtIndex(index: index, animated: contentSwitchAnimated)
    }
   
    func selectItemAtIndex(index: Int,animated: Bool) {
        performBatchUpdates({
            reloadData()
        }) { (finish) in
          
            self._currentSelectedIndex = index
            self.scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionView.ScrollPosition.centeredHorizontally, animated: animated)
        }
    }
}

extension ALNContentView: UICollectionViewDataSource{
    //MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: (type(of: self).description()), for: indexPath)
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        let scrollView: (UIScrollView & ALNContentProtocol) = _contentViews[indexPath.row]
        scrollView.config()
        cell.contentView.addSubview(scrollView)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dele = contentViewDelegate {
            _countOfItems = min(dele.numberOfItemsInContentView(contentView: self), _contentViews.count)
        }
        return _countOfItems
    }
}

extension ALNContentView: UIScrollViewDelegate{
    //MARK: UIScrollViewDelegate

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let index: Int = Int(scrollView.contentOffset.x / scrollView.frame.width)
        guard index != _currentSelectedIndex , let del = contentViewDelegate else{
            return
        }
        del.didUnselectItemAtIndex(contentView: self, unselectedIndex: _currentSelectedIndex)
        del.didSelectItemAtIndex(contentView: self, selectedIndex: index)
        _currentSelectedIndex = index
    }
}



extension ALNContentView: UICollectionViewDelegateFlowLayout{
    //MARK: UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return itemSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInset
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
    
}

extension ALNContentView{
    //MARK: kvo - "contentOffset"

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard keyPath == "contentOffset" , let chan = change else {
            return
        }
        
        guard let del = contentViewDelegate else {
            return
        }
        let contentOffset = chan[NSKeyValueChangeKey.newKey] as! CGPoint
        if isDragging || isTracking{
            let ratio = (contentOffset.x - CGFloat(_currentSelectedIndex) * frame.width) / frame.width
            let from = _currentSelectedIndex;
            var to = from + 1;
            if ratio > 0{
                if to == _countOfItems{
                    return
                }
            }
            else{
                if from == 0 {
                    return
                }
                to = from - 1
            }
            del.willSelectItemAtIndex(contentView: self, index:to , fromIndex: from, ratio: ratio)
            let index: Int = Int(contentOffset.x / frame.width)
            if index != _currentSelectedIndex{
                del.didUnselectItemAtIndex(contentView: self, unselectedIndex: _currentSelectedIndex)
                del.didSelectItemAtIndex(contentView: self, selectedIndex: index)
                _currentSelectedIndex = index
            }
            
        }
    }
}
