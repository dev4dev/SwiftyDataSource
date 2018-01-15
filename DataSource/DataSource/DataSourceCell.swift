//
//  DataSourceCell.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/13/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import Foundation


/// Protocol UITableViewCell subclaass should confrom to to be able work with the DataSource
protocol DataSourceCell: class {
    associatedtype Model: DataSourceModel
    static func configure(cell: Self, indexPath: IndexPath, model: Model)
}


/// Improved cell which makes UI updates inside of its class, and only exposes model property. It simplifies configuration of DataSource
protocol DataSourceModelCell: DataSourceCell {
    var model: Model? { get set }
}

extension DataSourceModelCell {
    static func configure(cell: Self, indexPath: IndexPath, model: Model) {
        cell.model = model
    }
}
