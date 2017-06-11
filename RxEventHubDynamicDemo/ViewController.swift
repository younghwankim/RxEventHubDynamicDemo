//
//  ViewController.swift
//  RxEventHubDynamicDemo
//
//  Created by 陈圣晗 on 23/05/2017.
//  Copyright © 2017 RxEventHubDynamicDemo. All rights reserved.
//

import UIKit

import RxSwift
import RxEventHub

class ViewController: UITableViewController {

    let disposeBag = DisposeBag()

    var rows: [Row] = []

    let anotherObject: AnotherObject = AnotherObject()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()

        RxEventHub
            .sharedHub
            .eventObservable(EventProviderA())
            .subscribeNext { (value) in
                print("String: \(value)")
            }
            .addDisposableTo(disposeBag)

        RxEventHub
            .sharedHub
            .eventObservable(EventProviderB())
            .subscribeNext { (value) in
                print("Int: \(value)")
            }
            .addDisposableTo(disposeBag)

        RxEventHub
            .sharedHub
            .eventObservable(EventProviderC())
            .subscribeNext { (value) in
                print("CustomData: part1 -> \(value.part1) | part2 -> \(value.part2)")
            }
            .addDisposableTo(disposeBag)

        anotherObject.startObserving()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let row = rows[indexPath.row]

        if row.data is String {
            RxEventHub.sharedHub.notify(EventProviderA(), data: row.data as! String)
        }

        if row.data is Int {
            RxEventHub.sharedHub.notify(EventProviderB(), data: row.data as! Int)
        }

        if row.data is CustomData {
            RxEventHub.sharedHub.notify(EventProviderC(), data: row.data as! CustomData)
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(String(Cell.self), forIndexPath: indexPath) as! Cell
        cell.txtLabel?.text = rows[indexPath.row].txt
        return cell
    }

    private func loadData() {
        rows.append(Row(txt: "1 Int", data: 1111))
        rows.append(Row(txt: "2 String", data: "2222"))
        rows.append(Row(txt: "3 CustomData", data: CustomData(part1: 3333, part2: ":)")))
    }
}

class Cell: UITableViewCell {
    @IBOutlet weak var txtLabel: UILabel?
}

struct Row {
    var txt: String = ""
    var data: Any
}

struct CustomData {
    var part1: Int = 0
    var part2: String = ""
}

class AnotherObject {

    let disposeBag = DisposeBag()

    func startObserving() {
        RxEventHub
            .sharedHub
            .eventObservable(EventProviderA())
            .subscribeNext { (value) in
                print("AnotherObject String: \(value)")
            }
            .addDisposableTo(disposeBag)

        RxEventHub
            .sharedHub
            .eventObservable(EventProviderB())
            .subscribeNext { (value) in
                print("AnotherObject Int: \(value)")
            }
            .addDisposableTo(disposeBag)

        RxEventHub
            .sharedHub
            .eventObservable(EventProviderC())
            .subscribeNext { (value) in
                print("AnotherObject CustomData: part1 -> \(value.part1) | part2 -> \(value.part2)")
            }
            .addDisposableTo(disposeBag)
    }
}

class EventProviderA: RxEventProvider<String> {}
class EventProviderB: RxEventProvider<Int> {}
class EventProviderC: RxEventProvider<CustomData> {}
