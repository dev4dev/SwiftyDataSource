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


        let personDescr = CellDescriptor(nibClass: ManualCell.self)
        dataSource.register(cellDescriptor: personDescr)

        let companyDescr = CellDescriptor(cellClass: ClassCell.self)
        dataSource.register(cellDescriptor: companyDescr)

        dataSource.register(cellDescriptor: CellDescriptor(kind: .klass(klass: UITableViewCell.self), { (cell, model: Dummy) in
            cell.textLabel?.text = model.name
        }))

        dataSource.addData([
            Person(name: "Sponge bob", address: "Under the see"),
            Person(name: "Patrick", address: "Near Sponge Bob"),
            Company(name: "EA", address: "Shitload"),
            Dummy(name: "So simple")
        ])

        test(model: Person(name: "ok", address: "OK"))
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

    func test<Model>(model: Model) {
        print(String(describing: type(of: Model.self)))
        print(String(describing: type(of: model)))
    }


}

