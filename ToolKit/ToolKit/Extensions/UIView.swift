//
//  UIView.swift
//  ToolKit
//
//  Created by KIEU, HAI on 2/5/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import Foundation

public extension UIView {
    func fillUpParent() {
        guard superview != nil else { return }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[view]-(0)-|", options: [], metrics: nil, views: ["view":self])
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[view]-(0)-|", options: [], metrics: nil, views: ["view":self])
        
        NSLayoutConstraint.activate(constraints)
    }
}
