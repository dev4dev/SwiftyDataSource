//
//  TestCell.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/1/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import UIKit

final class PersonCell: UITableViewCell, DataSourceModelCell {

    typealias Model = Person
    var model: Person? {
        didSet {
            textLabel?.text = model?.name
        }
    }
}
