//
//  RoomViewController.swift
//  RSSchoolHackatonApp
//
//  Created by Alex K on 8/1/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

import UIKit
import FirebaseAuth

class RoomViewController: UIViewController {
    
    var roomIdTextField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // MARK: - Scroll view
        
        self.view.backgroundColor = UIColor.white
        
        let scrollView = UIScrollView()
        self.view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.widthAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.widthAnchor),
            scrollView.heightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.heightAnchor),

        ])
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor),

        ])
        
        // MARK: - Text field
        let roomIdTextField = UITextFieldWithPadding(padding: UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0))
        self.roomIdTextField = roomIdTextField
        contentView.addSubview(roomIdTextField)
        roomIdTextField.translatesAutoresizingMaskIntoConstraints = false
        roomIdTextField.layer.cornerRadius = 10.0
        roomIdTextField.layer.masksToBounds = true
        roomIdTextField.layer.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1).cgColor
        roomIdTextField.placeholder = "Enter room id"
        NSLayoutConstraint.activate([
            roomIdTextField.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            roomIdTextField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            roomIdTextField.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -100.0),
        ])
        
        let idButton = UIButton()
        contentView.addSubview(idButton)
        idButton.setImage(UIImage.init(systemName: "arrow.right.circle"), for:.normal)
        idButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            idButton.leadingAnchor.constraint(equalTo: roomIdTextField.trailingAnchor, constant:10.0),
            idButton.centerYAnchor.constraint(equalTo: roomIdTextField.centerYAnchor, constant:0.0),
        ])
        idButton.addTarget(self, action: #selector(onIdButtonPress), for: .touchUpInside)
        
        // MARK: - Create room button
        let newRoomButton = UIButton()
        contentView.addSubview(newRoomButton)
        newRoomButton.setTitle("Create room", for:.normal)
        newRoomButton.translatesAutoresizingMaskIntoConstraints = false
        newRoomButton.setTitleColor(.systemBlue, for: .normal)
        NSLayoutConstraint.activate([
            newRoomButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant:-10.0),
            newRoomButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant:0.0),
        ])
        newRoomButton.addTarget(self, action: #selector(onNewRoomButtonPress), for: .touchUpInside)
    }
    
    @objc func onIdButtonPress() {
        guard let roomIdTextField = self.roomIdTextField else {
            return
        }
        guard let roomId = roomIdTextField.text else {
            return
        }
        //empty string crashes
        if roomId.isEmpty { return }

        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        Storage.getInstance().ref?.child("rooms").child(roomId).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let id = value?["id"] as? String ?? ""
            let title = value?["title"] as? String ?? ""
            let room = Room(id: id, title: title, userId: userId, time: Date())
            let tableViewController = TableViewControllerFactory.make(room: room)
            self.navigationController?.pushViewController(tableViewController, animated: true)
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    @objc func onNewRoomButtonPress() {
        self.navigationController?.pushViewController(CreateRoomViewController(), animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
