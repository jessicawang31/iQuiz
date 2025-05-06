//
//  Settings ViewController.swift
//  iQuiz
//
//  Created by Jessica Wang on 5/5/25.
//

import UIKit

class Settings_ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBOutlet weak var OkayButton: UIButton!
//    
    @IBAction func clickSubmitButton(_ sender: Any) {
        performSegue(withIdentifier: "toHome", sender: OkayButton)
    }

}
