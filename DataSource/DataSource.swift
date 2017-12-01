//
//  DataSource.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/1/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import UIKit

// MARK: - Model
protocol DataSourceModel {
    static var _Model_Name: String { get }
    var _Model_Name: String { get }
}

extension DataSourceModel {
    static var _Model_Name: String {
        return String(describing: type(of: self)).components(separatedBy: ".").first!
    }

    var _Model_Name: String {
        return String(describing: type(of: self))
    }
}

// MARK: - Cell
protocol DataSourceCell: class {
    associatedtype Model: DataSourceModel
    static func configure(cell: Self, model: Model)
}

protocol DataSourceCellAutomatic: DataSourceCell {
    var model: Model? { get set }
}

extension DataSourceCellAutomatic {
    static func configure(cell: Self, model: Model) {
        cell.model = model
    }
}

// MARK: - Descriptor
struct CellDescriptor {

    enum CellKind {
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

    var identifier: String {
        return kind.identifier
    }
    let kind: CellKind
    let modelClassName: String

    let configure: (UITableViewCell, Any) -> Void

    func register(in tableView: UITableView) {
        switch kind {
        case .klass(let klass):
            tableView.register(klass, forCellReuseIdentifier: identifier)
        case .nib(let name):
            tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: identifier)
        }
    }

    init<Cell: DataSourceCell>(cellClass: Cell.Type) {
        self.init(kind: CellKind.klass(klass: cellClass), cellClass: cellClass)
    }

    init<Cell: DataSourceCell>(nibClass: Cell.Type) {
        let nibName = String(String(describing: type(of: nibClass)).components(separatedBy: ".").first!)
        self.init(kind: CellKind.nib(name: nibName), cellClass: nibClass)
    }

    private init<Cell: DataSourceCell>(kind: CellKind, cellClass: Cell.Type) {
        self.kind = kind
        self.modelClassName = Cell.Model._Model_Name
        self.configure = { cell, model in
            cellClass.configure(cell: cell as! Cell, model: model as! Cell.Model)
        }
    }
}

// MARK: - DataSource
final class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    let tableView: UITableView
    private var descriptors: [String: CellDescriptor] = [:]
    private var callbacks: [String: (DataSourceModel) -> Void] = [:]
    var onSelectCallback: (DataSourceModel) -> () = { _ in }

    private var data: [DataSourceModel] = []

    init(tableView: UITableView) {
        self.tableView = tableView

        super.init()

        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    func register(cellDescriptor: CellDescriptor) {
        cellDescriptor.register(in: tableView)
        descriptors[cellDescriptor.modelClassName] = cellDescriptor
    }

    func addData(_ data: [DataSourceModel]) {
        self.data.append(contentsOf: data)
        tableView.reloadData()
    }

    func onSelect<Model: DataSourceModel>(_ callback: @escaping (Model) -> Void) {
        callbacks[Model._Model_Name] = { model in
            callback(model as! Model)
        }
    }

    // MARK: -

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = data[indexPath.row]
        guard let descriptor = descriptors[item._Model_Name] else {
            fatalError("Added unsupported class \(item._Model_Name)")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: descriptor.identifier, for: indexPath)
        descriptor.configure(cell, item)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = data[indexPath.row]
        onSelectCallback(item)
        guard let callback = callbacks[item._Model_Name] else { return }
        callback(item)
    }
}
