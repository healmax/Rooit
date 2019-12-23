//
//  NewsViewController.swift
//  Rooit
//
//  Created by Vincent on 2019/12/23.
//  Copyright © 2019 Vincent. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift

private let cellReuseID = "\(NewsListViewCell.self)"

class NewsListViewController: UIViewController {
    
    var viewModel: NewsListViewModelType!
    
    // UI
    private var collectionView: UICollectionView!
    private var refreshControl: UIRefreshControl!
    
    // RxSwift
    private let disposeBag = DisposeBag()
    
    static func instance(with viewModel: NewsListViewModelType) -> NewsListViewController {
        let vc = NewsListViewController()
        vc.viewModel = viewModel
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        bindViewModel()
        title = "Exam"
    }
    
    func bindViewModel() {
        guard let viewModel = viewModel else {
            fatalError("Need NewsListViewModelType")
        }
        
        let outputs = viewModel.ouputs
        
        outputs.loadCompleteDriver
            .filter{ $0 }
            .drive(onNext: { [weak self] _ in
                self?.collectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        outputs.isRefreshDriver
            .filter{ !$0 }
            .drive(onNext: { [weak self] isRefreshing in
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: Private
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let cellNib = UINib.init(nibName: cellReuseID, bundle: nil)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(cellNib, forCellWithReuseIdentifier: cellReuseID)
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        view.layoutIfNeeded()
    }
    
    @objc private func reloadData() {
        let inputs = viewModel.inputs
        inputs.refresh()
    }
}

extension NewsListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let outputs = viewModel.ouputs
        let cellModels = outputs.cellModels
        return cellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let outputs = viewModel.ouputs
        let viewModelType = outputs.cellModels[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseID, for: indexPath) as! NewsListViewCell
        cell.layoutIfNeeded()
        cell.bind(viewModelType)
        return cell
    }
}

extension NewsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: NewsListViewCell.cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
