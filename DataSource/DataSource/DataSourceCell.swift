//
//  DataSourceCell.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/13/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import Foundation

protocol DataSourceCell: class {
    associatedtype Model: DataSourceModel
    static func configure(cell: Self, indexPath: IndexPath, model: Model)
}

protocol DataSourceModelCell: DataSourceCell {
    var model: Model? { get set }
}

extension DataSourceModelCell {
    static func configure(cell: Self, indexPath: IndexPath, model: Model) {
        cell.model = model
    }
}
