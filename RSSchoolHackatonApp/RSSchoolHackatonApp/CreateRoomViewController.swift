//
//  CreateRoomViewController.swift
//  RSSchoolHackatonApp
//
//  Created by Alex K on 8/1/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class CreateRoomViewController: UIViewController {
    // MARK: -
    static func fromStoryboard() -> CreateRoomViewController {
        let storyboard = UIStoryboard(name: "RoomCreator", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "CreateRoomViewController") as? CreateRoomViewController else {
            fatalError("Unable to instantiate TableViewController!")
        }
        return vc
    }

    private var keyboardShowObserver: NSObjectProtocol!
    private var keyboardHideObserver: NSObjectProtocol!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    var roomTitleTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Text field
        self.roomTitleTextField = UITextFieldWithPadding(padding: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0))
        contentView.addSubview(roomTitleTextField)
        roomTitleTextField.translatesAutoresizingMaskIntoConstraints = false
        roomTitleTextField.layer.cornerRadius = 10.0
        roomTitleTextField.layer.masksToBounds = true
        roomTitleTextField.layer.borderColor = UIColor.systemGray.cgColor
        roomTitleTextField.layer.borderWidth = 2
        roomTitleTextField.placeholder = "Enter room title"
        roomTitleTextField.backgroundColor = .secondarySystemBackground
        NSLayoutConstraint.activate([
            roomTitleTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            roomTitleTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            roomTitleTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -100.0)
        ])

        let idButton = UIButton()
        contentView.addSubview(idButton)
        idButton.setImage(UIImage.init(systemName: "arrow.right.circle"), for: .normal)
        idButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            idButton.leadingAnchor.constraint(equalTo: roomTitleTextField.trailingAnchor, constant: 10.0),
            idButton.centerYAnchor.constraint(equalTo: roomTitleTextField.centerYAnchor, constant: 0.0)
        ])
        idButton.addTarget(self, action: #selector(onIdButtonPress), for: .touchUpInside)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        keyboardShowObserver =
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification,
                                                   object: nil,
                                                   queue: OperationQueue.main) { [weak self] notification in
                                                    guard let keyboardRect = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey]
                                                        as? NSValue else { return }
                                                    let frameKeyboard = keyboardRect.cgRectValue
                                                    self?.scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: frameKeyboard.size.height, right: 0.0)
                                                    self?.view.layoutIfNeeded()
        }

        keyboardHideObserver =
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                                   object: nil,
                                                   queue: OperationQueue.main) { [weak self] _ in
                                                    self?.scrollView.contentInset = .zero
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(keyboardShowObserver as Any)
        NotificationCenter.default.removeObserver(keyboardHideObserver as Any)
    }

    @objc func onIdButtonPress() {
        guard let title = self.roomTitleTextField?.text else {
            return
        }
        let tableViewController = TableViewControllerFactory.make(title: title)
        self.navigationController?.pushViewController(tableViewController, animated: true)
    }

}
