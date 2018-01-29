//
//  CoreService.swift
//  ToolKit
//
//  Created by KIEU, HAI on 1/28/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import UIKit


public typealias RequestCallback = ((_ success: Bool)->Void)
fileprivate let defaultMaxConcurrent = 5

open class CoreService {
    
    ///If you like to get a shared instance of a subclass of CoreService, then set the preferredClass
    public static var preferredClass : AnyClass?
    public static let shared = getPreferredInstance()
    
    fileprivate private(set) var queue : ServiceOperationQueue = {
        let queue = ServiceOperationQueue()
        queue.maxConcurrentOperationCount = defaultMaxConcurrent
        queue.qualityOfService = .background
        return queue
    }()
    
    private init() {}
    private static func getPreferredInstance() -> CoreService {
        guard let preferredClass = self.preferredClass else { return CoreService() }
        return (class_createInstance(preferredClass, class_getInstanceSize(preferredClass)) as? CoreService) ?? CoreService()
    }
    
    open func async(_ url : URL, callback: RequestCallback? = nil) {
        let operation = ServiceOperation(service: self, callback: callback)
        queue.addOperation(operation)
    }
    
    open func generateTimeStamp() -> TimeInterval {
        //Need to synchronize the method, to avoid generating timeStamps with same value
        //TODO: cleanup objc_sync_enter & objc_sync_exit
        objc_sync_enter(self)
        let timeStamp = Date().timeIntervalSince1970
        objc_sync_exit(self)
        return timeStamp
    }
}

final class ServiceOperationQueue : OperationQueue {
    
    @available(*, unavailable, message: "This method is no longer available")
    override func addOperation(_ block: @escaping () -> Void) {
        super.addOperation(block)
    }
    
    @available(*, unavailable, message: "This method is no longer available")
    override func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        super.addOperations(ops, waitUntilFinished: wait)
    }
}

fileprivate let defaultRetries = 1
open class ServiceOperation : Operation {
    
    fileprivate private(set) weak var service : CoreService?
    fileprivate let timestamp : TimeInterval
    private var beginTime : TimeInterval!
    private var endTime : TimeInterval!
    fileprivate var executionTime : TimeInterval {
        guard isFinished, beginTime != nil, endTime != nil else {
            return -1
        }
        return endTime - beginTime
    }
    private var tries : Int = defaultRetries
    
    fileprivate private(set) var callback : RequestCallback? {
        didSet {
            if callback == nil {
                completionBlock = nil
            } else {
                completionBlock = { [weak self] in
                    self?.endTime = Date().timeIntervalSince1970
                    self?.callback?(true)
                }
            }
        }
    }
    private var _isCancelled : Bool = false {
        didSet {
            callback = nil
        }
    }
    open override var isCancelled: Bool {
        return _isCancelled
    }
    
    override open func cancel() {
        _isCancelled = true
        super.cancel()
    }
    
    open override func start() {
        guard _isCancelled == false else { return }
    }
    
    open override func main() {
        guard _isCancelled == false else { return }
        beginTime = Date().timeIntervalSince1970
    }
    
    @available(*, unavailable, message: "Please use init(callback:) instead")
    private override init() {
        fatalError("Do not use this method")
    }
    
    public init(service: CoreService, callback: RequestCallback?) {
        self.timestamp = service.generateTimeStamp()
        self.service = service
        self.callback = callback
    }
    
    deinit {
        self.callback = nil
    }
}
