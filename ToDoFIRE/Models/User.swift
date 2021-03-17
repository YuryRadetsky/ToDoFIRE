//
//  User.swift
//  ToDoFIRE
//
//  Created by Yury Radetsky on 16.03.2021.
//

import Foundation
import Firebase

struct User {
    
    let uid: String
    let email: String
    
    init(user: Firebase.User) {
        self.uid = user.uid
        self.email = user.email!
    }
}
