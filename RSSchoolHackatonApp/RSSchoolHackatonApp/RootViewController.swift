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
    var current:UIViewController? = nil
    var authUI:FUIAuth? = nil
    
    init() {
        super.init(nibName: nil, bundle: nil)
        guard let authUI = FUIAuth.defaultAuthUI() else {
            return
        }
        self.authUI = authUI
        authUI.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
        ]
        authUI.providers = providers
        self.current = authUI.authViewController()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let current = self.current else {
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
      print("User: \(user)")
      print("Error: \(error)")
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
        let mainController = RoomViewController()
        self.addChild(mainController)
        mainController.view.frame = self.view.bounds
        self.view.addSubview(mainController.view)
        mainController.didMove(toParent: self)
        
        guard let current = self.current else {
            print("No initial controller.")
            return
        }
        
        current.willMove(toParent: nil)
        current.view.removeFromSuperview()
        current.removeFromParent()
        
        self.current = mainController
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
