//
//  ALNTestTableView.swift
//  NestedScrollView
//
//  Created by Allah on 2019/3/11.
//  Copyright © 2019年 Allah. All rights reserved.
//

import Foundation
import UIKit

class ALNTestTableView: UITableView,ALNContentProtocol,UITableViewDelegate,UITableViewDataSource  {
    func config() {
        
    }
    
    
    var datas = [String]()
    
   
    
    func selected() {
        
    }
    
    func unSelected() {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: (type(of: self).description()), for: indexPath)
        cell.textLabel?.text = datas[indexPath.row]
        return cell
    }
    
    init() {
        super.init(frame: CGRect.zero, style: UITableView.Style.plain)
        register(UITableViewCell.self, forCellReuseIdentifier: (type(of: self).description()))
        delegate = self
        dataSource = self
    }
 
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
