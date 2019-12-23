//
//  NewsListViewCell.swift
//  Rooit
//
//  Created by Vincent on 2019/12/23.
//  Copyright © 2019 Vincent. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift

class NewsListViewCell: UICollectionViewCell {
    static let cellHeight: CGFloat = 110
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private let disposeBag = DisposeBag()
    private let defaultImage = UIImage(named: "default")
    
    func bind(_ viewModel: NewsListViewCellModelType) {
        let outpust = viewModel.ouputs
        let imageProcessor = getImageProcessor()
        
        outpust.articleDriver
            .map{ $0.title }
            .drive(titleLabel.rx.text)
            .disposed(by: disposeBag)
        
        outpust.articleDriver
            .map{ $0.urlToImage }
            .unwrap()
            .map{ URL(string: $0) }
            .drive(imageView.kf.rx.image(
                placeholder: defaultImage,
                options: [.processor(imageProcessor),
                          .scaleFactor(UIScreen.main.scale),
                          .cacheOriginalImage])
            )
            .disposed(by: disposeBag)
    }
    
    private func getImageProcessor() -> ImageProcessor {
        let targetSize = imageView.frame.size
        let resize = ResizingImageProcessor.init(referenceSize: targetSize,
        mode: .aspectFill)
        let crop = CroppingImageProcessor(size: targetSize)
        let round = RoundCornerImageProcessor(
            cornerRadius: 4
        )
        return (resize >> crop) >> round
    }
}
