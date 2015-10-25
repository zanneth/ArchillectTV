//
//  ArchillectController.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/25/15.
//

import Foundation

protocol ArchillectControllerDelegate {
    func archillectControllerDidConnect(controller: ArchillectController)
    func archillectControllerDidReceiveNewAsset(controller: ArchillectController, asset: ArchillectAsset)
    func archillectControllerDidFailToLoad(controller: ArchillectController, error: NSError)
}

extension ArchillectControllerDelegate {
    func archillectControllerDidConnect(controller: ArchillectController) {}
    func archillectControllerDidReceiveNewAsset(controller: ArchillectController, asset: ArchillectAsset) {}
    func archillectControllerDidFailToLoad(controller: ArchillectController, error: NSError) {}
}

class ArchillectController {
    var delegate: ArchillectControllerDelegate?
    
    private var _urlSession:    NSURLSession
    private var _serverSession: ArchillectSession?
    private var _retryCount:    UInt
    
    static private let maxRetryCount: UInt = 5
    
    init()
    {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        config.timeoutIntervalForRequest = 25.0
        
        _urlSession = NSURLSession(configuration: config)
        _retryCount = 0
    }
    
    func connect()
    {
        if (_serverSession == nil) {
            _fetchNewSession({ (session: ArchillectSession?, error: NSError?) -> Void in
                if (session != nil) {
                    print("Began session: \(session)")
                    self._serverSession = session
                    self.delegate?.archillectControllerDidConnect(self)
                    
                    self._beginPollingForUpdates()
                } else {
                    print("Connection error: \(error)")
                    self.delegate?.archillectControllerDidFailToLoad(self, error: error!)
                }
            })
        }
    }
    
    func disconnect()
    {
        _serverSession = nil
    }
    
    // MARK: Internal
    
    internal func _archillectTVURL(requestParams: [String : String]) -> NSURL?
    {
        let baseURL = NSURL(string: "http://archillect.com")
        let tvSocketURL = baseURL!.URLByAppendingPathComponent("socket.io/")
        return tvSocketURL.URLByAppendingRequestParameters(requestParams)
    }
    
    internal func _archillectStandardRequestParams() -> [String : String]
    {
        let date = NSDate()
        let timeString = "\(Int(date.timeIntervalSince1970))"
        let params: [String : String] = [
            "EIO" : "3",
            "transport" : "polling",
            "t" : timeString
        ]
        return params
    }
    
    internal func _fetchNewSession(completion: (ArchillectSession?, NSError?) -> Void)
    {
        let params = _archillectStandardRequestParams()
        let connectURL = _archillectTVURL(params)
        let task = _urlSession.dataTaskWithURL(connectURL!) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            var session: ArchillectSession? = nil
            var clientError: NSError? = nil
            
            if (data != nil) {
                session = ArchillectSession(data!)
            }
            
            if (error != nil) {
                clientError = NSError.archillectError(.ConnectionError, underlying: error)
            }
            
            completion(session, clientError)
        }
        task.resume()
    }
    
    internal func _startPollRequest(completion: (ArchillectAsset?, NSError?) -> Void)
    {
        if (_serverSession != nil) {
            var params = _archillectStandardRequestParams()
            params["sid"] = _serverSession!.sessionID
            
            let url = _archillectTVURL(params)
            let task = _urlSession.dataTaskWithURL(url!, completionHandler: { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                var asset: ArchillectAsset? = nil
                var clientError: NSError? = nil
                
                if (data != nil) {
                    // check if we got an error response first
                    let errorResponse = ArchillectErrorResponse(data!)
                    if (errorResponse.code == 0) {
                        asset = ArchillectAsset(data!)
                    } else {
                        let userInfo = ["code" : errorResponse.code, "message" : errorResponse.message]
                        var errorCode: ArchillectErrorCode
                        if (errorResponse.code == 1) { // invalid session
                            errorCode = .InvalidSession
                        } else {
                            errorCode = .ServerError
                        }
                        
                        clientError = NSError.archillectError(errorCode, userInfo: userInfo as [NSObject : AnyObject])
                    }
                }
                
                if (error != nil && clientError == nil) {
                    clientError = NSError.archillectError(.ConnectionError, underlying: error)
                }
                
                completion(asset, clientError)
            })
            task.resume()
        } else {
            let error = NSError.archillectError(.InvalidSession)
            completion(nil, error)
        }
    }
    
    internal func _beginPollingForUpdates()
    {
        _startPollRequest({ (asset: ArchillectAsset?, error: NSError?) -> Void in
            if (asset != nil) {
                if (asset!.type != .Unknown) {
                    self.delegate?.archillectControllerDidReceiveNewAsset(self, asset: asset!)
                }
                
                self._beginPollingForUpdates()
            } else {
                print("Error fetching update: \(error)")
                
                let archillectError = ArchillectErrorCode(rawValue: error!.code)!
                if (archillectError == .InvalidSession) {
                    // recoverable--reload session
                    self._serverSession = nil
                    self.connect()
                } else {
                    if (self._retryCount < ArchillectController.maxRetryCount) {
                        print("Retrying...")
                        self._beginPollingForUpdates()
                    } else {
                        print("Reporting update failure")
                        self._retryCount = 0
                        self.delegate?.archillectControllerDidFailToLoad(self, error: error!)
                    }
                }
            }
        })
    }
}

internal struct ArchillectSession {
    var sessionID:      String          = ""
    var upgrades:       [String]        = []
    var pingInterval:   NSTimeInterval  = 0.0
    var pingTimeout:    NSTimeInterval  = 0.0
    
    init()
    {}
    
    init(_ responseData: NSData)
    {
        let jsonData = responseData.jsonDataByTrimmingBytes()
        if let dict = (try? NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions())) as? NSDictionary {
            if let sessionID = dict["sid"] as? NSString {
                self.sessionID = String(sessionID)
            }
            
            if let upgrades = dict["upgrades"] as? NSArray {
                for u in upgrades {
                    self.upgrades.append(String(u))
                }
            }
            
            if let pingInterval = dict["pingInterval"] as? NSNumber {
                self.pingInterval = pingInterval.doubleValue
            }
            
            if let pingTimeout = dict["pingTimeout"] as? NSNumber {
                self.pingTimeout = pingTimeout.doubleValue
            }
        }
    }
}

internal struct ArchillectErrorResponse {
    var code:       UInt    = 0
    var message:    String  = ""
    
    init()
    {}
    
    init(_ responseData: NSData)
    {
        let jsonData = responseData.jsonDataByTrimmingBytes()
        if let dict = (try? NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions())) as? NSDictionary {
            if let code = dict["code"] as? NSNumber {
                self.code = code.unsignedIntegerValue
            }
            
            if let message = dict["message"] as? NSString {
                self.message = (message as String)
            }
        }
    }
}
