//
//  ManualCell.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/1/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import UIKit

final class ManualCell: UITableViewCell, DataSourceCell {

    static func configure(cell: ManualCell, indexPath: IndexPath, model: Person) {
        cell.textLabel?.text = model.name + " - row \(indexPath.row)"
    }
}
