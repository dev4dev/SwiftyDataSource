//
//  CellDescriptor.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/13/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import UIKit

enum DataSourceRegisteredViewKind {
    case klass(klass: AnyClass)
    case nib(name: String)

    var identifier: String {
        switch self {
        case .klass(let klass):
            return String(describing: type(of: klass))
        case .nib(let name):
            return name
        }
    }
}

struct CellDescriptor {

    var identifier: String {
        return kind.identifier
    }
    let kind: DataSourceRegisteredViewKind
    let modelClassName: String

    let configure: (UITableViewCell, IndexPath, Any) -> Void

    func register(in tableView: UITableView) {
        switch kind {
        case .klass(let klass):
            tableView.register(klass, forCellReuseIdentifier: identifier)
        case .nib(let name):
            tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: identifier)
        }
    }

    init<Cell: DataSourceCell>(cellClass: Cell.Type) {
        self.init(kind: DataSourceRegisteredViewKind.klass(klass: cellClass), cellClass: cellClass)
    }

    init<Cell: DataSourceCell>(nibClass: Cell.Type) {
        let nibName = String(String(describing: type(of: nibClass)).components(separatedBy: ".").first!)
        self.init(kind: DataSourceRegisteredViewKind.nib(name: nibName), cellClass: nibClass)
    }

    init<Cell: UITableViewCell, Model: DataSourceModel>(kind: DataSourceRegisteredViewKind, _ config: @escaping (Cell, IndexPath, Model) -> Void) {
        self.kind = kind
        self.configure = { cell, indexPath, model in
            config(cell as! Cell, indexPath, model as! Model)
        }
        self.modelClassName = Model._Model_Name
    }

    private init<Cell: DataSourceCell>(kind: DataSourceRegisteredViewKind, cellClass: Cell.Type) {
        self.kind = kind
        self.modelClassName = Cell.Model._Model_Name
        self.configure = { cell, indexPath, model in
            cellClass.configure(cell: cell as! Cell, indexPath: indexPath, model: model as! Cell.Model)
        }
    }
}
