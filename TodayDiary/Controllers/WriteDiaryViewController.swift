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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUI()
        TextViewSetting()
        setDate()
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
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: currentTextCntLabel.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 31),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -31),
            textView.heightAnchor.constraint(equalToConstant: 180) // 초기 높이
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
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == UIColor(red: 0.653, green: 0.653, blue: 0.653, alpha: 1) else { return }
        
        textView.text = nil
        textView.textColor = UIColor(red: 0.565, green: 0.478, blue: 0.478, alpha: 1)
    }
    // Custom PlaceHolder
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
        
        // textView 높이 동적 조절
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach { (constraint) in
            /// 180 이하일때는 더 이상 줄어들지 않게하기
            if estimatedSize.height > 180 {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
        
//        // textView 높이 동적 조절
//        let size = CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude)
//        let estimatedSize = textView.sizeThatFits(size)
//        
//        // 높이 제약 조건 업데이트
//        if let heightConstraint = textView.constraints.first(where: { $0.firstAttribute == .height }) {
//            heightConstraint.constant = max(50, min(estimatedSize.height, 180)) // 최소 50, 최대 180
//        }
    }
}
