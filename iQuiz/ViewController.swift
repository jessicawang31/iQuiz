//
//  ViewController.swift
//  iQuiz
//
//  Created by Jessica  Wang on 5/5/25.
//

import UIKit

// Custom cell class
class QuizCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
}

// Data model
struct QuizTopic {
    let iconName: String
    let title: String
    let description: String
}

// Main view controller
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    // In-memory quiz topics
    let quizTopics: [QuizTopic] = [
        QuizTopic(iconName: "Math", title: "Mathematics", description: "Did you pass the third grade?"),
        QuizTopic(iconName: "Marvel", title: "Marvel Super Heroes", description: "Avengers, Assemble!"),
        QuizTopic(iconName: "Science", title: "Science!", description: "Because SCIENCE!")
    ]
    
    var selectedTopic: String = "Marvel Super Heroes"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizTopics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCell", for: indexPath) as! QuizCell
        let topic = quizTopics[indexPath.row]
        
        cell.titleLabel.text = topic.title
        cell.descriptionLabel.text = topic.description
        cell.iconImageView.image = UIImage(named: topic.iconName)
        
        return cell
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTopic = quizTopics[indexPath.row].title
        performSegue(withIdentifier: "setQuestion", sender: self)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "setQuestion",
//           let destinationVC = segue.destination as? Quiz_ViewController {
//            destinationVC.receivedData = selectedTopic
//        }
//    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }

    @IBAction func toSettings(_ sender: Any) {
        performSegue(withIdentifier: "toSettings", sender: sender)
    }
}
