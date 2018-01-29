//
//  UniversalNotificationCenter.swift
//  ToolKit
//
//  Created by KIEU, HAI on 1/28/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import UIKit

fileprivate let NotificationNameUnAvailable = "NotificationNameUnAvailable"

public final class UniversalNotificationCenter: NotificationCenter {
    
    #if DEBUG
    public var onInitializedUniversalNotificationCenter : (()->Void)?
    
    public var onPostingNotification : ((Notification)->Void)?
    public var onPostedNotification : ((Notification)->Void)?
    public var onShouldPostNotification : ((String)->Bool)?
    public var onPostedObserver : ((Observer)->Void)?
    public var onMonitoredObserver : ((Observer)->Void)?
    public var onDroppedObserver : ((Observer)->Void)?
    
    public private(set) var observers = [Observer]()
    
    deinit {
        observers.removeAll()
    }
    
    override public func post(_ notification: Notification) {
        onPostingNotification?(notification)
        super.post(notification)
        onPostedNotification?(notification)
    }
    override public func post(name aName: NSNotification.Name, object anObject: Any?) {
        guard onShouldPostNotification?(aName.rawValue) == true else { return }
        super.post(name: aName, object: anObject)
    }
    override public func post(name aName: NSNotification.Name, object anObject: Any?, userInfo aUserInfo: [AnyHashable : Any]? = nil) {
        guard onShouldPostNotification?(aName.rawValue) == true else { return }
        super.post(name: aName, object: anObject, userInfo: aUserInfo)
    }
    
    override public func addObserver(_ observer: Any, selector aSelector: Selector, name aName: NSNotification.Name?, object anObject: Any?) {
        super.addObserver(observer, selector: aSelector, name: aName, object: anObject)
        monitorObserver(observer as AnyObject, with: aName?.rawValue ?? NotificationNameUnAvailable)
    }
    
    override public func addObserver(forName name: NSNotification.Name?, object obj: Any?, queue: OperationQueue?, using block: @escaping (Notification) -> Void) -> NSObjectProtocol {
        monitorObserver(obj as AnyObject, with: name?.rawValue ?? NotificationNameUnAvailable)
        return super.addObserver(forName: name, object: obj, queue: queue, using: block)
    }
    
    override public func removeObserver(_ observer: Any) {
        super.removeObserver(observer)
        dropObserver(observer as AnyObject)
    }
    
    override public func removeObserver(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?) {
        super.removeObserver(observer, name: aName, object: anObject)
        removeObserver(observer)
    }
    
    private func monitorObserver(_ object: AnyObject, with notificationName: String) {
        let observer = Observer(object as AnyObject, notificationName)
        observers.append(observer)
        onMonitoredObserver?(observer)
    }
    
    private func dropObserver(_ object: AnyObject) {
        guard let found = lookupObserver(object as AnyObject) else { return }
        observers.remove(at: found.index)
    }
    
    private func lookupObserver(_ object: AnyObject) -> (index: Int,observer: Observer)? {
        
        for (index,observer) in observers.enumerated() {
            if object === observer.object {
                return (index,observer)
            }
        }
        return nil
    }
    
    private func lookupObservers(_ name: String) -> [Observer] {
        return observers.filter({ (observer) -> Bool in
            return observer.notificationName == name
        })
    }
    #endif
}

public final class Observer : Equatable {

    public static func ==(lhs: Observer, rhs: Observer) -> Bool {
        return lhs.object === rhs.object
    }
    
    public weak var object : AnyObject!
    public let notificationName : String
    
    fileprivate init(_ object: AnyObject, _ name: String) {
        self.object = object
        self.notificationName = name
    }
    
    deinit {
        object = nil
    }
}
