//
//  SceneDelegate.swift
//  PlayerTask
//
//  Created by Jackie basss on 06.08.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        
        window?.windowScene = windowScene
        
        let mediaPlayerView = PlayerViewController(nibName: "PlayerView", bundle: nil)
        mediaPlayerView.mediaPresenter = MediaPresenter()
        
        window?.rootViewController = mediaPlayerView
        
        window?.makeKeyAndVisible()
    }

}

