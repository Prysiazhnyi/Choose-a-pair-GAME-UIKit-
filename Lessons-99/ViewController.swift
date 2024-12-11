//
//  ViewController.swift
//  Lessons-99
//
//  Created by Serhii Prysiazhnyi on 11.12.2024.
//

import UIKit

class ViewController: UICollectionViewController {
    
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Choose a pair"
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath! // Путь к папке ресурсов
        let items = try! fm.contentsOfDirectory(atPath: path) // Получение всех файлов в папке
        
        for item in items {
            // Проверяем, что файл имеет расширение .png
            if item.hasSuffix(".png") {
                // Путь к изображению
                let imagePath = "\(path)/\(item)"
                if let image = UIImage(contentsOfFile: imagePath) {
                    images.append(image) // Добавляем изображение в массив
                }
            }
        }
        
        print("Загружено \(images.count) изображений.")
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        
        return cell
    }
    
}
