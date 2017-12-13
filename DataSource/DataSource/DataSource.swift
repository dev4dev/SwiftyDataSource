//
//  DataSource.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/1/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import UIKit



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
