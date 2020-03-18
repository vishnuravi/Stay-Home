//
//  ContentView.swift
//  Stay Home ios
//
//  Created by Rahul Sompuram on 3/18/20.
//  Copyright © 2020 Stay Home. All rights reserved.
//

import SwiftUI
import FBSDKLoginKit
import Firebase

struct ContentView: View {
    @EnvironmentObject var userData: UserDataViewModel
    
    var body: some View {
        Group {
            if userData.user != nil {
                TabHomeView()
            } else {
                StartView()
            }
        }.onAppear(perform: userData.trackAuthState)
    }
}

struct Login : UIViewRepresentable {
    
    func makeCoordinator() -> Login.Coordinator {
        return Login.Coordinator()
    }
    
    func makeUIView(context: UIViewRepresentableContext<Login>) -> FBLoginButton {
        let button = FBLoginButton()
        button.delegate = context.coordinator
        button.permissions = ["email"]
        return button
    }
    
    func updateUIView(_ uiView: FBLoginButton, context: UIViewRepresentableContext<Login>) {
        
    }
    
    class Coordinator : NSObject, LoginButtonDelegate {
        func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
            if error != nil {
                print((error?.localizedDescription)!)
                return
            }
            
            if AccessToken.current != nil {
                let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            
                Auth.auth().signIn(with: credential) { (res, error) in
                    if error != nil {
                        print((error?.localizedDescription)!)
                        return
                    }
                    
                    print("Success - sign in")
                }
            }
        }
        
        func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
            try! Auth.auth().signOut()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}