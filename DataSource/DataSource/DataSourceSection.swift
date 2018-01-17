//
//  DataSourceSection.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/13/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import UIKit

protocol DataSourceSectionDelegate: class {
    /**
     Request section's index from DataSource

     - parameter section:    Section itself

     - returns: Section's Index
     */
    func indexOfDataSourceSection(_ section: DataSourceSection) -> Int?

    /**
     Notifies delegate after data object insertion

     - parameter section:        Section Itself
     - parameter indexPath:    IndexPath of inserted object
     */
    func dataSourceSection(_ section: DataSourceSection, didAddObjectAtIndexPaths indexPaths: [IndexPath])

    /**
     Notifies delegate after data object deletion

     - parameter section:        Section Itself
     - parameter indexPath:    IndexPath of deleted object
     */
    func dataSourceSection(_ section: DataSourceSection, didDeleteObjectAtIndexPaths indexPaths: [IndexPath])
}

/// Class which represents Section in DataSource
final class DataSourceSection {
    enum HeaderViewKind {
        case title(String)
        case view(HeaderFooterViewInfo)
        case none

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
        let kind: DataSourceRegisteredViewKind
        let height: CGFloat
        let configure: (UITableViewHeaderFooterView, DataSourceSection) -> Void

        init<View: UITableViewHeaderFooterView>(identifier: String, kind: DataSourceRegisteredViewKind, height: CGFloat, _ configure: @escaping (View, DataSourceSection) -> Void) {
            self.identifier = identifier
            self.kind = kind
            self.height = height
            self.configure = { view, section in
                configure(view as! View, section)
            }
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

    private var operationsQueue = DispatchQueue(label: "me.antonyuk.dataSource.section.operations", attributes: [])

    var header: HeaderViewKind?
    var footer: HeaderViewKind?

    private var objects: [DataSourceModel] = []
    var objectsCount: Int {
        return objects.count
    }

    weak var delegate: DataSource?

    private func indexPathWithRow(_ row: Int) -> IndexPath {
        return IndexPath(row: row, section: delegate?.indexOfDataSourceSection(self) ?? 0)
    }

    /// Init section with initial dataset
    ///
    /// - Parameter data: Initial data
    init(data: [DataSourceModel]) {
        self.objects = data
    }

    func object(at index: Int) -> DataSourceModel? {
        guard index < objects.count else { return nil }
        return objects[index]
    }

    /**
     Add Data Object to the section

     - parameter object:    Data Object

     - returns: IndexPath of added object
     */
    @discardableResult func addObject(_ object: DataSourceModel) -> IndexPath {
        var indexPath: IndexPath?
        operationsQueue.sync(flags: .barrier, execute: { [unowned self] in
            let row = self.objectsCount
            self.objects.append(object)
            indexPath = self.indexPathWithRow(row)
            self.delegate?.dataSourceSection(self, didAddObjectAtIndexPaths: [indexPath!])
        })
        return indexPath!
    }

    /**
     Add Data Objects Array to the section

     - parameter objects:    Data Objects Array

     - returns: IndexPath array of added objects
     */
    @discardableResult func addObjects(_ objects: [DataSourceModel]) -> [IndexPath] {
        return objects.map({ (object) in
            return addObject(object)
        })
    }

    /**
     Insert Data Object to the section

     - parameter object:    Data Object
     - parameter index:    Target Index

     - returns: IndexPath of inserted Object, nil if index is out of bounds
     */
    @discardableResult func insertObject(_ object: DataSourceModel, atIndex index: Int) -> IndexPath? {
        guard index <= objects.count else { return nil }

        var indexPath: IndexPath? = nil
        operationsQueue.sync(flags: .barrier, execute: { [unowned self] in
            self.objects.insert(object, at: index)
            indexPath = self.indexPathWithRow(index)
            self.delegate?.dataSourceSection(self, didAddObjectAtIndexPaths: [indexPath!])
        })
        return indexPath
    }

    /**
     Delete Data Object from the section by index

     - parameter index:    Object's Index

     - returns: IndexPath of deleted object
     */
    @discardableResult func deleteObjectAtIndex(_ index: Int) -> IndexPath? {
        guard index < objects.count else { return nil }

        var indexPath: IndexPath? = nil
        self.operationsQueue.sync(flags: .barrier, execute: { [unowned self] in
            self.objects.remove(at: index)
            indexPath = self.indexPathWithRow(index)
            self.delegate?.dataSourceSection(self, didDeleteObjectAtIndexPaths: [indexPath!])
        })
        return indexPath
    }

    /**
     Delete Data Object from the section

     - parameter object:    Data Object

     - returns: IndexPath of deleted object
     */
    @discardableResult func deleteObject<Model: DataSourceModel>(where eq: (Model) -> Bool) -> IndexPath? {
        guard let index = objects.index(where: { obj in
            guard let model = obj as? Model else { return false }
            return eq(model)
        }) else { return nil }

        var indexPath: IndexPath?
        operationsQueue.sync(flags: .barrier, execute: { [unowned self] in
            self.objects.remove(at: index)
            indexPath = self.indexPathWithRow(index)
            self.delegate?.dataSourceSection(self, didDeleteObjectAtIndexPaths: [indexPath!])
        })
        return indexPath
    }

    /**
     Delete All Data
     */
    func deleteAllObjects() {
        guard let index = delegate?.indexOfDataSourceSection(self) else { return }
        let count = objectsCount
        let indexes = (0..<count).map { IndexPath(row: $0, section: index) }
        objects.removeAll()
        delegate?.dataSourceSection(self, didDeleteObjectAtIndexPaths: indexes)
    }
}
