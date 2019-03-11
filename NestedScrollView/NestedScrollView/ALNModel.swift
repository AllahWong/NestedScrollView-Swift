//
//  ALNModel.swift
//  NestedScrollView
//
//  Created by Allah on 2019/3/9.
//  Copyright © 2019年 Allah. All rights reserved.
//

import Foundation



//swift 中的三种权限
//private 私有的
//在哪里写的，就在哪里用。无论是类，变量，常量还是函数，一旦被标记为私有的，就只能在定义他们的源文件里使用，不能为别的文件所用。可以用来隐藏某些功能的细节实现方式。
//internal 内部的
//标记为internal的代码块，在整个应用（App bundle）或者框架（framework）的范围内都是可以访问的。
//public 公开的
//标记为public的代码块一般用来建立API，这是最开放的权限，使得任何人只要导入这个模块，都可以访问使用。
//swift里面所有的代码实体的默认权限都是internal。

open class ALNModel {
     var selected:Bool = false
    
}
