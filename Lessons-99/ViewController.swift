//
//  ViewController.swift
//  Lessons-99
//
//  Created by Serhii Prysiazhnyi on 11.12.2024.
//

import UIKit

class ViewController: UICollectionViewController {
    
    var images = [UIImage]()
    var imagesPlay = [UIImage]()
    
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
                if let image = UIImage(contentsOfFile: imagePath) {
                    images.append(image) // Добавляем изображение в массив
                }
            }
        }
        
        print("Загружено \(images.count) изображений.")
    }
    
    func imageRandom() {
        // Пока в массиве imagesPlay меньше 4 элементов
        while imagesPlay.count < 8 {
            // Получаем случайный элемент из массива images
            if let randomImage = images.randomElement(), let index = images.firstIndex(of: randomImage) {
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
            imageView.image = imagesPlay[indexPath.item]
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
        
        print(" firstImage ---\(firstIndex.item) ;  secondImage----\(secondIndex.item)")
        
        if firstImage == secondImage {
            print("Пары совпали!")
            if !imagesPlay.isEmpty {
            // Удаляем изображения из массива imagesPlay
            imagesPlay.remove(at: firstIndex.item)
            imagesPlay.remove(at: secondIndex.item)
            //imagesPlay.removeAll { $0 == firstImage }
            print("imagesPlay тут осталось -\(imagesPlay.count)")
            // Обновляем коллекцию, удаляя элементы с анимацией
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: [firstIndex, secondIndex])
            }, completion: nil)
            
            //if !images.isEmpty {
              //  imageRandom()
                collectionView.reloadData()
            }
            
        } else {
            print("Пары не совпали.")
            // Можно скрыть их (или вернуть на исходное состояние)
        }
        
        // Сбрасываем выбор
        firstSelectedIndex = nil
        secondSelectedIndex = nil
        isFirstSelection = true
    }
}
