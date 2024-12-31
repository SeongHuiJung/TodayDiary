//
//  ToastMessage.swift
//  TodayDiary
//
//  Created by 정성희 on 12/27/24.
//

import Foundation
import UIKit

func showToast(view : UIView , _ message : String, withDuration: Double, delay: Double) {
    let toastLabel = UILabel()
    let toastCheckImage = UIImageView()
    let toastBackground = UIView()
    
    print("???")
    
    // toastBackground
    toastBackground.frame = CGRect(x: 0, y: 0, width: 162, height: 32)
    toastBackground.layer.backgroundColor = UIColor(red: 0.739, green: 0.59, blue: 0.59, alpha: 1).cgColor
    toastBackground.layer.cornerRadius = 15
    view.addSubview(toastBackground)
    toastBackground.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        toastBackground.topAnchor.constraint(equalTo: view.topAnchor, constant: 75),
        toastBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 116),
        toastBackground.widthAnchor.constraint(equalToConstant: 162),
        toastBackground.heightAnchor.constraint(equalToConstant: 32)
    ])
    
    
    
    // toastLabel
    toastLabel.frame = CGRect(x: 0, y: 0, width: 113, height: 23)
    toastLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    toastLabel.font = UIFont(name: "AppleSDGothicNeo-Light", size: 14)
    toastLabel.text = message
    toastLabel.textAlignment = .center
    toastBackground.addSubview(toastLabel)
    toastLabel.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        toastLabel.centerYAnchor.constraint(equalTo: toastBackground.centerYAnchor),
        toastLabel.leadingAnchor.constraint(equalTo: toastBackground.leadingAnchor, constant: 33),
        toastLabel.widthAnchor.constraint(equalToConstant: 113),
        toastLabel.heightAnchor.constraint(equalToConstant: 23)
    ])
    
    
    
    // toastCheckImage
    toastCheckImage.frame = CGRect(x: 0, y: 0, width: 22, height: 22)
    toastCheckImage.layer.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
    toastCheckImage.image = UIImage(named: "toastMessageImage")
    toastBackground.addSubview(toastCheckImage)
    toastCheckImage.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
        toastCheckImage.centerYAnchor.constraint(equalTo: toastBackground.centerYAnchor),
        toastCheckImage.leadingAnchor.constraint(equalTo: toastBackground.leadingAnchor, constant: 6),
        toastCheckImage.widthAnchor.constraint(equalToConstant: 22),
        toastCheckImage.heightAnchor.constraint(equalToConstant: 22)
    ])
    
    
    
    
    UIView.animate(withDuration: withDuration, delay: delay, options: .curveEaseOut, animations: {
        toastBackground.alpha = 0.0
    }, completion: {(isCompleted) in
        toastBackground.removeFromSuperview()
    })
}
