//
//  NewsService.swift
//  Rooit
//
//  Created by Vincent on 2019/12/23.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import Alamofire

protocol NewsServiceType {
    func fetchNews(country: ArticlesPager.Country) -> Observable<[Article]>
}

class NewsService: NewsServiceType {
    
    private let diposeBag = DisposeBag()
    private let network = Network.sharedDefault
    private let repository = Repository<Article>()
    private let reachability = NetworkReachabilityManager(host: "NewsService")
    
    func fetchNews(country: ArticlesPager.Country) -> Observable<[Article]> {
        let isReachable = reachability?.isReachable ?? false
        
        
        
        let multiTarget = MultiTarget(NETNewsAPI.fetchNews(countery: .us))
        let online = network.request(target: multiTarget)
            .map( ArticlesPager.self )
            .map({ (articlesPager) -> [Article] in
                return articlesPager.articles ?? []
            })
            .do(onNext: { [weak self] (articles) in
                guard let self = self, articles.count > 0 else { return }
                self.repository.save(entities: articles, update: .all)
                    .subscribe()
                    .disposed(by: self.diposeBag)
            })
        
        let offline = repository.queryAll()
        return isReachable ? online : offline
    }
}
