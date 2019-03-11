//
//  ViewController.swift
//  NestedScrollView
//
//  Created by Allah on 2019/3/9.
//  Copyright © 2019年 Allah. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var titles = [ALNTestModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var tableViews = [ALNTestTableView]()
        for i in 0..<9{
            let table: ALNTestTableView = ALNTestTableView.init()
            var datas = [String]()
            for j in 0..<30{
                datas += ["测试 \(i),行 \(j)"]
            }
            table.datas = datas
            table.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 70)
            tableViews += [table]
            
            let model: ALNTestModel = ALNTestModel()
            model.title = "\(i)"
            titles += [model]
        }
        
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
        
        
    }
}

extension ViewController: ALNScrollViewDelegate{
    func numberOfItemsInScrollView(scrollView: ALNScrollView) -> Int {
        return titles.count
    }
    
    func titleCellClass() -> AnyClass {
        return ALNTestCell.self
    }
    
    
    //titleCell对应的model需要更新selected状态
    func configTitleCell(scrollView: ALNScrollView, titleCell: UICollectionViewCell & ALNTitleProtocol, index: Int) {
        titleCell.config(model: titles[index])
    }
    
    func didSelectItemAtIndex(scrollView: ALNScrollView, selectedIndex: Int) {
        
    }
    
    func didUnselectItemAtIndex(scrollView: ALNScrollView, unselectedIndex: Int) {
        
    }
    
    func willSelectItem(scrollView: ALNScrollView, item: (UICollectionViewCell & ALNTitleProtocol)?, index: Int, fromItem: (UICollectionViewCell & ALNTitleProtocol)?, fromIndex: Int, ratio: CGFloat) {
        if (item != nil) {
            let cell: ALNTestCell = item as! ALNTestCell
            cell.setTitleColor(color: interpolationColorFrom(fromColor: UIColor.black, toColor: UIColor.red, percent: ratio))
        }
      
        if fromItem != nil{
            let fromCell: ALNTestCell = fromItem as! ALNTestCell
            fromCell.setTitleColor(color: interpolationColorFrom(fromColor: UIColor.red, toColor: UIColor.black, percent: ratio))
        }  
    }
}


//MARK: test func
func interpolationFrom(from: CGFloat,to: CGFloat,percent:CGFloat) -> CGFloat {
    let perce = max(0, min(1, percent))
    return from + (to - from) * perce
}

func interpolationColorFrom(fromColor: UIColor,toColor: UIColor,percent: CGFloat) -> UIColor {
    let red: CGFloat = interpolationFrom(from:fromColor.test_red(), to: toColor.test_red(), percent: percent)
    let green: CGFloat = interpolationFrom(from:fromColor.test_green(), to: toColor.test_green(), percent: percent)
    let blue: CGFloat = interpolationFrom(from:fromColor.test_blue(), to: toColor.test_blue(), percent: percent)
    let alpha: CGFloat = interpolationFrom(from:fromColor.test_alpha(), to: toColor.test_alpha(), percent: percent)
return UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
}
