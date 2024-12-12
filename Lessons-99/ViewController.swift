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
    var questionTempView = [UIImage]()
    
    var firstSelectedIndex: IndexPath?
    var secondSelectedIndex: IndexPath?
    var isFirstSelection = true // Для определения первой ли это выборки
    
    // UIBarButtonItem для отображения счета
    var scoreButton: UIBarButtonItem!
    var score = 0 {
        didSet {
            // Обновляем UIBarButtonItem при изменении счета
            scoreButton.title = "Score: \(score)"
        }
    }
    
    // UIBarButtonItem для отображения счета
    var pairButton: UIBarButtonItem!
    var pairs = 0 {
        didSet {
            // Обновляем UIBarButtonItem при изменении счета
            pairButton.title = "Pairs Left: \(pairs)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Choose a pair"
        
        scoreButton = UIBarButtonItem(title: "Score: 0", style: .plain, target: self, action: nil)
        pairButton = UIBarButtonItem(title: "Pairs Left: 0", style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = scoreButton
        navigationItem.leftBarButtonItem = pairButton
        
        loadQuestionImages()
        loadImages()
        imageRandom()
        
    }
    
    func loadImages() {
        
        let fm = FileManager.default
        let path = Bundle.main.resourcePath! // Путь к папке ресурсов
        let items = try! fm.contentsOfDirectory(atPath: path) // Получение всех файлов в папке
        
        for item in items {
            // Проверяем, что файл имеет расширение .png
            if item.hasSuffix("-@2x.png") {
                // Путь к изображению
                let imagePath = "\(path)/\(item)"
                if let image = UIImage(contentsOfFile: imagePath) {
                    let imageStruct = imageViewStruct(id: UUID().uuidString, imageStruct: image, questionView: questionTempView.first)
                    images.append(imageStruct) // Добавляем изображение в массив
                    pairs = images.count
                }
            }
        }
        
        print("Загружено \(images.count) изображений.")
    }
    
    func loadQuestionImages() {
        if let image = UIImage(named: "questionView") {
            questionTempView.append(image)
        }
        print("Загружено \(questionTempView.count) изображений.")
    }
    
    func imageRandom() {
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
        
        // Перемешиваем массив
        imagesPlay.shuffle()
        collectionView.reloadData()
        print("В массиве imagePlay после дублирования \(imagesPlay.count) элементов.")
        print("В массиве imageы ОСТАЛОСЬ \(images.count) элементов.")
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesPlay.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            let imageStruct = imagesPlay[indexPath.item]
            imageView.image = imageStruct.shown ? imageStruct.imageStruct : imageStruct.questionView // Показываем или скрываем
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
        
        animatingView(tappedCell: tappedCell, indexPath: indexPath)
        
        // Если это первый выбор
        if isFirstSelection {
            firstSelectedIndex = indexPath
            isFirstSelection = false
        } else {
            
            if indexPath == firstSelectedIndex {
                resetSelection()
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
            score += 1
            pairs -= 1
            
            // Ожидаем завершения анимации второй карточки
            if let secondCell = collectionView.cellForItem(at: secondIndex),
               let secondImageView = secondCell.viewWithTag(1000) as? UIImageView {
                UIView.transition(with: secondImageView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                    secondImageView.image = secondImage.imageStruct
                }, completion: { _ in
                    // После завершения анимации удаляем элементы
                    self.collectionView.performBatchUpdates({
                        self.imagesPlay.removeAll { $0.id == firstImage.id }
                        self.collectionView.deleteItems(at: [firstIndex, secondIndex])
                    }, completion: nil)
                    
                    if self.imagesPlay.isEmpty && !self.images.isEmpty {
                        self.imageRandom()
                    }
                    
                    if self.pairs == 0 {
                        self.showGameOverAlert()
                    }
                })
            }
        } else {
            print("Пары не совпали.")
            if score != 0 {
                score -= 1
            }
            
            // Запланировать переворот карточек обратно
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.flipCard(at: firstIndex) // Переворот первой карточки обратно
                self.flipCard(at: secondIndex) // Переворот второй карточки обратно
            }
        }
        resetSelection()
    }
    
    /// Сбрасываем выбор/
    func resetSelection() {
        firstSelectedIndex = nil
        secondSelectedIndex = nil
        isFirstSelection = true
    }
    
    func showGameOverAlert() {
        let alert = UIAlertController(
            title: "Game Over",
            message: "Your final score is \(score). Would you like to play again?",
            preferredStyle: .alert
        )
        let restartAction = UIAlertAction(title: "Play Again", style: .default) { [weak self] _ in
            self?.restartGame()
        }
        alert.addAction(restartAction)
        present(alert, animated: true, completion: nil)
    }
    /// Перезапуск игрs: сброс счетчиков и обновляем изображения/
    func restartGame() {
        
        score = 0
        images = []
        imagesPlay = []
        loadImages()
        imageRandom()
        collectionView.reloadData()
    }
    
    func animatingView(tappedCell: UICollectionViewCell, indexPath: IndexPath) {
        var imageStruct = imagesPlay[indexPath.item]
        
        // Инвертируем состояние `shown`
        imageStruct.shown.toggle()
        imagesPlay[indexPath.item] = imageStruct
        
        // Анимация переворота
        if let imageView = tappedCell.viewWithTag(1000) as? UIImageView {
            let newImage = imageStruct.shown ? imageStruct.imageStruct : imageStruct.questionView
            UIView.transition(with: imageView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                imageView.image = newImage
            })
        }
    }
    
    func flipCard(at indexPath: IndexPath) {
        // Инвертируем состояние "shown"
        imagesPlay[indexPath.item].shown.toggle()
        
        if let cell = collectionView.cellForItem(at: indexPath),
           let imageView = cell.viewWithTag(1000) as? UIImageView {
            
            let newImage = imagesPlay[indexPath.item].shown
            ? imagesPlay[indexPath.item].imageStruct
            : imagesPlay[indexPath.item].questionView
            
            // Анимация переворота
            UIView.transition(with: imageView, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                imageView.image = newImage
            })
        }
    }
}
