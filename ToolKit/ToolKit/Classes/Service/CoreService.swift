//
//  CoreService.swift
//  ToolKit
//
//  Created by KIEU, HAI on 1/28/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import UIKit

///RequestId value must be unique
public typealias RequestTicket = TimeInterval
public typealias Success = Bool
public typealias RequestCallback = ((Success, Response?)->Void)
fileprivate let defaultMaxConcurrent = 5

extension RequestTicket {
    func cancel() {
        //TODO: need to implement
    }
}

open class CoreService {
    
    ///If you like to get a shared instance of a subclass of CoreService, then set the preferredClass
    public static var preferredClass : AnyClass?
    public static let shared = getPreferredInstance()
    
    fileprivate lazy var requestQueue : RequestQueue = { return createQueue() }()
    fileprivate lazy var session : URLSession = { return createSession() }()
    
    //External can have a chance to observer delegate
    public weak var externalSessionDelegate : URLSessionDelegate?
    //delegate itself to URLSession
    private var serviceSessionDelegate : ServiceURLSessionDelegate!
    
    func createQueue() -> RequestQueue {
        let queue = RequestQueue()
        queue.maxConcurrentOperationCount = defaultMaxConcurrent
        queue.qualityOfService = .background
        return queue
    }
    
    func createSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.networkServiceType = .default
        serviceSessionDelegate = ServiceURLSessionDelegate(self)
        session = URLSession.init(configuration: config, delegate: serviceSessionDelegate, delegateQueue: nil)
        return session
    }
    
    fileprivate init() {}
    deinit {
        requestQueue.cancelAllOperations()
    }
    private static func getPreferredInstance() -> CoreService {
        guard let preferredClass = self.preferredClass else { return CoreService() }
        return (class_createInstance(preferredClass, class_getInstanceSize(preferredClass)) as? CoreService) ?? CoreService()
    }
    
    open func request(_ url : URL, callback: RequestCallback? = nil) -> RequestTicket {
        fatalError("Please implement this in subclass")
    }
    
    ///If return nil, it means the requestId with its operation cannot be found
    ///If return true, it means cancelling is success
    ///If return false, it means canncelling is failure, maybe because the request has done
    public func cancel(_ requestId: RequestTicket) -> Bool? {
        //TODO: need to implement
        return false
    }
    
    fileprivate func generateTimeStamp() -> RequestTicket {
        //Need to synchronize the method, to avoid generating timeStamps with same value
        //TODO: cleanup objc_sync_enter & objc_sync_exit
        objc_sync_enter(self)
        let timeStamp = Date().timeIntervalSince1970
        defer { objc_sync_exit(self) }
        return timeStamp
    }
}

open class Service : CoreService {
    
    open override func request(_ url: URL, callback: RequestCallback?) -> RequestTicket {
        let request = Request.init(self, url, callback)
        requestQueue.addRequest(request)
        return request.requestTicket
    }

    open func get(_ url : URL, callback: RequestCallback? = nil) -> RequestTicket {
        //TODO: need to implement
        return request(url, callback: callback)
    }
    
    open func post(_ url : URL, callback: RequestCallback? = nil) -> RequestTicket {
        //TODO: need to implement
        return request(url, callback: callback)
    }
    
    open func update(_ url : URL, callback: RequestCallback? = nil) -> RequestTicket {
        //TODO: need to implement
        return request(url, callback: callback)
    }
    
    open func head(_ url : URL, callback: RequestCallback? = nil) -> RequestTicket {
        //TODO: need to implement
        return request(url, callback: callback)
    }
    
    open func delete(_ url : URL, callback: RequestCallback? = nil) -> RequestTicket {
        //TODO: need to implement
        return request(url, callback: callback)
    }
    
    open func download() {
        //TODO: need to implement
    }
    
    open func upload() {
        //TODO: need to implement
    }
}

fileprivate class ServiceURLSessionDelegate : NSObject, URLSessionDelegate {
    
    private weak var service : CoreService?
    
    init(_ service: CoreService) {
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
    
    @available(*, unavailable, message: "This method is no longer available")
    override func addOperation(_ op: Operation) {
        super.addOperation(op)
    }
    
    func addRequest(_ request: Request) {
        super.addOperation(request)
    }
    
    deinit {
        self.cancelAllOperations()
    }
}

fileprivate let defaultRetries = 1
open class Request : Operation {
    
    fileprivate private(set) weak var service : CoreService?
    
    fileprivate let requestTicket : RequestTicket
    fileprivate let url : URL
    fileprivate var task : URLSessionTask?
    fileprivate private(set) var callback : RequestCallback?
    private var tries : Int = defaultRetries
    
    fileprivate var beginTime : TimeInterval = 0
    fileprivate var endTime : TimeInterval = 0
    fileprivate var executionTime : TimeInterval { return endTime - beginTime }
    
    @available(*, unavailable, message: "Please use this initializer")
    private override init() { fatalError() }
    
    public init(_ service: CoreService,_ url: URL, _ callback: RequestCallback?) {
        
        self.requestTicket = service.generateTimeStamp()
        self.service = service
        self.url = url
        self.callback = callback
        super.init()
    }
    
    deinit { self.callback = nil }
    
    fileprivate private(set) var _isCancelled : Bool = false {
        didSet {
            didChangeValue(forKey: "isCancelled")
        }
        willSet {
            willChangeValue(forKey: "isCancelled")
        }
    }
    
    open override var isCancelled: Bool {
        return _isCancelled
    }
    
    fileprivate private(set) var _isFinished : Bool = false {
        didSet {
            didChangeValue(forKey: "isFinished")
        }
        willSet {
            willChangeValue(forKey: "isFinished")
        }
    }
    open override var isFinished: Bool { return _isFinished }
    
    fileprivate private(set) var _isExecuting : Bool = false {
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
    }
    
    open override var isReady: Bool { return true }
    open override var isExecuting: Bool { return _isExecuting }
    open override var isAsynchronous: Bool { return true }
    open override var isConcurrent: Bool { return true }
    
    open func suspend() {
        guard isCancelled == false, isFinished == false else { return }
        task?.suspend()
    }
    
    open func resume() {
        guard isCancelled == false, isFinished == false else { return }
        task?.resume()
    }
    
    override open func cancel() {
        callback = nil
        _isCancelled = true
        task?.cancel()
        super.cancel()
    }
    
    open override func start() {
        guard isCancelled == false else { _isFinished = true; return }
        task = service?.session.dataTask(with: url, completionHandler: responseHandler)
        beginTime = Date().timeIntervalSince1970
        tries -= 1
        task?.resume()
        _isExecuting = true
    }
    
    open override func main() {
        guard isCancelled == false else { _isFinished = true; return }
    }
    
    lazy var responseHandler : ((Data?, URLResponse?, Error?)->Void) = { [weak self] (data,urlResponse,error) in
        
        self?.endTime = Date().timeIntervalSince1970
        
        //The request is no longer existing, but I don't expected this
        guard let `self` = self else { fatalError("The request is no longer existing, but don't expected this") }
        
        // The request has been cancelled before
        guard self.isCancelled else {
            self._isFinished = true
            return
        }
        
        let response = Response.init(data, urlResponse, error)
        self.callback?(response.success, response)
        self._isExecuting = false
        self._isFinished = true
    }
}

extension URL : ExpressibleByStringLiteral {
    
    public typealias StringLiteralType = String
    
    public init(stringLiteral value: URL.StringLiteralType) {
        self.init(string: value)!
    }
}
