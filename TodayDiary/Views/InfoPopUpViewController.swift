//
//  InfoPopUpViewController.swift
//  TodayDiary
//
//  Created by 정성희 on 1/15/25.
//

import UIKit

class InfoPopUpViewController: UIViewController {

    var acceptBtnText : String?
    var infoText : String?
    
    var onAcceptAction: (() -> Void)?
    
    private let popView: UIView = {
        let view = UIView()
        //view.frame = CGRect(x: 0, y: 0, width: 324, height: 256)
        view.backgroundColor = UIColor(red: 1, green: 0.973, blue: 0.961, alpha: 1)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let markImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "exclamatio-mark") ?? nil
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
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let acceptBtn: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 291, height: 42)
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
        setUI()
        setData()
        setLayout()
        addTargerBtn()
    }
    
    func addAllSubViews() {
        view.addSubview(popView)
        popView.addSubview(markImage)
        popView.addSubview(infoLabel)
        popView.addSubview(acceptBtn)
    }
    
    func setLayout() {

        infoLabel.sizeToFit()
        let labelHeight = infoLabel.frame.size.height
        print(labelHeight)
        
        NSLayoutConstraint.activate([
            popView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 34),
            popView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -34),
            popView.heightAnchor.constraint(equalToConstant: labelHeight + 168)
        ])
        
        NSLayoutConstraint.activate([
            markImage.topAnchor.constraint(equalTo: popView.topAnchor, constant: 21),
            markImage.centerXAnchor.constraint(equalTo: popView.centerXAnchor),
            markImage.widthAnchor.constraint(equalToConstant: 50),
            markImage.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: popView.topAnchor, constant: 86),
            infoLabel.centerXAnchor.constraint(equalTo: popView.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            acceptBtn.bottomAnchor.constraint(equalTo: popView.bottomAnchor, constant: -17),
            acceptBtn.leadingAnchor.constraint(equalTo: popView.leadingAnchor, constant: 17),
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
        acceptBtn.setTitle(acceptBtnText ?? "확인" , for: .normal)
        infoLabel.text = infoText ?? "error"
    }
    
    func addTargerBtn() {
        acceptBtn.addTarget(self, action: #selector(tappedAcceptBtn), for: .touchUpInside)
    }
    
    /// popVC.onAcceptAction = {
    ///    popup 을 생성한 쪽에서 실행할 로직 작성
    ///}
    @objc func tappedAcceptBtn() {
        dismissPopup()
    }
    
    // popView 이외의 화면 클릭시 pop 뷰 끄는 함수
    @objc func handleBackgroundTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: view)
        if let popView = view.subviews.first(where: { $0 is UIView && $0.layer.cornerRadius == 16 }) {
            if !popView.frame.contains(tapLocation) {
                dismissPopup()
            }
        }
    }
    
    func dismissPopup() {
            // 팝업을 닫고, callback 호출
            dismiss(animated: false) { [weak self] in
                PopUpManager.shared.popupDidDismiss()
            }
        }
}
