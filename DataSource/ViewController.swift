//
//  ViewController.swift
//  DataSource
//
//  Created by Alex Antonyuk on 12/1/17.
//  Copyright © 2017 Alex Antonyuk. All rights reserved.
//

import UIKit

protocol NamedModel {
    var name: String { get }
}

extension Person: NamedModel {}

final class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private var dataSource: TableDataSource!
    private var testObject: Person?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setupDataSource()
        addData()
        operations()
    }

    private func setupDataSource() {
        dataSource = TableDataSource(tableView: tableView)
        dataSource.animation = .right

        dataSource.register(cellDescriptor: TableCellDescriptor(nibClass: PersonCell.self))
        dataSource.register(cellDescriptor: TableCellDescriptor(cellClass: CompanyCell.self))
        dataSource.register(cellDescriptor: TableCellDescriptor(kind: .klass(klass: UITableViewCell.self), { (cell, ip, model: Dummy) in
            cell.textLabel?.text = model.name + " - \(ip)"
        }))

        dataSource.onSelect { (model: Person) in
            print("👱🏻 Person selected \(model.name)")
        }
        dataSource.onSelect { (model: Company) in
            print("🏚 Company selected \(model.name)")
        }
        dataSource.onSelectCallback = { model in
            print("🌎 Generic model Selected \(model)")
            if let person = model as? Person {
                print("🌎👱🏻  Global select \(person)")
            } else if let company = model as? Company {
                print("🌎🏚 Global select \(company)")
            }
        }
    }

    private func addData() {
        //  custom view class header section
        let sponge = Person(name: "Sponge bob", address: "Under the sea")
        let section1 = TableDataSourceSection(data: [
            sponge,
            Person(name: "Patrick", address: "Near Sponge Bob"),
            Company(name: "EA", address: "Shitload")
            ])
        section1.header = .view(TableDataSourceSection.HeaderFooterViewInfo(identifier: "Header", kind: .klass(klass: SectionHeaderView.self), height: 45.0) { (view: SectionHeaderView, section) in
            view.title = "Wassup?"
        })
        section1.footer = .title("meh 🤖")
        dataSource.register(section: section1) // additional setup of sections
        dataSource.add(section: section1)

        // custom view nib header section
        let section2 = TableDataSourceSection(data: [
            Dummy(name: "So simple")
            ])
        section2.header = .view(TableDataSourceSection.HeaderFooterViewInfo(identifier: "NibHeader", kind: .nib(name: "NibHeaderView"), height: 24.0, { (view: NibHeaderView, section) in
            view.label.text = "Lorem Ipsum"
        }))
        dataSource.register(section: section2)
        dataSource.add(section: section2)

        // simple section
        let section3 = TableDataSourceSection(data: [
            Dummy(name: "Lol kek"),
            Dummy(name: "Cheburek"),
            Dummy(name: "👾")
        ])
        section3.header = .none
        dataSource.add(section: section3)

        testObject = sponge
    }

    private func operations() {
        guard let testObject = testObject else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            self.dataSource.section(at: 0)?.deleteObject(where: { (obj: Person) in
//                obj.name == testObject.name
//            })
            //            self.delete(sponge)
            self.dataSource.section(at: 0)?.delete(object: testObject)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.dataSource.addObjectToTheLastSection(testObject)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            self.dataSource.deleteObject(atIndexPath: IndexPath(row: 0, section: 0))
        }
    }

//    func delete<Model: DataSourceModel & NamedModel>(_ model: Model) {
//        dataSource.section(at: 0)?.deleteObject(where: { (obj: Model) -> Bool in
//            return obj.name == model.name
//        })
//    }
}

