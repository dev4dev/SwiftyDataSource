//
//  ClassCell.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/1/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import UIKit

class ClassCell: UITableViewCell, DataSourceCell {
    typealias Model = Company
    static func configure(cell: ClassCell, model: Company) {
        cell.model = model
    }


    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var model: Company? {
        didSet {
            textLabel?.text = model?.name
            detailTextLabel?.text = model?.address
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        textLabel?.textColor = .blue
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
