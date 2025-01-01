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
            
            // UserDefaults에 저장
            UserDefaults.standard.set(userID, forKey: "AppleUserID")
            print("Apple User ID 저장됨: \(userID)")
            
            // MARK: - 기존 방법 메인 페이지로 이동
            
            guard let secondVC = storyboard?.instantiateViewController(withIdentifier: "DiaryMainViewController") as? DiaryMainViewController else { return }
            secondVC.modalPresentationStyle = .fullScreen
            // UINavigationController 생성
            let navigationController = UINavigationController(rootViewController: secondVC)
            //self.navigationController?.pushViewController(navigationController, animated: true)
            navigationController.modalPresentationStyle = .fullScreen
            self.present(navigationController, animated: true, completion: nil)

            
            // 첫 로그인시에만 얻을 수 있는 정보
//            let fullName = appleIdCredential.fullName
//            let email = appleIdCredential.email
//            let identityToken = appleIdCredential.identityToken
//            let authorizationCode = appleIdCredential.authorizationCode
            
            print("Apple ID 로그인에 성공하였습니다.")
//            print("사용자 ID: \(userIdentifier)")
//            print("전체 이름: \(fullName?.givenName ?? "이미 로그인했음") \(fullName?.familyName ?? "")")
//            print("이메일: \(email ?? "이미 로그인했음")")
            
            //identityToken :  사용자에 대한 정보를 앱에 안전하게 전달하는 JWT.
//            print("Token: \(identityToken!)")
            
            // authorizationCode : 앱이 서버와 상호 작용하는 데 사용하는 토큰.
            // 5분간 유효, 1번만 사용 가능
//            print("authorizationCode: \(authorizationCode!)")
            
            // MARK: -  로그인화면부터 navigator 넣기 -> 성공
            // but 메인화면부터 바로 시작하면 안됨. 그래서 자동로그인 기능은 좀 고려해볼것
//            guard let secondVC = storyboard?.instantiateViewController(withIdentifier: "DiaryMainViewController") as? DiaryMainViewController else { return }
//            secondVC.modalPresentationStyle = .fullScreen
//            self.navigationController?.pushViewController(secondVC, animated: true)
//            
            
            
            
            // MARK: - gpt
            // 화면1 (로그인 화면)에서 화면2로 이동
            //let storyboard = UIStoryboard(name: "Main", bundle: nil)

            // 화면2의 NavigationController를 불러옵니다.
//            guard let navigationController = storyboard.instantiateViewController(withIdentifier: "DiaryMainViewController") as? UINavigationController else {
//                print("NavigationController를 찾을 수 없습니다.")
//                return }
//            
//            print("NavigationController 로드 성공") // 여기가 출력되면 정상적으로 불러온 것
//            // 화면2의 NavigationController를 Root로 하여 present 합니다.
//            navigationController.modalPresentationStyle = .fullScreen
//            self.present(navigationController, animated: true, completion: nil)

            
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
