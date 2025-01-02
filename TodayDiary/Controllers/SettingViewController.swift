//
//  SettingViewController.swift
//  TodayDiary
//
//  Created by 정성희 on 1/2/25.
//

import UIKit
import CoreData

class SettingViewController: UIViewController {

    private let context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate? else {
            print("AppDelegate가 초기화되지 않았습니다.")
            return nil
        }
        return appDelegate?.persistentContainer.viewContext
    }()
    
    private let loginInfoView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 359, height: 74)
        view.layer.backgroundColor = UIColor(red: 1, green: 0.973, blue: 0.961, alpha: 1).cgColor
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let userStatusImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "userStatus")
        image.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        image.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let loginLabel: UILabel = {
        var label = UILabel()
        label.text = "Apple 로그인이 되었어요."
        label.frame = CGRect(x: 0, y: 0, width: 167, height: 22)
        label.textColor = UIColor(red: 0.565, green: 0.478, blue: 0.478, alpha: 1)
        label.font = UIFont(name: Font.regular.rawValue, size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        var label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 223, height: 44)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = """
iCloud 에 자동으로 데이터가 저장됩니다.
iCloud 용량이 가득찰 경우 저장되지 않아요.
"""
        label.textColor = UIColor(red: 0.625, green: 0.625, blue: 0.625, alpha: 1)
        label.font = UIFont(name: Font.regular.rawValue, size: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let logoutView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 359, height: 57)
        view.layer.backgroundColor = UIColor(red: 0.902, green: 0.902, blue: 0.902, alpha: 1).cgColor
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logoutLabel: UILabel = {
        var label = UILabel()
        label.text = "로그아웃"
        label.frame = CGRect(x: 0, y: 0, width: 167, height: 22)
        label.textColor = UIColor(red: 0.514, green: 0.514, blue: 0.514, alpha: 1)
        label.font = UIFont(name: Font.bold.rawValue, size: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let moveMark: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "move-into")
        image.frame = CGRect(x: 0, y: 0, width: 11, height: 18)
        image.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let secessionBtn: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 56, height: 21)
        button.backgroundColor = .clear
        button.setTitle("회원탈퇴", for: .normal)
        
        button.titleLabel?.font = UIFont(name: Font.bold.rawValue, size: 16)
        button.setTitleColor(UIColor(red: 0.514, green: 0.514, blue: 0.514, alpha: 1), for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        setNavigationBtn()
        setConstraint()
        setLogoutBtn()
        addTargetTosecessionBtn()
    }
    
    deinit {
        print("설정 뷰 deinit")
    }
    
    // MARK: - 로그아웃, 회원탈퇴 함수
    @objc func logout() {
        loadLoginVC()
    }
    
    @objc func secession() {
        print("???")
        deleteAllData()
        print("데이터 제거 완료")
        loadLoginVC()
    }
    
    func deleteAllData() {
        guard let context = context else { return }
        let entityNames = context.persistentStoreCoordinator?.managedObjectModel.entities.compactMap { $0.name } ?? []
        do {
            for entityName in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                // Execute batch delete
                try context.execute(deleteRequest)
            }
            
            // Save context after deletion
            try context.save()
            print("모든 데이터가 성공적으로 삭제되었습니다.")
        } catch {
            print("모든 데이터를 삭제하는 중 오류 발생: \(error.localizedDescription)")
        }
    }
    
    func loadLoginVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let popVC = storyboard.instantiateViewController(withIdentifier: "PopUpViewController") as? PopUpViewController else {
            print("Failed to instantiate or cast PopUpViewController")
            return
        }
        // 데이터 전달
        popVC.markImageName = "exclamatio-mark"
        popVC.infoText = "로그아웃 할까요?"
        popVC.cancelBtnText = "취소"
        popVC.acceptBtnText = "확인"
        
        // 클로저 전달
        // 최종 로그인 확인버튼 누를시 해당 함수 실행
        popVC.onAcceptAction = {
            guard let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
            
            // UIWindow의 rootViewController를 loginVC로 변경하여 기존 vc 계층을 모두 deinit
            guard let window = UIApplication.shared.windows.first else { return }
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
        }
        
        popVC.modalPresentationStyle = .overFullScreen
        self.present(popVC, animated: false, completion: nil)
    }
    
    // MARK: - layout 및 constraint, ui design
    func setLogoutBtn() {
        // UITapGestureRecognizer 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(logout))
        logoutView.addGestureRecognizer(tapGesture)
        
        // 사용자 인터랙션 활성화
        logoutView.isUserInteractionEnabled = true
    }
    
    func setNavigationBtn() {
        // back 버튼
        var configuration = UIButton.Configuration.plain()  // 기본 스타일
        configuration.image = UIImage(named: "back")
        configuration.imagePadding = 10  // 이미지와 버튼의 경계 간격 설정
        configuration.imagePlacement = .leading  // 이미지 위치 설정
        let button = UIButton(configuration: configuration)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30) // 버튼 크기 설정
        button.addTarget(self, action: #selector(goBackPage), for: .touchUpInside)
        var barButton = UIBarButtonItem(customView: button)
        // 네비게이션 바에 추가 (왼쪽 버튼)
        navigationItem.leftBarButtonItem = barButton
        
        navigationItem.title = "설정"
        
        // 네비게이션 바 타이틀 텍스트 스타일 설정
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground() // 배경을 투명하게 설정
        appearance.shadowColor = .clear // 네비게이션 바의 하단 선(그림자) 제거
        appearance.backgroundColor = .clear // 배경 색상도 투명으로 설정 (필요에 따라 설정)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(red: 0.565, green: 0.478, blue: 0.478, alpha: 1), // 텍스트 색상
            .font: UIFont(name: Font.bold.rawValue, size: 20) // 폰트와 크기
        ]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func addTargetTosecessionBtn() {
        secessionBtn.addTarget(self, action: #selector(secession), for: .touchUpInside)
    }
    
    func setConstraint() {
        view.addSubview(loginInfoView)
        NSLayoutConstraint.activate([
            loginInfoView.topAnchor.constraint(equalTo: view.topAnchor, constant: 117),
            loginInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            loginInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            loginInfoView.heightAnchor.constraint(equalToConstant: 74)
        ])
        
        loginInfoView.addSubview(userStatusImage)
        NSLayoutConstraint.activate([
            userStatusImage.centerYAnchor.constraint(equalTo: loginInfoView.centerYAnchor),
            userStatusImage.leadingAnchor.constraint(equalTo: loginInfoView.leadingAnchor, constant: 16),
            userStatusImage.heightAnchor.constraint(equalToConstant: 40),
            userStatusImage.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        loginInfoView.addSubview(loginLabel)
        NSLayoutConstraint.activate([
            loginLabel.centerYAnchor.constraint(equalTo: loginInfoView.centerYAnchor),
            loginLabel.leadingAnchor.constraint(equalTo: loginInfoView.leadingAnchor, constant: 69)
        ])
        
        view.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: loginInfoView.bottomAnchor, constant: 10)
        ])
        
        view.addSubview(logoutView)
        NSLayoutConstraint.activate([
            logoutView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 34),
            logoutView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 17),
            logoutView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -17),
            logoutView.heightAnchor.constraint(equalToConstant: 57)
        ])
        
        logoutView.addSubview(logoutLabel)
        NSLayoutConstraint.activate([
            logoutLabel.centerYAnchor.constraint(equalTo: logoutView.centerYAnchor),
            logoutLabel.leadingAnchor.constraint(equalTo: logoutView.leadingAnchor, constant: 25)
        ])
        
        logoutView.addSubview(moveMark)
        NSLayoutConstraint.activate([
            moveMark.centerYAnchor.constraint(equalTo: logoutView.centerYAnchor),
            moveMark.trailingAnchor.constraint(equalTo: logoutView.trailingAnchor, constant: -18),
            moveMark.heightAnchor.constraint(equalToConstant: 18),
            moveMark.widthAnchor.constraint(equalToConstant: 11)
        ])

        view.addSubview(secessionBtn)
        NSLayoutConstraint.activate([
            secessionBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            secessionBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -62),
            secessionBtn.heightAnchor.constraint(equalToConstant: 21)
        ])
    }
    
    @objc func goBackPage() {
        navigationController?.popViewController(animated: true)
    }
}
