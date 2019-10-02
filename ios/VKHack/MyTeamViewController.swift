//
//  MyTeamViewController.swift
//  Sports.ru
//
//  Created by Yaroslav on 9/29/19.
//  Copyright © 2019 Mountain Viewer. All rights reserved.
//

import UIKit

class MyTeamViewController: UIViewController {
    
    @IBOutlet weak var teamImageView: UIImageView!
    @IBOutlet weak var firstContainer: UIView!
    @IBOutlet weak var secondContainer: UIView!
    
    @IBOutlet weak var firstString: UILabel!
    @IBOutlet weak var secondString: UILabel!
    @IBOutlet weak var thirdString: UILabel!
    @IBOutlet weak var fourthString: UILabel!
    
    @IBAction func firstShareButtonTouchUpInside(_ sender: Any) {
        guard let text1 = firstString.text, let text2 = secondString.text else {
            return
        }
        
        let vc = UIActivityViewController(activityItems: [text1 + " " + text2], applicationActivities: [])
        present(vc, animated: true)
    }
    @IBAction func secondShareButtonTouchUpInside(_ sender: Any) {
        guard let text1 = thirdString.text, let text2 = fourthString.text else {
            return
        }
        
        let vc = UIActivityViewController(activityItems: [text1 + " " + text2], applicationActivities: [])
        present(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstContainer.layer.cornerRadius = 15.0
        secondContainer.layer.cornerRadius = 15.0
        
        let img = UIImage(named: "sportsru")
        let imgView = UIImageView(frame: CGRect(x:0, y:0, width:30, height:30))
        imgView.image = img
        imgView.contentMode = .scaleAspectFit
        // setContent mode aspect fit
        self.navigationItem.titleView = imgView;
        
        guard let fs = UserDefaults.standard.object(forKey: "string1") as? String else {
            return
        }
        
        firstString.text = UserDefaults.standard.object(forKey: "string1") as! String
        secondString.text = UserDefaults.standard.object(forKey: "string2") as! String
        thirdString.text = UserDefaults.standard.object(forKey: "string3") as! String
        fourthString.text = UserDefaults.standard.object(forKey: "string4") as! String
        
//        let linkString2 = UserDefaults.standard.object(forKey: "link")
//        let url2 = URL(string: linkString2 as! String)
        guard let linkString = UserDefaults.standard.object(forKey: "link") as? String,
            let url = URL(string: linkString) else {
            return
        }
        
        teamImageView.load(url: url)
    }
}

