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

    
    // save 버튼 관련 변수
    private let saveBtn: UIButton = {
        let button = UIButton()
        button.setTitle("저장하기", for: .normal)
        button.backgroundColor = UIColor(red: 0.818, green: 0.59, blue: 0.59, alpha: 1)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor(red: 0.514, green: 0.514, blue: 0.514, alpha: 1), for: .disabled)
        
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveBtnTapped), for: .touchUpInside)
        //button.isEnabled = false
        return button
    }()
    
    var bottomSheetViewController: BottomSheetViewController?
    
    var isSaveBtnEnabled: Bool = false {
        didSet {
            //saveBtn.isEnabled = isSaveBtnEnabled
            saveBtn.backgroundColor = isSaveBtnEnabled ? UIColor(red: 0.818, green: 0.59, blue: 0.59, alpha: 1) : UIColor(red: 0.837, green: 0.837, blue: 0.837, alpha: 1)
        }
    }
    
    /// data.0 : date
    /// data.1 : emoji
    /// data.2 : text
    /// data.3 : uuid
    var data: (Date?, Int?, String?, UUID?) // 로드한 데이터 (처음 생성시에는 데이터 없음)
    var date: Date? // 로드한 데이터 (처음 생성시에는 데이터 없음)
    
    var selectedEmoji: Int?
    
    let textView = UITextView()
    var maxTextCount = 1000
    var originalTextViewHeight: CGFloat = 0 // 텍스트 뷰의 원래 높이 저장
    var textViewBottomConstraint: NSLayoutConstraint?
    var saveBtnBottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setUI()
        setLayout()
        setSaveBtn()
        TextViewSetting()
        setDate()
        
        setEmojiView()
        checkSaveBtnIsActive()
        
        registerNotifications()
        setNavigationBtn()
        
        // 커스텀 버튼을 추가하거나 특정 설정을 변경했을 때, 이 제스처가 의도대로 작동하지 않을 수 있다
        // delegate를 초기화하여 제스처가 기본 동작을 따르도록 만듬. 이렇게 하면, 네비게이션 컨트롤러에서 커스텀 버튼을 추가했더라도 스와이프 제스처가 제대로 작동
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        print("일기 작성 페이지 deinit")
    }
    
    // MARK: - Navigation
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
        
        // 삭제할 데이터가 있는 경우에만 삭제 버튼 표기
        guard data.3 != nil else { return }
        let meatBallBtn = UIButton(type: .custom)
        meatBallBtn.setImage(UIImage(named: "meatball"), for: .normal)
        meatBallBtn.frame = CGRect(x: 24, y: 0, width: 35, height: 35) // 이미지 크기에 맞게 설정
        meatBallBtn.addTarget(self, action: #selector(deleteDataBtnTapped), for: .touchUpInside)
        barButton = UIBarButtonItem(customView: meatBallBtn)
        // 네비게이션 바에 추가 (오른쪽 버튼)
        navigationItem.rightBarButtonItem = barButton
    }
    
    
    // MARK: - layout design func
    func setLayout() {
        moodImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            moodImage.topAnchor.constraint(equalTo: view.topAnchor, constant: 121),
            moodImage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 166),
            moodImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 166),
            moodImage.heightAnchor.constraint(equalToConstant: 61),
            moodImage.widthAnchor.constraint(equalToConstant: 61)
        ])
    }
    func setEmojiView() {
        moodImage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(setEmojiTapped))
        moodImage.addGestureRecognizer(tapGesture)
    }
    private func setSaveBtn() {
        view.addSubview(saveBtn)
    
        // 버튼 제약 조건 설정
        NSLayoutConstraint.activate([
            saveBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 31),
            saveBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -31),
            //saveBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -82),
            saveBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveBtn.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    func registerNotifications() {
        // 키보드 동작 관련
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // emoji cell 클릭 관련
        NotificationCenter.default.addObserver(self, selector: #selector(getEmojiSelected(_:)), name: NSNotification.Name("ClickEmojiNoti"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(backToMainVC), name: NSNotification.Name("backToMainVC"), object: nil)
    }
    
    @objc func backToMainVC() {
        print("메인페이지로 이동")
        navigationController?.popViewController(animated: true)
        
        NotificationCenter.default.post(name: NSNotification.Name("showDeleteToast"), object: nil, userInfo: nil)
    }
    
    func setUI() {
        view.backgroundColor = UIColor(red: 1, green: 0.971, blue: 0.96, alpha: 1)
        dateLabel.textColor = UIColor(red: 0.565, green: 0.478, blue: 0.478, alpha: 1)
        dayLabel.textColor = UIColor(red: 0.74, green: 0.635, blue: 0.635, alpha: 1)
        currentTextCntLabel.textColor = UIColor(red: 0.74, green: 0.635, blue: 0.635, alpha: 1)
    }
    
    // 이모지 무조건 선택해야 저장 버튼 활성화
    // 버튼 활성화 가능 여부 확인 함수
    func checkSaveBtnIsActive() {
        if selectedEmoji != nil || data.1 != nil {
            print("selectedEmoji \(selectedEmoji)")
            print("data.1 \(data.1)")
            isSaveBtnEnabled = true
        }
        else {
            isSaveBtnEnabled = false
        }
    }
    
    
    
    // MARK: - data setting
    func loadData() {
        // 감정 이모지 그림 설정
        moodImage.image = getEmoji(emojiNumber: data.1 ?? 0)
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

    
    
    // MARK: - tapped objc func
    @objc func goBackPage() {
        navigationController?.popViewController(animated: true)
    }
    @objc func saveBtnTapped() {
        if isSaveBtnEnabled == true {
            if let uuid = data.3 { updateData(id: uuid) }
            else { createData() }
        }
        else {
            showToast(view: view, "상단의 기분스티커를 선택하고 저장해주세요 :)", withDuration: 2.0, delay: 1.5)
        }
    }
    @objc func setEmojiTapped() {
        let viewController = EmojiViewController()
        let height: CGFloat = 500
        bottomSheetViewController = BottomSheetViewController(contentViewController: viewController,
                                                                  defaultHeight: height,
                                                                  cornerRadius: 25,
                                                              dimmedAlpha: 0.7,
                                                                  isPannedable: true)
        
        self.present(bottomSheetViewController!, animated: false, completion: nil)
    }
    @objc func getEmojiSelected(_ notification: Notification) {
        // 이모지 선택시 이모지 bottom sheet 내림
        bottomSheetViewController!.hideBottomSheetAndGoBack()
        // 선택한 이모지로 변경
        moodImage.image = getEmoji(emojiNumber:notification.object! as! Int)
        
        selectedEmoji = notification.object! as? Int
        
        checkSaveBtnIsActive()
    }
    @objc func deleteDataBtnTapped() {
        guard let id = data.3 else { return }
        //deleteData(id: id)
        
        let viewController = DeleteDiaryViewController()
        viewController.setUUID(uuid: id)
        viewController.writeDiaryVC = self
        let height: CGFloat = 137
        bottomSheetViewController = BottomSheetViewController(contentViewController: viewController,
                                                                  defaultHeight: height,
                                                                  cornerRadius: 16,
                                                              dimmedAlpha: 0.9,
                                                                  isPannedable: false)
        
        self.present(bottomSheetViewController!, animated: false, completion: nil)
    }
    
    
    // MARK: - CLUD
    func updateData(id: UUID) {
        // 업데이트할 데이터
        var update_text = ""
        var update_emoji = 1
        
        if textView.textColor == UIColor(red: 0.653, green: 0.653, blue: 0.653, alpha: 1) { update_text = "" }
        else { update_text = textView.text }
        
        if let selectedEmoji = selectedEmoji { update_emoji = selectedEmoji }
        else { update_emoji = data.1! }
        
        CoreDataManager.shared.updateDiary(id: id, text: update_text, emoji: update_emoji) {
            showToast(view: view, "저장에 성공했어요 :)", withDuration: 2.0, delay: 1.5)
        }
    }
    func createData() {
        // DateFormatter 설정
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 시간대
        formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm:ss"
        
        // 문자열에 시간 추가 (자정 기준)
        let dateLabelWithTime = "\(dateLabel.text!) 00:00:00"
        
        // 저장할 데이터
        let save_date = formatter.date(from: dateLabelWithTime)
        var save_text = ""
        let save_emoji = selectedEmoji!
        let save_uuid = UUID()
        
        
        if textView.textColor == UIColor(red: 0.653, green: 0.653, blue: 0.653, alpha: 1) {
            save_text = ""
        }
        else {
            save_text = textView.text
        }
        
        // 새로운 데이터 생성후, 그 페이지에서 바로 데이터를 또 저장할 경우
        // 새로운 데이터를 다시 생성하지 않고 수정으로 로드하기 위해 uuid 설정
        data.3 = save_uuid
        
        CoreDataManager.shared.createDiary(date: save_date!, text: save_text, emoji: save_emoji, uuid: save_uuid) {
            showToast(view: view, "저장에 성공했어요 :)", withDuration: 2.0, delay: 1.5)
        }
    }
    
    
    
    // MARK: - keyboard
    // 키보드가 올라오면 호출되는 메서드에서 키보드가 textView와 겹치는 부분만큼만 크기를 줄입니다.
    @objc func keyboardWillShow(_ notification: NSNotification) {
        
        // 기존 높이 제약이 있다면 이를 비활성화하고 새 제약을 설정
        if let currentConstraint = self.textViewBottomConstraint {
            currentConstraint.isActive = false
        }
        if let currentConstraint = self.saveBtnBottomConstraint {
            currentConstraint.isActive = false
        }

        // 하단 버튼 키보드 올릴시 키보드 위로 고정
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -keyboardFrame.height + self.view.safeAreaInsets.bottom - 10 - 50 - 10 )
            textViewBottomConstraint?.isActive = true
            
            self.saveBtnBottomConstraint = self.saveBtn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -keyboardFrame.height + self.view.safeAreaInsets.bottom - 10)
            self.saveBtnBottomConstraint?.isActive = true
              
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        // 기존 높이 제약이 있다면 이를 비활성화하고 새 제약을 설정
        if let currentConstraint = self.textViewBottomConstraint {
            currentConstraint.isActive = false
        }
        
        if let currentConstraint = self.saveBtnBottomConstraint {
            currentConstraint.isActive = false
        }

        // 하단 버튼 키보드 내리면 제자리 원위치
        UIView.animate(withDuration: 0.3) {
            self.textViewBottomConstraint = self.textView.bottomAnchor.constraint(equalTo: self.saveBtn.topAnchor, constant: -26 )
            self.textViewBottomConstraint?.isActive = true
            
            self.saveBtnBottomConstraint = self.saveBtn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
            self.saveBtnBottomConstraint?.isActive = true
            
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    // MARK: - textView 관련
    func TextViewSetting() {
        var flag = false
        // placehold
        // 저장된 일기가 없는 경우
        if textView.text == "" {
            // Custom PlaceHolder
            textView.text = "일기를 작성해보세요"
            textView.textColor = UIColor(red: 0.653, green: 0.653, blue: 0.653, alpha: 1)
            flag = true
        }
        // 저장된 일기가 있는 경우
        else {
            textView.textColor = UIColor(red: 0.565, green: 0.478, blue: 0.478, alpha: 1)
        }
        
        // 행간 설정
        let attrString = NSMutableAttributedString(string: textView.text!)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let font = UIFont(name: "AppleSDGothicNeo-Regular", size: 15)
        attrString.addAttribute(.font, value: font!, range: NSRange(location: 0, length: attrString.length))
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        textView.attributedText = attrString
        
        textView.backgroundColor = .white
        textView.isScrollEnabled = true
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        

        textView.autocapitalizationType = .none //자동 대문자 방지
        textView.layer.cornerRadius = 16
        // padding
        textView.textContainerInset = UIEdgeInsets(top: 19, left: 19, bottom: 19, right: 19)
        
        if flag == true {
            // Custom PlaceHolder
            //textView.text = "일기를 작성해보세요"
            textView.textColor = UIColor(red: 0.653, green: 0.653, blue: 0.653, alpha: 1)
        }
        // 저장된 일기가 있는 경우
        else {
            textView.textColor = UIColor(red: 0.565, green: 0.478, blue: 0.478, alpha: 1)
        }
        
        view.addSubview(textView)
        
        textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: saveBtn.topAnchor, constant: -26)
        
        // 원래 bottomAnchor 설정값 저장
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: currentTextCntLabel.topAnchor, constant: 20),
            textViewBottomConstraint!,
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 31),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -31),
        ])
        updateTextCount()
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
