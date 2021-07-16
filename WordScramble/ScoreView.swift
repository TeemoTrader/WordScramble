//
//  ScoreView.swift
//  WordScramble
//
//  Created by Teemo Norman on 7/16/21.
//

import SwiftUI

struct ScoreView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        Text("Your high score is \(ContentView().highScore)")
        Text("HIGH SCORE: \(ContentView().highScore.self)")
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView()
    }
}
