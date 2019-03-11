//
//  ALNTestColor.swift
//  NestedScrollView
//
//  Created by Allah on 2019/3/11.
//  Copyright © 2019年 Allah. All rights reserved.
//

import Foundation
import UIKit

extension UIColor  {
    
    func test_red() -> CGFloat {
        var r: CGFloat = 0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return r
    }
    func test_green() -> CGFloat {
        var g: CGFloat = 0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return g
    }
    func test_blue() -> CGFloat {
        var b: CGFloat = 0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return b
    }
    func test_alpha() -> CGFloat {
        return cgColor.alpha
    }
}
