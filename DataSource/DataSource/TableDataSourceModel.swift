//
//  TableDataSourceModel.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/13/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import Foundation

/// Protocol Model classes should conform to to be used with DataSource
protocol TableDataSourceModel {
    static var _Model_Name: String { get }
    var _Model_Name: String { get }
}

extension TableDataSourceModel {
    static var _Model_Name: String {
        return String(describing: type(of: self)).components(separatedBy: ".").first!
    }

    var _Model_Name: String {
        return String(describing: type(of: self))
    }
}
