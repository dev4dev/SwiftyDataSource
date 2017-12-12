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
    static func configure(cell: Self, indexPath: IndexPath, model: Model)
}

protocol DataSourceModelCell: DataSourceCell {
    var model: Model? { get set }
}

extension DataSourceModelCell {
    static func configure(cell: Self, indexPath: IndexPath, model: Model) {
        cell.model = model
    }
}

// MARK: - Descriptor
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

// MARK: - Section

protocol TitledView: class {
    var title: String? { get set }
}

final class DataSourceSection  {
    enum HeaderViewKind {
        case title(String)
        case view(HeaderFooterViewInfo)

        var info: HeaderFooterViewInfo? {
            guard case let .view(info) = self else { return nil }
            return info
        }

        var title: String? {
            guard case let .title(title) = self else { return nil }
            return title
        }
    }

    struct HeaderFooterViewInfo {
        let identifier: String
        let title: String?
        let kind: DataSourceRegisteredViewKind
        let height: CGFloat

        init(identifier: String, title: String?, kind: DataSourceRegisteredViewKind, height: CGFloat) {
            self.identifier = identifier
            self.title = title
            self.kind = kind
            self.height = height
        }

        func register(in tableView: UITableView) {
            switch kind {
            case .klass(klass: let klass):
                tableView.register(klass, forHeaderFooterViewReuseIdentifier: identifier)
            case .nib(name: let name):
                tableView.register(UINib(nibName: name, bundle: nil), forHeaderFooterViewReuseIdentifier: identifier)
            }
        }
    }

    private var data: [DataSourceModel] = []

    var header: HeaderViewKind?
    var footer: HeaderViewKind?

    var objectsCount: Int {
        return data.count
    }

    init(data: [DataSourceModel]) {
        self.data = data
    }

    func object(at index: Int) -> DataSourceModel? {
        guard index < data.count else { return nil }
        return data[index]
    }
}

// MARK: - DataSource
final class DataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    let tableView: UITableView
    private var descriptors: [String: CellDescriptor] = [:]
    private var callbacks: [String: (DataSourceModel) -> Void] = [:]
    var onSelectCallback: (DataSourceModel) -> () = { _ in }

    private var sections: [DataSourceSection] = []

    init(tableView: UITableView) {
        self.tableView = tableView

        super.init()

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.sectionFooterHeight = UITableViewAutomaticDimension
    }

    func register(cellDescriptor: CellDescriptor) {
        cellDescriptor.register(in: tableView)
        descriptors[cellDescriptor.modelClassName] = cellDescriptor
    }

    func register(section: DataSourceSection) {
        section.header?.info?.register(in: tableView)
        section.footer?.info?.register(in: tableView)
    }

    @discardableResult
    func add(section: DataSourceSection) -> Int {
        let index = sections.count
        sections.append(section)
        tableView.reloadData()
        return index
    }

    func onSelect<Model: DataSourceModel>(_ callback: @escaping (Model) -> Void) {
        callbacks[Model._Model_Name] = { model in
            callback(model as! Model)
        }
    }

    // MARK: -
    private func section(at index: Int) -> DataSourceSection? {
        guard index < sections.count else { return nil }
        return sections[index]
    }

    private func object(at indexPath: IndexPath) -> DataSourceModel? {
        return section(at: indexPath.section)?.object(at: indexPath.row)
    }

    // MARK: - DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let s = self.section(at: section) else { return 0 }
        return s.objectsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = object(at: indexPath) else {
            fatalError("WAT?")
        }

        guard let descriptor = descriptors[item._Model_Name] else {
            fatalError("Added unsupported class \(item._Model_Name)")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: descriptor.identifier, for: indexPath)
        descriptor.configure(cell, indexPath, item)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.section(at: section)?.header?.title
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.section(at: section)?.footer?.title
    }

    // MARK: - Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let object = object(at: indexPath) else { return }

        onSelectCallback(object)

        guard let callback = callbacks[object._Model_Name] else { return }
        callback(object)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let info = self.section(at: section)?.header?.info else { return nil }

        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: info.identifier)
        if let view  = view as? TitledView {
            view.title = info.title
        }
        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let info = self.section(at: section)?.footer?.info else { return nil }

        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: info.identifier)
        if let view  = view as? TitledView {
            view.title = info.title
        }
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.section(at: section)?.header?.info?.height ?? UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.section(at: section)?.footer?.info?.height ?? UITableViewAutomaticDimension
    }
}
