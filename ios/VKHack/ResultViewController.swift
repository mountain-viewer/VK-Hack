//
//  ResultViewController.swift
//  Sports.ru
//
//  Created by Yaroslav on 9/29/19.
//  Copyright © 2019 Mountain Viewer. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var resultImageView: UIImageView!
    
    var teamName: String?
    var result: Int?
    var imageLink: String?
    var topViewController: UIViewController?
    
    var shortNames = ["ПФК Арсенал" : "arsenal",
                      "ФК Ахмат" : "akhmat",
                      "ФК Динамо Москва" : "dinamo",
                      "ФК Зенит" : "zenit",
                      "ФК Краснодар" : "krasnodar",
                      "ПФК Крылья Советов" : "ks",
                      "ФК Локомотив" : "lokomotiv",
                      "ФК Оренбург" : "orenburg",
                      "ФК Ростов" : "rostov",
                      "ФК Рубин" : "rubin",
                      "ФК Сочи" : "sochi",
                      "ФК Спартак-Москва" : "spartak",
                      "ФК Тамбов" : "tambov",
                      "ФК Урал" : "ural",
                      "ФК Уфа" : "ufa",
                      "ПФК ЦСКА" : "cska"
    ]
    
    func configureButton() {
        shareButton.layer.borderColor = UIColor.white.cgColor
        shareButton.layer.borderWidth = 1.0
        shareButton.layer.cornerRadius = 8.0
    }
    @IBAction func doneButtonTouchUpInside(_ sender: Any) {
        topViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareButtonTouchUpInside(_ sender: Any) {
        if let image = resultImageView.image {
            let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
            present(vc, animated: true)
        }
    }
    
    func performRequest() {
        guard let teamName = teamName,
            let shortName = shortNames[teamName] else {
            return
        }
        
        let session = URLSession(configuration: .default)
        var datatask : URLSessionDataTask?
        let url = "http://95.213.37.132:5000/quiz/get_stories"
        
        var items = [URLQueryItem]()
        var myURL = URLComponents(string: url)
        let params = ["team_name": "\(shortName)", "true_answers": "\(result!)"]
        
        for (key,value) in params {
            items.append(URLQueryItem(name: key, value: value))
        }
        
        myURL?.queryItems = items
        let request =  URLRequest(url: (myURL?.url)!)
        
        datatask = session.dataTask(with: request, completionHandler: {data, response, error in
            if error == nil {
                let receivedData = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String]
                
                if let arr = receivedData, let url = URL(string: arr[0]) {
                    self.imageLink = arr[0]
                    self.resultImageView.load(url: url)
                }
            }
        })
        
        datatask?.resume()
    }
    
    func setViews() {
        guard let result = result else {
            return
        }
        resultLabel.text = String(format: "%d/5", result)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureButton()
        setViews()
        performRequest()
    }
}

extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
