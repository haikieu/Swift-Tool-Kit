//
//  SecuredUserDefaults.swift
//  ToolKit
//
//  Created by KIEU, HAI on 1/28/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import UIKit

public extension UserDefaults {
    public func initilizeSecuredUserDefaults() {
        object_setClass(UserDefaults.standard, MonitoredUserDefaults.self)
    }
    
    ///This is a hidden instance
    private var instance : MonitoredUserDefaults? {
        return UserDefaults.standard as? MonitoredUserDefaults
    }
    
    func onInitializedUserDefaults(callback: ((_ keys:[String])->Void)?) {
        instance?.onInitializedUserDefaults = callback
    }
    
    func onReadTheKeyValue(callback: ((_ key:String,_ value: Any?)->OverridenValue?)?) {
        instance?.onReadTheKeyValue = callback
    }
    
    func onWriteTheKeyValue(callback: ((_ key:String,_ value: Any?)->OverridenValue?)?) {
        instance?.onWriteTheKeyValue = callback
    }
    
    func onRemovedKey(callback: ((_ key:String)->Void)?) {
        instance?.onRemovedKey = callback
    }
    
    func onSynchorized(callback : ((Bool)->Void)?) {
        instance?.onSynchorized = callback
    }
    
    func onDebugReadingKey(callback: ((_ key:String)->Bool)?) {
        instance?.onDebugReadingKey = callback
    }
    
    func onDebugWritingKey(callback: ((_ key:String)->Bool)?) {
        instance?.onDebugWritingKey = callback
    }
    
    func cleanupCallbacks() {
        instance?.onDebugWritingKey = nil
        instance?.onDebugReadingKey = nil
        instance?.onSynchorized = nil
        instance?.onRemovedKey = nil
        instance?.onWriteTheKeyValue = nil
        instance?.onReadTheKeyValue = nil
        instance?.onInitializedUserDefaults = nil
    }
}

public typealias OverridenValue = Any
public typealias EncryptionValue = Any
public typealias DecryptionValue = Any

private class MonitoredUserDefaults: UserDefaults {

    ///To restrict access, and provide an strong encapsuplated features. This class is not encourged to create the instance outside of framework, developers don't need to know this hidden class
    ///Every business should be accessed in extension of UserDefaults
    fileprivate override init?(suiteName suitename: String?) {
        super.init(suiteName: suitename)
    }
    
    deinit {
        cleanupCallbacks()
    }
    
    fileprivate var onInitializedUserDefaults : ((_ keys:[String])->Void)?
    fileprivate var onReadTheKeyValue : ((_ key:String,_ value: Any?)->OverridenValue?)?
    fileprivate var onWriteTheKeyValue : ((_ key:String,_ value: Any?)->OverridenValue?)?
    fileprivate var onRemovedKey : ((_ key:String)->Void)?
    fileprivate var onSynchorized : ((Bool)->Void)?
    
    fileprivate var onDebugReadingKey : ((_ key:String)->Bool)?
    fileprivate var onDebugWritingKey : ((_ key:String)->Bool)?
    
    @available(*,unavailable,message: "Not support this yet")
    var onEncryptTheKeyValue : ((_ key:String,_ value: Any?)->EncryptionValue?)?
    @available(*,unavailable,message: "Not support this yet")
    var onDecryptTheKeyValue : ((_ key:String,_ value: Any?)->DecryptionValue?)?
    
    private func doReadingFlow(forKey key: String, value: Any?)->Any? {
        
        if onDebugReadingKey?(key) == true {
            //When SIGSTOP or SIGTSTP is sent to a process, the usual behaviour is to pause that process in its current state
            raise(SIGSTOP)
        }
        
        return onReadTheKeyValue?(key,value) ?? value
    }
    
    private func doWrittingFlow(_ key: String,_ value: Any?) -> Any? {
        
        if onDebugWritingKey?(key) == true {
            //When SIGSTOP or SIGTSTP is sent to a process, the usual behaviour is to pause that process in its current state
            raise(SIGSTOP)
        }
        
        return onWriteTheKeyValue?(key,value) ?? value
    }
    
    override func string(forKey defaultName: String) -> String? {
        return doReadingFlow(forKey: defaultName, value: super.string(forKey: defaultName)) as? String
    }
    
    override func array(forKey defaultName: String) -> [Any]? {
        return doReadingFlow(forKey: defaultName, value: super.array(forKey: defaultName)) as? [Any]
    }
    
    override func stringArray(forKey defaultName: String) -> [String]? {
        return doReadingFlow(forKey: defaultName, value: super.stringArray(forKey: defaultName)) as? [String]
    }
    
    override func data(forKey defaultName: String) -> Data? {
        return doReadingFlow(forKey: defaultName, value: super.data(forKey: defaultName)) as? Data
    }
    
    override func dictionary(forKey defaultName: String) -> [String : Any]? {
        return doReadingFlow(forKey: defaultName, value: super.dictionary(forKey: defaultName)) as? [String : Any]
    }
    
    override func object(forKey defaultName: String) -> Any? {
        return doReadingFlow(forKey: defaultName, value: super.object(forKey: defaultName))
    }
    
    override func url(forKey defaultName: String) -> URL? {
        return doReadingFlow(forKey: defaultName, value: super.url(forKey: defaultName)) as? URL
    }
    
    override func integer(forKey defaultName: String) -> Int {
        return doReadingFlow(forKey: defaultName, value: super.integer(forKey: defaultName)) as! Int
    }
    
    override func float(forKey defaultName: String) -> Float {
        return doReadingFlow(forKey: defaultName, value: super.float(forKey: defaultName)) as! Float
    }
    
    override func bool(forKey defaultName: String) -> Bool {
        return doReadingFlow(forKey: defaultName, value: super.bool(forKey: defaultName)) as! Bool
    }
    
    override func double(forKey defaultName: String) -> Double {
        return doReadingFlow(forKey: defaultName, value: super.double(forKey: defaultName)) as! Double
    }
    
    
    override func set(_ value: Bool, forKey defaultName: String) {
        super.set(doWrittingFlow(defaultName,value) ?? value, forKey: defaultName)
    }
    
    override func set(_ value: Int, forKey defaultName: String) {
        super.set(doWrittingFlow(defaultName,value) ?? value, forKey: defaultName)
    }
    
    override func set(_ value: Float, forKey defaultName: String) {
        super.set(doWrittingFlow(defaultName,value) ?? value, forKey: defaultName)
    }
    
    override func set(_ value: Double, forKey defaultName: String) {
        super.set(doWrittingFlow(defaultName,value) ?? value, forKey: defaultName)
    }
    
    override func set(_ url: URL?, forKey defaultName: String) {
        super.set(doWrittingFlow(defaultName,url) ?? url, forKey: defaultName)
    }
    
    override func set(_ value: Any?, forKey defaultName: String) {
        super.set(doWrittingFlow(defaultName,value) ?? value, forKey: defaultName)
    }
    
    override func removeObject(forKey defaultName: String) {
        super.removeObject(forKey: defaultName)
        onRemovedKey?(defaultName)
    }
    
    override func synchronize() -> Bool {
        let bool = super.synchronize()
        onSynchorized?(bool)
        return bool
    }
}


fileprivate class Engima {
    
}
