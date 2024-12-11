//
//  LoginViewController.swift
//  TodayDiary
//
//  Created by 정성희 on 12/12/24.
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController {

    let appleLoginBtn = ASAuthorizationAppleIDButton(type: .continue, style: .whiteOutline)
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(appleLoginBtn)
        appleLoginBtn.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
        setUpConstraints()
    }
    
    // 버튼 레이아웃 설정 함수
    private func setUpConstraints() {
        appleLoginBtn.translatesAutoresizingMaskIntoConstraints = false
        
        // Auto Layout 제약조건
        NSLayoutConstraint.activate([
            appleLoginBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            appleLoginBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
            let userIdentifier = appleIdCredential.user
            
            // 첫 로그인시에만 얻을 수 있는 정보
            let fullName = appleIdCredential.fullName
            let email = appleIdCredential.email
            let identityToken = appleIdCredential.identityToken
            let authorizationCode = appleIdCredential.authorizationCode
            
            print("Apple ID 로그인에 성공하였습니다.")
            print("사용자 ID: \(userIdentifier)")
            print("전체 이름: \(fullName?.givenName ?? "이미 로그인했음") \(fullName?.familyName ?? "")")
            print("이메일: \(email ?? "이미 로그인했음")")
            print("Token: \(identityToken!)")
            print("authorizationCode: \(authorizationCode!)")
            
            // 여기에 로그인 성공 후 수행할 작업을 추가하세요.
            print("로그인 성공")
            
            //            let mainVC = MainViewController()
            //            mainVC.modalPresentationStyle = .fullScreen
            //            present(mainVC, animated: true)
            
            // 암호 기반 인증에 성공한 경우(iCloud), 사용자의 인증 정보를 확인하고 필요한 작업을 수행합니다
            //        case let passwordCredential as ASPasswordCredential:
            //            let userIdentifier = passwordCredential.user
            //            let password = passwordCredential.password
            //
            //            print("암호 기반 인증에 성공하였습니다.")
            //            print("사용자 이름: \(userIdentifier)")
            //            print("비밀번호: \(password)")
            //
            //            // 여기에 로그인 성공 후 수행할 작업을 추가하세요.
            //            let mainVC = MainViewController()
            //            mainVC.modalPresentationStyle = .fullScreen
            //            present(mainVC, animated: true)
            //
            //        default: break
            
        default:
            break
        }
    }
    
    // 로그인 실패 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // handle error
    }
}
