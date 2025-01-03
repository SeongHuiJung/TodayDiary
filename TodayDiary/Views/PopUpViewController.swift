//
//  PopUpViewController.swift
//  TodayDiary
//
//  Created by 정성희 on 12/27/24.
//

import UIKit

class PopUpViewController: UIViewController {

    var cancelBtnText : String?
    var acceptBtnText : String?
    var infoText : String?
    var markImageName: String?
    
    var onAcceptAction: (() -> Void)?
    
    private let popView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 324, height: 194)
        view.backgroundColor = UIColor(red: 1, green: 0.973, blue: 0.961, alpha: 1)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let markImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "") ?? nil
        image.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        image.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let infoLabel : UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0.565, green: 0.478, blue: 0.478, alpha: 1)
        label.font = UIFont(name: Font.regular.rawValue, size: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cancelBtn: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 140, height: 42)
        button.backgroundColor = UIColor(red: 0.837, green: 0.837, blue: 0.837, alpha: 1)
        button.layer.cornerRadius = 7
        button.setTitle("", for: .normal)
        
        button.titleLabel?.font = UIFont(name: Font.bold.rawValue, size: 16)
        button.setTitleColor(UIColor(red: 0.514, green: 0.514, blue: 0.514, alpha: 1), for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let acceptBtn: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 140, height: 42)
        button.backgroundColor = UIColor(red: 0.797, green: 0.422, blue: 0.422, alpha: 1)
        button.layer.cornerRadius = 7
        button.setTitle("", for: .normal)
        
        button.titleLabel?.font = UIFont(name: Font.bold.rawValue, size: 16)
        button.setTitleColor(UIColor(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAllSubViews()
        setLayout()
        
        setUI()
        setData()
        
        addTargerBtn()
    }
    
    func addAllSubViews() {
        view.addSubview(popView)
        popView.addSubview(markImage)
        popView.addSubview(infoLabel)
        popView.addSubview(cancelBtn)
        popView.addSubview(acceptBtn)
    }
    
    func setLayout() {
        NSLayoutConstraint.activate([
            popView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 34),
            popView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -34),
            popView.heightAnchor.constraint(equalToConstant: 194)
        ])
        
        NSLayoutConstraint.activate([
            markImage.topAnchor.constraint(equalTo: popView.topAnchor, constant: 21),
            markImage.centerXAnchor.constraint(equalTo: popView.centerXAnchor),
            markImage.widthAnchor.constraint(equalToConstant: 50),
            markImage.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: popView.topAnchor, constant: 85),
            infoLabel.centerXAnchor.constraint(equalTo: popView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            cancelBtn.topAnchor.constraint(equalTo: popView.topAnchor, constant: 135),
            cancelBtn.leadingAnchor.constraint(equalTo: popView.leadingAnchor, constant: 17),
            cancelBtn.trailingAnchor.constraint(equalTo: popView.centerXAnchor, constant: -5),
            cancelBtn.heightAnchor.constraint(equalToConstant: 42)
        ])
        
        NSLayoutConstraint.activate([
            acceptBtn.topAnchor.constraint(equalTo: popView.topAnchor, constant: 135),
            acceptBtn.leadingAnchor.constraint(equalTo: popView.centerXAnchor, constant: 5),
            acceptBtn.trailingAnchor.constraint(equalTo: popView.trailingAnchor, constant: -17),
            acceptBtn.heightAnchor.constraint(equalToConstant: 42)
        ])
    }
    
    func setUI() {
        // 기존 뷰 투명
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        
        // 전체 화면에 탭 제스처 추가
        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        view.addGestureRecognizer(backgroundTapGesture)
    }
    
    func setData() {
        cancelBtn.setTitle(cancelBtnText ?? "취소" , for: .normal)
        acceptBtn.setTitle(acceptBtnText ?? "확인" , for: .normal)
        infoLabel.text = infoText ?? "error"
        markImage.image = UIImage(named: markImageName ?? "exclamatio-mark")
    }
    
    func addTargerBtn() {
        cancelBtn.addTarget(self, action: #selector(tappedCancelBtn), for: .touchUpInside)
        acceptBtn.addTarget(self, action: #selector(tappedAcceptBtn), for: .touchUpInside)
    }
    
    @objc func tappedCancelBtn() {
        dismiss(animated: false)
    }
    
    /// popVC.onAcceptAction = {
    ///    popup 을 생성한 쪽에서 실행할 로직 작성
    ///}
    @objc func tappedAcceptBtn() {
        self.onAcceptAction?()
    }
    
    // popView 이외의 화면 클릭시 pop 뷰 안보이게하는 함수
    @objc func handleBackgroundTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: view)
        if let popView = view.subviews.first(where: { $0 is UIView && $0.layer.cornerRadius == 16 }) {
            if !popView.frame.contains(tapLocation) {
                self.dismiss(animated: false)
            }
        }
    }
}
