//
//  DiaryMainViewController.swift
//  TodayDiary
//
//  Created by 정성희 on 12/12/24.
//

import UIKit
import CoreData
import FSCalendar
import CloudKit
import WidgetKit

class DiaryMainViewController: UIViewController {

    private let settingBtn: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 27, height: 27)
        button.backgroundColor = .clear
        button.setImage(UIImage(named: "setting"), for: .normal)
        button.isUserInteractionEnabled = true
        //button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    @IBOutlet weak var calendarView: FSCalendar!
    var count = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 프로토콜 연결
        calendarView.delegate = self
        calendarView.dataSource = self
        
        calendarView.reloadData() // cell reload
        
        // 커스텀 셀 등록 (CalendarCell 클래스는 밑에서 구현)
        calendarView.register(CalendarCell.self, forCellReuseIdentifier: "CalendarCell")
        
        setUI() // 캘린더 ui 설정
        setCalendarDesign(calendarView: calendarView) // 캘린더 기본 디자인 설정
        setSettingBtn() // 설정버튼 설정
        
        addNotification()
        
        // 네트워크 연결 안될시 안내 메시지 띄움
        if !NetworkCheck.shared.isConnected {
            let popText = """
네트워크 연결이 끊겼어요!
그동안 작성한 일기는
네트워크가 다시 연결되면
자동으로 iCloud 에 저장돼요.
"""
            showInfoPopUpView(infoText: popText, acceptBtnText: "확인")
        }
        
        calendarView.reloadData() // cell reload
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // 데이터 변경 후 메인화면으로 돌아올 시 cell 업데이트
        calendarView.reloadData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // WriteDiaryVC 에서 interactivePopGestureRecognizer = nil 으로 변경해두었기 때문에
        // 메인화면으로 돌아올때마다 interactivePopGestureRecognizer 설정해야함
        // 해당 작업을 하지 않으면 WriteDiaryVC 에서 사용하던 제스쳐 설정을 그대로 따르기 때문에 메인 페이지에서 오류발생
        // 또한 viewDidAppear 에서 실행하는 이유는 write WriteDiaryVC 에서 이전 페이지로 온전히 다 넘어가지 않더라도 viewWillAppear 가 실행되기 때문에 WriteDiaryVC 에서 더이상 제스쳐가 먹히지 않음
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        // 위젯 업데이트
        WidgetData.shared.isLogin = AccessManager.shared.loadUserIDFromKeychain() != nil ? true : false
        WidgetCenter.shared.reloadTimelines(ofKind: "DiaryWidget")
        
        CoreDataManager.shared.loadAllRegistered()
    }
    
    deinit {
        print("메인 달력 뷰 deinit")
    }
    
    func setUI() {
        view.backgroundColor = UIColor(red: 1, green: 0.971, blue: 0.96, alpha: 1)
    }
    
    func setSettingBtn() {
        let barButton = UIBarButtonItem(customView: settingBtn)
        // 네비게이션 바에 추가 (오른쪽 버튼)
        navigationItem.rightBarButtonItem = barButton
        settingBtn.addTarget(self, action: #selector(goSettingPage), for: .touchUpInside)
    }
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(showDeleteToast), name: NSNotification.Name("showDeleteToast"), object: nil)
        
        // cloudkit 저장소 꽉 차서 더이상 저장 못하는 경우 사용자에게 안내
        NotificationCenter.default.addObserver(
            forName: .NSPersistentStoreRemoteChange,
            object: nil,
            queue: .main
        ) { notification in
            // 동기화 상태를 알림에서 확인
            if let userInfo = notification.userInfo,
               let cloudKitError = userInfo[NSUnderlyingErrorKey] as? NSError {
                print("CloudKit sync error: \(cloudKitError)")

                // iCloud 저장소가 꽉 찬 경우 처리
                if cloudKitError.code == CKError.quotaExceeded.rawValue {
                    let popText = """
        iCloud 저장소가 꽉 찼어요!
        저장소를 비우기 전까진
        핸드폰에 일기가 저장돼요.
        저장소를 비우면 자동으로
        iCloud 동기화가 완료 됩니다.
        """
                    self.showInfoPopUpView(infoText: popText, acceptBtnText: "확인")
                }
            }
        }
    }
    
    func showInfoPopUpView(infoText: String, acceptBtnText: String) {
        PopUpManager.shared.addPopup { [weak self] in
            guard let self = self else { return }
            let popVC = InfoPopUpViewController()
            
            popVC.infoText = infoText
            popVC.acceptBtnText = acceptBtnText
            popVC.modalPresentationStyle = .overFullScreen
            
            self.present(popVC, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - 디버깅용 iCloud 꽉 찬 경우 테스트
    func triggerCloudKitQuotaExceeded() {
        // CKError.quotaExceeded 시뮬레이션
        let simulatedError = NSError(
            domain: CKError.errorDomain,
            code: CKError.quotaExceeded.rawValue,
            userInfo: [NSLocalizedDescriptionKey: "iCloud 저장소가 꽉 찼습니다."]
        )

        // 알림 생성 및 전송
        let userInfo: [AnyHashable: Any] = [NSUnderlyingErrorKey: simulatedError]
        NotificationCenter.default.post(
            name: .NSPersistentStoreRemoteChange,
            object: nil,
            userInfo: userInfo
        )
    }
    
    @objc func goSettingPage(){
        guard let secondVC = storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else { return }
        secondVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(secondVC, animated: true)
    }
    
    @objc func showDeleteToast() {
        print("일기삭제")
        showToast(view: view, "일기를 삭제했어요 :)", withDuration: 2.0, delay: 1.5)
    }
}

extension DiaryMainViewController: FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
    
    // 오늘 이후의 날짜는 선택이 불가능
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    
    // 커스텀 셀 로드
    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
        guard let cell = calendar.dequeueReusableCell(withIdentifier: "CalendarCell", for: date, at: position) as? CalendarCell else {
            return FSCalendarCell()
        }
        let day = Calendar.current.component(.day, from: date)
        cell.configure(with: "\(day)") // 셀에 날짜를 표시
        
        // 해당 일에 맞는 데이터 로드
        CoreDataManager.shared.loadDiary(dateData: date) { date, emoji , text , uuid in
            
            // 해당 일에 데이터가 있는 경우에만 데이터 set
            guard let date = date else { return }
            cell.setCalendarCellData(_date: date, _emoji: emoji, _text: text, _uuid: uuid!)
        }
        
        
//        if data.0 != nil {
//            cell.setCalendarCellData(_date: data.0!, _emoji: data.1, _text: data.2, _uuid: data.3!)
//        }
        
        cell.setCalendarCellDesign(monthPosition: position, date: date)
        return cell
    }
    
    
    // 셀 클릭시
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 일기 작성 페이지로 이동
        guard let secondVC = storyboard?.instantiateViewController(withIdentifier: "WriteDiaryViewController") as? WriteDiaryViewController else { return }
        secondVC.modalPresentationStyle = .fullScreen
        
        // 데이터 전달
        secondVC.date = date
        CoreDataManager.shared.loadDiary(dateData: date) { date, emoji , text , uuid in
            
            // 해당 일에 데이터가 있는 경우에만 데이터 set
            guard let date = date else { return }
            secondVC.data = (date,emoji,text,uuid)
        }
        navigationController?.pushViewController(secondVC, animated: false)
    }
}

extension DiaryMainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
