//
//  Quiz ViewController.swift
//  iQuiz
//
//  Created by Jessica Wang on 5/5/25.
//

import UIKit

class QuizViewController: UIViewController {

    @IBOutlet weak var questionTextView: UITextView!
    @IBOutlet weak var option1Button: UIButton!
    @IBOutlet weak var option2Button: UIButton!
    @IBOutlet weak var option3Button: UIButton!
    @IBOutlet weak var option4Button: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var promptLabel: UILabel!

    var topicTitle: String?
    var currentQuestionIndex = 0
    var selectedOption = 0
    var correctAnswer = 0
    var points = 0
    var totalQuestions = 0

    var questions: [(String, [String], Int)] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // counters
        currentQuestionIndex = 0
        selectedOption = 0
        correctAnswer = 0
        points = 0

        totalQuestions = questions.count
        loadQuestion()
    }

    func loadQuestion() {
        resetUI()
        guard currentQuestionIndex < questions.count else { return }

        let (question, options, correct) = questions[currentQuestionIndex]
        questionTextView.text = question
        correctAnswer = correct
        selectedOption = 0

        option1Button.setTitle(options[0], for: .normal)
        option2Button.setTitle(options[1], for: .normal)
        option3Button.setTitle(options[2], for: .normal)
        option4Button.setTitle(options[3], for: .normal)
        updatePointsLabel()
    }

    func resetUI() {
        feedbackLabel.isHidden = true
        promptLabel.isHidden = true
        nextButton.isHidden = true
        backButton.isHidden = true
        submitButton.isHidden = false
        setAllOptionsToGray()
    }

    func updatePointsLabel() {
        pointsLabel.text = "Points: \(points) / \(totalQuestions)"
    }

    func setAllOptionsToGray() {
        [option1Button, option2Button, option3Button, option4Button].forEach {
            $0?.backgroundColor = .systemGray5
        }
    }

    func highlightOption(_ option: Int) {
        setAllOptionsToGray()
        buttonForOption(option).backgroundColor = .blue
    }

    func buttonForOption(_ index: Int) -> UIButton {
        switch index {
        case 1: return option1Button
        case 2: return option2Button
        case 3: return option3Button
        case 4: return option4Button
        default: return UIButton()
        }
    }

    func showFeedback() {
        let correct = selectedOption == correctAnswer
        feedbackLabel.text = correct ? "Correct" : "Incorrect"
        feedbackLabel.isHidden = false
        buttonForOption(correctAnswer).backgroundColor = .green
        if !correct {
            buttonForOption(selectedOption).backgroundColor = .red
        }
        if correct { points += 1 }
        updatePointsLabel()
    }

    func toggleAnswerMode(_ active: Bool) {
        submitButton.isHidden = active
        nextButton.isHidden = !active
        backButton.isHidden = !active
    }

    @IBAction func selectOption1(_ sender: UIButton) {
        selectedOption = 1
        highlightOption(selectedOption)
        promptLabel.isHidden = true
    }

    @IBAction func selectOption2(_ sender: UIButton) {
        selectedOption = 2
        highlightOption(selectedOption)
        promptLabel.isHidden = true
    }

    @IBAction func selectOption3(_ sender: UIButton) {
        selectedOption = 3
        highlightOption(selectedOption)
        promptLabel.isHidden = true
    }

    @IBAction func selectOption4(_ sender: UIButton) {
        selectedOption = 4
        highlightOption(selectedOption)
        promptLabel.isHidden = true
    }

    @IBAction func submitTapped(_ sender: UIButton) {
        guard selectedOption > 0 else {
            promptLabel.isHidden = false
            return
        }
        showFeedback()
        toggleAnswerMode(true)
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        currentQuestionIndex += 1
        if currentQuestionIndex < questions.count {
            loadQuestion()
        } else {
            performSegue(withIdentifier: "showFinal", sender: self)
        }
    }

    @IBAction func backTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toHome", sender: self)
    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "showFinal", currentQuestionIndex < questions.count {
            loadQuestion()
            return false
        }
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFinal",
           let finalVC = segue.destination as? FinalViewController {
            let summary: String
            if points == totalQuestions {
                summary = "Points: \(points) / \(totalQuestions) Perfect!"
            } else if points == 0 {
                summary = "Points: \(points) / \(totalQuestions) Try again"
            } else {
                summary = "Points: \(points) / \(totalQuestions) Almost!"
            }
            finalVC.receivedData = summary
        }
    }
}
