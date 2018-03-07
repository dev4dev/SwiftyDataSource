//
//  Person.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/1/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import Foundation

class Person {
    let name: String
    let address: String

    init(name: String, address: String) {
        self.name = name
        self.address = address
    }
}

extension Person: DataSourceModel {}
extension Person: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: Person, rhs: Person) -> Bool {
        return lhs.name == rhs.name
    }
}
