//
//  SetupFlowViewModel.swift
//  TractorGPS_V2
//
//  Created by QTS Coder on 15/9/25.
//
import SwiftUI

class SetupFlowViewModel: ObservableObject {
    @Published var question1: String? {
        didSet { UserDefaults.standard.set(question1, forKey: "question1") }
    }
    @Published var question2: String? {
        didSet { UserDefaults.standard.set(question2, forKey: "question2") }
    }
    @Published var question3: String? {
        didSet { UserDefaults.standard.set(question3, forKey: "question3") }
    }
    
    init() {
        self.question1 = UserDefaults.standard.string(forKey: "question1")
        self.question2 = UserDefaults.standard.string(forKey: "question2")
        self.question3 = UserDefaults.standard.string(forKey: "question3")
    }
}
