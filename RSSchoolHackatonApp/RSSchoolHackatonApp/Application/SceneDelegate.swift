//
//  SceneDelegate.swift
//  RSSchoolHackatonApp
//
//  Created by Alex K on 8/1/20.
//  Copyright © 2020 Alex K. All rights reserved.
//

import UIKit
import FirebaseUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        setupGlobalTintColor()
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = RootViewController()
        window?.makeKeyAndVisible()
    }

    fileprivate func setupGlobalTintColor() {
        UINavigationBar.appearance().tintColor = .orange
        UIButton.appearance().tintColor = .orange
    }
}
