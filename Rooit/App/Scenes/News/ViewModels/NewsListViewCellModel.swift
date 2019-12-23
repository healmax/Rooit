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
    var cellHeight: CGFloat { get }
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
    var cellHeight: CGFloat
    
    // MARK: Private
    var articleBehavior: BehaviorRelay<Article>!
    
    init(article: Article) {
        articleBehavior = BehaviorRelay<Article>(value: article)
        articleDriver = articleBehavior.asDriver()
        
        let contentHeight = article.title?.height(withConstrainedWidth: NewsListViewCell.contentWidth, font: UIFont.systemFont(ofSize: 17)) ?? 0
        
        let realContentHeught = contentHeight < NewsListViewCell.minimunContentLabelHeight
            ? NewsListViewCell.minimunContentLabelHeight
            : contentHeight
        
        cellHeight = realContentHeught
            + NewsListViewCell.edgeInsets.top
            + NewsListViewCell.edgeInsets.bottom
    }
}
