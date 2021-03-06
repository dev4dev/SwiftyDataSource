//
//  TableDataSource.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/1/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import UIKit



// MARK: - DataSource
final class TableDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {

    /// Table View instance
    let tableView: UITableView


    /// Cell descriptiors associated with the model they is working with
    private var descriptors: [String: TableCellDescriptor] = [:]

    /// Selection callbacks associated with the model they will for for
    private var callbacks: [String: (TableDataSourceModel) -> Void] = [:]

    /// General selection callback which will be called for every row
    var onSelectCallback: (TableDataSourceModel) -> () = { _ in }

    /// Internal store of sections
    private var sections: [TableDataSourceSection] = []

    /// TableView's animation Style
    var animation: UITableViewRowAnimation? = nil

    /// Initializer accepts table view which will be server by this data source
    ///
    /// - Parameter tableView: TableView
    init(tableView: UITableView) {
        self.tableView = tableView

        super.init()

        self.tableView.dataSource = self
        self.tableView.delegate = self

        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.sectionFooterHeight = UITableViewAutomaticDimension
    }

    /// Register Cell Descriptor
    ///
    /// - Parameter cellDescriptor: Cell Descriptor
    func register(cellDescriptor: TableCellDescriptor) {
        cellDescriptor.register(in: tableView)
        descriptors[cellDescriptor.modelClassName] = cellDescriptor
    }


    /// Register section. Used when section has header/footer instantiated from class/nib
    ///
    /// - Parameter section: Section object
    func register(section: TableDataSourceSection) {
        section.header?.info?.register(in: tableView)
        section.footer?.info?.register(in: tableView)
    }

    /// Add section to the data source
    ///
    /// - Parameter section: Section
    /// - Returns: Index were section was added at
    @discardableResult
    func add(section: TableDataSourceSection) -> Int {
        let index = sections.count
        sections.append(section)
        section.delegate = self
        tableView.reloadData()
        return index
    }

    /// Add Object to the end of the section at index
    ///
    /// - Parameters:
    ///   - object: Object
    ///   - section: Section Index
    func addObject(_ object: TableDataSourceModel, toSection section: Int) {
        if let s = self.section(at: section) {
            s.addObject(object)
        } else {
            fatalError("[DataSource] Adding data: \(object) to non existing section")
        }
    }


    /// Add Object to the end of the last section
    ///
    /// - Parameter object: Object
    func addObjectToTheLastSection(_ object: TableDataSourceModel) {
        let sectionsCount = sections.count
        guard sectionsCount > 0 else { return }

        let lastSectionIndex = sectionsCount - 1
        addObject(object, toSection: lastSectionIndex)
    }

    /// Add Objects array to the end of the section at index
    ///
    /// - Parameters:
    ///   - objects: Objects array
    ///   - section: Secrion Index
    func addObjects(_ objects: [TableDataSourceModel], toSection section: Int) {
        if let s = self.section(at: section) {
            s.addObjects(objects)
        } else {
            fatalError("[DataSource] Adding data: \(objects) to non existing section")
        }
    }

    /// Insert Object at IndexPath
    ///
    /// - Parameters:
    ///   - object: Object
    ///   - indexPath: IndexPath
    func insertObject(_ object: TableDataSourceModel, atIndexPath indexPath: IndexPath) {
        if let s = self.section(at: indexPath.section) {
            s.insertObject(object, atIndex: (indexPath as NSIndexPath).row)
        }
    }

    /// Delete Data Object at IndexPath
    ///
    /// - Parameter indexPath: IndexPath
    func deleteObject(atIndexPath indexPath: IndexPath) {
        if let s = section(at: indexPath.section) {
            s.deleteObjectAtIndex(indexPath.row)
        }
    }

    // MARK: - Selection

    /// Registers model specific row selection callback
    ///
    /// - Parameter callback: Callback which accepts model object
    func onSelect<Model: TableDataSourceModel>(_ callback: @escaping (Model) -> Void) {
        callbacks[Model._Model_Name] = { model in
            callback(model as! Model)
        }
    }

    // MARK: -

    /// Returns section at index if exists
    ///
    /// - Parameter index: Index of section
    /// - Returns: Data source section or nil if index if out of bounds
    func section(at index: Int) -> TableDataSourceSection? {
        guard index < sections.count else { return nil }
        return sections[index]
    }

    /// Returns object at index pathif exists
    ///
    /// - Parameter indexPath: Index path of object
    /// - Returns: Generic DataSourceModel object or nil if not found
    func object(at indexPath: IndexPath) -> TableDataSourceModel? {
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
        guard let s = self.section(at: section), let info = s.header?.info else { return nil }

        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: info.identifier) else {
            fatalError("Header view with \(info.identifier) was not registered here")
        }
        info.configure(view, s)
        return view
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let s = self.section(at: section), let info = s.footer?.info else { return nil }

        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: info.identifier) else {
            fatalError("Footer view with \(info.identifier) was not registered here")
        }
        info.configure(view, s)
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.section(at: section)?.header?.info?.height ?? UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.section(at: section)?.footer?.info?.height ?? UITableViewAutomaticDimension
    }
}

extension TableDataSource: TableDataSourceSectionDelegate {
    func dataSourceSection(_ section: TableDataSourceSection, didAddObjectAtIndexPaths indexPaths: [IndexPath]) {
        if let animation = animation {
            tableView.performBatchUpdates({
                self.tableView.insertRows(at: indexPaths, with: animation)
            }, completion: nil)
        } else {
            tableView.reloadData()
        }
    }

    func dataSourceSection(_ section: TableDataSourceSection, didDeleteObjectAtIndexPaths indexPaths: [IndexPath]) {
        if let animation = animation {
            tableView.performBatchUpdates({
                self.tableView.deleteRows(at: indexPaths, with: animation)
            }, completion: nil)
        } else {
            tableView.reloadData()
        }
    }

    func indexOfDataSourceSection(_ section: TableDataSourceSection) -> Int? {
        return sections.index(where: {
            $0 === section
        })
    }
}
