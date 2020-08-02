//
//  TableViewController.swift
//  RSSchoolHackatonApp
//
//  Created by Arseniy Strakh on 01.08.2020.
//  Copyright © 2020 Alex K. All rights reserved.
//

import UIKit

protocol TopicsViewType: NSObjectProtocol {
    func showLoading()
    func hideLoading()
    func update(with room: Room)
    func reload(topics: [Topic])
    func insert(topic: Topic, at indexpath: IndexPath)
    func delete(topic: Topic)
    func showAlert(with message: String, completion: @escaping (() -> Void))
    func popNavigation()
}

class TableViewController: UITableViewController, TopicsViewType {

    var topics: [Topic] = []
    var room: Room?
    var manager: RoomManagerType?

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager?.fetch()
    }

    // MARK: - IBAction

    @IBAction func addButtonDidTap(_ sender: UIBarButtonItem) {
        let addAlert = UIAlertController(title: "Add topic", message: nil, preferredStyle: .alert)
        addAlert.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        addAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak addAlert] _ in
            guard let `self` = self else { return }
            guard let newName = addAlert?.textFields?[0].text else { return }
            guard !newName.isEmpty else { return }
            let topic = Topic(title: newName)
            self.topics.insert(topic, at: 0)
            self.manager?.add(topic: topic)
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        }))
        present(addAlert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        topics.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = topics[indexPath.row].title
        cell.accessoryType = topics[indexPath.row].active ? .checkmark : .none
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let topic = topics[indexPath.row]
            manager?.remove(topic: topic)
            topics.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - CollectionViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        topics[indexPath.row].active.toggle()
        manager?.update(topic: topics[indexPath.row])
        cell.accessoryType = topics[indexPath.row].active ? .checkmark : .none
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        topics.swapAt(fromIndexPath.row, to.row)
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // MARK: - TopicsViewType

    func update(with room: Room) {
        self.title = room.title
    }

    func reload(topics: [Topic]) {
        self.topics = topics
        tableView.reloadData()
    }

    func insert(topic: Topic, at indexpath: IndexPath) {
        self.topics.insert(topic, at: indexpath.row)
        self.tableView.reloadData()
    }

    func delete(topic: Topic) {
        self.topics.removeAll {
            $0.time == topic.time
        }
        self.tableView.reloadData()
    }

    func showLoading() {

    }

    func hideLoading() {

    }

    func showAlert(with message: String, completion: @escaping () -> Void) {
        let messageAlert = UIAlertController(title: "Something goes wrong", message: message, preferredStyle: .alert)
        messageAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion()
        }))
        present(messageAlert, animated: true, completion: nil)
    }

    func popNavigation() {
        navigationController?.popViewController(animated: true)
    }

}
