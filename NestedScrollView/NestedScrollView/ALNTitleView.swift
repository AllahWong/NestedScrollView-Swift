//
//  ALNTitleView.swift
//  NestedScrollView
//
//  Created by Allah on 2019/3/9.
//  Copyright © 2019年 Allah. All rights reserved.
//

import Foundation
import UIKit

protocol ALNTitleViewDelegate : class{
    func numberOfItemsInTitleView(titleView: ALNTitleView) -> Int

    /// title item must be subclass of UICollectionViewCell,and implement ALNTitleProtocol.
    ///
    /// - Returns: the class of title item
    func titleCellClass() -> AnyClass


    /// callback when the method cellForItemAtIndexPath in titleView is excuted,you can update title item here.
    ///
    /// - Parameters:
    ///   - titleView: self
    ///   - titleCell: currentcell returned by cellForItemAtIndexPath
    ///   - index: indexPath.row in cellForItemAtIndexPath
    func configTitleCell(titleView: ALNTitleView,titleCell: UICollectionViewCell & ALNTitleProtocol,index: Int)
    func didSelectItemAtIndex(titleView: ALNTitleView,selectedIndex: Int)
    func didUnselectItemAtIndex(titleView: ALNTitleView,unselectedIndex: Int)
    
}

class ALNTitleView: UICollectionView {
    
    private weak var _titleViewDelegate : (AnyObject & ALNTitleViewDelegate)?
    private var _currentSelectedIndex: Int = 0
    private var currentSelectedIndexPath: IndexPath?
    private var currentSelectedCell: (UICollectionViewCell & ALNTitleProtocol)?
    
    ///  titleSwitchAnimated :when YES,switch the item can see scrolling animation.default is YES.
    var titleSwitchAnimated: Bool = true
    
    ///  defaultSelectedIndex: default selectedIndex when first load,default 0
    var _defaultSelectedIndex: Int = 0
    
    ///  style of titles
    var minimumLineSpacing: CGFloat = 0
    var minimumInteritemSpacing: CGFloat = 0
    var sectionInset: UIEdgeInsets = UIEdgeInsets.zero
    var itemSize: CGSize = CGSize.zero
    
    
    
    // MARK:getter and setter
    public weak var titleViewDelegate : (AnyObject & ALNTitleViewDelegate)?{
        set{
         _titleViewDelegate = newValue

            guard let del = titleViewDelegate else {
                return
            }
            register(del.titleCellClass(), forCellWithReuseIdentifier: (type(of: self).description()))
        }
        get{
           return _titleViewDelegate
        }
    }
    var currentSelectedIndex: Int{
        get{
            guard let path = currentSelectedIndexPath  else {
                return 0
            }
            return path.row;
        }
    }
    var defaultSelectedIndex: Int{
        set{
            _defaultSelectedIndex = newValue;
            selectItemAtIndex(index: _defaultSelectedIndex, animated: false)
        }
        get{
            return _defaultSelectedIndex;
        }
    }
    
    
    //MARK: -init deinit
    deinit {
        print("\(#function)in\(#file)")
    }
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        print("\(#function)in\(#file)")

        backgroundColor = UIColor.clear
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *){
            contentInsetAdjustmentBehavior = .never
        }
        delegate = self
        dataSource = self
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        print("\(#function)in\(#file)")
    }
    
 
    //MARK: - select and unselect one item
    func selectItemAtIndex(index: Int) {
        selectItemAtIndex(index: index, animated: titleSwitchAnimated)
    }
    
    func selectItemAtIndex(index: Int,animated:Bool) {
        performBatchUpdates({
            reloadData()
        }) { (finish) in
            self.currentSelectedIndexPath = IndexPath(row: index, section: 0)
            self.scrollToItem(at: self.currentSelectedIndexPath!, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: animated)
            self.selectItem(at: self.currentSelectedIndexPath, animated: animated, scrollPosition: UICollectionView.ScrollPosition.centeredHorizontally)
            guard let cell = self.cellForItem(at: self.currentSelectedIndexPath!) else{
                return
            }

            self.currentSelectedCell = cell as? (UICollectionViewCell & ALNTitleProtocol)
            (cell as? (UICollectionViewCell & ALNTitleProtocol))!.selected()
        }
    }
    
    func unselectItemAtIndex(index: Int) {
        (cellForItem(at: IndexPath(row: index, section: 0)) as? (UICollectionViewCell & ALNTitleProtocol))?.unSelected()
    }
    
    //MARK: get titleCell
    func titleCellAtIndex(index: Int) -> (UICollectionViewCell & ALNTitleProtocol)? {
        return (cellForItem(at: IndexPath(row: index, section: 0)) as? (UICollectionViewCell & ALNTitleProtocol))
    }
}

extension ALNTitleView: UICollectionViewDataSource{
    //MARK:UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: UICollectionViewCell & ALNTitleProtocol = collectionView.dequeueReusableCell(withReuseIdentifier: (type(of: self).description()), for: indexPath) as! UICollectionViewCell & ALNTitleProtocol
        guard let del = titleViewDelegate else {
            return cell
        }
        del.configTitleCell(titleView: self, titleCell: cell, index: indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let del = titleViewDelegate else {
            return 0
        }
        return del.numberOfItemsInTitleView(titleView: self)
    }
}

extension ALNTitleView: UICollectionViewDelegate{
    //MARK:UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard currentSelectedCell == nil else {
            return
        }
        guard currentSelectedIndexPath?.row == indexPath.row else {
            return
        }
        //_currentSelectedCell当获取的cell未显示在屏幕上时获取为nil，没有及时更新选中状态
        currentSelectedCell = cell as? (UICollectionViewCell & ALNTitleProtocol)
        currentSelectedCell!.selected()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentSelectedIndexPath = indexPath
        currentSelectedCell = (collectionView.cellForItem(at: indexPath) as? (UICollectionViewCell & ALNTitleProtocol))
        if currentSelectedCell != nil{
            currentSelectedCell!.selected()
        }
        guard let del = titleViewDelegate else {
            return
        }
        del.didSelectItemAtIndex(titleView: self, selectedIndex: indexPath.row)
        
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

        if let cell = collectionView.cellForItem(at: indexPath){
            (cell as! (UICollectionViewCell & ALNTitleProtocol)).unSelected()
        }

        guard let del = titleViewDelegate else {
            return
        }
        del.didUnselectItemAtIndex(titleView: self, unselectedIndex: indexPath.row)
    }
}

extension ALNTitleView: UICollectionViewDelegateFlowLayout{
    //MARK:UICollectionViewDelegateFlowLayout
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
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
}
