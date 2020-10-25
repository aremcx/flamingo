//
//  ContentView.swift
//  flamingo
//
//  Created by Răzvan-Gabriel Geangu on 20/10/2020.
//

import SwiftUI

struct ContentView: View {
    /// This is the total balance that will be displayed in the AR Experience
    /// TODO: Get some real balance from somewhere
    @State var totalBalance: Float = 10832.55
    
    /// Card number will be recognised and set through the CardIO API.
    /// This will be shown on screen and will be used for identification.
    @State var cardNumber: String! = nil
    
    /// This enables the AR experience once the user has been successfuly identified by the **TypingDNA** API.
    @State var isAuthenticated: Bool = false
    
    /// This displays the authentication error if **TypingDNA** API is not successfull.
    @State var hasAuthError: Bool = false
    
    var body: some View {
        ZStack(content: {
            // MARK: AR Experience & Card recognition
            ARViewContainer(totalBalance: $totalBalance)
                .onCardInfoReceived(perform: { (cardNumber) in
                    let index = cardNumber.index(cardNumber.endIndex, offsetBy: -8)
                    self.cardNumber = String(cardNumber[index...])
                })
                .overlay(shouldDisplayExperience ? BlurView() : nil)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    hideKeyboard()
                }

            // MARK: - Identification
            if shouldDisplayExperience {
                VStack {
                    Text(kInsertCardLabel)
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0))
                        .multilineTextAlignment(.center)
                    Text(cardNumber.creditCardFormat)
                        .foregroundColor(.white)
                        .fontWeight(.heavy)
                        .font(Font.system(.title2))
                        .multilineTextAlignment(.center)
                    TypingDNATextField()
                        .frame(width: UIScreen.main.bounds.width * 0.8, height: 60, alignment: .center)
                    Button(kAuthenticateLabel) {
                        hideKeyboard()
                        verifyTypingPattern()
                    }
                    .alert(isPresented: $hasAuthError) {
                        Alert(title: Text(kAuthenticationError), message: Text(kTryAgainLabel), dismissButton: .default(Text(kOk), action: {
                            self.hasAuthError = false
                        }))
                    }
                    .padding(EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12))
                    .background(Color.white)
                    .cornerRadius(30)
                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))
                }
            }
        })
    }
    
    /// If the card number is defined and the user has been successfully authenticated the function will return `true`.
    var shouldDisplayExperience: Bool {
        get {
            return self.cardNumber != nil && !self.isAuthenticated
        }
    }
    
    /// Save typing pattern using **TypingDNA** API.
    /// TODO: Generate unique userId (i.e. maybe use the device unique identifier)
    func saveTypingPattern() {
        let typingPattern = TypingDNARecorderMobile.getTypingPattern(1, 0, self.cardNumber, 0)
        TypingDNAAPI.shared.save(typingPattern: typingPattern, id: "razzzy6g")
    }
    
    /// Identify pattern using **TypingDNA** API.
    ///
    /// Test users:
    ///     - ionut52
    ///     - razzzy6g
    func verifyTypingPattern() {
        let typingPattern = TypingDNARecorderMobile.getTypingPattern(1, 0, self.cardNumber, 0)
        TypingDNAAPI.shared.verify(typingPattern: typingPattern, id: "razzzy6g") { (response) in
            if response.result == 1 {
                self.isAuthenticated = true
            } else {
                self.isAuthenticated = false
                self.hasAuthError = true
            }
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
