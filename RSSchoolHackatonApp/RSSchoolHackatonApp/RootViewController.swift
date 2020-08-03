//
//  RootViewController.swift
//  VkRemoverIOS
//
//  Created by Alex K on 7/3/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

import UIKit
import FirebaseUI

class RootViewController: UIViewController, FUIAuthDelegate {
    var current: UIViewController?
    var authUI: FUIAuth?

    init() {
        super.init(nibName: nil, bundle: nil)
        guard let authUI = FUIAuth.defaultAuthUI() else {
            return
        }
        self.authUI = authUI
        authUI.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth()
        ]
        authUI.providers = providers
        self.current = authUI.authViewController()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard self.current != nil else {
            print("No initial controller.")
            return
        }

        guard let user = Auth.auth().currentUser else {
            showAuthViewController()
            return
        }
        print("Current user: \(user)")

        showRoomViewController()
    }

    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        print("User: \(String(describing: user))")
        print("Error: \(String(describing: error))")
      showRoomViewController()
    }

    func showAuthViewController() {
        guard let authUI = self.authUI else {
            return
        }
        let startViewController = authUI.authViewController()
        self.addChild(startViewController)
        startViewController.view.frame = self.view.bounds
        self.view.addSubview(startViewController.view)
        startViewController.didMove(toParent: self)

        guard let current = self.current else {
            print("No initial controller.")
            return
        }

        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()

        self.current = startViewController
    }

    func showRoomViewController() {
        let mainController = RoomViewController.fromStoryboard()
        let mainControllerWithNavigation = UINavigationController(rootViewController: mainController)

        self.addChild(mainControllerWithNavigation)
        mainControllerWithNavigation.view.frame = self.view.bounds
        self.view.addSubview(mainControllerWithNavigation.view)
        mainControllerWithNavigation.didMove(toParent: self)

        guard let current = self.current else {
            print("No initial controller.")
            return
        }

        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()

        self.current = mainControllerWithNavigation
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
