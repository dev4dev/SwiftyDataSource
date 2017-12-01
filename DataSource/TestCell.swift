//
//  TestCell.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/1/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import UIKit

class TestCell: UITableViewCell, DataSourceCell {
    typealias Model = Person


    var model: Person? {
        didSet {
            textLabel?.text = model?.name
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    static func configure(cell: TestCell, model: TestCell.Model) {
        cell.model = model
    }
}
