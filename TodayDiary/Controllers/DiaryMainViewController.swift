//
//  DiaryMainViewController.swift
//  TodayDiary
//
//  Created by 정성희 on 12/12/24.
//

import UIKit
import CoreData

class DiaryMainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAllData()
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
