//
//  Company.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/1/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import Foundation

class Company {
    let name: String
    let address: String

    init(name: String, address: String) {
        self.name = name
        self.address = address
    }
}

extension Company: TableDataSourceModel {}
