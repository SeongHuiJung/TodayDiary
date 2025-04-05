//
//  SecessionViewController.swift
//  TodayDiary
//
//  Created by 정성희 on 1/3/25.
//

import UIKit
import CoreData
import WidgetKit

class SecessionViewController: UIViewController {
    
    private let infoView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 324, height: 185)
        view.backgroundColor = UIColor(red: 0.935, green: 0.935, blue: 0.935, alpha: 1)
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let infoTitle : UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 53, height: 21)
        label.textColor = UIColor(red: 0.465, green: 0.465, blue: 0.465, alpha: 1)
        label.font = UIFont(name: Font.bold.rawValue, size: 15)
        label.textAlignment = .center
        label.text = "유의사항"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let infoDescription: UILabel = {
        var label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 309, height: 44)
        label.numberOfLines = 0
        
        label.text = """
회원을 탈퇴할 경우 작성했던 모든 일기 데이터가 삭제됩니다.
삭제된 데이터는 복구가 불가능합니다.
"""
        label.textColor = UIColor(red: 0.519, green: 0.519, blue: 0.519, alpha: 1)
        label.font = UIFont(name: Font.regular.rawValue, size: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // 행간 조절
        let attrString = NSMutableAttributedString(string: label.text!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        label.attributedText = attrString
        label.textAlignment = .center
        return label
    }()
    
    private let secessionBtn: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 359, height: 49)
        button.backgroundColor = UIColor(red: 0.88, green: 0.477, blue: 0.477, alpha: 1)
        button.layer.cornerRadius = 10
        button.setTitle("탈퇴하기", for: .normal)
        
        button.titleLabel?.font = UIFont(name: Font.bold.rawValue, size: 15)
        button.setTitleColor(.white, for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setConstraint()
        addTargetsecessionBtn()
        setUI()
    }
    
    deinit {
        print("secessionVC deinit")
    }
    
    func setUI() {
        view.backgroundColor = .white
    }
    
    func addTargetsecessionBtn() {
        secessionBtn.addTarget(self, action: #selector(popSecessionView), for: .touchUpInside)
    }
    
    @objc func popSecessionView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let popVC = storyboard.instantiateViewController(withIdentifier: "PopUpViewController") as? PopUpViewController else {
            print("Failed to instantiate or cast PopUpViewController")
            return
        }
        
        // 데이터 전달
        popVC.markImageName = "exclamatio-mark"
        popVC.infoText = "회원을 탈퇴할까요?"
        popVC.cancelBtnText = "취소"
        popVC.acceptBtnText = "확인"
        
        // 클로저 전달
        // 최종 탈퇴 확인버튼 누를시 해당 함수 실행
        popVC.onAcceptAction = {
            CoreDataManager.shared.deleteAllData()
            CoreDataManager.shared.deleteIsRegistered()
            
            let transitionView = UIView(frame: UIScreen.main.bounds)
            transitionView.backgroundColor = .white
            transitionView.alpha = 0.0
            guard let window = UIApplication.shared.windows.first else { return }
            window.addSubview(transitionView)
            
            // 애니메이션으로 페이드 효과 적용
            UIView.animate(withDuration: 0.3, animations: {
                transitionView.alpha = 1.0
            }) { _ in
                guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
                
                // UIWindow의 rootViewController를 loginVC로 변경하여 기존 vc 계층을 모두 deinit
                guard let window = UIApplication.shared.windows.first else { return }
                window.rootViewController = loginVC
                window.makeKeyAndVisible()
                
                // 전환 뷰 제거
                transitionView.removeFromSuperview()
                
                // 위젯 업데이트
                WidgetData.shared.isLogin = false
                WidgetCenter.shared.reloadTimelines(ofKind: "DiaryWidget")
            }
            
            // keychain 에 저장된 로그인 정보 삭제
            deleteUserIDFromKeychain()
        }
        
        popVC.modalPresentationStyle = .overFullScreen
        self.present(popVC, animated: false, completion: nil)
    }
    
    func setNavigationBar() {
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        navigationItem.title = "회원탈퇴"
        
        // back 버튼
        var configuration = UIButton.Configuration.plain()  // 기본 스타일
        configuration.image = UIImage(named: "back")
        configuration.imagePadding = 10  // 이미지와 버튼의 경계 간격 설정
        configuration.imagePlacement = .leading  // 이미지 위치 설정
        let button = UIButton(configuration: configuration)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30) // 버튼 크기 설정
        button.addTarget(self, action: #selector(goBackPage), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: button)
        // 네비게이션 바에 추가 (왼쪽 버튼)
        navigationItem.leftBarButtonItem = barButton
    }
    
    func setConstraint() {
        view.addSubview(infoView)
        NSLayoutConstraint.activate([
            infoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            infoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            infoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            infoView.heightAnchor.constraint(equalToConstant: 113)
        ])
        
        infoView.addSubview(infoTitle)
        NSLayoutConstraint.activate([
            infoTitle.topAnchor.constraint(equalTo: infoView.topAnchor, constant: 20),
            infoTitle.centerXAnchor.constraint(equalTo: infoView.centerXAnchor)
        ])
        
        infoView.addSubview(infoDescription)
        NSLayoutConstraint.activate([
            infoDescription.topAnchor.constraint(equalTo: infoTitle.bottomAnchor, constant: 12),
            infoDescription.centerXAnchor.constraint(equalTo: infoView.centerXAnchor)
        ])
        
        view.addSubview(secessionBtn)
        NSLayoutConstraint.activate([
            secessionBtn.topAnchor.constraint(equalTo: infoView.bottomAnchor, constant: 17),
            secessionBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            secessionBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            secessionBtn.heightAnchor.constraint(equalToConstant: 49)
        ])
    }
    
    @objc func goBackPage() {
        navigationController?.popViewController(animated: true)
    }
}
