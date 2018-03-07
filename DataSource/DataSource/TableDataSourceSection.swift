//
//  TableDataSourceSection.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/13/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import UIKit

protocol TableDataSourceSectionDelegate: class {
    /**
     Request section's index from DataSource

     - parameter section:    Section itself

     - returns: Section's Index
     */
    func indexOfDataSourceSection(_ section: TableDataSourceSection) -> Int?

    /**
     Notifies delegate after data object insertion

     - parameter section:        Section Itself
     - parameter indexPath:    IndexPath of inserted object
     */
    func dataSourceSection(_ section: TableDataSourceSection, didAddObjectAtIndexPaths indexPaths: [IndexPath])

    /**
     Notifies delegate after data object deletion

     - parameter section:        Section Itself
     - parameter indexPath:    IndexPath of deleted object
     */
    func dataSourceSection(_ section: TableDataSourceSection, didDeleteObjectAtIndexPaths indexPaths: [IndexPath])
}

/// Class which represents Section in DataSource
final class TableDataSourceSection {
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
        let kind: TableDataSourceRegisteredViewKind
        let height: CGFloat
        let configure: (UITableViewHeaderFooterView, TableDataSourceSection) -> Void

        init<View: UITableViewHeaderFooterView>(identifier: String, kind: TableDataSourceRegisteredViewKind, height: CGFloat, _ configure: @escaping (View, TableDataSourceSection) -> Void) {
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

    private var objects: [TableDataSourceModel] = []
    var objectsCount: Int {
        return objects.count
    }

    weak var delegate: TableDataSource?

    private func indexPathWithRow(_ row: Int) -> IndexPath {
        return IndexPath(row: row, section: delegate?.indexOfDataSourceSection(self) ?? 0)
    }

    /// Init section with initial dataset
    ///
    /// - Parameter data: Initial data
    init(data: [TableDataSourceModel]) {
        self.objects = data
    }

    func object(at index: Int) -> TableDataSourceModel? {
        guard index < objects.count else { return nil }
        return objects[index]
    }

    /**
     Add Data Object to the section

     - parameter object:    Data Object

     - returns: IndexPath of added object
     */
    @discardableResult func addObject(_ object: TableDataSourceModel) -> IndexPath {
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
    @discardableResult func addObjects(_ objects: [TableDataSourceModel]) -> [IndexPath] {
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
    @discardableResult func insertObject(_ object: TableDataSourceModel, atIndex index: Int) -> IndexPath? {
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
     Delete Data Object from the Section

     - parameter object:    Data Object

     - returns: IndexPath of deleted object
     */
    @discardableResult func deleteObject<Model: TableDataSourceModel>(where eq: (Model) -> Bool) -> IndexPath? {
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
    
    /// Delete DAta Object from the Section
    ///
    /// - Parameter object: Data Object
    /// - Returns: IndexPath of deleted object
    @discardableResult func delete<Model: TableDataSourceModel>(object: Model) -> IndexPath? where Model: Equatable {
        return deleteObject { model -> Bool in
            model == object
        }
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
