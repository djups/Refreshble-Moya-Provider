//  RefreshbleMoyaProvider.swift
//
//  Created by Alex on 5/7/19.
//  Copyright © 2019 Alexei Jovmir. All rights reserved.
//

import Foundation
import Moya
import SKActivityIndicatorView

struct Plugins {
    static let activity = NetworkActivityPlugin { change, target in
        switch change {
        case .began : SKActivityIndicator.show("Loading...")
        case .ended : SKActivityIndicator.dismiss()
        }
    }
}
let kUrlRefresh = "xxx.com/User/refreshToken"

class RefreshbleMoyaProvider<T: TargetType>: MoyaProvider<T>{
    
    @discardableResult
    open override func request(_ target: T,
                               callbackQueue: DispatchQueue? = .none,
                               progress: ProgressBlock? = .none,
                               completion: @escaping Completion) -> Cancellable {
        
        return super.request(target, callbackQueue: callbackQueue, progress: progress, completion: { result in
            switch result {
            case .success(_):
                completion(result)
            case let .failure(error):
                let response : Response? = error.response
                let statusCode : Int? = response?.statusCode
                
                if (statusCode == 401) {
                    self.refreshTokenSyncRequest(completion: { (int, data) in
                        do {
                            let dictonary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                            if let myDictionary = dictonary, let token = myDictionary["token"] as? String {
                                UserManager.storeCurrentToken(token: token)
                                
                                let _ = self.requestNormal(target, callbackQueue: callbackQueue, progress: progress, completion: { (resultNew) in
                                    //retry initial api call, using new token
                                    completion(resultNew)
                                })
                            }
                        } catch let error as NSError {
                            print(error)
                            completion(result)
                        }
                    })
                }
                print(error)
            }
        })
    }
    
    func refreshTokenSyncRequest(completion: @escaping (Int, Data?) -> ()) {
        let userId = UserManager.getCurrentUserObject().id
        let token = UserManager.getCurrentToken()
        
        var request = URLRequest(url: URL(string: kUrlRefresh)!)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "token")
        request.httpBody = "userId=\(userId)".data(using:String.Encoding.ascii, allowLossyConversion: false)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(0, nil) // or return an error code
                return
            }
            let httpStatus = response as? HTTPURLResponse
            let httpStatusCode:Int = (httpStatus?.statusCode)!
            completion(httpStatusCode, data)
        }
        task.resume()
    }
}


