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

        dataSource.register(cellDescriptor: CellDescriptor(nibClass: PersonCell.self))
        dataSource.register(cellDescriptor: CellDescriptor(cellClass: CompanyCell.self))
        dataSource.register(cellDescriptor: CellDescriptor(kind: .klass(klass: UITableViewCell.self), { (cell, ip, model: Dummy) in
            cell.textLabel?.text = model.name + " - \(ip)"
        }))

        // section 1
        let section1 = DataSourceSection(data: [
            Person(name: "Sponge bob", address: "Under the see"),
            Person(name: "Patrick", address: "Near Sponge Bob"),
            Company(name: "EA", address: "Shitload")
        ])
        section1.header = .view(DataSourceSection.HeaderFooterViewInfo(identifier: "Header", kind: .klass(klass: SectionHeaderView.self), height: 45.0) { (view: SectionHeaderView, section) in
            view.title = "Wassup?"
        })
        section1.footer = .title("meh 🤖")
        dataSource.register(section: section1)
        dataSource.add(section: section1)

        // secion
        let section2 = DataSourceSection(data: [
            Dummy(name: "So simple")
        ])
        section2.header = .view(DataSourceSection.HeaderFooterViewInfo(identifier: "NibHeader", kind: .nib(name: "NibHeaderView"), height: 24.0, { (view: NibHeaderView, section) in
            view.label.text = "Lorem Ipsum"
        }))
        dataSource.register(section: section2)
        dataSource.add(section: section2)

        // selection
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

