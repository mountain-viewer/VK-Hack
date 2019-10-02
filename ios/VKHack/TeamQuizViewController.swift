//
//  TeamQuizViewController.swift
//  Sports.ru
//
//  Created by Yaroslav on 9/28/19.
//  Copyright © 2019 Mountain Viewer. All rights reserved.
//

import UIKit

struct QuizModel {
    var teamName: String?
    var teamLogo: UIImage?
    var quizDescription: String?
}

class TeamQuizViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        populateDataSource()
        configure()
    }
    
    var currentViewControllerIndex = 0
    
    var dataSource: [QuizModel] = []
    var teamNames = ["ПФК Арсенал", "ФК Ахмат", "ФК Динамо Москва", "ФК Зенит", "ФК Краснодар", "ПФК Крылья Советов", "ФК Локомотив", "ФК Оренбург", "ФК Ростов", "ФК Рубин", "ФК Сочи", "ФК Спартак-Москва", "ФК Тамбов", "ФК Урал", "ФК Уфа", "ПФК ЦСКА"]
    var teamLogoPaths = [""]
    var imagePaths = ["ПФК Арсенал" : "arsenal_logo.png",
                      "ФК Ахмат" : "akhmat_logo.png",
                      "ФК Динамо Москва" : "dinamo_logo.png",
                      "ФК Зенит" : "zenit_logo.png",
                      "ФК Краснодар" : "krasnodar_logo.png",
                      "ПФК Крылья Советов" : "ks_logo.png",
                      "ФК Локомотив" : "lokomotiv_logo.png",
                      "ФК Оренбург" : "orenburg_logo.png",
                      "ФК Ростов" : "rostov_logo.png",
                      "ФК Рубин" : "rubin_logo.png",
                      "ФК Сочи" : "sochi_logo.png",
                      "ФК Спартак-Москва" : "spartak_logo.png",
                      "ФК Тамбов" : "tambov_logo.png",
                      "ФК Урал" : "ural_logo.png",
                      "ФК Уфа" : "ufa_logo.png",
                      "ПФК ЦСКА" : "cska_logo.png"
    ]
    
    func configure() {
        guard let pageViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: TeamQuizPageViewController.self)) as? TeamQuizPageViewController else {
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
        
        pageViewController.setViewControllers([startingViewController], direction: .forward, animated: true)
        
    }
    
    func detailViewControllerAt(index: Int) -> TeamQuizDataViewController? {
        
        if currentViewControllerIndex >= dataSource.count || dataSource.count == 0 {
            return nil
        }
        
        guard let dataViewController = storyboard?.instantiateViewController(withIdentifier: String(describing: TeamQuizDataViewController.self)) as? TeamQuizDataViewController else {
            return nil
        }
        
        dataViewController.index = index
        dataViewController.teamQuiz = dataSource[index]
        
        return dataViewController
    }
    
    func populateDataSource() {
        for teamName in teamNames {
            guard let teamLogo = imagePaths[teamName] else {
                continue
            }
            
            dataSource.append(QuizModel(teamName: teamName,
                                        teamLogo: UIImage(named: teamLogo),
                                        quizDescription: generateQuizDescription(for: teamName)))
        }
    }
    
    func generateQuizDescription(for teamName: String) -> String {
        return "Проверь свои знания и узнай, насколько хорошо ты знаешь " + teamName
    }
}

extension TeamQuizViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentViewControllerIndex
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return dataSource.count
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let dataViewController = viewController as? TeamQuizDataViewController
        guard var currentIndex = dataViewController?.index else {
            return nil
        }
        
        currentViewControllerIndex = currentIndex
        
        if currentIndex == 0 {
            return nil
        }
        
        currentIndex -= 1
        
        return detailViewControllerAt(index: currentIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let dataViewController = viewController as? TeamQuizDataViewController
        guard var currentIndex = dataViewController?.index else {
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
