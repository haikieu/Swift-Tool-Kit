//
//  UniversalNotificationCenter.swift
//  ToolKit
//
//  Created by KIEU, HAI on 1/28/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import UIKit

public extension NotificationCenter {
    
    public static func monitorNotificationCenter() {
        #if DEBUG
        object_setClass(NotificationCenter.`default`, MonitoredNotificationCenter.classForCoder())
        #endif
    }
    
    public var monitoredObservers : [Observer] {
        return self.universalNotificationCenter?.observers ?? []
    }
    
    public var availableNotifications : [String] {
        //TODO: need to implement
        return []
    }
    
    fileprivate var universalNotificationCenter : MonitoredNotificationCenter? {
        return NotificationCenter.`default` as? MonitoredNotificationCenter
    }
    
    public func onInitializedUniversalNotificationCenter(_ callback: (()->Void)?) {
        universalNotificationCenter?.onInitializedUniversalNotificationCenter = callback
    }
    
    public func onPostingNotification(_ callback: ((Notification)->Void)?) {
        universalNotificationCenter?.onPostingNotification = callback
    }
    public func onPostedNotification(_ callback: ((Notification)->Void)?) {
        universalNotificationCenter?.onPostedNotification = callback
    }
    public func onShouldPostNotification(_ callback : ((String)->Bool)?) {
        universalNotificationCenter?.onShouldPostNotification = callback
    }
    public func onPostedObserver(_ callback: ((Observer)->Void)?) {
        universalNotificationCenter?.onPostedObserver = callback
    }
    public func onMonitoredObserver(_ callback: ((Observer)->Void)?) {
        universalNotificationCenter?.onMonitoredObserver = callback
    }
    public func onDroppedObserver(_ callback: ((Observer)->Void)?) {
        universalNotificationCenter?.onDroppedObserver = callback
    }
}

fileprivate let NotificationNameUnAvailable = "NotificationNameUnAvailable"

public final class MonitoredNotificationCenter: NotificationCenter {
    
    
    fileprivate var onInitializedUniversalNotificationCenter : (()->Void)?
    
    fileprivate var onPostingNotification : ((Notification)->Void)?
    fileprivate var onPostedNotification : ((Notification)->Void)?
    fileprivate var onShouldPostNotification : ((String)->Bool)?
    fileprivate var onPostedObserver : ((Observer)->Void)?
    fileprivate var onMonitoredObserver : ((Observer)->Void)?
    fileprivate var onDroppedObserver : ((Observer)->Void)?
    
    fileprivate private(set) var observers = [Observer]()
    
    deinit {
        observers.removeAll()
    }
    
    #if DEBUG
    
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
        let observer = Observer(center: self,object as AnyObject, notificationName)
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

public final class Observer {

    public weak var notificationCenter : NotificationCenter?
    public weak var object : AnyObject?
    public let notificationName : String
    
    ///Not encourge to initialize this kind of instance outside of ToolKit framework
    fileprivate init(center: NotificationCenter,_ object: AnyObject, _ name: String) {
        self.object = object
        self.notificationName = name
        self.notificationCenter = center
    }
    
    func hold() {
        hold(seconds: .infinity)
    }
    func hold(seconds: TimeInterval) {
        //TODO: implement suspend
    }
    func skip(times: Int) {
        //TODO: implement skip
    }
    func destroy() {
        guard let object = self.object else { return }
        notificationCenter?.removeObserver(object)
    }
}

extension Observer : Equatable {
    public static func ==(lhs: Observer, rhs: Observer) -> Bool {
        return lhs.object === rhs.object
    }
}
