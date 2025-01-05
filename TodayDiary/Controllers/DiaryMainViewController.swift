//
//  DiaryMainViewController.swift
//  TodayDiary
//
//  Created by 정성희 on 12/12/24.
//

import UIKit
import CoreData
import FSCalendar

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
        fetchAllData()
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
    
    func fetchAllData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Diary")
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                
                // Core Data의 속성에 접근하기 위해 Key-Value Coding (KVC) 방식 사용
                if let date = result.value(forKey: "date") as? Date {
                    print("Fetched title: \(date)")
                }
                if let emoji = result.value(forKey: "emoji") as? Int {
                    print("Fetched content: \(emoji)")
                }
                if let text = result.value(forKey: "text") as? String {
                    print("Fetched content: \(text)")
                }
                if let uuid = result.value(forKey: "uuid") as? UUID {
                    print("Fetched content: \(uuid)")
                }
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    func fetchData(dateData: Date) -> (Date?, Int?, String?, UUID?) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Diary")
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy"
        let year = Int(dateFormatter.string(from: dateData))!
        
        dateFormatter.dateFormat = "M"
        let month = Int(dateFormatter.string(from: dateData))!
        
        dateFormatter.dateFormat = "d"
        let day = Int(dateFormatter.string(from: dateData))!

        var date : Date?
        var emoji : Int?
        var text : String?
        var uuid: UUID?
        
        // Calendar와 DateComponents를 이용하여 12월 조건을 설정
        let calendar = Calendar.current
        let startComponents = DateComponents(year: year, month: month, day: day, hour: 0, minute: 0, second: 0) // 원하는 연도와 월의 시작일
        let endComponents = DateComponents(year: year, month: month, day: day, hour: 23, minute: 59, second: 59) // 해당 월의 마지막일
        
        if let startDate = calendar.date(from: startComponents),
           let endDate = calendar.date(from: endComponents) {
            let predicate = NSPredicate(format: "date >= %@ AND date <= %@", startDate as NSDate, endDate as NSDate)
            fetchRequest.predicate = predicate
        }
        
        do {
            let results = try context.fetch(fetchRequest)
            //print("\(month)월 \(day)일 데이터 불러오기 성공")
            for result in results {
                if let _date = result.value(forKey: "date") as? Date {
                    print("Fetched date: \(_date)")
                    date = _date
                }
                if let _emoji = result.value(forKey: "emoji") as? Int {
                    print("Fetched emoji: \(_emoji)")
                    emoji = _emoji
                }
                if let _text = result.value(forKey: "text") as? String {
                    print("Fetched text: \(_text)")
                    text = _text
                }
                if let _uuid = result.value(forKey: "uuid") as? UUID {
                    print("Fetched uuid: \(_uuid)")
                    uuid = _uuid
                }
            }
        } catch {
            print("Error fetching December data: \(error)")
        }
        return (date, emoji, text, uuid)
    }
    
    func addNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(showDeleteToast), name: NSNotification.Name("showDeleteToast"), object: nil)
    }
    
    @objc func goSettingPage(){
        print("click")
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
        let data = fetchData(dateData: date)
        
        // 해당 일에 데이터가 있는 경우에만 데이터 set
        if data.0 != nil {
            cell.setCalendarCellData(_date: data.0!, _emoji: data.1, _text: data.2, _uuid: data.3!)
        }
        
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
        secondVC.data = fetchData(dateData: date)
        navigationController?.pushViewController(secondVC, animated: true)
        
        //self.present(secondVC, animated: true, completion: nil)
    }
}

extension DiaryMainViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
