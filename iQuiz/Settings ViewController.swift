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

        // Load saved URL or set default
        let savedURL = UserDefaults.standard.string(forKey: "quizDataURL") ??
            "http://tednewardsandbox.site44.com/questions.json"
        urlTextField.text = savedURL
    }

    @IBAction func checkNowTapped(_ sender: UIButton) {
        guard let urlString = urlTextField.text, !urlString.isEmpty else {
            showAlert(title: "missing URL", message: "enter valid JSON URL.")
            return
        }

        // save default url
        UserDefaults.standard.set(urlString, forKey: "quizDataURL")

        // check network
        if !isNetworkAvailable() {
            showAlert(title: "offline", message: "no internet connection")
            return
        }

        fetchQuizData(from: urlString) { quizTopics in
            DispatchQueue.main.async {
                if let quizTopics = quizTopics {
                    self.showAlert(title: "success", message: "loaded \(quizTopics.count) topics")
                } else {
                    self.showAlert(title: "error", message: "failed to load")
                }
            }
        }
    }

    func isNetworkAvailable() -> Bool {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "NetworkMonitor")
        var isConnected = false
        let semaphore = DispatchSemaphore(value: 0)

        monitor.pathUpdateHandler = { path in
            isConnected = path.status == .satisfied
            semaphore.signal()
            monitor.cancel()
        }

        monitor.start(queue: queue)
        semaphore.wait()
        return isConnected
    }

    func fetchQuizData(from urlString: String, completion: @escaping ([QuizTopic]?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                print("Error: No data")
                completion(nil)
                return
            }

            do {
                let topics = try JSONDecoder().decode([QuizTopic].self, from: data)
                completion(topics)
            } catch {
                print("Decoding error: \(error)")
                completion(nil)
            }
        }.resume()
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    // back home
    @IBOutlet weak var backHomeButton: UIButton!
    
    @IBAction func clickSubmitButton(_ sender: Any) {
        performSegue(withIdentifier: "toHome", sender: backHomeButton)
    }
}
