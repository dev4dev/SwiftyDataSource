//
//  SectionHeaderView.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/12/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import UIKit
import SnapKit

final class SectionHeaderView: UITableViewHeaderFooterView {

    var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    var titleLabel: UILabel = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)

        contentView.backgroundColor = .yellow
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
