//
//  UserDataViewModel.swift
//  Stay Home ios
//
//  Created by Rahul Sompuram on 3/18/20.
//  Copyright © 2020 Stay Home. All rights reserved.
//

import Combine
import Firebase
import FBSDKLoginKit
import MapKit

final class UserDataViewModel: ObservableObject {
    
    @Published var user: User?
    @Published var isNewUser: Bool?
    @Published var errorMessage = ""
    
    
    func reset(){
        self.user = User()
    }
    
    func trackAuthState() {
        _ = Auth.auth().addStateDidChangeListener({ (auth, user) in
            if let user = user {
                
                var ref: DatabaseReference!
                let userID = Auth.auth().currentUser!.uid
                ref = Database.database().reference().child("Users").child(userID)
                
                ref.observeSingleEvent(of: .value) { (snapshot) in
                    if(!snapshot.exists()) {
                        print("New user!")
                        self.isNewUser = true
                        ref.child("Points").setValue(0)
                        ref.child("HomeLat").setValue(0)
                        ref.child("HomeLong").setValue(0)
                        ref.child("Country").setValue("Unknown")
                        ref.child("LastRelocTimestamp").setValue(0)
                        ref.child("LastTickTimestamp").setValue(0)
                        ref.child("Streak").setValue(0)
                        ref.child("UnredeemedPoints").setValue(0)
                    } else {
                        print("Existing user!")
                        ref.observe(.value) { (snapshot) in
                            if let lastRelocTimestamp = snapshot.childSnapshot(forPath: "lastRelocTimestamp").value as? Double {
                                self.user?.lastRelocTimestamp = lastRelocTimestamp
                            }
                            if let lastTickTimestamp = snapshot.childSnapshot(forPath: "lastTickTimestamp").value as? Double {
                                self.user?.lastTickTimestamp = lastTickTimestamp
                            }
                            if let points = snapshot.childSnapshot(forPath: "Points").value as? Int {
                                self.user?.points = points
                            }
                            if let streak = snapshot.childSnapshot(forPath: "Streak").value as? Int {
                                self.user?.streak = streak
                            }
                            if let unredeemedPoints = snapshot.childSnapshot(forPath: "unredeemedPoints").value as? Int {
                                self.user?.unredeemedPoints = unredeemedPoints
                            }
                            if let username = snapshot.childSnapshot(forPath: "Username").value as? String {
                                self.user?.username = username
                            }
                        }
                        
                        
                        self.isNewUser = false
                    }
                }
                
                self.user = User(email: user.email!)
                
            } else {
                self.user = nil
            }
            
        })
    }
    
    func signIn() {
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
}
