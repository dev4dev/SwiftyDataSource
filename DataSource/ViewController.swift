//
//  ViewController.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/1/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var dataSource: DataSource!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        dataSource = DataSource(tableView: tableView)

        let personDescr = CellDescriptor(nibClass: PersonCell.self)
        dataSource.register(cellDescriptor: personDescr)

        let companyDescr = CellDescriptor(cellClass: CompanyCell.self)
        dataSource.register(cellDescriptor: companyDescr)

        dataSource.register(cellDescriptor: CellDescriptor(kind: .klass(klass: UITableViewCell.self), { (cell, model: Dummy) in
            cell.textLabel?.text = model.name
        }))

        let section1 = DataSourceSection(data: [
            Person(name: "Sponge bob", address: "Under the see"),
            Person(name: "Patrick", address: "Near Sponge Bob"),
            Company(name: "EA", address: "Shitload")
        ])
        section1.header = .view(DataSourceSection.HeaderFooterViewInfo(identifier: "Header", title: "WAT?", kind: .klass(klass: SectionHeaderView.self), height: 45.0))
        section1.footer = .title("meh 🤖")
        dataSource.register(section: section1)
        dataSource.add(section: section1)

        let section2 = DataSourceSection(data: [
            Dummy(name: "So simple")
        ])
        section2.header = .title("lol kek")
        dataSource.register(section: section2)
        dataSource.add(section: section2)

        dataSource.onSelect { (model: Person) in
            print("Person selected \(model.name)")
        }
        dataSource.onSelect { (model: Company) in
            print("Company selected \(model.name)")
        }
        dataSource.onSelectCallback = { model in
            print("Generic model Selected \(model)")
            if let person = model as? Person {
                print("Global select \(person)")
            } else if let company = model as? Company {
                print("Global select \(company)")
            }
        }
    }
}

