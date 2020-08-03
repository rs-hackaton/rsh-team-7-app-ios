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
    func update(topic: Topic)
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
    var unsubscribers: [() -> Void] = []
    lazy var activityIndicator: UIActivityIndicatorView =  {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .darkGray
        return indicator
    }()

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager?.fetch()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribers.forEach { unsubscriber in unsubscriber() }
    }

    // MARK: - IBAction

    @IBAction func infoButtonDidTap(_ sender: Any) {
        guard let room = room else { return }
        let message = "Room id: \(room.id)"
        let infoAlert = UIAlertController(title: "Room info", message: message, preferredStyle: .alert)
        infoAlert.addAction(UIAlertAction(title: "Copy to clipboard", style: .default, handler: { _ in
            UIPasteboard.general.string = room.id
        }))
        infoAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(infoAlert, animated: true, completion: nil)

    }
    @IBAction func addButtonDidTap(_ sender: UIBarButtonItem) {
        let addAlert = UIAlertController(title: "Add topic", message: nil, preferredStyle: .alert)
        addAlert.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        addAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak addAlert] _ in
            guard let `self` = self else { return }
            guard let newName = addAlert?.textFields?[0].text else { return }
            guard !newName.isEmpty else { return }
            self.manager?.addNewTopic(with: newName)
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
        }
    }

    // MARK: - CollectionViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        topics[indexPath.row].active.toggle()
        manager?.update(topic: topics[indexPath.row])
    }

    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        topics.swapAt(fromIndexPath.row, to.row)
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // MARK: - TopicsViewType
    
    func update(topic: Topic) {
        let filtered = topics.enumerated().filter( {(index, t) -> Bool in
            t.time == topic.time
        }).map({ IndexPath(row: $0.offset, section: 0) })
        for indexPath in filtered {
            topics[indexPath.row] = topic
        }
        tableView.reloadRows(at: filtered, with: .automatic)
    }

    func update(with room: Room) {
        self.room = room
        title = room.title
    }

    func reload(topics: [Topic]) {
        self.topics = topics
        tableView.reloadData()
    }

    func insert(topic: Topic, at indexpath: IndexPath) {
        topics.insert(topic, at: indexpath.row)
        tableView.insertRows(at: [indexpath], with: .automatic)
    }

    func delete(topic: Topic) {
        topics.removeAll {
            $0.time == topic.time
        }
        tableView.reloadData()
    }

    func showLoading() {
        setupActivityIndicator()
    }

    func hideLoading() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
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

    // MARK: -

    fileprivate func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.centerYAnchor),
        ])
        activityIndicator.startAnimating()
    }

}

