//
//  ClassCell.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/1/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import UIKit

final class CompanyCell: UITableViewCell, DataSourceModelCell {

    typealias Model = Company
    var model: Company? {
        didSet {
            textLabel?.text = model?.name
            detailTextLabel?.text = model?.address
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        textLabel?.textColor = .blue
    }
}
