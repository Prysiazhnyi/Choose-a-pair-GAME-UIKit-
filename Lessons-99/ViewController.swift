//
//  ViewController.swift
//  Lessons-99
//
//  Created by Serhii Prysiazhnyi on 11.12.2024.
//

import UIKit

class ViewController: UICollectionViewController {
    
    var images = [imageViewStruct]()
    var imagesPlay = [imageViewStruct]()
    //var id = NSUUID().uuidString
    
    var firstSelectedIndex: IndexPath?
    var secondSelectedIndex: IndexPath?
    var isFirstSelection = true // Для определения первой ли это выборки
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Choose a pair"
        
        loadImages()
        imageRandom()
    }
    
    func loadImages() {
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath! // Путь к папке ресурсов
        let items = try! fm.contentsOfDirectory(atPath: path) // Получение всех файлов в папке
        
        for item in items {
            // Проверяем, что файл имеет расширение .png
            if item.hasSuffix(".png") {
                // Путь к изображению
                let imagePath = "\(path)/\(item)"
               //id = NSUUID().uuidString
                if let image = UIImage(contentsOfFile: imagePath) {
                    let imageStruct = imageViewStruct(id: UUID().uuidString, imageStruct: image)
                    images.append(imageStruct) // Добавляем изображение в массив
                }
            }
        }
        
        print("Загружено \(images.count) изображений.")
    }
    
    func imageRandom() {
        // Пока в массиве imagesPlay меньше 4 элементов
        while imagesPlay.count < 8 {
            // Получаем случайный элемент из массива images
            if let randomImage = images.randomElement(), let index = images.firstIndex(where: { $0.id == randomImage.id }) {
                // Добавляем его в массив imagesPlay
                imagesPlay.append(randomImage)
                imagesPlay.append(randomImage)
                // Удаляем добавленный элемент из массива images
                images.remove(at: index)
            }
        }
        print("В массиве imagePlay \(imagesPlay.count) элементов.")
        
        // Дублируем элементы, чтобы создать пары
        //imagesPlay = tempImagePlay + tempImagePlay
        
        //imagesPlay += imagesPlay
        
        // Перемешиваем массив
        imagesPlay.shuffle()
        print("В массиве imagePlay после дублирования \(imagesPlay.count) элементов.")
        print("В массиве imageы ОСТАЛОСЬ \(images.count) элементов.")
        
        // Обновляем коллекцию
        collectionView.reloadData()
    }
    
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesPlay.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            let imageStruct = imagesPlay[indexPath.item]
                   imageView.image = imageStruct.shown ? imageStruct.imageStruct : nil // Показываем или скрываем
               }
        
        // Добавляем обработку выбора ячейки
        cell.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_:)))
        cell.addGestureRecognizer(tapGesture)
        
        return cell
    }
    
    @objc func cellTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedCell = sender.view as? UICollectionViewCell else { return }
        guard let indexPath = collectionView.indexPath(for: tappedCell) else { return }
        
        print("indexPath  -- \(indexPath)")
        
        // Если это первый выбор
        if isFirstSelection {
            firstSelectedIndex = indexPath
            isFirstSelection = false
        } else {
            
            if indexPath == firstSelectedIndex {
                print("Нельзя выбрать ту же ячейку дважды!")
                firstSelectedIndex = nil
                secondSelectedIndex = nil
                isFirstSelection = true
                return
            }
            
            secondSelectedIndex = indexPath
            // Проверяем на совпадение
            checkMatch()
            isFirstSelection = true
        }
    }
    
    /// Метод для проверки выбранных элементов на совпадение
    func checkMatch() {
        guard let firstIndex = firstSelectedIndex, let secondIndex = secondSelectedIndex else {
            return
        }
        
        let firstImage = imagesPlay[firstIndex.item]
        let secondImage = imagesPlay[secondIndex.item]
        
        if firstImage.id == secondImage.id {
            print("Пары совпали!")
            
            // Удаляем элементы с совпадающим id
            let targetId = firstImage.id
            imagesPlay.removeAll { $0.id == targetId }
            
            print("imagesPlay тут осталось - \(imagesPlay.count) элементов.")
            
           //collectionView.reloadData()
            // Обновляем коллекцию с анимацией
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [firstIndex, secondIndex])
            }, completion: nil)
            
            if imagesPlay.isEmpty {
                if !images.isEmpty
                {
                    imageRandom()
                    print("В ролительском массиве больше нет изображений")
                }
                print("Массив пустой, игра закончена \(imagesPlay.count)")
            }
        } else {
            print("Пары не совпали.")
            // Логика для скрытия изображений
        }
        // Сбрасываем выбор
        firstSelectedIndex = nil
        secondSelectedIndex = nil
        isFirstSelection = true
    }
}
