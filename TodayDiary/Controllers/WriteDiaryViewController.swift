//
//  WriteDiaryViewController.swift
//  TodayDiary
//
//  Created by 정성희 on 12/17/24.
//

import UIKit

class WriteDiaryViewController: UIViewController {
    
    var date: Date?
    
    let textView = UITextView()
    
    @IBOutlet weak var currentTextCntLabel: UILabel!
    @IBOutlet weak var moodImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    var maxTextCount = 200
    
    var originalTextViewHeight: CGFloat = 0 // 텍스트 뷰의 원래 높이 저장
    
    var textViewHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        TextViewSetting()
        setDate()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        //registerKeyboardNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    // 키보드가 올라오면 호출되는 메서드에서 키보드가 textView와 겹치는 부분만큼만 크기를 줄입니다.
    @objc func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = keyboardFrame.height
        let safeAreaBottom = view.safeAreaInsets.bottom
        
        // textView의 현재 위치
        let textViewBottom = textView.frame.origin.y + textView.frame.height
        
        print("비교 textViewBottom \(textViewBottom)")
        print("비교 키보드 위치 \(view.frame.height - keyboardHeight - safeAreaBottom)")
        
        self.originalTextViewHeight = self.textView.constraints.first(where: { $0.firstAttribute == .height })!.constant // 원래 높이 저장
        
        print("self.originalTextViewHeight \(self.originalTextViewHeight)")
        // 겹치는 부분을 계산 (textView bottom이 키보드 상단보다 클 경우)
        if textViewBottom > view.frame.height - keyboardHeight - safeAreaBottom {
            let overlapHeight = textViewBottom - (view.frame.height - keyboardHeight - safeAreaBottom)
            
            // 텍스트 뷰의 높이를 겹친 부분만큼 줄여줍니다.
            let newHeight = originalTextViewHeight - overlapHeight
            
            // 최대 높이보다 줄어들지 않도록 합니다.
            let adjustedHeight = max(newHeight, 200) // 최소 높이는 180으로 설정
            //textView.heightAnchor.constraint(equalToConstant: adjustedHeight).isActive = true
            
            // 기존 높이 제약이 있다면 이를 비활성화하고 새 제약을 설정
            if let currentConstraint = textViewHeightConstraint {
                currentConstraint.isActive = false
            }
            
            UIView.animate(withDuration: 0.3) {
                self.textViewHeightConstraint = self.textView.heightAnchor.constraint(equalToConstant: adjustedHeight)
                self.textViewHeightConstraint?.isActive = true
                self.view.layoutIfNeeded() // 애니메이션 적용
            }
        }
        
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        // 기존 높이 제약이 있다면 이를 비활성화하고 새 제약을 설정
        if let currentConstraint = self.textViewHeightConstraint {
            currentConstraint.isActive = false
        }
        
        // 애니메이션을 사용하여 원래 높이로 되돌리기
        UIView.animate(withDuration: 0.3) {
            self.textViewHeightConstraint = self.textView.heightAnchor.constraint(equalToConstant: self.originalTextViewHeight)
            self.textViewHeightConstraint?.isActive = true
            self.view.layoutIfNeeded() // 애니메이션 적용
        }
    }
    
    
    func adjustTextViewHeight(for keyboardHeight: CGFloat) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            let safeAreaBottom = self.view.safeAreaInsets.bottom
            let heightAdjustment = keyboardHeight - safeAreaBottom
            print("heightAdjustment \(heightAdjustment)")
            // 텍스트 뷰의 높이 조정
            if let heightConstraint = self.textView.constraints.first(where: { $0.firstAttribute == .height }) {
                if keyboardHeight > 0 {
                    self.originalTextViewHeight = heightConstraint.constant // 원래 높이 저장
                    heightConstraint.constant -= heightAdjustment
                } else {
                    print("키보드 내릴때 self.originalTextViewHeight \(self.originalTextViewHeight)")
                    heightConstraint.constant = self.originalTextViewHeight // 원래 높이로 복원
                    textView.heightAnchor.constraint(equalToConstant: originalTextViewHeight).isActive = true
                    print("heightConstraint.constant \(heightConstraint.constant)")
                }
                //self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func tappedBackBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setDate() {
        guard let date = date else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        dateLabel.text = String(dateFormatter.string(from: date))
        
        dateFormatter.dateFormat = "E요일"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        dayLabel.text = String(dateFormatter.string(from: date))
    }
    
    func setUI() {
        view.backgroundColor = UIColor(red: 1, green: 0.971, blue: 0.96, alpha: 1)
        dateLabel.textColor = UIColor(red: 0.565, green: 0.478, blue: 0.478, alpha: 1)
        dayLabel.textColor = UIColor(red: 0.74, green: 0.635, blue: 0.635, alpha: 1)
        currentTextCntLabel.textColor = UIColor(red: 0.74, green: 0.635, blue: 0.635, alpha: 1)
    }
    
    func TextViewSetting() {
        textView.backgroundColor = .white
        textView.isScrollEnabled = true
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: currentTextCntLabel.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 31),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -31),
            textView.heightAnchor.constraint(equalToConstant: 500) // 초기 높이
        ])
        
        textView.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15)
        textView.autocapitalizationType = .none //자동 대문자 방지
        textView.layer.cornerRadius = 16
        
        // Custom PlaceHolder
        textView.text = "일기를 작성해보세요"
        textView.textColor = UIColor(red: 0.653, green: 0.653, blue: 0.653, alpha: 1)
        
        // padding
        textView.textContainerInset = UIEdgeInsets(top: 19, left: 19, bottom: 19, right: 19)
    }
}

extension WriteDiaryViewController: UITextViewDelegate {
    // Custom PlaceHolder
    // 키보드 올릴때
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == UIColor(red: 0.653, green: 0.653, blue: 0.653, alpha: 1) else { return }
        
        textView.text = nil
        textView.textColor = UIColor(red: 0.565, green: 0.478, blue: 0.478, alpha: 1)
    }
    // Custom PlaceHolder
    // 키보드 내릴때
    func textViewDidEndEditing(_ textView: UITextView) {
        if(textView.text == ""){
            textView.text = "일기를 작성해보세요"
            textView.textColor = UIColor(red: 0.653, green: 0.653, blue: 0.653, alpha: 1)
        }
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) /// 화면을 누르면 키보드 내려가게 하는 것
    }
    
    // 텍스트에 변화가 생길때 마다
    func textViewDidChange(_ textView: UITextView) {
        print("글자 작성중")
        // 글자수 제한
        // 글자수 넘어가면 마지막 문자 자동제거
        if textView.text.count > maxTextCount {
            textView.deleteBackward()
        }
        
        // 이거 왜 안됑...ㅠㅠ 일단 주석처리
        //        else if textView.text.count == 150 {
        //            // 글자 수 부분 색상 빨갛게 변경
        //            let attributedString = NSMutableAttributedString(string: "\(textView.text.count) / 150")
        //            attributedString.addAttribute(.foregroundColor, value: UIColor(red: 0.765, green: 0.302, blue: 0.302, alpha: 1), range: ("\(textView.text.count) / 150" as NSString).range(of:"\(textView.text.count)"))
        //            currentTextCntLabel.attributedText = attributedString
        //        }
        
        // 글자 수 표시
        if textView.textColor == UIColor(red: 0.653, green: 0.653, blue: 0.653, alpha: 1) {
            currentTextCntLabel.text = "0 / \(maxTextCount)"
        }
        else {
            currentTextCntLabel.text = "\(textView.text.count) / \(maxTextCount)"
        }
        
        // 현재 입력하는 줄로 포커스 이동
        //        let cursorPosition = textView.selectedRange
        //        textView.scrollRangeToVisible(cursorPosition)
        
        //textView 높이 동적 조절
        //        let size = CGSize(width: view.frame.width, height: .infinity)
        //        let estimatedSize = textView.sizeThatFits(size)
        //
        //        textView.constraints.forEach { (constraint) in
        //            /// 180 이하일때는 더 이상 줄어들지 않게하기
        //            print("estimatedSize \(estimatedSize.height)")
        //            if 200 < estimatedSize.height && estimatedSize.height < 450 {
        //                if constraint.firstAttribute == .height {
        //                    constraint.constant = estimatedSize.height
        //                }
        //            }
        //        }
    }
}
