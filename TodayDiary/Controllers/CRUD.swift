//
//  CRUD.swift
//  TodayDiary
//
//  Created by 정성희 on 12/27/24.
//

import Foundation
import CoreData

// MARK: - CLUD
//func updateData(id: UUID, context: NSManagedObjectContext?) {
//    guard let context = context else { return }
//    let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Diary")
//    fetchRequest.predicate = NSPredicate(format: "uuid = %@", id.uuidString)
//    
//    do {
//        guard let result = try? context.fetch(fetchRequest),
//              let object = result.first as? NSManagedObject else { return }
//        
//        if let selectedEmoji = selectedEmoji {
//            object.setValue(selectedEmoji, forKey: "emoji")
//        }
//        else {
//            object.setValue(data.1! , forKey: "emoji")
//        }
//        //object.setValue(selectedEmoji!, forKey: "emoji") // error!
//        
//        if textView.textColor == UIColor(red: 0.653, green: 0.653, blue: 0.653, alpha: 1) {
//            object.setValue("", forKey: "text")
//        }
//        else {
//            object.setValue(textView.text, forKey: "text")
//        }
//        try context.save()
//    } catch {
//        print("error: \(error.localizedDescription)")
//    }
//    showToast(view: view, "저장에 성공했어요 :)", withDuration: 2.0, delay: 1.5)
//}
//func createData() {
//    guard let context = context else { return }
//    guard let entityDescription = NSEntityDescription.entity(forEntityName: "Diary", in: context) else {
//        print("Error: Entity 'Diary' not found in the model")
//        return
//    }
//    
//    // DateFormatter 설정
//    let formatter = DateFormatter()
//    formatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일
//    formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // 한국 시간대
//    formatter.dateFormat = "yyyy년 MM월 dd일 HH:mm:ss"
//    
//    // 문자열에 시간 추가 (자정 기준)
//    let dateLabelWithTime = "\(dateLabel.text!) 00:00:00"
//    
//    // 문자열을 Date로 변환
//    let koreaDate = formatter.date(from: dateLabelWithTime)
//    
//    let diary = NSManagedObject(entity: entityDescription, insertInto: context)
//    diary.setValue(koreaDate, forKey: "date")
//    
//    if textView.textColor == UIColor(red: 0.653, green: 0.653, blue: 0.653, alpha: 1) {
//        diary.setValue("", forKey: "text")
//    }
//    else {
//        diary.setValue(textView.text, forKey: "text") // error!
//    }
//    
//    diary.setValue(selectedEmoji!, forKey: "emoji") // error!
//    let uuid = UUID()
//    diary.setValue(uuid, forKey: "uuid")
//    
//    // 새로운 데이터 생성후, 그 페이지에서 바로 데이터를 또 저장할 경우
//    // 새로운 데이터를 다시 생성하지 않고 수정으로 로드하기 위해 uuid 설정
//    data.3 = uuid
//    
//    do {
//        try context.save()
//        print("Data saved successfully!")
//    } catch {
//        print("Error saving data: \(error)")
//    }
//    
//    showToast(view: view, "저장에 성공했어요 :)", withDuration: 2.0, delay: 1.5)
//}
//func deleteData(id: UUID) {
//    guard let context = context else { return }
//    let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Diary")
//    fetchRequest.predicate = NSPredicate(format: "uuid = %@", id.uuidString)
//    
//    do {
//        guard let result = try? context.fetch(fetchRequest),
//              let object = result.first as? NSManagedObject else { return }
//        context.delete(object)
//        
//        try context.save()
//    } catch {
//        print("error: \(error.localizedDescription)")
//    }
//}
