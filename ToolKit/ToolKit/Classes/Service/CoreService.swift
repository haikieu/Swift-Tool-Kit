//
//  CoreService.swift
//  ToolKit
//
//  Created by KIEU, HAI on 1/28/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import UIKit

///RequestId value must be unique
public typealias RequestId = TimeInterval
public typealias Success = Bool
public typealias RequestCallback = ((Success, Response?)->Void)
fileprivate let defaultMaxConcurrent = 5

open class CoreService {
    
    ///If you like to get a shared instance of a subclass of CoreService, then set the preferredClass
    public static var preferredClass : AnyClass?
    public static let shared = getPreferredInstance()
    
    fileprivate private(set) var queue : RequestQueue = {
        let queue = RequestQueue()
        queue.maxConcurrentOperationCount = defaultMaxConcurrent
        queue.qualityOfService = .background
        return queue
    }()
    
    fileprivate init() {}
    deinit {
        queue.cancelAllOperations()
    }
    private static func getPreferredInstance() -> CoreService {
        guard let preferredClass = self.preferredClass else { return CoreService() }
        return (class_createInstance(preferredClass, class_getInstanceSize(preferredClass)) as? CoreService) ?? CoreService()
    }
    
    open func async(_ url : URL, callback: RequestCallback? = nil) -> RequestId {
        let operation = Request(service: self, callback: callback)
        queue.addOperation(operation)
        return operation.timestamp
    }
    
    ///If return nil, it means the requestId with its operation cannot be found
    ///If return true, it means cancelling is success
    ///If return false, it means canncelling is failure, maybe because the request has done
    public func cancel(_ requestId: RequestId) -> Bool? {
        //TODO: need to implement
        return false
    }
    
    fileprivate func generateTimeStamp() -> RequestId {
        //Need to synchronize the method, to avoid generating timeStamps with same value
        //TODO: cleanup objc_sync_enter & objc_sync_exit
        objc_sync_enter(self)
        let timeStamp = Date().timeIntervalSince1970
        defer { objc_sync_exit(self) }
        return timeStamp
    }
}

open class Service : CoreService {
    
    //External can have a chance to observer delegate
    public weak var externalSessionDelegate : URLSessionDelegate?
    //delegate itself to URLSession
    private var serviceSessionDelegate : ServiceURLSessionDelegate!
    private var session : URLSession!
    
    override init() {
        super.init()
        
        let config = URLSessionConfiguration.default
        config.networkServiceType = .default
        serviceSessionDelegate = ServiceURLSessionDelegate(self)
        session = URLSession.init(configuration: config, delegate: serviceSessionDelegate, delegateQueue: nil)
        
    }
    
    deinit {
        
    }
    
    open func get(_ url : URL, callback: RequestCallback? = nil) -> RequestId {
        //TODO: need to implement
        return async(url, callback: callback)
    }
    
    open func post(_ url : URL, callback: RequestCallback? = nil) -> RequestId {
        //TODO: need to implement
        return async(url, callback: callback)
    }
    
    open func update(_ url : URL, callback: RequestCallback? = nil) -> RequestId {
        //TODO: need to implement
        return async(url, callback: callback)
    }
    
    open func head(_ url : URL, callback: RequestCallback? = nil) -> RequestId {
        //TODO: need to implement
        return async(url, callback: callback)
    }
    
    open func delete(_ url : URL, callback: RequestCallback? = nil) -> RequestId {
        //TODO: need to implement
        return async(url, callback: callback)
    }
    
    open func download() {
        //TODO: need to implement
    }
    
    open func upload() {
        //TODO: need to implement
    }
}

fileprivate class ServiceURLSessionDelegate : NSObject, URLSessionDelegate {
    
    private weak var service : Service?
    
    init(_ service: Service) {
        self.service = service
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        service?.externalSessionDelegate?.urlSession?(session, didBecomeInvalidWithError: error)
    }
    
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        service?.externalSessionDelegate?.urlSession?(session, didReceive: challenge, completionHandler: completionHandler)
    }
    
    public func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        service?.externalSessionDelegate?.urlSessionDidFinishEvents?(forBackgroundURLSession: session)
    }
}

final class RequestQueue : OperationQueue {
    
    @available(*, unavailable, message: "This method is no longer available")
    override func addOperation(_ block: @escaping () -> Void) {
        super.addOperation(block)
    }
    
    @available(*, unavailable, message: "This method is no longer available")
    override func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        super.addOperations(ops, waitUntilFinished: wait)
    }
    
    deinit {
        self.cancelAllOperations()
    }
}

fileprivate let defaultRetries = 1
open class Request : Operation {
    
    fileprivate private(set) weak var service : CoreService?
    fileprivate let timestamp : RequestId
    fileprivate var beginTime : TimeInterval!
    fileprivate var endTime : TimeInterval!
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
                    self?.callback?(true, nil)
                }
            }
        }
    }
    fileprivate var _isCancelled : Bool = false {
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
        fatalError("Please implement this in subclass of CoreOperation")
    }
    
    open override func main() {
        fatalError("Please implement this in subclass of CoreOperation")
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

open class URLOperation : Request {
    open override func start() {
        guard _isCancelled == false else { return }
    }
    
    open override func main() {
        guard _isCancelled == false else { return }
        beginTime = Date().timeIntervalSince1970
    }
}
