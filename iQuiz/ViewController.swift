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

    var quizTopics: [QuizTopic] = []

    var selectedTopic: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }

    // pt4
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let savedTopics = loadSavedTopics() {
            quizTopics = savedTopics
        } else {
            quizTopics = [
                QuizTopic(title: "Mathematics", desc: "How are your math skills?", questions: []),
                QuizTopic(title: "Science", desc: "Ready to put your knowledge to the test?", questions: []),
                QuizTopic(title: "Marvel Super Heroes", desc: "Are you a real Marvel fan?", questions: [])
            ]
        }

        tableView.reloadData()
    }

    func loadSavedTopics() -> [QuizTopic]? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("quizzes.json")
        if let data = try? Data(contentsOf: url) {
            return try? JSONDecoder().decode([QuizTopic].self, from: data)
        }
        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return quizTopics.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QuizCell", for: indexPath) as! QuizCell
        let topic = quizTopics[indexPath.row]

        cell.titleLabel.text = topic.title
        cell.descriptionLabel.text = topic.desc

        let imgName: String
        switch topic.title {
        case "Mathematics": imgName = "Math"
        case "Science!": imgName = "Science"
        case "Marvel Super Heroes": imgName = "Marvel"
        default: imgName = ""
        }

        cell.iconImageView.image = UIImage(named: imgName)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTopic = quizTopics[indexPath.row].title
        performSegue(withIdentifier: "setQuestion", sender: tableView.cellForRow(at: indexPath))
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setQuestion",
           let destinationVC = segue.destination as? QuizViewController,
           let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {

            let selected = quizTopics[indexPath.row]
            selectedTopic = selected.title
            print("Passing topic: \(selectedTopic ?? "nil")")
            destinationVC.topicTitle = selected.title
            destinationVC.questions = selected.questions.map {
                ($0.text, $0.answers, Int($0.answer) ?? 0)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }

    @IBAction func toSettings(_ sender: Any) {
        // If using segue now, this could be removed
        let alert = UIAlertController(
            title: "Settings",
            message: "Settings go here",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
