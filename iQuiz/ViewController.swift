//
//  ViewController.swift
//  iQuiz
//
//  Created by Jessica Wang on 5/5/25.
//

import UIKit

// pt3
struct QuizTopic: Codable {
    let title: String
    let desc: String
    let questions: [Question]
}

struct Question: Codable {
    let text: String
    let answers: [String]
    let answer: Int
}
//

class QuizCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    
    // tuple array
    let quizTopics = [
        ("Mathematics", "How are you math skills?"),
        ("Science", "Ready to put your knowledge to the test?"),
        ("Marvel Super Heroes", "Are you a real Marvel fan?")
    ]
    
//    var selectedTopic: String = "Science"
    var selectedTopic: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        //pt3
        let savedURL = UserDefaults.standard.string(forKey: "quizURL") ?? "http://tednewardsandbox.site44.com/questions.json"
        fetchQuizzes(from: savedURL)

    }
    
    // pt3
    func fetchQuizzes(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.showNetworkAlert(message: "failed: \(error.localizedDescription)")
                    return
                }
                guard let data = data else {
                    self.showNetworkAlert(message: "no data received")
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let fetchedTopics = try decoder.decode([QuizTopic].self, from: data)
                    print("success!: \(fetchedTopics.count)")
                    // TODO: Store fetchedTopics in your quizTopics array and reload tableView
                } catch {
                    self.showNetworkAlert(message: "failed")
                    print("error: \(error)")
                }
            }
        }.resume()
    }
    
    func showNetworkAlert(message: String) {
        let alert = UIAlertController(title: "Network Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    //
    
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


//    @IBAction func toSettings(_ sender: Any) {
//        let alert = UIAlertController(
//            title: "Settings",
//            message: "Settings go here",
//            preferredStyle: .alert
//        )
//        alert.addAction(UIAlertAction(title: "OK", style: .default))
//
//        present(alert, animated: true)
//    }
    @IBAction func toSettings(_ sender: Any) {
            let alert = UIAlertController(title: "Settings", message: "Enter a URL", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "http://..."
            }
            alert.addAction(UIAlertAction(title: "Check Now", style: .default, handler: { _ in
                if let url = alert.textFields?.first?.text, !url.isEmpty {
                    UserDefaults.standard.set(url, forKey: "quizURL")
                    self.fetchQuizzes(from: url)
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alert, animated: true)
        }

}
