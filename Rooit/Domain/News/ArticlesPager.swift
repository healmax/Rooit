//
//  ArticlesPager.swift
//  Rooit
//
//  Created by Vincent on 2019/12/23.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation

struct ArticlesPager: Codable {
    enum Country: String {
        case us = "us"
    }
    
    var status: String?
    var totalResults: Int?
    var articles: [Article]?
}

struct Article: Codable {
    var author: String?
    var title: String?
    var url: String
    var urlToImage: String?
}
