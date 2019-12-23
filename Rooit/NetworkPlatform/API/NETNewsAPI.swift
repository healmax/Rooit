//
//  NewsAPI.swift
//  Rooit
//
//  Created by Vincent on 2019/12/23.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import Moya


enum NETNewsAPI {
    //Post
    case fetchNews(countery: ArticlesPager.Country)
}

extension NETNewsAPI: TargetType {
    var path: String {
        switch self {
        case .fetchNews:
            return "v2/top-headlines"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .fetchNews:
            return .get
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        var parameters: [String: Any] = [:]
        parameters["apiKey"] = Network.apiKey
        switch self {
        case let .fetchNews(country):
            parameters["country"] = country.rawValue
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
}
