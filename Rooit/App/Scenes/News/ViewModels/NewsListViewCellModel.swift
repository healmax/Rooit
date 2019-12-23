//
//  NewsListViewCellModel.swift
//  Rooit
//
//  Created by Vincent on 2019/12/23.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import RxCocoa

protocol NewsListViewCellModelInput {
    
}

protocol NewsListViewCellModelOutput {
    var articleDriver: Driver<Article> { get }
}

protocol NewsListViewCellModelType: NewsListViewCellModelInput, NewsListViewCellModelOutput {
    var inputs: NewsListViewCellModelInput { get }
    var ouputs: NewsListViewCellModelOutput { get }
}

class NewsListViewCellModel: NewsListViewCellModelType, NewsListViewCellModelInput, NewsListViewCellModelOutput {
    
    var inputs: NewsListViewCellModelInput { return self }
    var ouputs: NewsListViewCellModelOutput { return self }
    
    // MAKR: Outputs
    var articleDriver: Driver<Article>
    
    // MARK: Private
    var articleBehavior: BehaviorRelay<Article>!
    
    init(article: Article) {
        articleBehavior = BehaviorRelay<Article>(value: article)
        articleDriver = articleBehavior.asDriver()
    }
}
