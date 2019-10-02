//
//  QuestionViewController.swift
//  Sports.ru
//
//  Created by Yaroslav on 9/29/19.
//  Copyright © 2019 Mountain Viewer. All rights reserved.
//

import UIKit

struct QuestionModel {
    var question: String?
    var questionText: String?
    var totalQuestions: String?
    var questionImage: UIImage?
    
    var option1: String?
    var option2: String?
    var option3: String?
    var option4: String?
    
    var correctOption: String?
    var isLast: Bool?
    var mainViewController: QuestionViewController?
    var topViewController: UIViewController?
}

class QuestionViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateDataSource()
        configure()
    }
    
    var topViewController: UIViewController?
    var teamName: String?
    var currentViewControllerIndex = 0
    var dataSource: [QuestionModel] = []
    
    var questions = ["Вопрос 1", "Вопрос 2", "Вопрос 3", "Вопрос 4", "Вопрос 5"]
    var questionImages = ["captain", "stadium", "goal", "rivals", "manager"]
    var totalQuestions = "/5"
    
    // Mocks
    var questionTexts = ["Кто является капитаном команды ",
                         "Какова вместительность стадиона команды ",
                         "Кто является лучшим бомбардиром команды ",
                         "Сколько раз ",
                         "Кто является тренером команды "]
    
    var options1 = ["Я", "Я", "Я", "Я", "Я"]
    var options2 = ["Ты", "Ты", "Ты", "Ты", "Ты"]
    var options3 = ["Мы", "Мы", "Мы", "Мы", "Мы"]
    var options4 = ["Вы", "Вы", "Вы", "Вы", "Вы"]
    var correctOptions = ["Я", "Ты", "Мы", "Вы", "Я"]
    
    var result = 0
    
    func populateDataSource() {
        for i in 0..<questions.count {
            guard let questionImage = UIImage(named: questionImages[i]) else {
                continue
            }
            
            let isLast = (i + 1) == questions.count
            
            dataSource.append(QuestionModel(question: questions[i],
                                            questionText: questionTexts[i],
                                            totalQuestions: totalQuestions,
                                            questionImage: questionImage,
                                            option1: options1[i],
                                            option2: options2[i],
                                            option3: options3[i],
                                            option4: options4[i],
                                            correctOption: correctOptions[i],
                                            isLast: isLast,
                                            mainViewController: self,
                                            topViewController: topViewController))
        }
    }
    
    func configure() {
        guard let pageViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: QuestionPageViewController.self)) as? QuestionPageViewController else {
            return
        }
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(pageViewController.view)
        
        let views : [String : Any] = ["pageView" : pageViewController.view as Any]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[pageView]-0-|",
                                                                  options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                  metrics: nil,
                                                                  views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[pageView]-0-|",
                                                                  options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                                  metrics: nil,
                                                                  views: views))
        
        guard let startingViewController = detailViewControllerAt(index: currentViewControllerIndex) else {
            return
        }
        
        pageViewController.setViewControllers([startingViewController], direction: .forward, animated: false)
        
    }
    
    func detailViewControllerAt(index: Int) -> QuestionDataViewController? {
        
        if currentViewControllerIndex >= dataSource.count || dataSource.count == 0 {
            return nil
        }
        
        guard let dataViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: QuestionDataViewController.self)) as? QuestionDataViewController else {
            return nil
        }
        
        if index < 0 || index >= dataSource.count {
            return nil
        }
        
        dataViewController.index = index
        dataViewController.questionModel = dataSource[index]
        
        return dataViewController
    }
}

extension QuestionViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentViewControllerIndex
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return dataSource.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let dataViewController = viewController as? QuestionDataViewController
        guard var currentIndex = dataViewController?.index,
            let answerSelected = dataViewController?.answerSelected else {
            return nil
        }
        
        if currentIndex == dataSource.count - 1 {
            return nil
        }
        
        currentViewControllerIndex = currentIndex
        currentIndex += 1
        
        return detailViewControllerAt(index: currentIndex)
    }
}
