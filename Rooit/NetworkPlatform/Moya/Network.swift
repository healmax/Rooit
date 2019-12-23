//
//  Network.swift
//  Rooit
//
//  Created by Vincent on 2019/12/23.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import RxCocoa
import Alamofire

private func JSONResponseDataFormatter(_ data: Data) -> Data {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return prettyData
    } catch {
        return data // fallback to original data if it can't be serialized.
    }
}

class Network {

    static let apiKey = "fb0c630cec5d43ac98e4ae6b7776df59"
    static let sharedDefault = Network.newDefaultNetwork()
    static let sharedUploadDefault = Network.newDefaultUploadNetwork()
    //    static let sharedDefault = Network.newStubbingNetworking()
    
    private(set) var provider: MoyaProvider<MultiTarget>!
    
    public init(endpointClosure: @escaping MoyaProvider<MultiTarget>.EndpointClosure = MoyaProvider<MultiTarget>.defaultEndpointMapping,
                requestClosure: @escaping MoyaProvider<MultiTarget>.RequestClosure = MoyaProvider<MultiTarget>.defaultRequestMapping,
                stubClosure: @escaping MoyaProvider<MultiTarget>.StubClosure = MoyaProvider<MultiTarget>.neverStub,
                manager: Manager = Network.defaultSessionManager(),
                plugins: [PluginType] = Network.defaultPluginTypes(),
                trackInflights: Bool = false) {
        
        provider = MoyaProvider.init(endpointClosure: endpointClosure, requestClosure: requestClosure, stubClosure: stubClosure, manager: manager, plugins: plugins, trackInflights: trackInflights)
    }
    
    func requestWithProgress(target: MultiTarget) -> Observable<Moya.ProgressResponse> {
        let actualRequest = self.provider.rx.requestWithProgress(target, callbackQueue: DispatchQueue.main)
        
        return self.refreshTokenIfNeeded()
            .flatMap { _ in
                return actualRequest
            }
    }
    
    func request(target: MultiTarget, retry: Int = 1) -> Observable<Moya.Response>  {
        let actualRequest = self.provider.rx.request(target)
        return self.refreshTokenIfNeeded()
            .flatMap { _ in
                return actualRequest
        }
        .filterSuccessfulStatusCodes()
        .catchError { (error) -> Observable<Response> in
            // 集中管理錯誤訊息
            return Observable.error(error)
        }
        .retry(retry)
    }
}

extension Network {
    func refreshTokenIfNeeded() -> Observable<Bool> {
        if true {
            return .just(false)
        }
    }
}

extension Network {
    static private func newDefaultNetwork() -> Network {
        return Network()
    }
    
    static private func newDefaultUploadNetwork() -> Network {
        return Network(manager: Network.defaultUploadSessionManager())
    }
    
    // API開發尚未完成, 可以用TargetType的SamepleData做測試
    static private func newStubbingNetworking() -> Network {
        return Network(stubClosure: MoyaProvider.delayedStub(1))
    }
    
    static private func defaultPluginTypes() -> [PluginType] {
        return []
        return [NetworkLoggerPlugin(verbose: true, cURL: true, responseDataFormatter: JSONResponseDataFormatter)]
    }
    
    static private func defaultSessionManager() -> Alamofire.SessionManager {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 20 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 10 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return SessionManager(configuration: configuration)
    }
    
    static private func defaultUploadSessionManager() -> Alamofire.SessionManager {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 120 // as seconds, you can set your request timeout
        configuration.timeoutIntervalForResource = 120 // as seconds, you can set your resource timeout
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return SessionManager(configuration: configuration)
    }
}

extension TargetType {
    public var baseURL: URL {
        return URL(string: "https://newsapi.org/")!
    }
}

extension MultiTarget: AccessTokenAuthorizable {
    public var authorizationType: AuthorizationType {
        return .custom("")
    }
}

