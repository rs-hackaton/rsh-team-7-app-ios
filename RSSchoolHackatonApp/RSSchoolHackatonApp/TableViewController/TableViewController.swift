//
//  TableViewController.swift
//  RSSchoolHackatonApp
//
//  Created by Arseniy Strakh on 01.08.2020.
//  Copyright © 2020 Alex K. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    var topics: [Topic] = []
    var room: Room?

    static func fromStoryboard(room: Room) -> TableViewController {
        let storyboard = UIStoryboard(name: "Table", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "TableViewController") as? TableViewController else {
            fatalError("Unable to instantiate TableViewController!")
        }
        vc.room = room
        return vc
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
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
            let topic = Topic(title: newName)
            self.topics.insert(topic, at: 0)
            // send to presenter
            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        }))
        present(addAlert, animated: true, completion: nil)
    }

    @IBAction func actionButtonDidTap(_ sender: Any) {

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
            topics.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            //      let topic = Topic(name: "")
            //      topics.insert(topic, at: indexPath.row)
            //      tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        topics[indexPath.row].active.toggle()
        cell.accessoryType = topics[indexPath.row].active ? .checkmark : .none
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        topics.swapAt(fromIndexPath.row, to.row)
    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }

}
