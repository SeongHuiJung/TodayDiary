//
//  SceneDelegate.swift
//  TodayDiary
//
//  Created by 정성희 on 12/11/24.
//

import UIKit
import AuthenticationServices
import CoreData
import CloudKit

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
        
        // 로딩 2초 후 화면 전환
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.checkAppleSignInState()
        }
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

    func checkICloudAccountStatus(completion: @escaping (Bool) -> Void) {
        CKContainer.default().accountStatus { accountStatus, error in
            if accountStatus == .available {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func checkAppleSignInState() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        CoreDataManager.shared.fetchIsRegistered()
        
        if let userID = loadUserIDFromKeychain() {
            checkICloudAccountStatus { isICloudAvailable in
                if isICloudAvailable == true {
                    appleIDProvider.getCredentialState(forUserID: userID) { (credentialState, error) in
                        DispatchQueue.main.async {
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            
                            switch credentialState {
                            case .authorized:
                                print("Apple ID is authorized.")
                                // DiaryMainViewController로 전환
                                
                                /// isRegistered 값이 존재하지 않는 경우
                                guard let isRegistered = CoreDataManager.shared.isRegistered else {
                                    // 로그인 화면으로 전환
                                    print("계정이 존재하지 않습니다. 로그인 화면으로 전환합니다.")
                                    guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
                                    self.window?.rootViewController = loginVC
                                    
                                    return
                                }
                                
                                /// 자동로그인 성공
                                /// 네트워크 연결이 됐을때, 안됐을때 모두 수행
                                print("계정이 존재합니다. 자동로그인을 진행합니다")
                                guard let diaryMainVC = storyboard.instantiateViewController(withIdentifier: "DiaryMainViewController") as? DiaryMainViewController else { return }
                                
                                self.window?.rootViewController = UINavigationController(rootViewController: diaryMainVC)
                                

                                /// 가입 했다가 애플로 로그인 설정 직접 삭제한 경우
                            case .revoked, .notFound:
                                print("계정 Apple ID revoked.")
                                // 로그인 화면으로 전환
                                guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
                                self.window?.rootViewController = loginVC
                            default:
                                break
                            }
                        }
                    }
                }
                else {
                    print("icloud 설정 확인해주세요")
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: Notification.Name("iCloudSetError"), object: nil)
                    }
                }
            }
            
            
        } else {
            // Apple ID가 저장되지 않았을 경우, 로그인 화면으로 전환
            /// 로그아웃 후, 탈퇴한 경우, 생전 처음 회원 가입 하는 경우
            DispatchQueue.main.async {
                print("로그인해주세요")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
                self.window?.rootViewController = loginVC
            }
        }
    }
    
    // Keychain에서 userID 가져오기
    func loadUserIDFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "AppleUserID",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess {
            if let data = item as? Data {
                print("Keychain User ID 불러오기 성공")
                return String(data: data, encoding: .utf8)
            }
        } else {
            print("User ID 불러오기 실패, 상태: \(status)")
        }
        return nil
    }
}
