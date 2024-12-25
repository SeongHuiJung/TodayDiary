//
//  EmojiViewController.swift
//  TodayDiary
//
//  Created by 정성희 on 12/23/24.
//

import UIKit

class EmojiCollectionView: UICollectionView {
    // none
}

class EmojiCell: UICollectionViewCell {
    
    var emojiImage: UIImageView!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpCell()
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpCell()
    }
    
    func setUpCell() {
        emojiImage = UIImageView()
        contentView.addSubview(emojiImage)
        emojiImage.translatesAutoresizingMaskIntoConstraints = false
        emojiImage.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        emojiImage.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor).isActive = true
        emojiImage.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor).isActive = true
        emojiImage.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor).isActive = true
    }
}

class EmojiViewController: UIViewController {
    
    private var customCollectionView: EmojiCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        registerCollectionView()
        collectionViewDelegate()
    }
    
    func configureCollectionView() {
        customCollectionView = EmojiCollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        customCollectionView.translatesAutoresizingMaskIntoConstraints = false
        customCollectionView.backgroundColor = UIColor(red: 1, green: 0.973, blue: 0.961, alpha: 1)
        self.view.addSubview(customCollectionView)
        customCollectionView.topAnchor.constraint(equalTo: view.topAnchor, constant: 120).isActive = true
        customCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 40).isActive = true
        customCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        customCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -40).isActive = true
    }
    
    func registerCollectionView() {
        customCollectionView.register(EmojiCell.classForCoder(), forCellWithReuseIdentifier: "emoji")
    }
    
    func collectionViewDelegate() {
        customCollectionView.delegate = self
        customCollectionView.dataSource = self
    }
    
}

extension EmojiViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = customCollectionView.dequeueReusableCell(withReuseIdentifier: "emoji", for: indexPath) as! EmojiCell
        cell.emojiImage.image = getEmoji(emoji: indexPath.row + 1)
        return cell
    }
    
    // 셀 클릭 시 호출되는 함수
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 노티피케이션 발송
        // 선택한 이모지 번호 object 로 전달
        NotificationCenter.default.post(name: NSNotification.Name("ClickEmojiNoti"), object: indexPath.row + 1, userInfo: nil)
    }
}
