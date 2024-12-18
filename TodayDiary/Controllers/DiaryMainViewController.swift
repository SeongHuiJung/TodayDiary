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
    
    @IBOutlet weak var calendarView: FSCalendar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        fetchAllData()
        
        // 프로토콜 연결
        calendarView.delegate = self
        calendarView.dataSource = self
        
        calendarView.placeholderType = .fillSixRows
        
        // 커스텀 셀 등록 (CalendarCell 클래스는 밑에서 구현)
        calendarView.register(CalendarCell.self, forCellReuseIdentifier: "CalendarCell")
        
        setCalendarDesign(calendarView: calendarView)
    }
    
    func fetchAllData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Diary")
        do {
            let results = try context.fetch(fetchRequest)
            print("불러오기 성공")
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
    
    @IBAction func tappedAddDataBtn(_ sender: UIButton) {
        
        guard let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
            print("Error: Managed Object Context is nil")
            return
        }
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Diary", in: context) else {
            print("Error: Entity 'Diary' not found in the model")
            return
        }
        
        let diary = NSManagedObject(entity: entityDescription, insertInto: context)
        diary.setValue(Date(), forKey: "date")
        diary.setValue(1, forKey: "emoji")
        diary.setValue("시뮬레이터 데이터 추가!", forKey: "text")
        diary.setValue(UUID(), forKey: "uuid")
        
        do {
            try context.save()
            print("Data saved successfully!")
        } catch {
            print("Error saving data: \(error)")
        }
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
        
        
        
//        if position == .current {
//            let day = Calendar.current.component(.day, from: date)
//            cell.configure(with: "\(day)") // 셀에 날짜를 표시
//            
//            cell.isHidden = false // 현재 월 날짜는 보이게 설정
//        } else {
//            // 이전 달 및 다음 달의 셀은 숨김
//            cell.isHidden = true
//        }
        return cell
    }

    
    // 셀 클릭시
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 일기 작성 페이지로 이동
        guard let secondVC = storyboard?.instantiateViewController(withIdentifier: "WriteDiaryViewController") as? WriteDiaryViewController else { return }
        secondVC.modalPresentationStyle = .fullScreen
        
        // 데이터 전달
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        secondVC.dateString = dateFormatter.string(from: date)
        
        self.present(secondVC, animated: true, completion: nil)
    }
}
