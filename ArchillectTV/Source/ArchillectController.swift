//
//  ArchillectController.swift
//  ArchillectTV
//
//  Created by Charles Magahern on 10/25/15.
//

import Foundation

protocol ArchillectControllerDelegate {
    func archillectControllerDidConnect(_ controller: ArchillectController)
    func archillectControllerDidReceiveNewAsset(_ controller: ArchillectController, asset: ArchillectAsset)
    func archillectControllerDidFailToLoad(_ controller: ArchillectController, error: ArchillectError)
}

extension ArchillectControllerDelegate {
    func archillectControllerDidConnect(_ controller: ArchillectController) {}
    func archillectControllerDidReceiveNewAsset(_ controller: ArchillectController, asset: ArchillectAsset) {}
    func archillectControllerDidFailToLoad(_ controller: ArchillectController, error: ArchillectError) {}
}

class ArchillectController {
    var delegate: ArchillectControllerDelegate?
    
    fileprivate var _urlSession:    URLSession
    fileprivate var _serverSession: ArchillectSession?
    fileprivate var _retryCount:    UInt
    
    static fileprivate let maxRetryCount: UInt = 5
    
    init()
    {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 25.0
        
        _urlSession = URLSession(configuration: config)
        _retryCount = 0
    }
    
    func connect()
    {
        if (_serverSession == nil) {
            _fetchNewSession({ (session: ArchillectSession?, error: ArchillectError?) -> Void in
                if (session != nil && session!.isValid()) {
                    self._serverSession = session
                    self.delegate?.archillectControllerDidConnect(self)
                    
                    self._beginPollingForUpdates()
                } else if let error = error {
                    self.delegate?.archillectControllerDidFailToLoad(self, error: error)
                } else {
                    self.delegate?.archillectControllerDidFailToLoad(self, error: ArchillectError(.unknown))
                }
            })
        }
    }
    
    func disconnect()
    {
        _serverSession = nil
    }
    
    // MARK: Internal
    
    internal func _archillectTVURL(_ requestParams: [String : String]) -> URL?
    {
        let baseURL = URL(string: "http://archillect.com")
        let tvSocketURL = baseURL!.appendingPathComponent("socket.io/")
        return tvSocketURL.URLByAppendingRequestParameters(requestParams)
    }
    
    internal func _archillectStandardRequestParams() -> [String : String]
    {
        let date = Date()
        let timeString = "\(Int(date.timeIntervalSince1970))"
        let params: [String : String] = [
            "EIO" : "3",
            "transport" : "polling",
            "t" : timeString
        ]
        return params
    }
    
    internal func _fetchNewSession(_ completion: @escaping (ArchillectSession?, ArchillectError?) -> Void)
    {
        let params = _archillectStandardRequestParams()
        let connectURL = _archillectTVURL(params)
        let task = _urlSession.dataTask(with: connectURL!, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            var session: ArchillectSession? = nil
            var clientError: ArchillectError? = nil
            
            if let data = data {
                session = ArchillectSession(data)
            }
            
            if (error != nil) {
                clientError = ArchillectError(.connectionError)
            }
            
            completion(session, clientError)
        })
        task.resume()
    }
    
    internal func _startPollRequest(_ completion: @escaping (ArchillectAsset?, ArchillectError?) -> Void)
    {
        if (_serverSession != nil) {
            var params = _archillectStandardRequestParams()
            params["sid"] = _serverSession!.sessionID
            
            let url = _archillectTVURL(params)
            let task = _urlSession.dataTask(with: url!, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
                var asset: ArchillectAsset? = nil
                var clientError: ArchillectError? = nil
                
                if (data != nil) {
                    // check if we got an error response first
                    let errorResponse = ArchillectErrorResponse(data!)
                    if (errorResponse.code == 0) {
                        asset = ArchillectAsset(data!)
                    } else {
                        var errorCode: ArchillectError.ErrorCode
                        if (errorResponse.code == 1) { // invalid session
                            errorCode = .invalidSession
                        } else {
                            errorCode = .serverError
                        }
                        
                        clientError = ArchillectError(errorCode)
                    }
                }
                
                if (error != nil) {
                    clientError = ArchillectError(.connectionError)
                }
                
                completion(asset, clientError)
            })
            task.resume()
        } else {
            let error = ArchillectError(.invalidSession)
            completion(nil, error)
        }
    }
    
    internal func _beginPollingForUpdates()
    {
        _startPollRequest({ (asset: ArchillectAsset?, error: ArchillectError?) -> Void in
            if (asset != nil) {
                if (asset!.type != .unknown) {
                    self.delegate?.archillectControllerDidReceiveNewAsset(self, asset: asset!)
                }
                
                self._beginPollingForUpdates()
            } else {
                NSLog("Error fetching update: \(error ?? ArchillectError(.unknown))")
                
                if (error?.code == .invalidSession) {
                    // recoverable--reload session
                    self._serverSession = nil
                    self.connect()
                } else {
                    if (self._retryCount < ArchillectController.maxRetryCount) {
                        NSLog("Retrying...")
                        self._beginPollingForUpdates()
                    } else {
                        NSLog("Reporting update failure")
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
    var pingInterval:   TimeInterval  = 0.0
    var pingTimeout:    TimeInterval  = 0.0
    
    init()
    {}
    
    init(_ responseData: Data)
    {
        let jsonData = responseData.jsonDataByTrimmingBytes()
        if let dict = (try? JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions())) as? NSDictionary {
            if let sessionID = dict["sid"] as? NSString {
                self.sessionID = String(sessionID)
            }
            
            if let upgrades = dict["upgrades"] as? NSArray {
                for u in upgrades {
                    self.upgrades.append(String(describing: u))
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
    
    func isValid() -> Bool
    {
        return (self.sessionID.characters.count > 0)
    }
}

internal struct ArchillectErrorResponse {
    var code:       UInt    = 0
    var message:    String  = ""
    
    init()
    {}
    
    init(_ responseData: Data)
    {
        let jsonData = responseData.jsonDataByTrimmingBytes()
        if let dict = (try? JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions())) as? NSDictionary {
            if let code = dict["code"] as? NSNumber {
                self.code = code.uintValue
            }
            
            if let message = dict["message"] as? NSString {
                self.message = (message as String)
            }
        }
    }
}
