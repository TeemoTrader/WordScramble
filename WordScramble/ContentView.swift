//
//  ContentView.swift
//  WordScramble
//
//  Created by Teemo Norman on 7/14/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var wordsRemaining = 5
    @State var timeRemaining = 5
    @State var highScore = 0
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.white]), startPoint: .bottom, endPoint: .top).ignoresSafeArea()
                VStack {
                    Text("\(wordsRemaining) Words Remaining")
                        .font(.system(size: 40))
                    Circle()
                        .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        
                        .overlay(Text("\(timeRemaining)")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 80))
                                    .onReceive(timer) { _ in
                                        if timeRemaining > 0 {
                                            timeRemaining -= 1
                                        } else {
                                            if wordsRemaining > 0 {
                                                startGame()
                                                timeRemaining += 5
                                                wordsRemaining -= 1
                                            } else {
                                                timeRemaining += 5
                                                wordsRemaining += 5
                                                usedWords = [""]
                                                if score > highScore {
                                                    highScore = score
                                                    score = 0
                                                } else {
                                                    score = 0
                                                }
                                            }
                                            
                                        }
                                        
                                    } )
                    
                    Text(rootWord)
                        .fontWeight(.bold)
                        .font(.system(size: 60))
                    TextField("Enter your word", text: $newWord, onCommit: addNewWord)
                        .textFieldStyle(RoundedBorderTextFieldStyle()).autocapitalization(.none)
                        .padding()
                    
                    ZStack {
                    List(usedWords, id: \.self) {
                        Image(systemName: "\($0.count).circle").foregroundColor(.blue).imageScale(.large)
                        Text($0)
                            .font(.system(size: 30))
                        
                        
                        
                    }
                    }
                    Text("Score: \(score)")
                        .fontWeight(.bold)
                        .font(.system(size: 35))
                    
                    
                    
                }
                .font(.title)
                .navigationBarItems(trailing: Text("Top Score: \(highScore)"))
                .onAppear(perform: startGame)
                .alert(isPresented: $showingError) {
                    Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
            }
            
        }
    }
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {
            return
        }
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        guard  isPossible(word: answer) else {
            wordError(title: "word not recognized", message: "You can't just make words up, you know!")
            return
        }
        guard isReal(word: answer) else {
            wordError(title: "word not possible", message: "That isn't a real word")
            return
        }
        usedWords.insert(answer, at: 0)
        newWord = ""
        score += answer.count
    }
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try?
                String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement()
                    ?? "silkworm"
                return
            }
            
        }
        fatalError("Could not load start.txt from bundle.")
    }
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord.lowercased()
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
    }
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
