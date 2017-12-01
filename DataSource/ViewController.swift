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


        let personDescr = CellDescriptor(kind: .nib(name: "TestCell"), cellClass: TestCell.self)
        dataSource.register(cellDescriptor: personDescr)

        let companyDescr = CellDescriptor(kind: .klass(klass: ClassCell.self), cellClass: ClassCell.self)
        dataSource.register(cellDescriptor: companyDescr)
        dataSource.addData([
            Person(name: "Sponge bob", address: "Under the see"),
            Company(name: "EA", address: "Shitload")
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

