//
//  DataSourceSection.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/13/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import UIKit

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
