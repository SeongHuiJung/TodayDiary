//
//  LoginViewController.swift
//  TodayDiary
//
//  Created by 정성희 on 12/12/24.
//

import UIKit
import AuthenticationServices
import WidgetKit

class LoginViewController: UIViewController {

    @IBOutlet weak var logoImage: UIImageView!
    let appleLoginBtn = ASAuthorizationAppleIDButton(type: .continue, style: .whiteOutline)
    override func viewDidLoad() {
        super.viewDidLoad()
        WidgetCenter.shared.reloadTimelines(ofKind: "DiaryWidget")
        
        // Do any additional setup after loading the view.
        view.addSubview(appleLoginBtn)
        appleLoginBtn.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        setUpConstraints()
        self.view.backgroundColor = UIColor(red: 1, green: 0.973, blue: 0.961, alpha: 1)
    }
    
    deinit {
        print("로그인 화면 deinit")
    }
    
    // 버튼 레이아웃 설정 함수
    private func setUpConstraints() {
        appleLoginBtn.translatesAutoresizingMaskIntoConstraints = false
        
        // Auto Layout 제약조건
        NSLayoutConstraint.activate([
            appleLoginBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleLoginBtn.topAnchor.constraint(equalTo: logoImage.bottomAnchor, constant: 41),
            appleLoginBtn.heightAnchor.constraint(equalToConstant: 50), // 버튼 높이
            appleLoginBtn.widthAnchor.constraint(equalToConstant: 250) // 버튼 너비
        ])
    }
    
    @objc func didTapSignIn() {
        print("Start sign in")
        
        let provider = ASAuthorizationAppleIDProvider()
        let requset = provider.createRequest()
        
        // 사용자에게 제공받을 정보를 선택 (이름 및 이메일) -- 아래 이미지 참고
        requset.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [requset])
        // 로그인 정보 관련 대리자 설정
        controller.delegate = self
        // 인증창을 보여주기 위해 대리자 설정
        controller.presentationContextProvider = self
        // 요청
        controller.performRequests()
    }
    
    func performAppleLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email] // 요청할 권한 지정 (필요 시)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate,
                               ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    // 인증 성공시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            // 매번 인증시 얻을 수 있는 정보
            let userID = appleIdCredential.user

            let identityToken = appleIdCredential.identityToken // 5분 후 사용불가
            let authorizationCode = appleIdCredential.authorizationCode // 10분 후 사용불가, 한번만 사용가능

            
            // Keychain에 저장
            saveUserIDToKeychain(userID: userID)
            
            // 첫 로그인시에만 얻을 수 있는 정보
            let fullName = appleIdCredential.fullName
            let email = appleIdCredential.email

            // MARK: - 기존 방법 메인 페이지로 이동
            guard let secondVC = storyboard?.instantiateViewController(withIdentifier: "DiaryMainViewController") as? DiaryMainViewController else { return }
            secondVC.modalPresentationStyle = .fullScreen
            // UINavigationController 생성
            let navigationController = UINavigationController(rootViewController: secondVC)
            //self.navigationController?.pushViewController(navigationController, animated: true)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)

            CoreDataManager.shared.setTrueIsRegistered()
            print("Apple ID 로그인에 성공하였습니다.")
        default:
            break
        }
    }
    
    // Keychain에 userID 저장
    func saveUserIDToKeychain(userID: String) {
        let data = Data(userID.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword, // 일반 비밀번호 저장
            kSecAttrAccount as String: "AppleUserID",      // 고유 키
            kSecValueData as String: data                 // 저장할 데이터
        ]
        // 기존 데이터 삭제
        SecItemDelete(query as CFDictionary)
        // 새로운 데이터 추가
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("Keychain에 User ID 저장 성공")
        } else {
            print("Keychain에 User ID 저장 실패, 상태: \(status)")
        }
    }
    
    
    
    // 로그인 실패 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // handle error
    }
}

// Keychain에서 userID 삭제
func deleteUserIDFromKeychain() {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "AppleUserID"
    ]
    let status = SecItemDelete(query as CFDictionary)
    if status == errSecSuccess {
        print("User ID 삭제 성공")
    } else {
        print("User ID 삭제 실패, 상태: \(status)")
    }
}
