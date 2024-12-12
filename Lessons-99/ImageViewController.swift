//
//  ImageViewController.swift
//  Lessons-99
//
//  Created by Serhii Prysiazhnyi on 12.12.2024.
//

import UIKit

/// Структура свойств изображения
struct imageViewStruct {
    
    var id: String
    var shown: Bool = true
    var imageStruct: UIImage!
    
    static func == (lhs: imageViewStruct, rhs: imageViewStruct) -> Bool {
        return lhs.id == rhs.id
    }
}
