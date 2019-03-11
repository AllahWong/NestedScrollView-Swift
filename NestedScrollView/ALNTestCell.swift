//
//  ALNTestCell.swift
//  NestedScrollView
//
//  Created by Allah on 2019/3/11.
//  Copyright © 2019年 Allah. All rights reserved.
//

import Foundation
import UIKit

class ALNTestCell: UICollectionViewCell {
   
    var titleLabel:UILabel = UILabel()
    var _model: ALNTestModel = ALNTestModel()
    
    func setTitleColor(color: UIColor) {
        titleLabel.textColor = color
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.frame = CGRect.init(x: 0, y: 0, width: 100, height: 50)
        contentView.addSubview(titleLabel)
        backgroundColor = UIColor.cyan
    }
    

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        
    }
}


extension ALNTestCell: ALNTitleProtocol{
     func config(model: ALNModel) {
        _model = model as! ALNTestModel
        titleLabel.text = _model.title

        if _model.selected{
            unSelected()
        }
        else{
            unSelected()
        }
    }
    
    func selected() {
        titleLabel.textColor = UIColor.red
    }
    
    func unSelected() {
        titleLabel.textColor = UIColor.black

    }
    
}
