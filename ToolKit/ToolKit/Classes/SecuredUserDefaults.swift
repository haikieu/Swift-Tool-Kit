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
    //TODO: implement
    }
}

private class SecuredUserDefaults: UserDefaults {

    let engima : Engima = Engima()
    
    override func string(forKey defaultName: String) -> String? {
        return super.string(forKey: defaultName)
    }
    
    override func array(forKey defaultName: String) -> [Any]? {
        return super.array(forKey: defaultName)
    }
    
    override func stringArray(forKey defaultName: String) -> [String]? {
        return super.stringArray(forKey: defaultName)
    }
    
    override func data(forKey defaultName: String) -> Data? {
        return super.data(forKey: defaultName)
    }
    
    override func dictionary(forKey defaultName: String) -> [String : Any]? {
        return super.dictionary(forKey: defaultName)
    }
    
    override func object(forKey defaultName: String) -> Any? {
        return super.object(forKey: defaultName)
    }
    
    override func value(forKey key: String) -> Any? {
        return super.value(forKey: key)
    }
    
    override func value(forKeyPath keyPath: String) -> Any? {
        return super.value(forKeyPath: keyPath)
    }
    
    override func integer(forKey defaultName: String) -> Int {
        return super.integer(forKey: defaultName)
    }
    
    override func float(forKey defaultName: String) -> Float {
        return super.float(forKey: defaultName)
    }
    
    override func bool(forKey defaultName: String) -> Bool {
        return super.bool(forKey: defaultName)
    }
    
    override func double(forKey defaultName: String) -> Double {
        return super.double(forKey: defaultName)
    }
    
    override func synchronize() -> Bool {
        return super.synchronize()
    }
    
    override func removeObject(forKey defaultName: String) {
        super.removeObject(forKey: defaultName)
    }
}


fileprivate class Engima {
    
}
