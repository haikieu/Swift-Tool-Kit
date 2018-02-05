//
//  UIViewController.swift
//  ToolKitUI
//
//  Created by KIEU, HAI on 2/4/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController {
    
    func presentInput(title: String, actionText: String, cancelText: String, completion: @escaping ((_ confirm: Bool,_ input: String?)->Void)) {
        let inputVC = UIAlertController.init(title: title, message: nil, preferredStyle: .alert)
        inputVC.addTextField { (textField) in
        }
        inputVC.addAction(UIAlertAction.init(title: actionText, style: .default, handler: { [weak self, weak inputVC] (action) in
            guard self != nil else { return }
            completion(true, inputVC?.textFields?.first?.text)
        }))
        inputVC.addAction(UIAlertAction.init(title: cancelText, style: .cancel, handler: { [weak self] (action) in
            guard self != nil else { return }
            completion(false, nil)
        }))
        present(inputVC, animated: true, completion: nil)
    }
    
    public var topPresentedViewController : UIViewController? {
        if presentedViewController == nil {
            return self
        }
        return presentedViewController?.topPresentedViewController
    }
}
