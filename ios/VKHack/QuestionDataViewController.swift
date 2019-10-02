//
//  QuestionDataViewController.swift
//  Sports.ru
//
//  Created by Yaroslav on 9/28/19.
//  Copyright © 2019 Mountain Viewer. All rights reserved.
//

import UIKit

class QuestionDataViewController: UIViewController {
    
    // Outlets
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionTextLabel: UILabel!
    @IBOutlet weak var totalQuestionsLabel: UILabel!
    @IBOutlet weak var questionImageView: UIImageView!
    
    @IBOutlet weak var option1Button: UIButton!
    @IBOutlet weak var option2Button: UIButton!
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var option4Button: UIButton!
    
    // Actions
    
    @IBAction func optionButtonTouchUpInside(_ sender: UIButton) {
        if !answerSelected {
            answerSelected = true
            
            guard let senderTitle = sender.titleLabel?.text,
                let correctOption = questionModel?.correctOption else {
                return
            }
            
            if senderTitle != correctOption {
                sender.backgroundColor = .red
            } else {
                sender.backgroundColor = .green
                if let result = mainViewController?.result {
                    mainViewController?.result = result + 1
                }
                
            }
            
            if let option1ButtonTitle = option1Button.titleLabel?.text, option1ButtonTitle == correctOption {
                option1Button.backgroundColor = .green
            }
            
            if let option2ButtonTitle = option2Button.titleLabel?.text, option2ButtonTitle == correctOption {
                option2Button.backgroundColor = .green
            }
            
            if let option3ButtonTitle = option3Button.titleLabel?.text, option3ButtonTitle == correctOption {
                option3Button.backgroundColor = .green
            }
            
            if let option4ButtonTitle = option4Button.titleLabel?.text, option4ButtonTitle == correctOption {
                option4Button.backgroundColor = .green
            }
            
            if isLast {
                performSegue(withIdentifier: "ResultSegue", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ResultViewController,
            let result = mainViewController?.result,
            let teamName = mainViewController?.teamName else {
            return
        }
        
        if #available(iOS 13.0, *) {
            vc.isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
        vc.topViewController = topViewController
        vc.teamName = teamName
        vc.result = result
    }
    
    // Vars
    
    var answerSelected: Bool = false
    var isLast: Bool = false
    var index: Int?
    var questionModel: QuestionModel?
    var teamName: String?
    var mainViewController: QuestionViewController?
    var topViewController: UIViewController?
    
    // Helper methods
    
    func configureButtons() {
        option1Button.layer.cornerRadius = 5.0
        option2Button.layer.cornerRadius = 5.0
        option3Button.layer.cornerRadius = 5.0
        option4Button.layer.cornerRadius = 5.0
        
        option1Button.layer.borderColor = UIColor.white.cgColor
        option2Button.layer.borderColor = UIColor.white.cgColor
        option3Button.layer.borderColor = UIColor.white.cgColor
        option4Button.layer.borderColor = UIColor.white.cgColor
        
        option1Button.layer.borderWidth = 1.0
        option2Button.layer.borderWidth = 1.0
        option3Button.layer.borderWidth = 1.0
        option4Button.layer.borderWidth = 1.0
    }
    
    func setViews() {
        self.questionLabel.text = questionModel?.question
        self.questionTextLabel.text = questionModel?.questionText
        self.totalQuestionsLabel.text = questionModel?.totalQuestions
        self.questionImageView.image = questionModel?.questionImage
        
        self.option1Button.setTitle(questionModel?.option1, for: .normal)
        self.option2Button.setTitle(questionModel?.option2, for: .normal)
        self.option3Button.setTitle(questionModel?.option3, for: .normal)
        self.option4Button.setTitle(questionModel?.option4, for: .normal)
        self.isLast = questionModel?.isLast ?? false
        self.mainViewController = questionModel?.mainViewController
        self.topViewController = questionModel?.topViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureButtons()
        setViews()
    }
}
