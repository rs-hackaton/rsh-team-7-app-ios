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

  static func fromStoryboard() -> TableViewController {
    let storyboard = UIStoryboard(name: "Table", bundle: nil)
    guard let vc = storyboard.instantiateInitialViewController() as? TableViewController else {
      fatalError("Unable to instantiate TableViewController!")
    }
    return vc
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonDidTap))
    navigationItem.rightBarButtonItems = [self.editButtonItem, addButton]
  }
  
  // MARK: - Table view data source
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    topics.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    cell.textLabel?.text = topics[indexPath.row].name
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
      let topic = Topic(name: "", date: Date())
      topics.insert(topic, at: indexPath.row)
      tableView.insertRows(at: [indexPath], with: .automatic)
    }
  }

  // Override to support rearranging the table view.
  override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
    topics.swapAt(fromIndexPath.row, to.row)
  }

  override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the item to be re-orderable.
    return true
  }

  @objc func addButtonDidTap() {

  }

  // MARK: - Navigation

  //   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
  //   // Get the new view controller using segue.destination.
  //   // Pass the selected object to the new view controller.
  //   }

  
}
