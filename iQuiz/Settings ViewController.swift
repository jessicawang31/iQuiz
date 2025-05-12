//
//  Settings ViewController.swift
//  iQuiz
//
//  Created by Jessica Wang on 5/11/25.
//

import UIKit
import Network

class SettingsViewController: UIViewController {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var checkNowButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // load
        let savedURL = UserDefaults.standard.string(forKey: "quizDataURL")
            ?? "http://tednewardsandbox.site44.com/questions.json"
        urlTextField.text = savedURL
    }

    @IBAction func checkNowTapped(_ sender: UIButton) {
        guard let urlString = urlTextField.text, !urlString.isEmpty else {
            showAlert(title: "missing URL", message: "please enter valid JSON URL")
            return
        }

        UserDefaults.standard.set(urlString, forKey: "quizDataURL")
        print("Saved URL: \(urlString)")

        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            monitor.cancel()
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    print("Network available. Proceeding to fetch.")
                    self.fetchQuizData(from: urlString)
                } else {
                    self.showAlert(title: "offline", message: "no connection")
                }
            }
        }

        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    func fetchQuizData(from urlString: String) {
        print("Fetching from: \(urlString)")

        guard let url = URL(string: urlString) else {
            showAlert(title: "invalid URL", message: "check input")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(title: "download failed", message: error.localizedDescription)
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert(title: "error", message: "no data")
                }
                return
            }

            do {
                let quizTopics = try JSONDecoder().decode([QuizTopic].self, from: data)
                print("Downloaded \(quizTopics.count) topics.")
                self.saveTopicsLocally(quizTopics)

                DispatchQueue.main.async {
                    self.showAlert(title: "success", message: "loaded \(quizTopics.count) topics")
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "could not parse JSON")
                }
            }
        }.resume()
    }

    // pt4
    func saveTopicsLocally(_ topics: [QuizTopic]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(topics) {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("quizzes.json")
            try? data.write(to: url)
            print("Saved quizzes to file: \(url)")
        } else {
            print("Failed to encode topics")
        }
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @IBAction func clickSubmitButton(_ sender: Any) {
        dismiss(animated: true)
    }
}
