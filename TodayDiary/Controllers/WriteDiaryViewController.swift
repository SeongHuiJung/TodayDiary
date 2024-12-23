//
//  WriteDiaryViewController.swift
//  TodayDiary
//
//  Created by 정성희 on 12/17/24.
//

import UIKit
import CoreData

class WriteDiaryViewController: UIViewController {
    
    @IBOutlet weak var currentTextCntLabel: UILabel!
    @IBOutlet weak var moodImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    private let context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate? else {
            print("AppDelegate가 초기화되지 않았습니다.")
            return nil
        }
        return appDelegate?.persistentContainer.viewContext

    }()
    
    private let saveBtn: UIButton = {
        let button = UIButton()
        button.setTitle("저장하기", for: .normal)
        button.backgroundColor = UIColor(red: 0.818, green: 0.59, blue: 0.59, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveBtnTapped), for: .touchUpInside)
        return button
    }()
    private var buttonBottomConstraint: NSLayoutConstraint?
    
    var date: Date?
    
    /// data.0 : date
    /// data.1 : emoji
    /// data.2 : text
    /// data.4 : uuid
    var data: (Date?, Int?, String?, UUID?)
    
    let textView = UITextView()
    
    var maxTextCount = 200
    
    var originalTextViewHeight: CGFloat = 0 // 텍스트 뷰의 원래 높이 저장
    
    var textViewHeightConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        setUI()
        TextViewSetting()
        setDate()
        setSaveBtn()
        
        registerKeyboardNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func saveBtnTapped() {
        if let uuid = data.3 { updateData(id: uuid) }
        else { createData() }
    }
    
    func updateData(id: UUID) {
        guard let context = context else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Diary")
        //        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Plan")
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", id.uuidString)
        //        fetchRequest.predicate = NSPredicate(format: "uuid = %@", id as CVarArg)
        
        do {
            guard let result = try? context.fetch(fetchRequest),
                  let object = result.first as? NSManagedObject else { return }
            object.setValue(1, forKey: "emoji")
            object.setValue(textView.text, forKey: "text")
            try context.save()
        } catch {
            print("error: \(error.localizedDescription)")
        }
        print("수정성공")
    }
    
    func createData() {
        guard let context = context else { return }
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Diary", in: context) else {
            print("Error: Entity 'Diary' not found in the model")
            return
        }
        
        // DateFormatter 설정
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 시간대
        formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm:ss"

        // 문자열에 시간 추가 (자정 기준)
        let dateLabelWithTime = "\(dateLabel.text!) 00:00:00"
        
        // 문자열을 Date로 변환
        let koreaDate = formatter.date(from: dateLabelWithTime)
        print("한국 시간 기준 Date 객체: \(koreaDate)")
      
        let diary = NSManagedObject(entity: entityDescription, insertInto: context)
        diary.setValue(koreaDate, forKey: "date")
        diary.setValue(1, forKey: "emoji")
        diary.setValue(textView.text, forKey: "text")
        diary.setValue(UUID(), forKey: "uuid")
        
        do {
            try context.save()
            print("Data saved successfully!")
        } catch {
            print("Error saving data: \(error)")
        }
    }
    
    private func setSaveBtn() {
        view.addSubview(saveBtn)
        
        buttonBottomConstraint = saveBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
        
        // 버튼 제약 조건 설정
        
        NSLayoutConstraint.activate([
            saveBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 31),
            saveBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -31),
            saveBtn.heightAnchor.constraint(equalToConstant: 50),
            buttonBottomConstraint!
        ])
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
        
        self.originalTextViewHeight = self.textView.constraints.first(where: { $0.firstAttribute == .height })!.constant // 원래 높이 저장
        
        // 겹치는 부분을 계산 (textView bottom이 키보드 상단보다 클 경우)
        // 50 -> 하단 버튼 높이
        // 10 -> 키보드와 버튼 사이 간격 (키보드 올라왔을 때만)
        if textViewBottom > view.frame.height - keyboardHeight - safeAreaBottom - 50 - 10 {
            let overlapHeight = textViewBottom - (view.frame.height - keyboardHeight - safeAreaBottom - 50 - 10)
            
            // 텍스트 뷰의 높이를 겹친 부분만큼 줄여줍니다.
            let newHeight = originalTextViewHeight - overlapHeight
            
            // 최대 높이보다 줄어들지 않도록 합니다.
            let adjustedHeight = max(newHeight, 180) // 최소 높이는 180으로 설정
            
            // 기존 높이 제약이 있다면 이를 비활성화하고 새 제약을 설정
            if let currentConstraint = textViewHeightConstraint {
                currentConstraint.isActive = false
            }
            
            UIView.animate(withDuration: 0.3) {
                self.textViewHeightConstraint = self.textView.heightAnchor.constraint(equalToConstant: CGFloat(adjustedHeight))
                self.textViewHeightConstraint?.isActive = true
                self.view.layoutIfNeeded() // 애니메이션 적용
            }
        }
        
        // 하단 버튼 키보드 올릴시 키보드 위로 고정
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            buttonBottomConstraint?.constant = -keyboardFrame.height + view.safeAreaInsets.bottom - 10
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
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
        
        // 하단 버튼 키보드 내리면 제자리 원위치
        buttonBottomConstraint?.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func tappedBackBtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadData() {
        // 감정 이모지 그림 설정
        moodImage.image = getEmoji(emoji: data.1 ?? 0)
        // 일기 데이터 로드
        textView.text = data.2 ?? ""
    }
    
    func setDate() {
        guard let date = date else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 M월 d일"
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
            textView.heightAnchor.constraint(equalToConstant: 480) // 초기 높이
        ])
        
        textView.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15)
        textView.autocapitalizationType = .none //자동 대문자 방지
        textView.layer.cornerRadius = 16
        
        // 저장된 일기가 없는 경우
        if textView.text == "" {
            // Custom PlaceHolder
            textView.text = "일기를 작성해보세요"
            textView.textColor = UIColor(red: 0.653, green: 0.653, blue: 0.653, alpha: 1)
        }
        // 저장된 일기가 있는 경우
        else {
            textView.textColor = UIColor(red: 0.565, green: 0.478, blue: 0.478, alpha: 1)
        }
        
        updateTextCount()
        
        // padding
        textView.textContainerInset = UIEdgeInsets(top: 19, left: 19, bottom: 19, right: 19)
    }
    
    func updateTextCount() {
        // 글자 수 표시
        if textView.textColor == UIColor(red: 0.653, green: 0.653, blue: 0.653, alpha: 1) {
            currentTextCntLabel.text = "0 / \(maxTextCount)"
        }
        else {
            currentTextCntLabel.text = "\(textView.text.count) / \(maxTextCount)"
        }
    }
}

extension WriteDiaryViewController: UITextViewDelegate {
    // Custom PlaceHolder
    // 키보드 올릴때
    func textViewDidBeginEditing(_ textView: UITextView) {
        guard textView.textColor == UIColor(red: 0.653, green: 0.653, blue: 0.653, alpha: 1) else { return }
        
        textView.text = ""
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
        // 글자수 제한
        // 글자수 넘어가면 마지막 문자 자동제거
        if textView.text.count > maxTextCount {
            textView.deleteBackward()
        }
        
        updateTextCount()
    }
}
