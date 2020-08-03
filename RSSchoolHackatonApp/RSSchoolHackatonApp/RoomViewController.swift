//
//  RoomViewController.swift
//  RSSchoolHackatonApp
//
//  Created by Alex K on 8/1/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RoomViewController: UIViewController, UITextFieldDelegate {

    // MARK: -
    static func fromStoryboard() -> RoomViewController {
        let storyboard = UIStoryboard(name: "Room", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "RoomViewController") as? RoomViewController else {
            fatalError("Unable to instantiate TableViewController!")
        }
        return vc
    }

    // MARK: -
    var roomIdTextField: UITextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    // Keyboard support observers.
    private var keyboardShowObserver: NSObjectProtocol!
    private var keyboardHideObserver: NSObjectProtocol!

    // MARK: -
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        // MARK: - Text field
        self.roomIdTextField =  UITextFieldWithPadding(padding: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0))
        contentView.addSubview(roomIdTextField)
        roomIdTextField.translatesAutoresizingMaskIntoConstraints = false
        roomIdTextField.layer.cornerRadius = 10.0
        roomIdTextField.layer.masksToBounds = true
//        roomIdTextField.layer.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1).cgColor
        roomIdTextField.placeholder = "Enter room id"
        NSLayoutConstraint.activate([
            roomIdTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            roomIdTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            roomIdTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -100.0)
        ])
        roomIdTextField.delegate = self
        let idButton = UIButton()
        contentView.addSubview(idButton)
        idButton.setImage(UIImage.init(systemName: "arrow.right.circle"), for: .normal)
        idButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            idButton.leadingAnchor.constraint(equalTo: roomIdTextField.trailingAnchor, constant: 10.0),
            idButton.centerYAnchor.constraint(equalTo: roomIdTextField.centerYAnchor, constant: 0.0)
        ])
        idButton.addTarget(self, action: #selector(onIdButtonPress), for: .touchUpInside)

        // MARK: - Create room button
        let newRoomButton = UIButton()
        contentView.addSubview(newRoomButton)
        newRoomButton.setTitle("Create room", for: .normal)
        newRoomButton.translatesAutoresizingMaskIntoConstraints = false
        newRoomButton.setTitleColor(.systemBlue, for: .normal)
        NSLayoutConstraint.activate([
            newRoomButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0),
            newRoomButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0.0)
        ])
        newRoomButton.addTarget(self, action: #selector(onNewRoomButtonPress), for: .touchUpInside)

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
                                                    self?.scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: frameKeyboard.size.height + 20, right: 0.0)
                                                    self?.view.layoutIfNeeded()
        }
        keyboardHideObserver =
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                                   object: nil,
                                                   queue: OperationQueue.main) { [weak self] notification in
                                                    self?.scrollView.contentInset = .zero
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(keyboardShowObserver as Any)
        NotificationCenter.default.removeObserver(keyboardHideObserver as Any)
    }

    // MARK: -
    @objc func onIdButtonPress() {
        guard let roomIdTextField = self.roomIdTextField else {
            return
        }
        guard let roomId = roomIdTextField.text else {
            return
        }
        if roomId.isEmpty { return }
        let tableViewController = TableViewControllerFactory.make(roomId: roomId)
        let valid = Storage.validatePath(roomId)
        guard valid else { return }
        navigationController?.pushViewController(tableViewController, animated: true)
    }

    @objc func onNewRoomButtonPress() {
        navigationController?.pushViewController(CreateRoomViewController.fromStoryboard(), animated: true)
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        true
    }
}
