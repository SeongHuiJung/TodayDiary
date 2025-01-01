//
//  DeleteDiaryViewController.swift
//  TodayDiary
//
//  Created by 정성희 on 12/27/24.
//

import UIKit
import CoreData

class DeleteDiaryViewController: UIViewController {
    var uuid : UUID?
    var writeDiaryVC : UIViewController?
    
    private let context: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate? else {
            print("AppDelegate가 초기화되지 않았습니다.")
            return nil
        }
        return appDelegate?.persistentContainer.viewContext
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
        
        
    }
    
    func setUUID(uuid: UUID) {
        self.uuid = uuid
    }
    
    func setUI() {
        let buttonView = UIView()
        buttonView.backgroundColor = UIColor(red: 1, green: 0.973, blue: 0.961, alpha: 1)
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(buttonView)
        
        // Auto Layout 설정
        NSLayoutConstraint.activate([
            buttonView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -49),
            buttonView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonView.heightAnchor.constraint(equalToConstant: 67)
        ])
        
        // UIView에 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteBtnTapped))
        buttonView.addGestureRecognizer(tapGesture)
        
        // UIView가 사용자와 상호작용 가능하도록 설정
        buttonView.isUserInteractionEnabled = true
        
        
        let label = UILabel()
        label.textColor = UIColor(red: 0.565, green: 0.478, blue: 0.478, alpha: 1)
        label.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 18)
        label.text = "일기 삭제"
        label.textAlignment = .center
        buttonView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 50)
        ])
        
        let trashcan = UIImageView()
        trashcan.frame = CGRect(x: 0, y: 0, width: 15, height: 19)
        trashcan.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        trashcan.image = UIImage(named: "trashcan")
        buttonView.addSubview(trashcan)
        trashcan.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            trashcan.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor),
            trashcan.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 15),
            trashcan.widthAnchor.constraint(equalToConstant: 22),
            trashcan.heightAnchor.constraint(equalToConstant: 22)
        ])
    }
    
    @objc func deleteBtnTapped() {
        // 일기 삭제 버튼 bottom sheet 내리고,
        // 부모 뷰 컨트롤러에서 popVC를 present
        if let parentVC = self.presentingViewController {
            self.dismiss(animated: false) {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let popVC = storyboard.instantiateViewController(withIdentifier: "PopUpViewController") as? PopUpViewController else {
                    print("Failed to instantiate or cast PopUpViewController")
                    return
                }
                
                // 데이터 전달
                popVC.markImageName = "exclamatio-mark"
                popVC.infoText = "일기를 삭제하시겠어요?"
                popVC.cancelBtnText = "취소"
                popVC.acceptBtnText = "삭제"
                
                // 클로저 전달
                // 데이터 최종삭제 확인버튼 누를시 해당 함수 실행
                popVC.onAcceptAction = {
                    self.deleteData(id: self.uuid!)
                    parentVC.dismiss(animated: false)
                    NotificationCenter.default.post(name: NSNotification.Name("backToMainVC"), object: nil, userInfo: nil)
                }
                
                popVC.modalPresentationStyle = .overFullScreen
                parentVC.present(popVC, animated: false, completion: nil)
            }
        }
    }
    
    func deleteData(id: UUID) {
        guard let context = context else { return }
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Diary")
        fetchRequest.predicate = NSPredicate(format: "uuid = %@", id.uuidString)
        
        do {
            guard let result = try? context.fetch(fetchRequest),
                  let object = result.first as? NSManagedObject else { return }
            context.delete(object)
            
            try context.save()
        } catch {
            print("error: \(error.localizedDescription)")
        }
    }
}
