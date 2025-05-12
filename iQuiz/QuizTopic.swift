//
//  Settings ViewController.swift
//  iQuiz
//
//  Created by Jessica Wang on 5/11/25.
//

import Foundation

struct QuizTopic: Codable {
    let title: String
    let desc: String
    let questions: [QuizQuestion]
}

struct QuizQuestion: Codable {
    let text: String
    let answer: String
    let answers: [String]
}
