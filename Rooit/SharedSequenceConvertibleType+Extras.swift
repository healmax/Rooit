//
//  s.swift
//  Rooit
//
//  Created by Vincent on 2019/12/23.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation
import RxCocoa

extension SharedSequenceConvertibleType {
    
    func unwrap<T>() -> RxCocoa.SharedSequence<Self.SharingStrategy, T> where Self.E == Optional<T> {
        return filter{ $0 != nil }.map{ $0! }
    }
}

