//
//  Final ViewController.swift
//  iQuiz
//
//  Created by Jessica Wang on 5/5/25.
//

import UIKit

class FinalViewController: UIViewController {
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!

    var receivedData: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        pointsLabel.text = receivedData
    }

    @IBAction func nextTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "toHome", sender: sender)
    }
}
