//
//  CoreDataManager.swift
//  TodayDiary
//
//  Created by 정성희 on 1/5/25.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    var isRegistered: Int?

    private init() {}

    lazy var persistentContainer: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "TodayDiary")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            // 충돌 해결 정책 및 자동 병합 설정
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            container.viewContext.automaticallyMergesChangesFromParent = true
        })
        return container
    }()

    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Diary Entity Methods
    func createDiary(date: Date, text: String, emoji: Int, uuid: UUID, closure : () -> ()) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Diary", in: context) else {
            print("Error: Entity 'Diary' not found in the model")
            return
        }
        let diary = NSManagedObject(entity: entityDescription, insertInto: context)
        diary.setValue(date, forKey: "date")
        diary.setValue(text, forKey: "text")
        diary.setValue(emoji, forKey: "emoji")
        diary.setValue(uuid, forKey: "uuid")
        saveContext()
        
        closure()
        print("일기 데이터 생성 성공 ! :)")
    }
    
    func updateDiary(id: UUID, text: String, emoji: Int, closure: () -> ()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Diary")
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", id.uuidString)
        
        do {
            guard let result = try? context.fetch(fetchRequest),
                  let object = result.first as? NSManagedObject else { return }
            
            object.setValue(text, forKey: "text")
            object.setValue(emoji, forKey: "emoji")

            try context.save()
            
            closure()
            print("일기 데이터 업데이트 성공 ! :)")
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    func loadDiary(dateData: Date) -> (Date?, Int?, String?, UUID?) {
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
        
        // Calendar와 DateComponents를 이용하여 N월 조건을 설정
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
                    //print("Fetched date: \(_date)")
                    date = _date
                }
                if let _emoji = result.value(forKey: "emoji") as? Int {
                    //print("Fetched emoji: \(_emoji)")
                    emoji = _emoji
                }
                if let _text = result.value(forKey: "text") as? String {
                    //print("Fetched text: \(_text)")
                    text = _text
                }
                if let _uuid = result.value(forKey: "uuid") as? UUID {
                    //print("Fetched uuid: \(_uuid)")
                    uuid = _uuid
                }
            }
        } catch {
            print("Error fetching December data: \(error)")
        }
        return (date, emoji, text, uuid)
    }
    
    func deleteDiary(id: UUID) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Diary")
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", id.uuidString)
        
        do {
            guard let result = try? context .fetch(fetchRequest),
                  let object = result.first as? NSManagedObject else { return }
            context.delete(object)
            
            try context.save()
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
    
    // 디버깅 전용 함수
    // Diary Container 의 모든 데이터 로드
    func fetchAllDiary() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Diary")
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
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
    
    // 로컬의 모든 데이터 저장
    // 엔티티 존재하면 수정, 존재하지 않으면 생성
    // 이후에 수정
    func fetchAllDiaryAndSaveOrUpdate() {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Diary")
        do {
            let results = try context.fetch(fetchRequest)
            for result in results {
                var save_date = Date()
                var save_emoji = 1
                var save_text = ""
                var save_uuid = UUID()
                
                if let date = result.value(forKey: "date") as? Date {
                    print("Fetched title: \(date)")
                    save_date = date
                }
                if let emoji = result.value(forKey: "emoji") as? Int {
                    print("Fetched content: \(emoji)")
                    save_emoji = emoji
                }
                if let text = result.value(forKey: "text") as? String {
                    print("Fetched content: \(text)")
                    save_text = text
                }
                if let uuid = result.value(forKey: "uuid") as? UUID {
                    print("Fetched content: \(uuid)")
                    save_uuid = uuid
                }
                
                // 같은 날짜의 엔티티가 있는지 확인
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Diary")
                fetchRequest.predicate = NSPredicate(format: "date == %@", save_date as CVarArg)
                do {
                    let result = try context.fetch(fetchRequest)
                    // 같은 날짜의 엔티티 존재 -> 업데이트 해야함
                    if !result.isEmpty {
                        updateDiary(id: save_uuid, text: save_text, emoji: save_emoji) {
                        }
                    }
                    // 같은 날짜의 엔티티 존재x -> 생성 해야함
                    else {
                    }
                } catch {
                    print("Error: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    // MARK: - AccountInfo Entity Methods
    func fetchIsRegistered() {
        isRegistered = loadIsRegistered()
        print("isRegistered: \(isRegistered)")
    }

    func loadIsRegistered() -> Int? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "AccountInfo")
        do {
            // 모든 AccountInfo 엔터티 가져오기
            let results = try context.fetch(fetchRequest)
                     
            for result in results {
                if let isRegistered = result.value(forKey: "isRegistered") as? Bool {
                    print("isRegistered date: \(isRegistered)")
                    return 1
                }
            }
            print("isRegistered 데이터가 없음") // = 가입한 적이 없거나, 탈퇴한 계정
            return nil
        } catch {
            // 에러 처리 해야함
            print("연결실패 Error fetching isRegistered data: \(error)")
            return nil
        }
    }

    
    // 첫 가입 -> 1 로 생성
    // 탈퇴시 -> 삭제
    // 1 -> 가입된 상태
    // nil -> 탈퇴 또는 가입한적 없는 신규회원
    func setTrueIsRegistered() {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "AccountInfo", in: context) else {
            print("Error: Entity 'AccountInfo' not found in the model")
            return
        }
        let diary = NSManagedObject(entity: entityDescription, insertInto: context)
        diary.setValue(1, forKey: "isRegistered")
        saveContext()
        
        print("true 로 저장 성공")
    }
    
    func deleteIsRegistered() {
        let entityNames = context.persistentStoreCoordinator?.managedObjectModel.entities.compactMap { $0.name } ?? []
        do {
            for entityName in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                // Execute batch delete
                try context.execute(deleteRequest)
            }
            
            // Save context after deletion
            try context.save()
            print("IsRegistered 가 성공적으로 삭제되었습니다.")
        } catch {
            print("IsRegistered를 삭제하는 중 오류 발생: \(error.localizedDescription)")
        }
    }

    // MARK: - Save Context
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
