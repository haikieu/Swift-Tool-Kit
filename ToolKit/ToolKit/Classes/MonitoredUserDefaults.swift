//
//  SecuredUserDefaults.swift
//  ToolKit
//
//  Created by KIEU, HAI on 1/28/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import UIKit

public typealias OverridenValue = Any
public typealias EncryptionValue = Any
public typealias DecryptionValue = Any

public extension UserDefaults {
    
    fileprivate var monitor : UFMonitor? {
        #if DEBUG
        return UFMonitor.shared
        #else
        return nil
        #endif
    }
    
    public func startup() {
        #if DEBUG
        object_setClass(self, MonitoredUserDefaults.self)
        UserDefaults.standard.instance.monitor?.isStartup = true
        #endif
    }
    
    ///This is a hidden instance
    private var instance : MonitoredUserDefaults! {
        return UserDefaults.standard as! MonitoredUserDefaults
    }
    
    private func handeIfNotCallStartupYet() {
        guard monitor?.isStartup == true else {
            fatalError("Please make sure you called UserDefaults.startup() before do anymore further")
        }
    }
    
    func onInitializedUserDefaults(callback: ((_ keys:[String])->Void)?) {
        handeIfNotCallStartupYet()
        monitor?.onInitializedUserDefaults = callback
    }
    
    func onReadTheKeyValue(callback: ((_ key:String,_ value: Any?)->OverridenValue?)?) {
        handeIfNotCallStartupYet()
        monitor?.onReadTheKeyValue = callback
    }
    
    func onWriteTheKeyValue(callback: ((_ key:String,_ value: Any?)->OverridenValue?)?) {
        handeIfNotCallStartupYet()
        monitor?.onWriteTheKeyValue = callback
    }
    
    func onRemovedKey(callback: ((_ key:String)->Void)?) {
        handeIfNotCallStartupYet()
        monitor?.onRemovedKey = callback
    }
    
    func onSynchorized(callback : ((Bool)->Void)?) {
        handeIfNotCallStartupYet()
        callback?(false)
        monitor?.onSynchorized = callback
    }
    
    func onDebugReadingKey(callback: ((_ key:String)->Bool)?) {
        handeIfNotCallStartupYet()
        monitor?.onDebugReadingKey = callback
    }
    
    func onDebugWritingKey(callback: ((_ key:String)->Bool)?) {
        handeIfNotCallStartupYet()
        monitor?.onDebugWritingKey = callback
    }
}

fileprivate class MonitoredUserDefaults: UserDefaults {
    
    ///To restrict access, and provide an strong encapsuplated features. This class is not encourged to create the instance outside of framework, developers don't need to know this hidden class
    ///Every business should be accessed in extension of UserDefaults
    fileprivate override init?(suiteName suitename: String?) {
        super.init(suiteName: suitename)
    }
    
    deinit {
        monitor?.cleanupCallbacks()
    }
    
    override func string(forKey defaultName: String) -> String? {
        return monitor?.doReadingFlow(forKey: defaultName, value: super.string(forKey: defaultName)) as? String
    }
    
    override func array(forKey defaultName: String) -> [Any]? {
        return monitor?.doReadingFlow(forKey: defaultName, value: super.array(forKey: defaultName)) as? [Any]
    }
    
    override func stringArray(forKey defaultName: String) -> [String]? {
        return monitor?.doReadingFlow(forKey: defaultName, value: super.stringArray(forKey: defaultName)) as? [String]
    }
    
    override func data(forKey defaultName: String) -> Data? {
        return monitor?.doReadingFlow(forKey: defaultName, value: super.data(forKey: defaultName)) as? Data
    }
    
    override func dictionary(forKey defaultName: String) -> [String : Any]? {
        return monitor?.doReadingFlow(forKey: defaultName, value: super.dictionary(forKey: defaultName)) as? [String : Any]
    }
    
    override func object(forKey defaultName: String) -> Any? {
        return monitor?.doReadingFlow(forKey: defaultName, value: super.object(forKey: defaultName))
    }
    
    override func url(forKey defaultName: String) -> URL? {
        return monitor?.doReadingFlow(forKey: defaultName, value: super.url(forKey: defaultName)) as? URL
    }
    
    override func integer(forKey defaultName: String) -> Int {
        return monitor?.doReadingFlow(forKey: defaultName, value: super.integer(forKey: defaultName)) as! Int
    }
    
    override func float(forKey defaultName: String) -> Float {
        return monitor?.doReadingFlow(forKey: defaultName, value: super.float(forKey: defaultName)) as! Float
    }
    
    override func bool(forKey defaultName: String) -> Bool {
        return monitor?.doReadingFlow(forKey: defaultName, value: super.bool(forKey: defaultName)) as! Bool
    }
    
    override func double(forKey defaultName: String) -> Double {
        return monitor?.doReadingFlow(forKey: defaultName, value: super.double(forKey: defaultName)) as! Double
    }
    
    
    override func set(_ value: Bool, forKey defaultName: String) {
        super.set(monitor?.doWrittingFlow(defaultName,value) ?? value, forKey: defaultName)
    }
    
    override func set(_ value: Int, forKey defaultName: String) {
        super.set(monitor?.doWrittingFlow(defaultName,value) ?? value, forKey: defaultName)
    }
    
    override func set(_ value: Float, forKey defaultName: String) {
        super.set(monitor?.doWrittingFlow(defaultName,value) ?? value, forKey: defaultName)
    }
    
    override func set(_ value: Double, forKey defaultName: String) {
        super.set(monitor?.doWrittingFlow(defaultName,value) ?? value, forKey: defaultName)
    }
    
    override func set(_ url: URL?, forKey defaultName: String) {
        super.set(monitor?.doWrittingFlow(defaultName,url) ?? url, forKey: defaultName)
    }
    
    override func set(_ value: Any?, forKey defaultName: String) {
        super.set(monitor?.doWrittingFlow(defaultName,value) ?? value, forKey: defaultName)
    }
    
    override func removeObject(forKey defaultName: String) {
        super.removeObject(forKey: defaultName)
        monitor?.onRemovedKey?(defaultName)
    }
    
    override func synchronize() -> Bool {
        let bool = super.synchronize()
        monitor?.onSynchorized?(bool)
        return bool
    }
}

fileprivate protocol UFMonitorInterface {
    var isStartup : Bool { get set }
    var onInitializedUserDefaults : ((_ keys:[String])->Void)? { get set}
    var onReadTheKeyValue : ((_ key:String,_ value: Any?)->OverridenValue?)? { get set}
    var onWriteTheKeyValue : ((_ key:String,_ value: Any?)->OverridenValue?)? { get set }
    var onRemovedKey : ((_ key:String)->Void)? { get set }
    var onSynchorized : ((Bool)->Void)? { get set }
    
    var onDebugReadingKey : ((_ key:String)->Bool)? { get set }
    var onDebugWritingKey : ((_ key:String)->Bool)? { get set }
    
    //    @available(*,unavailable,message: "Not support this yet")
    //    var onEncryptTheKeyValue : ((_ key:String,_ value: Any?)->EncryptionValue?)? { get set }
    //    @available(*,unavailable,message: "Not support this yet")
    //    var onDecryptTheKeyValue : ((_ key:String,_ value: Any?)->DecryptionValue?)? { get set }
}

fileprivate extension UFMonitorInterface {
    
    func doReadingFlow(forKey key: String, value: Any?)->Any? {
        
        if onDebugReadingKey?(key) == true {
            //When SIGSTOP or SIGTSTP is sent to a process, the usual behaviour is to pause that process in its current state
            raise(SIGSTOP)
        }
        
        guard let callback = onReadTheKeyValue else {
            return value
        }
        return callback(key,value) ?? value
    }
    
    func doWrittingFlow(_ key: String,_ value: Any?) -> Any? {
        
        if onDebugWritingKey?(key) == true {
            //When SIGSTOP or SIGTSTP is sent to a process, the usual behaviour is to pause that process in its current state
            raise(SIGSTOP)
        }
        
        return onWriteTheKeyValue?(key,value) ?? value
    }
    
    func cleanupCallbacks() {
        //        handeIfNotCallStartupYet()
        var instance = self
        instance.onDebugWritingKey = nil
        instance.onDebugReadingKey = nil
        instance.onSynchorized = nil
        instance.onRemovedKey = nil
        instance.onWriteTheKeyValue = nil
        instance.onReadTheKeyValue = nil
        instance.onInitializedUserDefaults = nil
    }
    
    private func setAssociatedObject(key:String, value: Any?) {
        objc_setAssociatedObject(self, key, value, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
    }
    
    private func getAssociatedObject(key:String) -> Any? {
        return objc_getAssociatedObject(self, key)
    }
}

fileprivate class UFMonitor : UFMonitorInterface {
    var isStartup: Bool = false
    
    var onInitializedUserDefaults: (([String]) -> Void)?
    
    var onReadTheKeyValue: ((String, Any?) -> OverridenValue?)?
    
    var onWriteTheKeyValue: ((String, Any?) -> OverridenValue?)?
    
    var onRemovedKey: ((String) -> Void)?
    
    var onSynchorized: ((Bool) -> Void)?
    
    var onDebugReadingKey: ((String) -> Bool)?
    
    var onDebugWritingKey: ((String) -> Bool)?
    
    #if DEBUG
    static let shared = UFMonitor()
    #else
    static let shared : UFMonitor? = nil
    #endif
}
