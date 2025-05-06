//
//  ViewController.swift
//  iQuiz
//
//  Created by Jessica Wang on 5/5/25.
//

import UIKit

class QuizCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    // Use a simple tuple array just like the working code
    let quizTopics = [
        ("Mathematics", "How are you math skills?"),
        ("Science", "Ready to put your knowledge to the test?"),
        ("Marvel Super Heroes", "Are you a real Marvel fan?")
    ]
    
    var selectedTopic: String = "Marvel Super Heroes"
//    var selectedTopic: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizTopics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCell", for: indexPath) as! QuizCell
        let topic = quizTopics[indexPath.row]
        
        cell.titleLabel.text = topic.0
        cell.descriptionLabel.text = topic.1
        
        let imgName: String
        switch topic.0 {
        case "Mathematics":
            imgName = "Math"
        case "Science":
            imgName = "Science"
        case "Marvel Super Heroes":
            imgName = "Marvel"
        default:
            imgName = ""
        }
        cell.iconImageView.image = UIImage(named: imgName)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTopic = quizTopics[indexPath.row].0
        performSegue(withIdentifier: "setQuestion", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setQuestion",
           let destinationVC = segue.destination as? QuizViewController {
            destinationVC.topicTitle = selectedTopic
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }

    @IBAction func toSettings(_ sender: Any) {
        performSegue(withIdentifier: "toSettings", sender: sender)
    }
}
