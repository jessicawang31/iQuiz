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
    
    enum CodingKeys: String, CodingKey {
        case text, answers, answer
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        answers = try container.decode([String].self, forKey: .answers)
        
        // Try decoding as Int first, then fallback to parsing String
        if let intAnswer = try? container.decode(Int.self, forKey: .answer) {
            answer = intAnswer
        } else {
            let strAnswer = try container.decode(String.self, forKey: .answer)
            guard let parsedInt = Int(strAnswer) else {
                throw DecodingError.dataCorruptedError(forKey: .answer, in: container, debugDescription: "Answer is not a valid integer.")
            }
            answer = parsedInt
        }
    }
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
//    let quizTopics = [
//        ("Mathematics", "How are you math skills?"),
//        ("Science", "Ready to put your knowledge to the test?"),
//        ("Marvel Super Heroes", "Are you a real Marvel fan?")
//    ]
    var quizTopics: [(String, String)] = []

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
    
    // pt4
    func fetchQuizzes(from urlString: String) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.loadLocalQuizzes() // Fallback if offline
                    self.showNetworkAlert(message: "Failed: \(error.localizedDescription)")
                    return
                }

                guard let data = data else {
                    self.loadLocalQuizzes()
                    self.showNetworkAlert(message: "No data received")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let fetchedTopics = try decoder.decode([QuizTopic].self, from: data)
                    self.quizTopics = fetchedTopics.map { ($0.title, $0.desc) }
                    self.tableView.reloadData()

                    let fileURL = self.getLocalFileURL()
                    try data.write(to: fileURL)
                    print("Saved locally")
                } catch {
                    self.loadLocalQuizzes()
                    self.showNetworkAlert(message: "Failed")
                    print("Error: \(error)")
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
            alert.addAction(UIAlertAction(title: "check Now", style: .default, handler: { _ in
                if let url = alert.textFields?.first?.text, !url.isEmpty {
                    UserDefaults.standard.set(url, forKey: "quizURL")
                    self.fetchQuizzes(from: url)
                }
            }))
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel))
            present(alert, animated: true)
        }
    
    func getLocalFileURL() -> URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("quizzes.json")
    }

    func loadLocalQuizzes() {
        let fileURL = getLocalFileURL()
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let localTopics = try decoder.decode([QuizTopic].self, from: data)
            self.quizTopics = localTopics.map { ($0.title, $0.desc) }
            self.tableView.reloadData()
            print("loaded local quizzes.")
        } catch {
            print("failed: \(error)")
        }
    }

}
