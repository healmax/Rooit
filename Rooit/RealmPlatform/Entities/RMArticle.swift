//
//  RMArticle.swift
//  Rooit
//
//  Created by Vincent on 2019/12/23.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import RealmSwift

class RMArticle: Object {
    
    @objc dynamic var author: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var url: String = ""
    @objc dynamic var urlToImage: String = ""
    
    override class func primaryKey() -> String? {
        return "url"
    }
}

extension RMArticle: DomainConvertibleType {
    func asDomain() -> Article {
        return Article(author: author, title: title, url: url, urlToImage: urlToImage)
    }
}

extension Article: RealmRepresentable {
    
    var uid: String {
        "url"
    }
    
    func asRealm() -> RMArticle {
        return RMArticle.build { object in
            object.author = author ?? ""
            object.title = title ?? ""
            object.url = url
            object.urlToImage = urlToImage ?? ""
        }
    }
}
