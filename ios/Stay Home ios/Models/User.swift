//
//  User.swift
//  Stay Home ios
//
//  Created by Rahul Sompuram on 3/18/20.
//  Copyright © 2020 Stay Home. All rights reserved.
//
import Foundation

struct User {
    var firstName: String
    var lastName: String
    var email: String
    var id: String?
    var isLoggedIn: Bool
    
    var lastRelocTimestamp: Double
    var lastTickTimestamp: Double
    var points: Int
    var streak: Int
    var unredeemedPoints: Int
    var username: String
    
    
    init(firstName: String = "",
         lastName: String = "",
         email: String = "",
         username: String = "",
         id: String? = nil,
         isLoggedIn: Bool = false) {
        
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.username = username
        self.id = id
        self.isLoggedIn = isLoggedIn
        
        self.lastRelocTimestamp = 0
        self.lastTickTimestamp = 0
        self.points = 0
        self.streak = 0
        self.unredeemedPoints = 0
    }
         
}
