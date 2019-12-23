//
//  Convertion.swift
//  Rooit
//
//  Created by Vincent on 2019/12/23.
//  Copyright © 2019 Vincent. All rights reserved.
//

import Foundation

protocol DomainConvertibleType {
    associatedtype DomainType
    func asDomain() -> DomainType
}
