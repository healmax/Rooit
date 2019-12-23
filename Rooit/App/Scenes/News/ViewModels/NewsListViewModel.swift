//
//  NewsListViewModel.swift
//  Rooit
//
//  Created by Vincent on 2019/12/23.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol NewsListViewModelInput {
    func refresh()
}

protocol NewsListViewModelOutput {
    var loadCompleteDriver: Driver<Bool> { get }
    var cellModelsDriver: Driver<[NewsListViewCellModelType]> { get }
    var cellModels: [NewsListViewCellModelType] { get }
    var isRefreshDriver: Driver<Bool> { get }
}

protocol NewsListViewModelType: NewsListViewModelInput, NewsListViewModelOutput {
    var inputs: NewsListViewModelInput { get }
    var ouputs: NewsListViewModelOutput { get }
}

class NewsListViewModel: NewsListViewModelType, NewsListViewModelInput, NewsListViewModelOutput {
    
    var inputs: NewsListViewModelInput { return self }
    var ouputs: NewsListViewModelOutput { return self }

    // MARK: Input
    func refresh() {
        self.loadCompleteBehavior.accept(false)
        refreshBehavior.accept(true)
    }

    // MARK: Outputs
    var loadCompleteDriver: Driver<Bool>
    var isRefreshDriver: Driver<Bool>
    var cellModelsDriver: Driver<[NewsListViewCellModelType]>
    var cellModels: [NewsListViewCellModelType] {
        return cellModelsBehavior.value
    }

    // MARK: Private
    private let disposeBag = DisposeBag()
    private var refreshBehavior = BehaviorRelay<Bool>(value: true)
    private let serviceType: NewsServiceType
    private var cellModelsBehavior = BehaviorRelay<[NewsListViewCellModelType]>(value: [])
    private var loadCompleteBehavior = BehaviorRelay<Bool>(value: false)
    
    init(serviceType: NewsServiceType) {
        self.serviceType = serviceType
        cellModelsDriver = cellModelsBehavior.asDriver()
        isRefreshDriver = refreshBehavior.asDriver()
        loadCompleteDriver = loadCompleteBehavior.asDriver()

        self.isRefreshDriver.asDriver()
            .flatMapLatest { [weak self] (isRefreshing) -> Driver<[Article]>  in
                guard let self = self, isRefreshing else { return .empty() }
                return self.fetchNews()
            }
            .map { (articles) -> [NewsListViewCellModelType] in
                return articles.map { (article) -> NewsListViewCellModelType in
                    NewsListViewCellModel(article: article)
                }
            }
            .do(onNext: { [weak self] _ in
                self?.refreshBehavior.accept(false)
                self?.loadCompleteBehavior.accept(true)
            })
            .drive(cellModelsBehavior)
            .disposed(by: disposeBag)
    }
    
    private func fetchNews() -> Driver<[Article]> {
        return serviceType.fetchNews(country: .us)
            .asDriver { [weak self] (error) -> SharedSequence<DriverSharingStrategy, [Article]> in
                self?.refreshBehavior.accept(false)
                return .never()
            }
    }
}
