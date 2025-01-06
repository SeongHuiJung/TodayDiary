//
//  SceneDelegate.swift
//  TodayDiary
//
//  Created by 정성희 on 12/11/24.
//

import UIKit
import AuthenticationServices
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        // 초기 루트 뷰 컨트롤러를 로딩 화면으로 설정
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loadingVC = storyboard.instantiateViewController(withIdentifier: "LoadingViewController")
        window.rootViewController = loadingVC
        window.makeKeyAndVisible()
        
        // 로그인 상태를 확인
        checkAppleSignInState()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        CoreDataManager.shared.saveContext()
    }

    func checkAppleSignInState() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        CoreDataManager.shared.fetchIsRegistered()
        
        if let userID = UserDefaults.standard.string(forKey: "AppleUserID") {
            appleIDProvider.getCredentialState(forUserID: userID) { (credentialState, error) in
                DispatchQueue.main.async {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    
                    switch credentialState {
                    case .authorized:
                        print("Apple ID is authorized.")
                        // DiaryMainViewController로 전환
                        
                        guard let isRegistered = CoreDataManager.shared.isRegistered else {
                            // 로그인 화면으로 전환
                            print("계정이 존재하지 않습니다. 로그인 화면으로 전환합니다.")
                            guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
                            self.window?.rootViewController = loginVC
                            return
                        }
                        print("계정이 존재합니다. 자동로그인을 진행합니다")
                        guard let diaryMainVC = storyboard.instantiateViewController(withIdentifier: "DiaryMainViewController") as? DiaryMainViewController else { return }
                        
                        self.window?.rootViewController = UINavigationController(rootViewController: diaryMainVC)


                    case .revoked,.notFound:
                        print("Apple ID not found or revoked.")
                        // 로그인 화면으로 전환
                        guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
                        self.window?.rootViewController = loginVC
                    default:
                        break
                    }
                }
            }
        } else {
            // Apple ID가 저장되지 않았을 경우, 로그인 화면으로 전환
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
                self.window?.rootViewController = loginVC
            }
        }
    }
}
