//
//  Toast.swift
//  ToolKit
//
//  Created by KIEU, HAI on 2/4/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import Foundation

protocol ToastInterface {
    func toast(message : String, completion: (()->Void)?) -> Bool
    
    func toast(confirm : String, completion: ((_ confirm: Bool)->Void)) -> Bool
}

public final class Toast {
    
    public static func message(_ message: String, completion: (() -> Void)?) -> Bool {
        return UIApplication.shared.toast(message: message, completion: completion)
    }
    
    public static func confirm(_ confirm: String, completion: ((Bool) -> Void)) -> Bool {
        return UIApplication.shared.toast(confirm: confirm, completion: completion)
    }
}

extension UIViewController : ToastInterface {
    func toast(message : String, completion: (()->Void)?) -> Bool {
        //TODO: need to implement
        let vc = ToastViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
        return true
    }
    
    func toast(confirm : String, completion: ((_ confirm: Bool)->Void)) -> Bool {
        //TODO: need to implement
        let vc = ToastViewController()
        vc.modalTransitionStyle = .crossDissolve
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
        return true
    }
}

extension UIApplication : ToastInterface {
    func toast(message: String, completion: (() -> Void)?) -> Bool {
        let toastView = ToastView()
        keyWindow?.addSubview(toastView)
        toastView.fillUpParent()
        toastView.show()
        return true
//        return (keyWindow?.rootViewController?.topPresentedViewController?.toast(message: message, completion: completion)) ?? false
    }
    
    func toast(confirm: String, completion: ((Bool) -> Void)) -> Bool {
//        return (keyWindow?.rootViewController?.topPresentedViewController?.toast(confirm: confirm, completion: completion)) ?? false
        return false
    }
    
    fileprivate var topViewController : UIViewController {
        
        return (keyWindow?.rootViewController)!
    }
    
}


fileprivate class ToastView : UIView {
    
    var isModal : Bool = false
    
//    var overlay : UIView = UIView()
    var container : UIView = UIView()
    var textLabel : UILabel = UILabel()
    
    var tapGesture : UITapGestureRecognizer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        //Add subviews
//        addSubview(overlay)
        addSubview(container)
        container.addSubview(textLabel)
        
        //Turn on autolayout
//        overlay.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
//        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[view]-(0)-|", options: [], metrics: nil, views: ["view" : overlay])
//        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[view]-(0)-|", options: [], metrics: nil, views: ["view" : overlay])
//
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[view]-(20)-|", options: [], metrics: nil, views: ["view" : container])
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:[view(40)]-(50)-|", options: [], metrics: nil, views: ["view" : container])
        
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|-(20)-[view]-(20)-|", options: [], metrics: nil, views: ["view" : textLabel])
        constraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[view]-(0)-|", options: [], metrics: nil, views: ["view" : textLabel])
        NSLayoutConstraint.activate(constraints)
        
        alpha = 0
        
//        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        container.backgroundColor = UIColor.blue
        container.layer.cornerRadius = 5
        
        textLabel.textAlignment = .center
        textLabel.lineBreakMode = .byTruncatingTail
        textLabel.textColor = .white
        
        textLabel.text = "Hello world"
        
        tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(handleTapGesture(_:)))
        container.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        
    }
    
    fileprivate func show() {
        self.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 1
        })
    }
    
    fileprivate func dismiss() {
        UIView.animate(withDuration: 0.5, animations: {
            self.alpha = 0
        }) { [weak self] (finished) in
            self?.removeFromSuperview()
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        
 
        if container.frame.contains(point) {
            return true
        }
        
        return super.point(inside: point, with: event)
    }
}

fileprivate class ToastViewController : UIViewController {
    
    lazy var toastView : ToastView = {
        let v = ToastView()
        view.addSubview(v)
        v.fillUpParent()
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = toastView
    }
}


