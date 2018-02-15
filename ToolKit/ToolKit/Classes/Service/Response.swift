//
//  Response.swift
//  ToolKit
//
//  Created by Hai Kieu on 2/13/18.
//  Copyright © 2018 haikieu2907@icloud.com. All rights reserved.
//

import UIKit

open class Response {
    
    //MARK: - Response metadata
    fileprivate let data : Data?
    fileprivate let response : URLResponse?
    fileprivate lazy var httpResponse : HTTPURLResponse? = { return response as? HTTPURLResponse }()
    fileprivate let error : Error?
    
    init(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        self.data = data
        self.response = response
        self.error = error
    }
    
    //MARK: - Success & http code
    public var success : Bool { return httpCode == 200 && self.error == nil }
    public lazy var httpCode : Int = { httpResponse!.statusCode }()
    
    //MARK: - Headers
    public lazy var headers : [AnyHashable:Any] = { return httpResponse!.allHeaderFields }()
    
    //MARK: - Body and its utilities
    public lazy var body : Any? = { return data }()
    public lazy var bodyStr : String? = { return nil }()
    public lazy var bodyDic : [String:Any]? = {
        return nil
    }()
    
}
